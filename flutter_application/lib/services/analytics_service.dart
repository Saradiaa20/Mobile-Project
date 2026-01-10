import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/analytics_model.dart';

class AnalyticsService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // 1. Get System Counts (for Admin Dashboard Cards)
  Future<Map<String, int>> getSystemStats() async {
    try {
      // Run these counts in parallel for performance
      final responses = await Future.wait([
        _supabase.from('profiles').count(), // Total Users
        _supabase.from('brandowner').count(), // Total Brands
        _supabase.from('products').count(), // Total Products
        _supabase.from('reviews').count(), // Total Reviews
      ]);

      return {
        'total_users': responses[0],
        'total_brands': responses[1],
        'total_products': responses[2],
        'total_reviews': responses[3],
      };
    } catch (e) {
      // Fallback if 'count' is not enabled or fails
      print('Analytics Error: $e');
      return {
        'total_users': 0,
        'total_brands': 0,
        'total_products': 0,
        'total_reviews': 0,
      };
    }
  }

  // 2. Get Recent Activity (e.g., Last 5 users joined)
  Future<List<Map<String, dynamic>>> getRecentUsers() async {
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .order('created_at', ascending: false) // Newest first
          .limit(5);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching recent users: $e');
      return [];
    }
  }

  Future<SalesAnalytics> getBrandAnalytics(String brandId, {int days = 30}) async {
    final startDate = DateTime.now().subtract(Duration(days: days));

    // Get orders for this brand
    final orders = await _supabase
        .from('orders')
        .select('*, order_items(*)')
        .eq('brand_id', brandId)
        .gte('created_at', startDate.toIso8601String());

    // Calculate metrics
    double totalRevenue = 0;
    int totalOrders = orders.length;
    int productsSold = 0;

    for (var order in orders) {
      totalRevenue += order['total'] as double;
      final items = order['order_items'] as List;
      for (var item in items) {
        productsSold += item['quantity'] as int;
      }
    }

    double avgOrderValue = totalOrders > 0 ? totalRevenue / totalOrders : 0;

    // Get top products
    final topProducts = await _getTopProducts(brandId, days);

    // Get recent orders
    final recentOrders = await _getRecentOrders(brandId);

    return SalesAnalytics(
      totalRevenue: totalRevenue,
      totalOrders: totalOrders,
      averageOrderValue: avgOrderValue,
      productsSold: productsSold,
      topProducts: topProducts,
      recentOrders: recentOrders,
    );
  }

  Future<List<TopProduct>> _getTopProducts(String brandId, int days) async {
    // Query to get top selling products
    final response = await _supabase.rpc('get_top_products', params: {
      'brand_uuid': brandId,
      'days_ago': days,
      'limit_count': 5,
    });

    return (response as List)
        .map((e) => TopProduct(
              productId: e['product_id'],
              name: e['product_name'],
              quantitySold: e['quantity_sold'],
              revenue: e['total_revenue'].toDouble(),
              imagePath: e['image_path'],
            ))
        .toList();
  }

  Future<List<RecentOrder>> _getRecentOrders(String brandId) async {
    final orders = await _supabase
        .from('orders')
        .select('id, created_at, total, status, order_items(count)')
        .eq('brand_id', brandId)
        .order('created_at', ascending: false)
        .limit(10);

    return (orders as List)
        .map((e) => RecentOrder(
              orderId: e['id'],
              date: DateTime.parse(e['created_at']).toString().split(' ')[0],
              total: e['total'].toDouble(),
              status: e['status'],
              itemCount: e['order_items'][0]['count'],
            ))
        .toList();
  }
}
