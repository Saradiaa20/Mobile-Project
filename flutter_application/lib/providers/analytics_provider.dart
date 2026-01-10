import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/analytics_model.dart';
import '../services/analytics_service.dart';

final analyticsServiceProvider = Provider((ref) => AnalyticsService());

final brandAnalyticsProvider = FutureProvider.family<SalesAnalytics, Map<String, dynamic>>((ref, params) async {
  final service = ref.watch(analyticsServiceProvider);
  final brandId = params['brandId'] as String;
  final days = params['days'] as int? ?? 30;
  return await service.getBrandAnalytics(brandId, days: days);
});
