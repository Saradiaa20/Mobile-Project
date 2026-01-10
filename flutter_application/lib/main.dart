import 'package:flutter/material.dart';
import 'package:flutter_application/providers/cart_provider.dart';
import 'package:flutter_application/providers/checkout_provider.dart';
import 'package:flutter_application/providers/favorite_provider.dart';
import 'package:flutter_application/providers/order_provider.dart';
import 'package:flutter_application/widgets/auth_checker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as provider;
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://ptnxcsugztfcdyrjhbrj.supabase.co',
    anonKey: 'sb_publishable_hek7Qv_4MBnKC9cx1LRsZA_4ttCtIz9',
  );

  runApp(const ProviderScope(child: MyApp()));
}

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'GoLocal',
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData(
//         primaryColor: const Color(0xFFACBDAA),
//         scaffoldBackgroundColor: Colors.white,
//         appBarTheme: const AppBarTheme(
//           backgroundColor: Colors.white,
//           foregroundColor: Colors.black,
//           elevation: 0,
//         ),
//         elevatedButtonTheme: ElevatedButtonThemeData(
//           style: ElevatedButton.styleFrom(
//             backgroundColor: const Color(0xFFACBDAA),
//             foregroundColor: Colors.white,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(8),
//             ),
//           ),
//         ),
//       ),
//       home: const LoginScreen(),
//       //home: const HomeScreen(),
//       // home: const BrandHomeScreen(
//       //   brandId: '947961b0-af07-4892-9a15-5e8f85eb1120',
//       // ),
//     );
//   }
// }




class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GoLocal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFFACBDAA),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFACBDAA),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      home: provider.MultiProvider(  // Use the alias
        providers: [
          provider.ChangeNotifierProvider(create: (_) => CheckoutProvider()),
          provider.ChangeNotifierProvider(create: (_) => CartProvider()),
          provider.ChangeNotifierProvider(create: (_) => OrdersProvider()),
          provider.ChangeNotifierProvider(create: (_) => FavoritesProvider()),
        ],
        child: const AuthChecker(),
      ),
    );
  }
}