import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ─── Primary Palette ─────────────────────────────────────
  static const Color bgDark = Color(0xFFFFFFFF);
  static const Color bgCard = Color(0xFFF8F9FB);
  static const Color bgCardLight = Color(0xFFF1F4F8);
  static const Color bgSidebar = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE0E6ED);
  static const Color borderLight = Color(0xFFEEF2F7);

  // ─── Accent Colors ───────────────────────────────────────
  static const Color accentGreen = Color(0xFF03A9F4); // Changed to Light Blue
  static const Color accentOrange = Color(0xFFFF9800);
  static const Color accentPurple = Color(0xFFAB47BC);
  static const Color accentCyan = Color(0xFF00BCD4);
  static const Color accentRed = Color(0xFFEF5350);
  static const Color accentBlue = Color(0xFF2196F3); // Standard Blue for buttons
  static const Color accentPink = Color(0xFFEC407A);
  static const Color accentYellow = Color(0xFFFFEE58);

  // ─── Text Colors ─────────────────────────────────────────
  static const Color textPrimary = Color(0xFF1A1A24);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);

  // ─── Gradients ───────────────────────────────────────────
  static const LinearGradient sidebarGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFFFFF), Color(0xFFF8F9FB)],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFFFFF), Color(0xFFF8F9FB)],
  );

  static LinearGradient accentGradient(Color color) => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [color.withValues(alpha: 0.1), color.withValues(alpha: 0.05)],
  );

  // ─── Glass Decoration ────────────────────────────────────
  static BoxDecoration glassDecoration({
    Color? glowColor,
    double borderRadius = 16,
    double opacity = 0.06,
  }) {
    return BoxDecoration(
      color: Colors.white.withValues(alpha: 0.9),
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: glowColor?.withValues(alpha: 0.2) ?? border,
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
        if (glowColor != null)
          BoxShadow(
            color: glowColor.withValues(alpha: 0.05),
            blurRadius: 15,
            spreadRadius: -2,
          ),
      ],
    );
  }

  static BoxDecoration solidCardDecoration({
    Color? glowColor,
    double borderRadius = 16,
  }) {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: glowColor?.withValues(alpha: 0.2) ?? border,
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
        if (glowColor != null)
          BoxShadow(
            color: glowColor.withValues(alpha: 0.04),
            blurRadius: 20,
            spreadRadius: -4,
          ),
      ],
    );
  }

  // ─── Theme Data ──────────────────────────────────────────
  static ThemeData get lightTheme { // Renamed from darkTheme
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: bgDark,
      primaryColor: accentGreen,
      colorScheme: const ColorScheme.light(
        primary: accentGreen,
        secondary: accentCyan,
        surface: bgCard,
        error: accentRed,
        onSurface: textPrimary,
      ),
      textTheme: GoogleFonts.montserratTextTheme().apply(
        bodyColor: textPrimary,
        displayColor: textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textPrimary),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: bgCardLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: accentGreen, width: 1.5),
        ),
        labelStyle: const TextStyle(color: textSecondary),
        hintStyle: const TextStyle(color: textMuted),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentBlue, // Blue for buttons
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          elevation: 0,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  // ─── Text Styles ─────────────────────────────────────────
  static TextStyle get heading1 => GoogleFonts.montserrat(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: textPrimary,
  );

  static TextStyle get heading2 => GoogleFonts.montserrat(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static TextStyle get heading3 => GoogleFonts.montserrat(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: textPrimary,
  );

  static TextStyle get bodyText => GoogleFonts.montserrat(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: textSecondary,
  );

  static TextStyle get caption => GoogleFonts.montserrat(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: textMuted,
  );

  static TextStyle get kpiValue => GoogleFonts.montserrat(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: textPrimary,
  );

  static TextStyle get kpiLabel => GoogleFonts.montserrat(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: textMuted,
    letterSpacing: 1.2,
  );
}
