import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color background = Color(0xFF131313);
  static const Color surface = Color(0xFF202020);
  static const Color primary = Color(0xFF00FFD1);
  static const Color onSurface = Color(0xFFE5E2E1);
  static const Color secondary = Color(0xFFB0C6FF);
  static const Color accentRed = Color(0xFFFF4B4B);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      colorScheme: const ColorScheme.dark(
        surface: surface,
        primary: primary,
        secondary: secondary,
        onSurface: onSurface,
        error: accentRed,
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.spaceGrotesk(
          fontSize: 96,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: -0.04,
        ),
        headlineLarge: GoogleFonts.spaceGrotesk(
          fontSize: 32,
          fontWeight: FontWeight.w600,
        ),
        headlineMedium: GoogleFonts.spaceGrotesk(
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 18,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 16,
        ),
        labelLarge: GoogleFonts.lexend(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
