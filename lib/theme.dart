import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const background = Color(0xFFF7F6F2); // papel
  static const surface = Color(0xFFFFFFFF);
  static const ink = Color(0xFF1B1F1E); // tinta
  static const muted = Color(0xFF6B7573);
  static const border = Color(0xFFE2E0D9);
  static const primary = Color(0xFF11705F); // verde-teal
  static const success = Color(0xFF2E9E6B);
  static const warning = Color(0xFFC98A18);
  static const danger = Color(0xFFC0453B);
}

ThemeData buildTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      surface: AppColors.surface,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: AppColors.background,
  );

  return base.copyWith(
    textTheme: GoogleFonts.dmSansTextTheme(base.textTheme).copyWith(
      headlineSmall: GoogleFonts.spaceGrotesk(
          fontSize: 24, fontWeight: FontWeight.w600, color: AppColors.ink),
      titleMedium: GoogleFonts.spaceGrotesk(
          fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.ink),
      bodyMedium: GoogleFonts.dmSans(fontSize: 14, color: AppColors.ink),
      bodySmall: GoogleFonts.dmSans(fontSize: 12, color: AppColors.muted),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.background,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      titleTextStyle: GoogleFonts.spaceGrotesk(
          fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.ink),
      iconTheme: const IconThemeData(color: AppColors.ink),
    ),
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
    ),
    chipTheme: base.chipTheme.copyWith(
      backgroundColor: const Color(0xFFEFEEE8),
      side: const BorderSide(color: AppColors.border),
      labelStyle: GoogleFonts.dmSans(fontSize: 12, color: AppColors.ink),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.border),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.surface,
      indicatorColor: AppColors.primary.withOpacity(0.12),
      labelTextStyle: WidgetStatePropertyAll(
        GoogleFonts.dmSans(fontSize: 11, color: AppColors.ink),
      ),
      height: 64,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.ink,
        side: const BorderSide(color: AppColors.border),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    ),
  );
}
