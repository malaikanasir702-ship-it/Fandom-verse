import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/sqlite_helper.dart';

class LocalStorageService {
  static const String _keyThemeMode = 'app_theme_mode';
  static const String _keyNotificationsEnabled = 'notifications_enabled';
  static const String _keyPriceDropAlerts = 'price_drop_alerts';

  final SharedPreferences _prefs;

  LocalStorageService(this._prefs);

  Future<void> saveThemeMode(ThemeMode mode) async {
    await _prefs.setString(_keyThemeMode, mode.toString());
  }

  ThemeMode getThemeMode() {
    final modeStr = _prefs.getString(_keyThemeMode);
    if (modeStr == ThemeMode.light.toString()) return ThemeMode.light;
    if (modeStr == ThemeMode.dark.toString()) return ThemeMode.dark;
    return ThemeMode.dark; // Default Cyber Fandom Dark
  }

  bool getNotificationsEnabled() => _prefs.getBool(_keyNotificationsEnabled) ?? true;
  Future<void> setNotificationsEnabled(bool value) => _prefs.setBool(_keyNotificationsEnabled, value);

  bool getPriceDropAlerts() => _prefs.getBool(_keyPriceDropAlerts) ?? true;
  Future<void> setPriceDropAlerts(bool value) => _prefs.setBool(_keyPriceDropAlerts, value);

  Future<double> getStorageFootprintMB() async {
    return await SqliteHelper.instance.calculateCacheSizeMB();
  }

  Future<void> clearOfflineStorage() async {
    await SqliteHelper.instance.clearOfflineCache();
  }

  Future<String> exportBookmarksJson() async {
    final bookmarks = await SqliteHelper.instance.query('posts');
    final bookmarkedOnly = bookmarks.where((p) => p['is_bookmarked'] == 1).toList();
    return jsonEncode({
      'export_date': DateTime.now().toIso8601String(),
      'app': 'Fandom Verse Pocket Edition',
      'total_saved': bookmarkedOnly.length,
      'bookmarks': bookmarkedOnly,
    });
  }
}
