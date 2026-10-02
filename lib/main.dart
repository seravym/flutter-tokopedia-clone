import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '/screens/home/home_screen.dart';
import '/screens/splash/loading_page.dart';
import 'login_page.dart';

void main() {
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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}
