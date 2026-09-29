import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF42B549),
        title: const Text(
          'Tokopedia',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: const Center(
        child: Text('Homepage'),
      ),
    );
  }
}