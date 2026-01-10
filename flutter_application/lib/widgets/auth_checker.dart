import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/auth_provider.dart';
import '../screens/auth/login_screen.dart';
import '../screens/customer/home_screen.dart';
import '../screens/brand/brand_home_screen.dart';
import '../screens/admin/admin_dashboard_screen.dart';

/// Widget that checks authentication state and routes accordingly
class AuthChecker extends ConsumerWidget {
  const AuthChecker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (auth) {
        // No session = show login
        if (auth.session == null) {
          return const LoginScreen();
        }

        // Has session = check role and route accordingly
        final userProfileAsync = ref.watch(userProfileProvider);

        return userProfileAsync.when(
          data: (profile) {
            if (profile == null) {
              // Profile not found, show login
              return const LoginScreen();
            }

            final role = profile['role'] as String?;
            final userId = profile['id'] as String;

            // Route based on role
            switch (role) {
              case 'admin':
                return const AdminHomeScreen();

              case 'brand':
              case 'brand_owner':
              case 'brandOwner':
                // Get brandId from brandowner table
                return FutureBuilder<String?>(
                  future: _getBrandId(userId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Scaffold(
                        body: Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFFACBDAA),
                          ),
                        ),
                      );
                    }

                    if (snapshot.hasError || snapshot.data == null) {
                      return Scaffold(
                        body: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.store_outlined,
                                  size: 64,
                                  color: Colors.grey,
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Brand Profile Not Found',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Your brand information could not be found. Please contact support.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                ElevatedButton(
                                  onPressed: () {
                                    ref.read(authControllerProvider).signOut();
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFACBDAA),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 32,
                                      vertical: 16,
                                    ),
                                  ),
                                  child: const Text('Sign Out'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }

                    // Brand found - route to BrandHomeScreen
                    return BrandHomeScreen(brandId: snapshot.data!);
                  },
                );

              case 'user':
              case 'customer':
              default:
                // Customer - route to HomeScreen
                return const HomeScreen();
            }
          },
          loading: () => const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFFACBDAA)),
            ),
          ),
          error: (error, stack) {
            print('Error loading profile: $error');
            return const LoginScreen();
          },
        );
      },
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFACBDAA)),
        ),
      ),
      error: (error, stack) {
        print('Auth state error: $error');
        return const LoginScreen();
      },
    );
  }

  /// Get brandId from brandowner table using user's profile ID
  Future<String?> _getBrandId(String userId) async {
    try {
      final response = await Supabase.instance.client
          .from('brandowner')
          .select('brandid')
          .eq('id', userId) // Match on profiles.id (user's UUID)
          .single();

      return response['brandid'] as String?;
    } catch (e) {
      print('Error fetching brandId: $e');
      return null;
    }
  }
}
