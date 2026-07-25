import 'package:flutter/material.dart';

/// Central colour palette for the SetHarbour portfolio edition.
///
/// This mirrors the production SetHarbour palette so the portfolio build stays
/// visually consistent with the supplied screenshots. Change a value here and
/// it updates across the entire app.
class AppColours {
  AppColours._();

  // ── Accent (same in both themes) ──────────────────────────────────────────
  static const Color accent = Color(0xFF29B6F6);
  static const Color accentDeep = Color(0xFF0288D1);
  static const Color accentLight = Color(0xFF7FDBFF);

  // ── Semantic (same in both themes) ────────────────────────────────────────
  static const Color success = Color(0xFF34C759);
  static const Color warning = Color(0xFFFF9800);
  static const Color danger = Colors.redAccent;
  static const Color gold = Color(0xFFFFD700);
  static const Color goldGlow = Color(0xFFFFB547);

  // Interval timer ring / "get ready" + "work" states.
  static const Color intervalWork = Color(0xFFFF9800);
  static const Color intervalRest = Color(0xFF29B6F6);

  // Folder icon in the plans browser.
  static const Color folder = Color(0xFFF0A83C);

  // ── Helpers ───────────────────────────────────────────────────────────────
  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  // ── Scaffold / page background ────────────────────────────────────────────
  static Color scaffold(BuildContext context) =>
      isDark(context) ? const Color(0xFF0A0F14) : const Color(0xFFF2F4F7);

  // ── Card surfaces ─────────────────────────────────────────────────────────
  static Color cardBg(BuildContext context) =>
      isDark(context) ? const Color(0xFF121A22) : Colors.white;

  static Color cardBorder(BuildContext context) =>
      isDark(context) ? const Color(0xFF1E2A36) : const Color(0xFFDDE3EC);

  static Color cardSelected(BuildContext context) =>
      isDark(context) ? const Color(0xFF162431) : const Color(0xFFE8F6FD);

  // ── Input fields ──────────────────────────────────────────────────────────
  static Color inputBg(BuildContext context) =>
      isDark(context) ? const Color(0xFF0A0F14) : const Color(0xFFF7F9FC);

  // ── Navigation bar ────────────────────────────────────────────────────────
  static Color navBar(BuildContext context) =>
      isDark(context) ? const Color(0xFF101720) : Colors.white;

  // ── Text ──────────────────────────────────────────────────────────────────
  static Color textPrimary(BuildContext context) =>
      isDark(context) ? Colors.white : const Color(0xFF0D1B2A);

  static Color textSecondary(BuildContext context) =>
      isDark(context) ? Colors.white70 : const Color(0xFF4A5568);

  static Color textMuted(BuildContext context) =>
      isDark(context) ? Colors.white54 : const Color(0xFF8899AA);

  static Color textHint(BuildContext context) =>
      isDark(context) ? Colors.white38 : const Color(0xFFAABBCC);

  // ── Dividers ──────────────────────────────────────────────────────────────
  static Color divider(BuildContext context) =>
      isDark(context) ? const Color(0xFF1E2A36) : const Color(0xFFE2E8F0);

  // ── Accent tinted backgrounds ─────────────────────────────────────────────
  static Color accentSubtle(BuildContext context) =>
      isDark(context) ? const Color(0x1429B6F6) : const Color(0xFFE3F4FD);

  static Color accentBorder(BuildContext context) =>
      isDark(context) ? const Color(0xFF17415A) : const Color(0xFFB3DFF7);

  // ── Chip / pill ───────────────────────────────────────────────────────────
  static Color chipBg(BuildContext context) =>
      isDark(context) ? const Color(0xFF08141F) : const Color(0xFFF0F8FF);

  // ── Stat card accent bar colours (fixed, not theme dependent) ────────────
  static const Color statBlue = accent;
  static const Color statGreen = Color(0xFF4CAF50);
  static const Color statOrange = Color(0xFFFF9800);
  static const Color statPurple = Color(0xFFAB47BC);
}
