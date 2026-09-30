import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Palet warna: hijau Tokopedia yang dibuat lebih "dewasa" + aksen peach & lilac
/// biar kesannya aesthetic, bersih, dan elegan ala Gen Z.
class AppColors {
  static const green = Color(0xFF00A650);
  static const greenDark = Color(0xFF0B3D2A);
  static const mint = Color(0xFFE6F6EC);
  static const mintSoft = Color(0xFFF1FAF4);
  static const bg = Color(0xFFF5F7F5);
  static const ink = Color(0xFF111815);
  static const sub = Color(0xFF6B7A72);
  static const line = Color(0xFFE5EBE7);
  static const peach = Color(0xFFFF6B4A);
  static const peachSoft = Color(0xFFFFEDE8);
  static const lilac = Color(0xFF7C5CFF);
  static const lilacSoft = Color(0xFFEFEBFF);
  static const star = Color(0xFFFFB020);

  static const heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0B3D2A), Color(0xFF00A650)],
  );
}

/// Helper gaya teks (Plus Jakarta Sans).
class T {
  static TextStyle s(
    double size, {
    FontWeight w = FontWeight.w500,
    Color c = AppColors.ink,
    double? h,
    double? ls,
    TextDecoration? deco,
  }) =>
      GoogleFonts.plusJakartaSans(
        fontSize: size,
        fontWeight: w,
        color: c,
        height: h,
        letterSpacing: ls,
        decoration: deco,
      );

  static TextStyle get h1 => s(26, w: FontWeight.w800, h: 1.15, ls: -0.8);
  static TextStyle get h2 => s(20, w: FontWeight.w800, h: 1.2, ls: -0.4);
  static TextStyle get h3 => s(16, w: FontWeight.w700, h: 1.25, ls: -0.2);
  static TextStyle get body => s(14, h: 1.5);
  static TextStyle get small => s(12, c: AppColors.sub, h: 1.4);
}

class AppTheme {
  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.green,
      primary: AppColors.green,
      surface: Colors.white,
    );
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.bg,
    );
    return base.copyWith(
      textTheme: GoogleFonts.plusJakartaSansTextTheme(base.textTheme)
          .apply(bodyColor: AppColors.ink, displayColor: AppColors.ink),
      splashFactory: InkRipple.splashFactory,
    );
  }
}

/// Bayangan lembut yang dipakai kartu-kartu.
List<BoxShadow> softShadow([double opacity = 0.06]) => [
      BoxShadow(
        color: const Color(0xFF0B3D2A).withValues(alpha: opacity),
        blurRadius: 24,
        offset: const Offset(0, 8),
      ),
    ];
