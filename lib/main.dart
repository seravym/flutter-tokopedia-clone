import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '/screens/home/home_screen.dart';
import '/screens/splash/loading_page.dart';
import '/screens/onboarding/onboarding_screen.dart';
import 'login_page.dart';
import 'core/theme.dart';
import 'services/auth_store.dart';
import 'services/budget_repository.dart';
import 'services/saved_folders_repository.dart';
import 'services/cart_store.dart';
import 'services/order_store.dart';
import 'services/product_repository.dart';
import 'screens/product/product_detail_page.dart';
import 'services/wishlist_store.dart';
import 'pages/otp_page.dart';
import 'pages/profile_page.dart';
import 'pages/signUp_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Future.wait([
    AuthStore.instance.load(),
    CartStore.instance.load(),
    OrderStore.instance.load(),
    WishlistStore.instance.load(),
    BudgetRepository.instance.load(),
    SavedFoldersRepository.instance.load(),
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
        GoRoute(path: '/', builder: (context, state) => const LoadingPage()),
        GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
        GoRoute(path: '/', builder: (context, state) => const LoadingPage()),
        GoRoute(
          path: '/onboarding',
          builder: (context, state) => const OnboardingScreen(),
        ),
        GoRoute(path: '/login', builder: (context, state) => const LoginPage()),

        GoRoute(
          path: '/signup',
          builder: (context, state) => const SignUpPage(),
        ),
        GoRoute(path: '/otp', builder: (context, state) => const OtpPage()),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfilePage(),
        ),
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
        // 7. Detail Product
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
