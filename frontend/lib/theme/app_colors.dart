import 'package:flutter/material.dart';

abstract final class AppColors {
  // Primary brand — deep forest green, high contrast for outdoor tablet screens
  static const primary = Color(0xFF1A5C3A);
  static const primaryLight = Color(0xFF2D6A4F);
  static const primaryContainer = Color(0xFFDCF0E6);
  static const onPrimary = Color(0xFFFFFFFF);
  static const onPrimaryContainer = Color(0xFF0D2E1D);

  // Surface & background — warm off-white, easier on eyes than pure white
  static const surface = Color(0xFFF4F7F5);
  static const surfaceCard = Color(0xFFFFFFFF);
  static const surfaceVariant = Color(0xFFE8F0EB);

  // Borders & dividers
  static const border = Color(0xFFD0DDD5);
  static const borderStrong = Color(0xFFAABDB4);
  static const divider = Color(0xFFE4EDE7);

  // Text — high contrast for outdoor readability
  static const textPrimary = Color(0xFF0D1F17);
  static const textSecondary = Color(0xFF4D6B5A);
  static const textTertiary = Color(0xFF7A9488);
  static const textOnDark = Color(0xFFFFFFFF);
  static const textOnDarkMuted = Color(0xCCFFFFFF);

  // Status — all darkened for outdoor / sunlight readability
  static const pending = Color(0xFFC2410C);
  static const pendingBg = Color(0xFFFFF3E8);
  static const pendingBorder = Color(0xFFFED7AA);

  static const synced = Color(0xFF166534);
  static const syncedBg = Color(0xFFDCFCE7);
  static const syncedBorder = Color(0xFFBBF7D0);

  static const warning = Color(0xFF92400E);
  static const warningBg = Color(0xFFFEFCE8);
  static const warningBorder = Color(0xFFFDE68A);
  static const warningIcon = Color(0xFFD97706);

  static const draft = Color(0xFF374151);
  static const draftBg = Color(0xFFF3F4F6);
  static const draftBorder = Color(0xFFD1D5DB);

  static const error = Color(0xFFB91C1C);
  static const errorBg = Color(0xFFFEF2F2);
  static const errorBorder = Color(0xFFFECACA);

  // Connectivity status bar
  static const offlineBg = Color(0xFF7F1D1D);
  static const onlineBg = Color(0xFF14532D);
  static const syncPendingBg = Color(0xFF78350F);
}
