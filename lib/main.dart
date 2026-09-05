import 'package:flutter/material.dart';

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
      home: const TokopediaLoadingScreen(), 
    );
  }
}

class TokopediaLoadingScreen extends StatelessWidget {
  const TokopediaLoadingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF42B549),
      body: Center(
        child: Text(
          'tokopedia',
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: -2, 
          ),
        ),
      ),
    );
  }
}
