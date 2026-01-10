import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_application/screens/customer/home_screen.dart';
import 'package:flutter_application/screens/customer/profile_screen.dart';
import 'package:flutter_application/screens/customer/search_screen.dart';
import 'package:flutter_application/screens/customer/cart_screen.dart';
import 'package:flutter_application/screens/customer/favorite_screen.dart';

import '../../providers/cart_provider.dart';

class AppLayout extends StatelessWidget {
  final Widget body;
  final Widget? drawer;

  const AppLayout({
    super.key,
    required this.body,
    this.drawer,
  });

  void _openSearch(BuildContext context) {
    showSearch(context: context, delegate: AppSearchDelegate());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: drawer,

      // APP BAR
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'GOLOCAL',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w900,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _openSearch(context),
          ),
        ],
      ),

      body: body,

      // BOTTOM NAV
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        showUnselectedLabels: false,
      onTap: (index) {
  if (index == 0) {
    // HOME
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  } else if (index == 1) {
    // SEARCH
    _openSearch(context);
  } else if (index == 2) {
    // CART
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CartScreen()),
    );
  } else if (index == 3) {
    // FAVORITE
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const FavoriteScreen()),
    );
  } else if (index == 4) {
    //  PROFILE
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ProfileScreen()),
    );
  }
},
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: '',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: '',
          ),

          BottomNavigationBarItem(
            label: '',
            icon: Consumer(
              builder: (context, ref, _) {
                final cartItems = ref.watch(cartProvider);

                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.shopping_bag_outlined),
                    if (cartItems.isNotEmpty)
                      Positioned(
                        right: -6,
                        top: -6,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 18,
                            minHeight: 18,
                          ),
                          child: Text(
                            cartItems.length.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
          ),

          const BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            label: '',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: '',
          ),
        ],
      ),
    );
  }
}
