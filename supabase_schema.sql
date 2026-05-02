-- =============================================================================
-- LuxeCart — Supabase schema (idempotent)
-- =============================================================================
-- Run top-to-bottom in the Supabase SQL editor. Safe to re-run.
--
-- Tables: users, products, orders, order_items, payments
-- Row-level security is enabled on every table.
-- Roles: 'user' (default), 'admin'.
-- =============================================================================

-- ----- Extensions ------------------------------------------------------------
create extension if not exists pgcrypto;            -- gen_random_uuid()

-- ----- USERS (extends auth.users) -------------------------------------------
create table if not exists public.users (
  id          uuid primary key references auth.users(id) on delete cascade,
  name        text not null default '',
  email       text not null unique,
  role        text not null default 'user' check (role in ('user','admin')),
  phone       text,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

-- ----- PRODUCTS --------------------------------------------------------------
create table if not exists public.products (
  id              uuid primary key default gen_random_uuid(),
  name            text not null,
  description     text,
  about           text,
  category        text,
  price           numeric(10,2) not null check (price >= 0),
  -- discount: 'none' | 'percentage' (0-100) | 'fixed' (currency amount)
  discount_type   text not null default 'none'
                    check (discount_type in ('none','percentage','fixed')),
  discount_value  numeric(10,2) not null default 0 check (discount_value >= 0),
  stock_quantity  integer not null default 0 check (stock_quantity >= 0),
  image_url       text,
  is_active       boolean not null default true,    -- frontend visibility
  is_featured     boolean not null default false,   -- show on home
  created_by      uuid references public.users(id) on delete set null,
  created_at      timestamptz not null default now(),
  updated_at      timestamptz not null default now()
);

create index if not exists idx_products_active   on public.products(is_active);
create index if not exists idx_products_featured on public.products(is_featured);
create index if not exists idx_products_category on public.products(category);
create index if not exists idx_products_name_trgm
  on public.products using gin (name gin_trgm_ops);
-- enable trigram for fuzzy search; safe to skip if unavailable
do $$ begin
  create extension if not exists pg_trgm;
exception when others then null;
end $$;

-- Computed view: effective price after discount
create or replace view public.products_with_effective_price as
select
  p.*,
  case
    when p.discount_type = 'percentage'
      then greatest(p.price - (p.price * p.discount_value / 100.0), 0)
    when p.discount_type = 'fixed'
      then greatest(p.price - p.discount_value, 0)
    else p.price
  end as effective_price
from public.products p;

-- ----- ORDERS ----------------------------------------------------------------
create table if not exists public.orders (
  id               uuid primary key default gen_random_uuid(),
  user_id          uuid not null references public.users(id) on delete restrict,
  recipient_name   text not null,
  phone            text not null,
  shipping_address text not null,
  total_amount     numeric(10,2) not null check (total_amount >= 0),
  status           text not null default 'pending'
                     check (status in ('pending','paid','cod','completed','cancelled')),
  notes            text,
  created_at       timestamptz not null default now(),
  updated_at       timestamptz not null default now()
);

create index if not exists idx_orders_user   on public.orders(user_id);
create index if not exists idx_orders_status on public.orders(status);

-- ----- ORDER ITEMS -----------------------------------------------------------
create table if not exists public.order_items (
  id               uuid primary key default gen_random_uuid(),
  order_id         uuid not null references public.orders(id) on delete cascade,
  product_id       uuid not null references public.products(id) on delete restrict,
  product_name     text not null,                -- snapshot at order time
  unit_price       numeric(10,2) not null,       -- snapshot of effective price
  quantity         integer not null check (quantity > 0),
  discount_applied numeric(10,2) not null default 0,
  subtotal         numeric(10,2) not null check (subtotal >= 0),
  created_at       timestamptz not null default now()
);

create index if not exists idx_order_items_order   on public.order_items(order_id);
create index if not exists idx_order_items_product on public.order_items(product_id);

-- ----- PAYMENTS --------------------------------------------------------------
create table if not exists public.payments (
  id               uuid primary key default gen_random_uuid(),
  order_id         uuid not null references public.orders(id) on delete cascade,
  user_id          uuid not null references public.users(id) on delete restrict,
  amount           numeric(10,2) not null check (amount >= 0),
  payment_method   text not null check (payment_method in ('card','cod','online')),
  status           text not null default 'pending'
                     check (status in ('pending','paid','failed','cod','completed')),
  transaction_ref  text,
  cardholder_name  text,
  card_last4       text,
  expiry_month     text,
  expiry_year      text,
  created_at       timestamptz not null default now(),
  updated_at       timestamptz not null default now()
);

create index if not exists idx_payments_order  on public.payments(order_id);
create index if not exists idx_payments_user   on public.payments(user_id);
create index if not exists idx_payments_status on public.payments(status);

-- =============================================================================
-- TRIGGERS
-- =============================================================================

-- Generic updated_at touch
create or replace function public.set_updated_at() returns trigger
language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end $$;

drop trigger if exists trg_users_updated    on public.users;
drop trigger if exists trg_products_updated on public.products;
drop trigger if exists trg_orders_updated   on public.orders;
drop trigger if exists trg_payments_updated on public.payments;

create trigger trg_users_updated    before update on public.users    for each row execute function public.set_updated_at();
create trigger trg_products_updated before update on public.products for each row execute function public.set_updated_at();
create trigger trg_orders_updated   before update on public.orders   for each row execute function public.set_updated_at();
create trigger trg_payments_updated before update on public.payments for each row execute function public.set_updated_at();

-- Decrement product stock when an order item is inserted.
create or replace function public.decrement_stock_on_order_item() returns trigger
language plpgsql as $$
begin
  update public.products
     set stock_quantity = greatest(stock_quantity - new.quantity, 0)
   where id = new.product_id;
  return new;
end $$;

drop trigger if exists trg_decrement_stock on public.order_items;
create trigger trg_decrement_stock
  after insert on public.order_items
  for each row execute function public.decrement_stock_on_order_item();

-- Auto-create row in public.users when a new auth.users is created.
create or replace function public.handle_new_auth_user() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  insert into public.users (id, email, name, role)
  values (
    new.id,
    coalesce(new.email, ''),
    coalesce(new.raw_user_meta_data->>'name', ''),
    coalesce(new.raw_user_meta_data->>'role', 'user')
  )
  on conflict (id) do nothing;
  return new;
end $$;

drop trigger if exists trg_on_auth_user_created on auth.users;
create trigger trg_on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_auth_user();

-- =============================================================================
-- RLS
-- =============================================================================
alter table public.users       enable row level security;
alter table public.products    enable row level security;
alter table public.orders      enable row level security;
alter table public.order_items enable row level security;
alter table public.payments    enable row level security;

-- helper: is the current request from an admin?
create or replace function public.is_admin() returns boolean
language sql stable security definer set search_path = public as $$
  select coalesce((select role = 'admin' from public.users where id = auth.uid()), false);
$$;

-- ----- USERS policies --------------------------------------------------------
drop policy if exists users_self_select on public.users;
drop policy if exists users_self_insert on public.users;
drop policy if exists users_self_update on public.users;
drop policy if exists users_admin_all   on public.users;

create policy users_self_select on public.users
  for select using (auth.uid() = id or public.is_admin());

create policy users_self_insert on public.users
  for insert with check (auth.uid() = id);

create policy users_self_update on public.users
  for update using (auth.uid() = id) with check (auth.uid() = id);

create policy users_admin_all on public.users
  for all using (public.is_admin()) with check (public.is_admin());

-- ----- PRODUCTS policies -----------------------------------------------------
drop policy if exists products_public_read on public.products;
drop policy if exists products_admin_write on public.products;

-- everyone can read active products; admins read everything
create policy products_public_read on public.products
  for select using (is_active or public.is_admin());

-- only admins can insert/update/delete
create policy products_admin_write on public.products
  for all using (public.is_admin()) with check (public.is_admin());

-- ----- ORDERS policies -------------------------------------------------------
drop policy if exists orders_owner_select on public.orders;
drop policy if exists orders_owner_insert on public.orders;
drop policy if exists orders_admin_update on public.orders;

create policy orders_owner_select on public.orders
  for select using (auth.uid() = user_id or public.is_admin());

create policy orders_owner_insert on public.orders
  for insert with check (auth.uid() = user_id);

-- only admins can change order status
create policy orders_admin_update on public.orders
  for update using (public.is_admin()) with check (public.is_admin());

-- ----- ORDER ITEMS policies --------------------------------------------------
drop policy if exists order_items_select on public.order_items;
drop policy if exists order_items_insert on public.order_items;

create policy order_items_select on public.order_items
  for select using (
    exists (
      select 1 from public.orders o
       where o.id = order_id
         and (o.user_id = auth.uid() or public.is_admin())
    )
  );

create policy order_items_insert on public.order_items
  for insert with check (
    exists (
      select 1 from public.orders o
       where o.id = order_id
         and o.user_id = auth.uid()
    )
  );

-- ----- PAYMENTS policies -----------------------------------------------------
drop policy if exists payments_owner_select on public.payments;
drop policy if exists payments_owner_insert on public.payments;
drop policy if exists payments_admin_update on public.payments;

create policy payments_owner_select on public.payments
  for select using (auth.uid() = user_id or public.is_admin());

create policy payments_owner_insert on public.payments
  for insert with check (auth.uid() = user_id);

create policy payments_admin_update on public.payments
  for update using (public.is_admin()) with check (public.is_admin());

-- =============================================================================
-- BACK-FILL HELPERS
-- =============================================================================
-- Seed: promote the first registered user to admin (run manually as needed):
--   update public.users set role = 'admin' where email = 'you@example.com';

-- Migrate legacy payments table created by SETUP_PAYMENTS_TABLE.sql:
-- (no-op if columns already match new schema)
do $$ begin
  alter table public.payments add column if not exists order_id uuid;
exception when others then null;
end $$;
