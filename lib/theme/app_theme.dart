import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const bg = Color(0xFF0A0A12);
  static const surface = Color(0xFF14141F);
  static const card = Color(0xFF1E1E2E);
  static const card2 = Color(0xFF252538);
  static const gold = Color(0xFFEAB308);
  static const goldDark = Color(0xFFCA8A04);
  static const rose = Color(0xFFF43F5E);
  static const roseDark = Color(0xFFE11D48);
  static const textWhite = Colors.white;
  static const textMuted = Color(0xFF9CA3AF);
  static const textDim = Color(0xFF6B7280);
  static const borderGlass = Color(0x22FFFFFF);
}

ThemeData buildTheme() {
  final base = ThemeData.dark(useMaterial3: true);
  return base.copyWith(
    scaffoldBackgroundColor: AppColors.bg,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.gold,
      secondary: AppColors.rose,
      surface: AppColors.bg,
      background: AppColors.bg,
    ),
    textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
      bodyColor: Colors.white,
      displayColor: Colors.white,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white),
    ),
  );
}
