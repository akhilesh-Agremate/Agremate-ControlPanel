import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // ─── Brand Palette ────────────────────────────────────────
  static const Color brandSteelBlue = Color(0xFF2083D5); // Primary brand blue
  static const Color brandBlueGrey = Color(0xFF6CA0DA); // Secondary accent
  static const Color brandPaleSky = Color(
    0xFFCEE1F3,
  ); // Light background accent
  static const Color brandWhite = Color(0xFFFFFFFF); // Background white
  static const Color brandRed = Color(0xFFE24B4A); // Error / Expired states
  static const Color brandRedLight = Color(0xFFFCEBEB); // Light red background

  // ─── Primary Palette ─────────────────────────────────────
  static const Color bgDark = brandWhite;
  static const Color bgCard = Color(0xFFF8FBFF); // near-white with blue tint
  static const Color bgCardLight = brandPaleSky;
  static const Color bgSidebar = brandWhite;
  static const Color border = Color(0xFFCEE1F3); // Pale Sky as border
  static const Color borderLight = Color(0xFFE6F0FA);

  // Landlord Theme (Steel Blue)
  static const Color landlordBg = brandPaleSky;
  static const Color landlordBorder = brandBlueGrey;
  static const Color landlordFill = brandSteelBlue;
  static const Color landlordText = Color(0xFF0D4A8A); // dark blue for text

  // Tenant Theme (Blue Grey)
  static const Color tenantBg = Color(0xFFE8F1FB);
  static const Color tenantBorder = brandBlueGrey;
  static const Color tenantFill = brandBlueGrey;
  static const Color tenantText = Color(0xFF2B5C8A); // medium blue for text

  // Status Badge Themes — using blue palette
  static const Color statusRentedBg = brandPaleSky;
  static const Color statusRentedText = brandSteelBlue;

  static const Color statusAvailableBg = brandPaleSky;
  static const Color statusAvailableText = brandSteelBlue;

  static const Color statusRequestedBg = Color(0xFFEAF2FB);
  static const Color statusRequestedText = brandBlueGrey;

  // Maintenance & Error stay red
  static const Color statusMaintenanceBg = brandRedLight;
  static const Color statusMaintenanceText = brandRed;

  // Subscription Badge
  static const Color statusActiveBg = brandPaleSky;
  static const Color statusActiveText = brandSteelBlue;

  // Dashboard KPI Card Themes — all blue, expired = red
  static const Color kpiRentBorder = brandSteelBlue;
  static const Color kpiRentNumber = brandSteelBlue;

  static const Color kpiPendingBorder = brandBlueGrey;
  static const Color kpiPendingNumber = Color(0xFF0D4A8A);

  static const Color kpiSubsBorder = brandBlueGrey;
  static const Color kpiSubsNumber = brandSteelBlue;

  static const Color kpiExpiredBorder = brandRed;
  static const Color kpiExpiredNumber = brandRed;

  // ─── Accent Colors ───────────────────────────────────────
  static const Color accentGreen = brandSteelBlue;
  static const Color accentOrange = brandBlueGrey;
  static const Color accentPurple = brandBlueGrey;
  static const Color accentCyan = brandSteelBlue;
  static const Color accentRed = brandRed;
  static const Color accentBlue = brandSteelBlue;
  static const Color accentPink = brandBlueGrey;
  static const Color accentYellow = brandPaleSky;

  // ─── Text Colors ─────────────────────────────────────────
  static const Color textPrimary = Color(0xFF1A1A24);
  static const Color textSecondary = Color(0xFF4A6A8A); // blue-tinted secondary
  static const Color textMuted = Color(0xFF8AA8C8); // pale blue muted

  // ─── Gradients ───────────────────────────────────────────
  static const LinearGradient sidebarGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [brandWhite, Color(0xFFF0F7FF)],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [brandWhite, Color(0xFFF0F7FF)],
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
    );
  }

  // ─── Theme Data ──────────────────────────────────────────
  static ThemeData get lightTheme {
    // Renamed from darkTheme
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: bgDark,
      primaryColor: brandSteelBlue,
      colorScheme: const ColorScheme.light(
        primary: brandSteelBlue,
        secondary: brandBlueGrey,
        surface: bgCard,
        error: brandRed,
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
          borderSide: const BorderSide(color: brandSteelBlue, width: 1.5),
        ),
        labelStyle: const TextStyle(color: textSecondary),
        hintStyle: const TextStyle(color: textMuted),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentBlue, // Blue for buttons
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
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
