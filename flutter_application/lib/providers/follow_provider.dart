import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/follow_service.dart';

final followServiceProvider = Provider((ref) => FollowService());

// Check if following a brand
final isFollowingProvider = FutureProvider.family<bool, FollowParams>((ref, params) async {
  final service = ref.watch(followServiceProvider);
  return await service.isFollowing(params.userId, params.brandId);
});

// Get follower count
final followerCountProvider = FutureProvider.family<int, String>((ref, brandId) async {
  final service = ref.watch(followServiceProvider);
  return await service.getFollowerCount(brandId);
});

class FollowParams {
  final String userId;
  final String brandId;

  FollowParams(this.userId, this.brandId);
}