import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';

/// --------------------
/// STATE
/// --------------------
class ProductState {
  final List<Product> products;
  final List<Product> searchResults;
  final Map<String, List<Product>> previewProducts;
  final bool isLoading;
  final bool isSearching;

  const ProductState({
    this.products = const [],
    this.searchResults = const [],
    this.previewProducts = const {},
    this.isLoading = false,
    this.isSearching = false,
  });

  ProductState copyWith({
    List<Product>? products,
    List<Product>? searchResults,
    Map<String, List<Product>>? previewProducts,
    bool? isLoading,
    bool? isSearching,
  }) {
    return ProductState(
      products: products ?? this.products,
      searchResults: searchResults ?? this.searchResults,
      previewProducts: previewProducts ?? this.previewProducts,
      isLoading: isLoading ?? this.isLoading,
      isSearching: isSearching ?? this.isSearching,
    );
  }

  operator [](int other) {}
}

/// --------------------
/// PROVIDER
/// --------------------
final productProvider =
    StateNotifierProvider<ProductNotifier, ProductState>((ref) {
  return ProductNotifier();
});

/// --------------------
/// NOTIFIER
/// --------------------
class ProductNotifier extends StateNotifier<ProductState> {
  final ProductService _service = ProductService();

  ProductNotifier() : super(const ProductState());

  // LOAD PRODUCTS ~Sara
  Future<void> loadProducts(String filter) async {
    state = state.copyWith(isLoading: true);

    try {
      final products = await _service.fetchProducts(filter: filter);
      state = state.copyWith(products: products);
    } catch (e) {
      state = state.copyWith(products: []);
      print('LOAD PRODUCTS ERROR: $e');
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  // SEARCH PRODUCTS ~Nada 
  Future<void> searchProducts(String query) async {
    if (query.trim().isEmpty) {
      state = state.copyWith(
        searchResults: [],
        isSearching: false,
      );
      return;
    }

    state = state.copyWith(isSearching: true);

    try {
      final results = await _service.searchProducts(query);
      state = state.copyWith(searchResults: results);
    } catch (e) {
      print('SEARCH ERROR: $e');
    } finally {
      state = state.copyWith(isSearching: false);
    }
  }

  // PREVIEW PRODUCTS ~Sara&Nada
  Future<void> loadPreviewProducts(String filter) async {
    if (state.previewProducts.containsKey(filter)) return;

    try {
      final products = await _service.fetchProducts(filter: filter);
      final updatedPreview = Map<String, List<Product>>.from(
        state.previewProducts,
      );

      updatedPreview[filter] = products.take(4).toList();

      state = state.copyWith(previewProducts: updatedPreview);
    } catch (e) {
      print('PREVIEW ERROR: $e');
    }
  }

  // ADD PRODUCT ~Sara
  Future<void> add(Product product, File? imageFile) async {
    try {
      String? imagePath;

      if (imageFile != null) {
        imagePath = await _service.saveImageLocally(imageFile);
      }

      final newProduct = await _service.addProduct(
        product.copyWith(imagePath: imagePath),
      );

      state = state.copyWith(
        products: [...state.products, newProduct],
      );
    } catch (e) {
      print('ADD PRODUCT ERROR: $e');
      rethrow;
    }
  }

  // UPDATE PRODUCT ~Sara
  Future<void> update(Product product, File? newImageFile) async {
    try {
      String? imagePath = product.imagePath;

      if (newImageFile != null) {
        if (product.imagePath.isNotEmpty) {
          await _service.deleteLocalImage(product.imagePath);
        }
        imagePath = await _service.saveImageLocally(newImageFile);
      }

      final updatedProduct = product.copyWith(imagePath: imagePath);
      await _service.updateProduct(updatedProduct);

      state = state.copyWith(
        products: state.products
            .map((p) =>
                p.productId == updatedProduct.productId ? updatedProduct : p)
            .toList(),
      );
    } catch (e) {
      print('UPDATE ERROR: $e');
      rethrow;
    }
  }

  // DELETE PRODUCT ~Sara
  Future<void> delete(String productId) async {
    try {
      final product =
          state.products.firstWhere((p) => p.productId == productId);

      await _service.deleteProduct(productId, product.imagePath);

      state = state.copyWith(
        products:
            state.products.where((p) => p.productId != productId).toList(),
      );
    } catch (e) {
      print('DELETE ERROR: $e');
      rethrow;
    }
  }

  
}
