import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/product_provider.dart';
import '../customer/product_details_screen.dart';

Timer? _debounce;

class AppSearchDelegate extends SearchDelegate<String?> {
  @override
  String get searchFieldLabel => 'Search';

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        Consumer(
          builder: (context, ref, _) => IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              query = '';
              ref.read(productProvider).searchResults.clear();
            },
          ),
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildBody(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
       // final provider = ref.read(productProvider);
        _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 400), () {
        ref.read(productProvider.notifier).searchProducts(query);
        });

        return _buildBody(context);
      },
    );
  }

  Widget _buildBody(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        final provider = ref.watch(productProvider);

        if (query.trim().isEmpty) {
          return const Center(child: Text('Start typing to search'));
        }

        if (provider.isSearching) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.searchResults.isEmpty) {
          return const Center(child: Text('No products found'));
        }

        return ListView.builder(
          itemCount: provider.searchResults.length,
          itemBuilder: (context, index) {
            final product = provider.searchResults[index];

            return ListTile(
              leading: Image.asset(
                'assets/images/${product.imagePath}',
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              ),
              title: Text(product.name),
              subtitle: Text('EGP ${product.price.toInt()}'),
              onTap: () {
                close(context, null);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProductDetailsScreen(product: product),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
