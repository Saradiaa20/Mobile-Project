import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/analytics_model.dart';
import '../services/analytics_service.dart';

final analyticsServiceProvider = Provider((ref) => AnalyticsService());

final brandAnalyticsProvider = FutureProvider.family<SalesAnalytics, String>((ref, brandId) async {
  final service = ref.watch(analyticsServiceProvider);
  return await service.getBrandAnalytics(brandId);
});