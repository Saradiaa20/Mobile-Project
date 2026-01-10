import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/cart_item_model.dart';
import '../models/product_model.dart';

final cartProvider =
    StateNotifierProvider<CartNotifier, List<CartItem>>(
  (ref) => CartNotifier(),
);

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  // ADD TO CART
  void addToCart({
    required Product product,
    required String size,
    required String color,
  }) {
    final index = state.indexWhere(
      (item) =>
          item.productId == product.id &&
          item.size == size &&
          item.color == color,
    );

    if (index != -1) {
      final updatedItem = CartItem(
        productId: state[index].productId,
        name: state[index].name,
        price: state[index].price,
        imagePath: state[index].imagePath,
        size: state[index].size,
        color: state[index].color,
        quantity: state[index].quantity + 1,
      );

      state = [
        ...state.sublist(0, index),
        updatedItem,
        ...state.sublist(index + 1),
      ];
    } else {
      state = [
        ...state,
        CartItem(
          productId: product.id,
          name: product.name,
          price: product.price,
          imagePath: 'assets/images/${product.imagePath}',
          size: size,
          color: color,
          quantity: 1,
        ),
      ];
    }
  }

  // REMOVE ITEM
  void removeFromCart(CartItem item) {
    state = state.where((e) => e != item).toList();
  }

  // INCREASE QTY
  void increaseQty(CartItem item) {
    state = state.map((i) {
      if (i == item) {
        return CartItem(
          productId: i.productId,
          name: i.name,
          price: i.price,
          imagePath: i.imagePath,
          size: i.size,
          color: i.color,
          quantity: i.quantity + 1,
        );
      }
      return i;
    }).toList();
  }

  // DECREASE QTY
  void decreaseQty(CartItem item) {
    if (item.quantity > 1) {
      state = state.map((i) {
        if (i == item) {
          return CartItem(
            productId: i.productId,
            name: i.name,
            price: i.price,
            imagePath: i.imagePath,
            size: i.size,
            color: i.color,
            quantity: i.quantity - 1,
          );
        }
        return i;
      }).toList();
    }
  }

  // TOTAL PRICE
  double get totalPrice =>
      state.fold(0, (sum, i) => sum + i.price * i.quantity);

  // CART COUNT
  int get totalItems =>
      state.fold(0, (sum, i) => sum + i.quantity);

  // convert cart to order items
  List<Map<String, dynamic>> toOrderItems() {
    return state.map((item) {
      return {
        'product_id': item.productId,
        'quantity': item.quantity,
        'price': item.price,
        'size': item.size,
        'color': item.color,
      };
    }).toList();
  }

  // CLEAR CART
  void clearCart() {
    state = [];
  }
}
