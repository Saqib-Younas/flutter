import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:e_commerce_flutter/src/model/product.dart';

/// API layer for everything product-related. Read endpoints respect Supabase
/// RLS, so customer code only sees `is_active` rows; admin code with the
/// `admin` role sees everything.
class ProductService {
  ProductService._();

  static final _supabase = Supabase.instance.client;
  static const _table = 'products';

  // ---- Reads (customer side) -----------------------------------------------

  /// Active products only. Used on the customer home / list screens.
  static Future<List<Product>> fetchActive() async {
    final response = await _supabase
        .from(_table)
        .select()
        .eq('is_active', true)
        .order('created_at', ascending: false);
    return _parse(response);
  }

  /// Featured + active products for the home highlight.
  static Future<List<Product>> fetchFeatured({int limit = 6}) async {
    final response = await _supabase
        .from(_table)
        .select()
        .eq('is_active', true)
        .eq('is_featured', true)
        .order('created_at', ascending: false)
        .limit(limit);
    return _parse(response);
  }

  /// Global search across name, description, category, about. Case-insensitive.
  static Future<List<Product>> search(String query) async {
    if (query.trim().isEmpty) return fetchActive();
    final term = '%${query.trim()}%';
    final response = await _supabase
        .from(_table)
        .select()
        .eq('is_active', true)
        .or(
          'name.ilike.$term,'
          'description.ilike.$term,'
          'about.ilike.$term,'
          'category.ilike.$term',
        )
        .order('created_at', ascending: false);
    return _parse(response);
  }

  // ---- Reads (admin side) --------------------------------------------------

  /// All products (active and inactive). Requires admin role due to RLS.
  static Future<List<Product>> fetchAllForAdmin({String? search}) async {
    final base = _supabase.from(_table).select();
    final query = search != null && search.trim().isNotEmpty
        ? base.or(
            'name.ilike.%$search%,'
            'description.ilike.%$search%,'
            'about.ilike.%$search%,'
            'category.ilike.%$search%',
          )
        : base;
    final response = await query.order('created_at', ascending: false);
    return _parse(response);
  }

  // ---- Writes (admin) ------------------------------------------------------

  static Future<Product> create(Product product) async {
    final response = await _supabase
        .from(_table)
        .insert(product.toJson())
        .select()
        .single();
    return Product.fromJson(response);
  }

  static Future<Product> update(Product product) async {
    if (product.id.isEmpty) {
      throw ArgumentError('Cannot update product without an id');
    }
    final response = await _supabase
        .from(_table)
        .update(product.toJson())
        .eq('id', product.id)
        .select()
        .single();
    return Product.fromJson(response);
  }

  static Future<void> delete(String id) async {
    await _supabase.from(_table).delete().eq('id', id);
  }

  static Future<void> setActive(String id, bool isActive) async {
    await _supabase.from(_table).update({'is_active': isActive}).eq('id', id);
  }

  static Future<void> setFeatured(String id, bool isFeatured) async {
    await _supabase
        .from(_table)
        .update({'is_featured': isFeatured})
        .eq('id', id);
  }

  static Future<void> adjustStock(String id, int delta) async {
    final current = await _supabase
        .from(_table)
        .select('stock_quantity')
        .eq('id', id)
        .single();
    final next =
        ((current['stock_quantity'] as num?)?.toInt() ?? 0) + delta;
    await _supabase
        .from(_table)
        .update({'stock_quantity': next < 0 ? 0 : next})
        .eq('id', id);
  }

  // ---- Real-time -----------------------------------------------------------

  /// Live stream of all active products. Uses Supabase Realtime; subscribers
  /// are automatically notified on insert/update/delete.
  static Stream<List<Product>> activeStream() {
    return _supabase
        .from(_table)
        .stream(primaryKey: ['id'])
        .order('created_at')
        .map((rows) => rows
            .where((r) => r['is_active'] == true)
            .map(Product.fromJson)
            .toList());
  }

  static Stream<List<Product>> adminStream() {
    return _supabase
        .from(_table)
        .stream(primaryKey: ['id'])
        .order('created_at')
        .map((rows) => rows.map(Product.fromJson).toList());
  }

  // ---- Internal ------------------------------------------------------------
  static List<Product> _parse(dynamic rows) =>
      (rows as List).map((e) => Product.fromJson(e)).toList();
}
