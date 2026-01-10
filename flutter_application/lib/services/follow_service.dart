import 'package:supabase_flutter/supabase_flutter.dart';

class FollowService {
  final _client = Supabase.instance.client;

  /// Follow a brand
  Future<void> followBrand(String userId, String brandId) async {
    try {
      await _client.from('follows').insert({
        'user_id': userId,
        'brand_id': brandId,
      });

      // Increment follower count
      await _client
          .from('brandowner')
          .update({
            'followers_count': _client.rpc('increment', params: {'x': 1}),
          })
          .eq('brandid', brandId);
    } catch (e) {
      print('Error following brand: $e');
      rethrow;
    }
  }

  /// Unfollow a brand
  Future<void> unfollowBrand(String userId, String brandId) async {
    try {
      await _client.from('follows').delete().match({
        'user_id': userId,
        'brand_id': brandId,
      });

      // Decrement follower count
      final currentCount = await getFollowerCount(brandId);
      final newCount = currentCount > 0 ? currentCount - 1 : 0;
      
      await _client
          .from('brandowner')
          .update({'followers_count': newCount})
          .eq('brandid', brandId);
    } catch (e) {
      print('Error unfollowing brand: $e');
      rethrow;
    }
  }

  /// Check if user follows brand
  Future<bool> isFollowing(String userId, String brandId) async {
    try {
      final response = await _client
          .from('follows')
          .select()
          .eq('user_id', userId)
          .eq('brand_id', brandId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      print('Error checking follow status: $e');
      return false;
    }
  }

  /// Get follower count for brand
  Future<int> getFollowerCount(String brandId) async {
    try {
      final response = await _client
          .from('brandowner')
          .select('followers_count')
          .eq('brandid', brandId)
          .single();

      return response['followers_count'] ?? 0;
    } catch (e) {
      print('Error getting follower count: $e');
      return 0;
    }
  }

  /// Get all brands user follows
  Future<List<String>> getUserFollowedBrands(String userId) async {
    try {
      final response = await _client
          .from('follows')
          .select('brand_id')
          .eq('user_id', userId);

      return (response as List).map((e) => e['brand_id'] as String).toList();
    } catch (e) {
      print('Error getting followed brands: $e');
      return [];
    }
  }
}