import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

// Tamil script needs more line height to avoid clipping descenders.
// Applied to all text styles so switching locale never clips characters.
const double _h = 1.55;

abstract final class AppTextStyles {
  static TextStyle get displayLarge => GoogleFonts.notoSans(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        height: _h,
      );

  static TextStyle get headline => GoogleFonts.notoSans(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: _h,
      );

  static TextStyle get title => GoogleFonts.notoSans(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: _h,
      );

  static TextStyle get body => GoogleFonts.notoSans(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        height: _h,
      );

  static TextStyle get bodySecondary => GoogleFonts.notoSans(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        height: _h,
      );

  static TextStyle get label => GoogleFonts.notoSans(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
        height: _h,
      );

  static TextStyle get sectionHeader => GoogleFonts.notoSans(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.textTertiary,
        letterSpacing: 0.8,
        height: _h,
      );

  // Tabular figures keep currency columns aligned
  static TextStyle get amount => GoogleFonts.notoSans(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        fontFeatures: [const FontFeature.tabularFigures()],
        height: 1.3,
      );

  static TextStyle get amountSmall => GoogleFonts.notoSans(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        fontFeatures: [const FontFeature.tabularFigures()],
        height: 1.3,
      );

  static TextStyle get fieldLabel => GoogleFonts.notoSans(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
        height: _h,
      );

  static TextStyle get badge => GoogleFonts.notoSans(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        height: 1.2,
      );

  static TextStyle get button => GoogleFonts.notoSans(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
        height: 1.2,
      );

  static TextStyle get appBarTitle => GoogleFonts.notoSans(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textOnDark,
        height: _h,
      );

  static TextStyle get appBarSubtitle => GoogleFonts.notoSans(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AppColors.textOnDarkMuted,
        height: _h,
      );
}
