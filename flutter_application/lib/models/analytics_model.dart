class SalesAnalytics {
  final double totalRevenue;
  final int totalOrders;
  final double averageOrderValue;
  final int productsSold;
  final List<TopProduct> topProducts;
  final List<RecentOrder> recentOrders;

  SalesAnalytics({
    required this.totalRevenue,
    required this.totalOrders,
    required this.averageOrderValue,
    required this.productsSold,
    required this.topProducts,
    required this.recentOrders,
  });
}

class TopProduct {
  final String productId;
  final String name;
  final int quantitySold;
  final double revenue;
  final String? imagePath;

  TopProduct({
    required this.productId,
    required this.name,
    required this.quantitySold,
    required this.revenue,
    this.imagePath,
  });
}

class RecentOrder {
  final String orderId;
  final String date;
  final double total;
  final String status;
  final int itemCount;

  RecentOrder({
    required this.orderId,
    required this.date,
    required this.total,
    required this.status,
    required this.itemCount,
  });
}