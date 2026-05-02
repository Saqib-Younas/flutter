-- ✅ CREATE PAYMENTS TABLE IN SUPABASE
-- Run this in your Supabase SQL Editor

CREATE TABLE IF NOT EXISTS payments (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  
  -- 👤 Customer Info
  name TEXT NOT NULL,
  phone TEXT NOT NULL,
  shipping_address TEXT NOT NULL,
  
  -- 💰 Payment Info
  amount DECIMAL(10,2) NOT NULL,
  payment_method TEXT NOT NULL CHECK (payment_method IN ('card', 'cod')),
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'completed', 'failed')),
  
  -- 💳 Card Info (OPTIONAL - only for card payments)
  cardholder_name TEXT,
  card_number TEXT,
  expiry_month TEXT,
  expiry_year TEXT,
  cvv TEXT,
  
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ✅ CREATE INDEX FOR FASTER QUERIES
CREATE INDEX IF NOT EXISTS idx_payments_user_id ON payments(user_id);
CREATE INDEX IF NOT EXISTS idx_payments_created_at ON payments(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_payments_status ON payments(status);

-- ✅ ENABLE ROW LEVEL SECURITY (RLS)
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;

-- ✅ ALLOW USERS TO VIEW ONLY THEIR OWN PAYMENTS
CREATE POLICY "Users can view their own payments" ON payments
  FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own payments" ON payments
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own payments" ON payments
  FOR UPDATE
  USING (auth.uid() = user_id);

-- ✅ TRIGGER TO AUTO-UPDATE updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_payments_updated_at
BEFORE UPDATE ON payments
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- ✅ VIEW ALL PAYMENTS (for admin purposes)
-- This query shows all payments with user info
-- SELECT 
--   p.id,
--   p.user_id,
--   p.name,
--   p.phone,
--   p.shipping_address,
--   p.amount,
--   p.payment_method,
--   p.status,
--   p.created_at
-- FROM payments p
-- ORDER BY p.created_at DESC;
