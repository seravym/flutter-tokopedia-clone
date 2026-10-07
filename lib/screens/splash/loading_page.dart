import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoadingPage extends StatefulWidget {
  const LoadingPage({super.key});

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  Timer? _blinkTimer;
  bool _isDarkMode = true;

  @override
  void initState() {
    super.initState();

    _blinkTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (mounted) {
        setState(() {
          _isDarkMode = !_isDarkMode;
        });
      }
    });

    Future.delayed(const Duration(seconds: 3), () {
      _blinkTimer?.cancel();
      if (mounted) {
        context.go('/onboarding');
      }
    });
  }

  @override
  void dispose() {
    _blinkTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color backgroundColor = _isDarkMode ? Colors.black : Colors.white;
    
    final String owlLogoPath = _isDarkMode 
        ? 'assets/images/logo_owl_white.png'  
        : 'assets/images/logo_owl_black.png'; 

    return Scaffold(
      body: Container(
        color: backgroundColor,
        width: double.infinity,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(owlLogoPath, width: 128),
              const SizedBox(height: 16),

              ColorFiltered(
                colorFilter: ColorFilter.mode(
                  _isDarkMode ? Colors.white : Colors.black, 
                  BlendMode.srcIn
                ),
                child: Image.asset('assets/images/logo_text.png', width: 220),
              ),
              
              const SizedBox(height: 50),
              CircularProgressIndicator(
                color: _isDarkMode ? Colors.white : Colors.black,
              ),
            ],
          ),
        ),
      ),
    );
  }
}