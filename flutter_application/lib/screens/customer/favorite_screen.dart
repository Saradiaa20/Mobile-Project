import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/product_model.dart';
import '../../providers/favorite_provider.dart';
import '../../services/supabase_service.dart';
import '../../utils/responsive.dart';
import 'product_details_screen.dart';

class FavoriteScreen extends ConsumerStatefulWidget {
  const FavoriteScreen({super.key});

  @override
  ConsumerState<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends ConsumerState<FavoriteScreen> {
  List<Product> _favoriteProducts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavoriteProducts();
  }

  Future<void> _loadFavoriteProducts() async {
    setState(() => _isLoading = true);

    final user = SupabaseService.client.auth.currentUser;
    if (user == null) {
      setState(() {
        _favoriteProducts = [];
        _isLoading = false;
      });
      return;
    }

    // load favorites 
    await ref.read(favoritesProvider.notifier).loadFavorites();
    final favoriteIds = ref.read(favoritesProvider).toList();

    if (favoriteIds.isEmpty) {
      setState(() {
        _favoriteProducts = [];
        _isLoading = false;
      });
      return;
    }

    final response =
        await SupabaseService.client.from('products').select();

    final allProducts =
        (response as List).map((e) => Product.fromJson(e)).toList();

    setState(() {
      _favoriteProducts =
          allProducts.where((p) => favoriteIds.contains(p.id)).toList();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double screenPadding = Responsive.padding(context);
    final double titleFontSize =
        Responsive.fontSize(context, mobile: 24, tablet: 26, desktop: 28);
    final double bodyFontSize =
        Responsive.fontSize(context, mobile: 12, tablet: 14, desktop: 16);

    final isLoggedIn =
        SupabaseService.client.auth.currentUser != null;

    return Scaffold(
      appBar: AppBar(title: const Text('My Favorites')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : !isLoggedIn
              ? _LoginRequired(
                  titleFontSize: titleFontSize,
                  bodyFontSize: bodyFontSize,
                )
              : _favoriteProducts.isEmpty
                  ? _EmptyFavorites(
                      titleFontSize: titleFontSize,
                      bodyFontSize: bodyFontSize,
                    )
                  : RefreshIndicator(
                      onRefresh: _loadFavoriteProducts,
                      child: GridView.builder(
                        padding: EdgeInsets.all(screenPadding),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.7,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: _favoriteProducts.length,
                        itemBuilder: (_, index) {
                          return _FavoriteProductCard(
                            product: _favoriteProducts[index],
                            onFavoriteRemoved: _loadFavoriteProducts,
                          );
                        },
                      ),
                    ),
    );
  }
}

class _FavoriteProductCard extends ConsumerWidget {
  final Product product;
  final VoidCallback onFavoriteRemoved;

  const _FavoriteProductCard({
    required this.product,
    required this.onFavoriteRemoved,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesProvider);
    final notifier = ref.read(favoritesProvider.notifier);

    final isFav = favorites.contains(product.id);

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailsScreen(product: product),
          ),
        ).then((_) => onFavoriteRemoved());
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.asset(
                      'assets/images/${product.imagePath}',
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: InkWell(
                      onTap: () async {
                        await notifier.toggleFavorite(product.id);
                        onFavoriteRemoved();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.9),
                        ),
                        child: Icon(
                          isFav
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: isFav ? Colors.red : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(6),
              child: Text(
                product.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(
                'EGP ${product.price.toInt()}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFACBDAA),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyFavorites extends StatelessWidget {
  final double titleFontSize;
  final double bodyFontSize;

  const _EmptyFavorites({
    required this.titleFontSize,
    required this.bodyFontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No favorites yet',
            style: TextStyle(
              fontSize: titleFontSize,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start adding products to your favorites',
            style: TextStyle(
              fontSize: bodyFontSize,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}

class _LoginRequired extends StatelessWidget {
  final double titleFontSize;
  final double bodyFontSize;

  const _LoginRequired({
    required this.titleFontSize,
    required this.bodyFontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.login, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Please Login',
            style: TextStyle(
              fontSize: titleFontSize,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You need to login to view your favorites',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: bodyFontSize,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}
