import 'package:flutter/material.dart';

class AppColors {
  final bool isDark;
  AppColors._(this.isDark);

  factory AppColors.of(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AppColors._(isDark);
  }

  // ── Backgrounds ───────────────────────────────────────────
  // Light: soft cyan-to-lavender tint — matched from screenshots
  // Dark: almost black with very slight purple tint
  Color get scaffold =>
      isDark ? const Color(0xFF000000) : const Color(0xFFEADEE1);

  // Card light: very light lavender-grey (not pure white)
  Color get card =>
      isDark ? const Color(0xFF411F61) : const Color(0xFFF0EDF8);

  Color get cardAlt =>
      isDark ? const Color(0xFF442065) : const Color(0xFFEAE7F5);

  // Input bg light: even lighter lavender
  Color get inputBg =>
      isDark ? const Color(0xFF451F64) : const Color(0xFFF3F0FA);

  // Stat cards light: soft lavender-grey, very subtle — no border
  Color get statCard =>
      isDark ? const Color(0xFF442062) : const Color(0xFFECEAF5);

  // ── Text ──────────────────────────────────────────────────
  Color get textPrimary =>
      isDark ? Colors.white : const Color(0xFF1A0A35);

  Color get textSecondary =>
      isDark ? const Color(0xFFB8B0D8) : const Color(0xFF6B6490);

  Color get textHint =>
      isDark ? const Color(0xFF7A7298) : const Color(0xFF9E98B8);

  // ── Borders ───────────────────────────────────────────────
  // Light: solid teal — thick and clearly visible like screenshots
  Color get border =>
      isDark
          ? const Color(0xFF3ECFCF)
          : const Color(0xFF3ECFCF);

  Color get divider =>
      isDark ? const Color(0xFF2A1D50) : const Color(0xFFD8D4EE);

  // ── Nav bar ───────────────────────────────────────────────
  Color get navBg =>
      isDark ? const Color(0xFF080810) : Colors.white;

  Color get navSelected => const Color(0xFF3ECFCF);

  Color get navUnselected =>
      isDark ? const Color(0xFF6B6490) : const Color(0xFF7A7498);

  // ── Filter tabs ───────────────────────────────────────────
  // Light: subtle lavender background for the filter pill
  Color get filterBg =>
      isDark ? const Color(0xFF1C1040) : const Color(0xFFE8E5F5);

  Color get filterActive => Colors.white;

  Color get filterActiveText => Colors.white;

  // ── Shadow ────────────────────────────────────────────────
  Color get shadow =>
      isDark
          ? Colors.black.withOpacity(0.5)
          : const Color(0xFF6C63FF).withOpacity(0.08);

  // ── Section card header bg ────────────────────────────────
  Color get sectionHeaderBg =>
      isDark ? const Color(0xFF231550) : const Color(0xFFEAE7F5);

  // ── Brand / Status colors ─────────────────────────────────
  static const Color purple = Color(0xFF462265);
  static const Color teal   = Color(0xFF3ECFCF);
  static const Color orange = Color(0xFFFF7043);
  static const Color red    = Color(0xFFE53935);
  static const Color green  = Color(0xFF43A047);
}