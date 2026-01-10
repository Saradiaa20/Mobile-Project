
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/cart/cart_item_card.dart';
import 'home_screen.dart';
import 'checkout_screen.dart';
import '../../utils/responsive.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);

    final double screenPadding = Responsive.padding(context);
    final double titleFontSize =
        Responsive.fontSize(context, mobile: 24, tablet: 26, desktop: 28);
    final double bodyFontSize =
        Responsive.fontSize(context, mobile: 12, tablet: 14, desktop: 16);

    return Scaffold(
      appBar: AppBar(title: const Text('My Cart')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: ListView.separated(
                itemCount: cartItems.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = cartItems[index];

                  return CartItemCard(
                    item: item,
                    onAdd: () => cartNotifier.increaseQty(item),
                    onRemove: () => cartNotifier.decreaseQty(item),
                    onDelete: () => cartNotifier.removeFromCart(item),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            _CartSummary(total: cartNotifier.totalPrice),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  backgroundColor: const Color(0xFFACBDAA),
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Color(0xFFACBDAA)),
                ),
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                    (route) => false,
                  );
                },
                child: const Text('Continue Shopping'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CheckoutScreen()),
                  );
                },
                child: const Text('Checkout'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartSummary extends StatelessWidget {
  final double total;
  const _CartSummary({required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey.shade200,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Total', style: TextStyle(fontWeight: FontWeight.bold)),
          Text(
            'EGP ${total.toStringAsFixed(0)}',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
