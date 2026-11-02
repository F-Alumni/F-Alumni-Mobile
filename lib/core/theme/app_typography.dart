import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTypography {
  // H1: 24px/32px, Bold, Slate 900. Used for page titles.
  static TextStyle get h1 => GoogleFonts.inter(
    fontSize: 24,
    height: 32 / 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  // H2: 20px/28px, Bold, Slate 900. Used for section headers.
  static TextStyle get h2 => GoogleFonts.inter(
    fontSize: 20,
    height: 28 / 20,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  // H3: 16px/24px, Semi-Bold, Slate 900. Used for card titles.
  static TextStyle get h3 => GoogleFonts.inter(
    fontSize: 16,
    height: 24 / 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // Body: 14px/20px, Regular, Slate 700. Used for post content and general text.
  static TextStyle get body => GoogleFonts.inter(
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.normal,
    color: const Color(0xFF334155), // Slate 700
  );

  // Small: 12px/16px, Medium, Slate 500. Used for timestamps and metadata.
  static TextStyle get small => GoogleFonts.inter(
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w500,
    color: const Color(0xFF64748B), // Slate 500
  );

  // Material-style aliases used by the existing feature screens.
  static TextStyle get headlineMedium =>
      h1.copyWith(fontSize: 28, height: 34 / 28);
  static TextStyle get headlineSmall => h1;
  static TextStyle get titleMedium => h3;
  static TextStyle get titleSmall => h3.copyWith(fontSize: 14, height: 20 / 14);
  static TextStyle get bodyLarge =>
      body.copyWith(fontSize: 16, height: 24 / 16);
  static TextStyle get bodyMedium => body;
  static TextStyle get bodySmall => small;
  static TextStyle get labelLarge =>
      small.copyWith(fontSize: 14, fontWeight: FontWeight.w600);
  static TextStyle get labelMedium => small.copyWith(fontSize: 12);
  static TextStyle get labelSmall => small.copyWith(fontSize: 10);
}
