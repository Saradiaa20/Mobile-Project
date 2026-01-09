import 'package:flutter/foundation.dart';
import 'package:flutter_application/services/product_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import '../models/product_model.dart';
import '../services/product_service.dart';

final productProvider = StateNotifierProvider<ProductNotifier, List<Product>>((
  ref,
) {
  return ProductNotifier();
});

class ProductNotifier extends StateNotifier<List<Product>> {
  final ProductService service = ProductService();

  bool _isLoading = false;
  final Map<String, List<Product>> _previewProducts = {};

  ProductNotifier() : super([]);

  // Fix getters
  bool get isLoading => _isLoading;
  List<Product> get products => state;
  Map<String, List<Product>> get previewProducts => _previewProducts;

  Future<void> loadProducts(String brandId) async {
    try {
      _isLoading = true;
      print('Loading products for brand: $brandId');
      final products = await service.getBrandProducts(brandId);
      state = products;
      _isLoading = false;
      print('State updated with ${products.length} products');
    } catch (e) {
      _isLoading = false;
      print('Error in loadProducts: $e');
      state = [];
      rethrow;
    }
  }

  Future<void> add(Product product, File? imageFile) async {
    try {
      print('Adding new product...');
      String? imagePath;

      // Save image locally if provided
      if (imageFile != null) {
        imagePath = await service.saveImageLocally(imageFile);
        print('Image saved with filename: $imagePath');
      }

      // Create product with image path (productId should be empty for new products)
      final productWithImage = product.copyWith(
        productId: '', // Empty for new products
        imagePath: imagePath,
      );

      print('Calling service.addProduct...');
      final newProduct = await service.addProduct(productWithImage);

      print('Product added, updating state...');
      state = [...state, newProduct];

      print(
        'State updated successfully. New product ID: ${newProduct.productId}',
      );
    } catch (e) {
      print('Error in add: $e');
      rethrow;
    }
  }

  Future<void> update(Product product, File? newImageFile) async {
    try {
      print('Updating product: ${product.productId}');
      String? imagePath = product.imagePath;

      // If new image is uploaded
      if (newImageFile != null) {
        print('New image provided, updating...');

        // Delete old image if exists
        if (product.imagePath != null && product.imagePath!.isNotEmpty) {
          await service.deleteLocalImage(product.imagePath!);
          print('Old image deleted');
        }

        // Save new image locally
        imagePath = await service.saveImageLocally(newImageFile);
        print('New image saved: $imagePath');
      }

      // Update product with new image path
      final updatedProduct = product.copyWith(imagePath: imagePath);

      print('Calling service.updateProduct...');
      await service.updateProduct(updatedProduct);

      print('Product updated in Supabase, updating state...');
      state = state
          .map(
            (p) => p.productId == updatedProduct.productId ? updatedProduct : p,
          )
          .toList();

      print('State updated successfully');
    } catch (e) {
      print('Error in update: $e');
      rethrow;
    }
  }

  Future<void> delete(String productId) async {
    try {
      print('Deleting product: $productId');

      final product = state.firstWhere(
        (p) => p.productId == productId,
        orElse: () => throw Exception('Product not found'),
      );

      print('Calling service.deleteProduct...');
      await service.deleteProduct(productId, product.imagePath);

      print('Product deleted from Supabase, updating state...');
      state = state.where((p) => p.productId != productId).toList();

      print('State updated successfully');
    } catch (e) {
      print('Error in delete: $e');
      rethrow;
    }
  }

// Implement loadPreviewProducts
  Future<void> loadPreviewProducts(String filter) async {
    if (_previewProducts.containsKey(filter)) return;

    try {
      final products = await service.fetchProducts(filter: filter);
      _previewProducts[filter] = products.take(4).toList();
      ChangeNotifier();
    } catch (e) {
      print('Error loading preview products: $e');
    }
  }
}
