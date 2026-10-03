import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '/screens/home/home_screen.dart';
import '/screens/splash/loading_page.dart';
import 'login_page.dart';
import 'core/theme.dart';
import 'services/auth_store.dart';
import 'services/cart_store.dart';
import 'services/order_store.dart';
import 'services/product_repository.dart';
import 'screens/product/product_detail_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Future.wait([
    AuthStore.instance.load(),
    CartStore.instance.load(),
    OrderStore.instance.load(),
  ]);
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final GoRouter router = GoRouter(
      initialLocation: '/',
      debugLogDiagnostics: true,

      routes: [
        // 1. Splash Screen 
        GoRoute(path: '/', builder: (context, state) => const LoadingPage()),

        // 2. Login Page
        GoRoute(path: '/login', builder: (context, state) => const LoginPage()),

        // 3. Home Screen 
        GoRoute(
          path: '/home',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const HomeScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(
                    opacity: CurveTween(curve: Curves.easeInOut)
                        .animate(animation),
                    child: child,
                  );
                },
          ),
        ),
       // 4. Detail Product 
        GoRoute(
          path: '/product/:id',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return FutureBuilder(
              future: ProductRepository.instance.all(),
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snapshot.hasError) {
                  return Scaffold(
                    body: Center(child: Text('Gagal fetch: ${snapshot.error}')),
                  );
                }
                final products = snapshot.data!;
                final product = products.firstWhere(
                  (p) => p.id.toString() == id,
                  orElse: () => products.first,
                );
                return ProductDetailPage(product: product);
              },
            );
          },
        ),
      ],

      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Text(
            'Halaman tidak ditemukan: ${state.error}',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );

    return MaterialApp.router(
      title: 'Tokopedia Clone',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(), 
      routerConfig: router,
    );
  }
}
