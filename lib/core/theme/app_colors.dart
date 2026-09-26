import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ─── Solid Comic Brand Palette (Zero Gradients, Zero Glows) ───
  static const Color comicRed = Color(0xFFE51924); // Primary Action Red ("READ NOW", "NEW")
  static const Color comicRedDark = Color(0xFFB71C1C);
  static const Color comicYellow = Color(0xFFFFCC00); // Rating ⚡, circular action buttons
  static const Color comicYellowDark = Color(0xFFF59E0B);
  static const Color comicBlack = Color(0xFF111216); // Deep Comic Ink
  static const Color comicWhite = Color(0xFFFFFFFF); // Pure Solid White
  static const Color comicGray = Color(0xFF6B7280); // Subtitle / Metadata
  static const Color comicGrayLight = Color(0xFFF3F4F6);
  static const Color comicBorderColor = Color(0xFFE5E7EB);

  // Solid Hero Ring Colors (for "YOUR FAVOURITE HEROES" avatars)
  static const Color heroRed = Color(0xFFE51924);
  static const Color heroBlue = Color(0xFF1E88E5);
  static const Color heroYellow = Color(0xFFFFCC00);
  static const Color heroGreen = Color(0xFF2E7D32);
  static const Color heroPurple = Color(0xFF8E24AA);
  static const Color heroOrange = Color(0xFFFF6D00);
  static const Color heroCyan = Color(0xFF00ACC1);

  // ─── Solid Dark Palette ───
  static const Color darkPrimary = comicRed;
  static const Color darkSecondary = comicYellow;
  static const Color darkAccentGold = comicYellow;
  static const Color darkBackground = Color(0xFF111216);
  static const Color darkSurface = Color(0xFF1C1D24);
  static const Color darkSurfaceElevated = Color(0xFF252730);
  static const Color darkTextPrimary = Color(0xFFFFFFFF);
  static const Color darkTextSecondary = Color(0xFF9CA3AF);
  static const Color darkBorder = Color(0xFF2E313D);
  static const Color darkGlass = Color(0xFF1C1D24); // 100% Solid

  // ─── Solid Light Palette (Default Reference Look) ───
  static const Color lightPrimary = comicRed;
  static const Color lightSecondary = comicYellow;
  static const Color lightAccentGold = comicYellow;
  static const Color lightBackground = Color(0xFFF8F9FA); // Clean comic canvas
  static const Color lightSurface = Color(0xFFFFFFFF); // Clean solid paper
  static const Color lightSurfaceElevated = Color(0xFFF1F3F5);
  static const Color lightTextPrimary = Color(0xFF111216);
  static const Color lightTextSecondary = Color(0xFF6B7280);
  static const Color lightBorder = Color(0xFFE5E7EB);
  static const Color lightGlass = Color(0xFFFFFFFF); // 100% Solid

  // ─── Common Semantic Colors ───
  static const Color success = Color(0xFF10B981);
  static const Color error = comicRed;
  static const Color warning = comicYellow;
  static const Color info = Color(0xFF2563EB);

  // ─── Fandom Category Colors ───
  static const Color animeViolet = Color(0xFF8E24AA);
  static const Color gamingGreen = Color(0xFF2E7D32);
  static const Color sciFiCyan = Color(0xFF0288D1);
  static const Color marvelRed = Color(0xFFE51924);
  static const Color kpopPink = Color(0xFFD81B60);
  static const Color comicsAmber = Color(0xFFFF8F00);

  // ─── Admin Light Palette ───
  static const Color adminLightBackground = Color(0xFFF8FAFC);
  static const Color adminLightSurface = Color(0xFFFFFFFF);
  static const Color adminLightSurfaceElevated = Color(0xFFF1F5F9);
  static const Color adminLightBorder = Color(0xFFE2E8F0);
  static const Color adminLightTextPrimary = Color(0xFF0F172A);
  static const Color adminLightTextSecondary = Color(0xFF64748B);
  static const Color adminLightTextMuted = Color(0xFF94A3B8);
  static const Color adminLightCardBorder = Color(0xFFE2E8F0);
}
