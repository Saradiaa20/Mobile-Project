import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// STATE
class CheckoutState {
  final TextEditingController emailController;
  final TextEditingController firstNameController;
  final TextEditingController lastNameController;
  final TextEditingController addressController;
  final TextEditingController cityController;
  final TextEditingController phoneController;

  final String? emailError;
  final String? addressError;
  final String? phoneError;
  final String governorate;

  CheckoutState({
    required this.emailController,
    required this.firstNameController,
    required this.lastNameController,
    required this.addressController,
    required this.cityController,
    required this.phoneController,
    this.emailError,
    this.addressError,
    this.phoneError,
    this.governorate = 'Cairo',
  });

  CheckoutState copyWith({
    String? emailError,
    String? addressError,
    String? phoneError,
    String? governorate,
  }) {
    return CheckoutState(
      emailController: emailController,
      firstNameController: firstNameController,
      lastNameController: lastNameController,
      addressController: addressController,
      cityController: cityController,
      phoneController: phoneController,
      emailError: emailError,
      addressError: addressError,
      phoneError: phoneError,
      governorate: governorate ?? this.governorate,
    );
  }
}
// PROVIDER
final checkoutProvider =
    StateNotifierProvider<CheckoutNotifier, CheckoutState>(
  (ref) => CheckoutNotifier(),
);

// NOTIFIER
class CheckoutNotifier extends StateNotifier<CheckoutState> {
  CheckoutNotifier()
      : super(
          CheckoutState(
            emailController: TextEditingController(),
            firstNameController: TextEditingController(),
            lastNameController: TextEditingController(),
            addressController: TextEditingController(),
            cityController: TextEditingController(),
            phoneController: TextEditingController(),
          ),
        );
  // SET GOVERNORATE
  void setGovernorate(String value) {
    state = state.copyWith(governorate: value);
  }

  // VALIDATION 
  bool validate() {
    bool isValid = true;

    String? emailError;
    String? addressError;
    String? phoneError;

    if (state.emailController.text.isEmpty) {
      emailError = 'Email is required';
      isValid = false;
    }

    if (state.addressController.text.isEmpty) {
      addressError = 'Address is required';
      isValid = false;
    }

    if (state.phoneController.text.isEmpty) {
      phoneError = 'Phone is required';
      isValid = false;
    }

    state = state.copyWith(
      emailError: emailError,
      addressError: addressError,
      phoneError: phoneError,
    );

    return isValid;
  }

  // SUBMIT ORDER
  Future<void> submitOrder({
    required double total,
    required List items,
  }) async {
    if (!validate()) return;

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }

    debugPrint('ORDER CREATED');
    debugPrint('User: ${user.id}');
    debugPrint('Total: $total');
    debugPrint('Items count: ${items.length}');
    debugPrint('First name: ${state.firstNameController.text}');
    debugPrint('Last name: ${state.lastNameController.text}');
    debugPrint('City: ${state.cityController.text}');
    debugPrint('Address: ${state.addressController.text}');
    debugPrint('Governorate: ${state.governorate}');
    debugPrint('Phone: ${state.phoneController.text}');

    
  }

  // DISPOSE
  @override
  void dispose() {
    state.emailController.dispose();
    state.firstNameController.dispose();
    state.lastNameController.dispose();
    state.addressController.dispose();
    state.cityController.dispose();
    state.phoneController.dispose();
    super.dispose();
  }
}
