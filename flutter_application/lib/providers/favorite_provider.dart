import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/favorite_service.dart';

/// PROVIDER
final favoritesProvider =
    StateNotifierProvider<FavoritesNotifier, Set<String>>(
  (ref) => FavoritesNotifier(),
);

/// NOTIFIER
class FavoritesNotifier extends StateNotifier<Set<String>> {
  FavoritesNotifier() : super({});

  final FavoriteService _favoriteService = FavoriteService();

  /// LOAD FAVORITES
  Future<void> loadFavorites() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final ids =
        await _favoriteService.getFavoriteProductIds(user.id);

    state = {...ids};
  }

  /// CHECK
  bool isFavorite(String productId) {
    return state.contains(productId);
  }

  /// TOGGLE
  Future<void> toggleFavorite(String productId) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    if (state.contains(productId)) {
      await _favoriteService.removeFavorite(
        userId: user.id,
        productId: productId,
      );
      state = state.where((id) => id != productId).toSet();
    } else {
      await _favoriteService.addFavorite(
        userId: user.id,
        productId: productId,
      );
      state = {...state, productId};
    }
  }
}
