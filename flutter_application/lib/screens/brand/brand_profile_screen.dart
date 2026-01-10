import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:io';
import '../../models/brand_model.dart';
import '../../models/product_model.dart';
import '../../services/brand_service.dart';
import '../../services/product_service.dart';
import '../../services/follow_service.dart';
import '../../providers/auth_provider.dart';
import '../customer/product_details_screen.dart';

class BrandProfileScreen extends ConsumerStatefulWidget {
  final String brandId;

  const BrandProfileScreen({super.key, required this.brandId});

  @override
  ConsumerState<BrandProfileScreen> createState() => _BrandProfileScreenState();
}

class _BrandProfileScreenState extends ConsumerState<BrandProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Brand? _brand;
  List<Product> _products = [];
  bool _isLoading = true;
  bool _isFollowing = false;
  int _followerCount = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadBrandData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadBrandData() async {
    setState(() => _isLoading = true);

    try {
      // Load brand info
      final brandService = BrandService();
      final brand = await brandService.getBrand(widget.brandId);

      // Load products
      final productService = ProductService();
      final products = await productService.getBrandProducts(widget.brandId);

      // Check if following (if user is logged in)
      final user = ref.read(currentUserProvider);
      bool isFollowing = false;
      int followerCount = 0;

      if (user != null) {
        final followService = FollowService();
        isFollowing = await followService.isFollowing(user.id, widget.brandId);
        followerCount = await followService.getFollowerCount(widget.brandId);
      }

      setState(() {
        _brand = brand;
        _products = products;
        _isFollowing = isFollowing;
        _followerCount = followerCount;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading brand data: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleFollow() async {
    final user = ref.read(currentUserProvider);
    if (user == null) {
      // Show login prompt
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to follow brands')),
      );
      return;
    }

    try {
      final followService = FollowService();
      
      if (_isFollowing) {
        await followService.unfollowBrand(user.id, widget.brandId);
        setState(() {
          _isFollowing = false;
          _followerCount--;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unfollowed')),
        );
      } else {
        await followService.followBrand(user.id, widget.brandId);
        setState(() {
          _isFollowing = true;
          _followerCount++;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Following'),
            backgroundColor: Color(0xFFACBDAA),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFACBDAA)),
        ),
      );
    }

    if (_brand == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Brand not found')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              pinned: true,
              expandedHeight: 0,
              iconTheme: const IconThemeData(color: Colors.black),
            ),
          ];
        },
        body: Column(
          children: [
            // Profile Header
            _buildProfileHeader(),

            // Tab Bar
            Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              child: TabBar(
                controller: _tabController,
                indicatorColor: const Color(0xFFACBDAA),
                labelColor: Colors.black,
                unselectedLabelColor: Colors.grey,
                tabs: const [
                  Tab(icon: Icon(Icons.grid_on)),
                  Tab(icon: Icon(Icons.info_outline)),
                ],
              ),
            ),

            // Tab Views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildProductsGrid(),
                  _buildAboutTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              // Profile Picture
              if (_brand!.logoPath != null && _brand!.logoPath!.isNotEmpty)
                FutureBuilder<String>(
                  future: BrandService().getLocalLogoPath(_brand!.logoPath!),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFACBDAA),
                            width: 3,
                          ),
                        ),
                        child: ClipOval(
                          child: Image.file(
                            File(snapshot.data!),
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: Colors.grey[100],
                              child: Icon(
                                Icons.store,
                                size: 40,
                                color: Colors.grey[400],
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                    return Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey[100],
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFACBDAA),
                        ),
                      ),
                    );
                  },
                )
              else
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[100],
                    border: Border.all(color: Colors.grey[300]!, width: 3),
                  ),
                  child: Icon(
                    Icons.store,
                    size: 40,
                    color: Colors.grey[400],
                  ),
                ),

              const SizedBox(width: 24),

              // Stats
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStat(_products.length.toString(), 'Products'),
                    _buildStat(_followerCount.toString(), 'Followers'),
                    _buildStat('0', 'Following'),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Brand Name & Description
          Align(
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _brand!.brandName ?? 'Unnamed Brand',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_brand!.description != null &&
                    _brand!.description!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    _brand!.description!,
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                    ),
                  ),
                ],
                if (_brand!.address != null && _brand!.address!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          _brand!.address!,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Follow Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _toggleFollow,
              style: ElevatedButton.styleFrom(
                backgroundColor: _isFollowing ? Colors.grey[300] : const Color(0xFFACBDAA),
                foregroundColor: _isFollowing ? Colors.black : Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: Text(
                _isFollowing ? 'Following' : 'Follow',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildProductsGrid() {
    if (_products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'No products yet',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(2),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: _products.length,
      itemBuilder: (context, index) {
        final product = _products[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProductDetailsScreen(product: product),
              ),
            );
          },
          child: Container(
            color: Colors.grey[200],
            child: product.imagePath != null && product.imagePath!.isNotEmpty
                ? FutureBuilder<String>(
                    future: ProductService().getLocalImagePath(product.imagePath!),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Image.file(
                          File(snapshot.data!),
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Icon(
                            Icons.image_not_supported,
                            color: Colors.grey[400],
                          ),
                        );
                      }
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFACBDAA),
                          strokeWidth: 2,
                        ),
                      );
                    },
                  )
                : Icon(Icons.image, color: Colors.grey[400], size: 40),
          ),
        );
      },
    );
  }

  Widget _buildAboutTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'About',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (_brand!.description != null && _brand!.description!.isNotEmpty)
            Text(
              _brand!.description!,
              style: TextStyle(color: Colors.grey[700], height: 1.5),
            ),
          const SizedBox(height: 24),
          if (_brand!.address != null && _brand!.address!.isNotEmpty) ...[
            const Text(
              'Location',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.grey[600], size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _brand!.address!,
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 24),
          const Text(
            'Joined',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            '${_brand!.createdAt.day}/${_brand!.createdAt.month}/${_brand!.createdAt.year}',
            style: TextStyle(color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }
}