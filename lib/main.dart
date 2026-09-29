import 'package:flutter/material.dart';
import 'screens/loading_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import '/login_page.dart';
import 'screens/home_screen.dart';  

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tokopedia',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF42B549)),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/':          (context) => const LoadingScreen(),
        '/onboarding':(context) => const OnboardingScreen(),
        '/login':     (context) => const LoginPage(),
        '/profile':   (context) => const HomeScreen(), 
      },
    );
  }
}