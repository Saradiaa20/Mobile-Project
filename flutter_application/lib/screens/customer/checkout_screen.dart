
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/checkout_provider.dart';
import '../../providers/cart_provider.dart';
import '../../utils/responsive.dart';
import 'home_screen.dart';

class CheckoutScreen extends ConsumerWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = ref.watch(checkoutProvider);
    final notifier = ref.read(checkoutProvider.notifier);

    final cart = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);

    final double screenPadding = Responsive.padding(context);
    final double titleFontSize =
        Responsive.fontSize(context, mobile: 24, tablet: 26, desktop: 28);
    final double bodyFontSize =
        Responsive.fontSize(context, mobile: 12, tablet: 14, desktop: 16);

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// CONTACT
            const Text(
              'Contact',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: provider.emailController,
              decoration: InputDecoration(
                labelText: 'Email or mobile phone number',
                errorText: provider.emailError,
                border: const OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 24),

            /// DELIVERY
            const Text(
              'Delivery',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: provider.firstNameController,
              decoration: const InputDecoration(
                labelText: 'First name',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: provider.lastNameController,
              decoration: const InputDecoration(
                labelText: 'Last name',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: provider.addressController,
              decoration: InputDecoration(
                labelText: 'Address',
                errorText: provider.addressError,
                border: const OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: provider.cityController,
              decoration: const InputDecoration(
                labelText: 'City',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              value: provider.governorate,
              items: const [
                DropdownMenuItem(value: 'Cairo', child: Text('Cairo')),
                DropdownMenuItem(value: 'Giza', child: Text('Giza')),
                DropdownMenuItem(value: 'Alexandria', child: Text('Alexandria')),
                DropdownMenuItem(value: 'Aswan', child: Text('Aswan')),
                DropdownMenuItem(value: 'Asyut', child: Text('Asyut')),
                DropdownMenuItem(value: 'Beheira', child: Text('Beheira')),
                DropdownMenuItem(value: 'Beni Suef', child: Text('Beni Suef')),
                DropdownMenuItem(value: 'Dakahlia', child: Text('Dakahlia')),
                DropdownMenuItem(value: 'Damietta', child: Text('Damietta')),
                DropdownMenuItem(value: 'Faiyum', child: Text('Faiyum')),
                DropdownMenuItem(value: 'Gharbia', child: Text('Gharbia')),
                DropdownMenuItem(value: 'Ismailia', child: Text('Ismailia')),
                DropdownMenuItem(value: 'Kafr El Sheikh', child: Text('Kafr El Sheikh')),
                DropdownMenuItem(value: 'Luxor', child: Text('Luxor')),
                DropdownMenuItem(value: 'Matrouh', child: Text('Matrouh')),
                DropdownMenuItem(value: 'Minya', child: Text('Minya')),
                DropdownMenuItem(value: 'Monufia', child: Text('Monufia')),
                DropdownMenuItem(value: 'New Valley', child: Text('New Valley')),
                DropdownMenuItem(value: 'North Sinai', child: Text('North Sinai')),
                DropdownMenuItem(value: 'Port Said', child: Text('Port Said')),
                DropdownMenuItem(value: 'Qalyubia', child: Text('Qalyubia')),
                DropdownMenuItem(value: 'Qena', child: Text('Qena')),
                DropdownMenuItem(value: 'Red Sea', child: Text('Red Sea')),
                DropdownMenuItem(value: 'Sharqia', child: Text('Sharqia')),
                DropdownMenuItem(value: 'Sohag', child: Text('Sohag')),
                DropdownMenuItem(value: 'South Sinai', child: Text('South Sinai')),
                DropdownMenuItem(value: 'Suez', child: Text('Suez')),
              ],
              onChanged: (value) {
                if (value != null) {
                  notifier.setGovernorate(value);
                }
              },
              decoration: const InputDecoration(
                labelText: 'Governorate',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: provider.phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Phone',
                errorText: provider.phoneError,
                border: const OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 24),

            /// SHIPPING
            const Text(
              'Shipping method',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            const CardRow(
              title: 'Standard Shipping',
              subtitle: 'Delivery in 2–3 days',
              trailing: 'E£90.00',
            ),

            const SizedBox(height: 24),

            /// PAYMENT
            const Text(
              'Payment',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            const CardRow(
              title: 'Cash on Delivery (COD)',
            ),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFACBDAA),
                ),
                onPressed: () async {
                  await notifier.submitOrder(
                    total: cartNotifier.totalPrice,
                    items: cart,
                  );

                  cartNotifier.clearCart();

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Order placed successfully')),
                  );

                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                    (_) => false,
                  );
                },
                child: const Text(
                  'Complete order',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
}
class CardRow extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? trailing;

  const CardRow({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              if (subtitle != null)
                Text(subtitle!,
                    style: const TextStyle(color: Colors.grey)),
            ],
          ),
          if (trailing != null)
            Text(trailing!,
                style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}