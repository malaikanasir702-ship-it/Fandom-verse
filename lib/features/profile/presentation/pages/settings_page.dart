import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/database/sqlite_helper.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/bloc/theme_bloc.dart';
import '../../../../core/theme/bloc/theme_event.dart';
import '../../../../core/theme/bloc/theme_state.dart';
import '../../../../core/widgets/glass_container.dart';

class SettingsPage extends StatefulWidget {
  final ValueChanged<ThemeMode>? onThemeChanged;
  final ThemeMode currentThemeMode;

  const SettingsPage({
    super.key,
    this.onThemeChanged,
    this.currentThemeMode = ThemeMode.dark,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _pushNotifications = true;
  bool _eventReminders = true;
  bool _priceDropAlerts = true;
  bool _offlineStorage = true;
  double _cacheSizeMB = 45.2;

  @override
  void initState() {
    super.initState();
    _loadCacheSize();
  }

  Future<void> _loadCacheSize() async {
    final size = await SqliteHelper.instance.calculateCacheSizeMB();
    setState(() => _cacheSizeMB = size);
  }

  void _showClearCacheConfirmDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(ctx).brightness == Brightness.dark
            ? AppColors.darkSurfaceElevated
            : AppColors.lightSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Clear Offline Cache?'),
        content: const Text(
          'This will purge temporary image and offline caches. Your bookmarks and orders will remain safely intact in SQLite.',
          style: TextStyle(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              final navigator = Navigator.of(ctx);
              await SqliteHelper.instance.clearOfflineCache();
              await _loadCacheSize();
              if (mounted) {
                navigator.pop();
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('Offline cache cleared successfully!'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            child: const Text('Clear Cache', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _exportBookmarksJson() async {
    final bookmarks = await SqliteHelper.instance.query('posts');
    final bookmarked = bookmarks.where((p) => p['is_bookmarked'] == 1).toList();

    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(ctx).brightness == Brightness.dark
            ? AppColors.darkSurfaceElevated
            : AppColors.lightSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.file_download_done_rounded, color: AppColors.success),
            SizedBox(width: 8),
            Text('Bookmarks Exported'),
          ],
        ),
        content: Text(
          'Successfully packaged ${bookmarked.length} saved fandom articles into offline JSON format.',
          style: const TextStyle(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('App Settings', style: TextStyle(fontWeight: FontWeight.w800)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          // Theme Settings Section
          _buildSectionHeader('Appearance & Dual-Theme Engine', isDark),
          BlocBuilder<ThemeBloc, ThemeState>(
            builder: (context, themeState) {
              final activeMode = themeState.themeMode;
              return GlassContainer(
                padding: const EdgeInsets.all(16),
                borderColor: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Select App Palette',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildThemeCard(
                          title: 'Cyber Dark',
                          icon: Icons.dark_mode_rounded,
                          mode: ThemeMode.dark,
                          isSelected: activeMode == ThemeMode.dark,
                          isDark: isDark,
                        ),
                        const SizedBox(width: 10),
                        _buildThemeCard(
                          title: 'Lumina Light',
                          icon: Icons.light_mode_rounded,
                          mode: ThemeMode.light,
                          isSelected: activeMode == ThemeMode.light,
                          isDark: isDark,
                        ),
                        const SizedBox(width: 10),
                        _buildThemeCard(
                          title: 'System',
                          icon: Icons.phone_android_rounded,
                          mode: ThemeMode.system,
                          isSelected: activeMode == ThemeMode.system,
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 24),

          // Notification Preferences
          _buildSectionHeader('Notifications & Radar Alerts', isDark),
          GlassContainer(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            borderColor: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            child: Column(
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Push Announcements', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  subtitle: const Text('Breaking fandom announcements & trailer drops', style: TextStyle(fontSize: 11)),
                  value: _pushNotifications,
                  activeThumbColor: AppColors.darkSecondary,
                  onChanged: (val) => setState(() => _pushNotifications = val),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Event Radar Reminders', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  subtitle: const Text('Countdown alerts for convention opening & tickets', style: TextStyle(fontSize: 11)),
                  value: _eventReminders,
                  activeThumbColor: AppColors.darkSecondary,
                  onChanged: (val) => setState(() => _eventReminders = val),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Price Drop Alerts', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  subtitle: const Text('Get notified when wishlist merchandise goes on sale', style: TextStyle(fontSize: 11)),
                  value: _priceDropAlerts,
                  activeThumbColor: AppColors.darkSecondary,
                  onChanged: (val) => setState(() => _priceDropAlerts = val),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Offline Storage & Cache Manager
          _buildSectionHeader('Offline SQLite Storage & Cache', isDark),
          GlassContainer(
            padding: const EdgeInsets.all(16),
            borderColor: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Offline Footprint', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    Text(
                      '${_cacheSizeMB.toStringAsFixed(1)} MB',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: isDark ? AppColors.darkSecondary : AppColors.lightPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Visual Storage Breakdown Bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 85,
                        child: Container(height: 8, color: AppColors.darkPrimary),
                      ),
                      Expanded(
                        flex: 10,
                        child: Container(height: 8, color: AppColors.darkSecondary),
                      ),
                      Expanded(
                        flex: 5,
                        child: Container(height: 8, color: AppColors.darkAccentGold),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                Row(
                  children: [
                    _buildLegendItem('Media (42 MB)', AppColors.darkPrimary, isDark),
                    const SizedBox(width: 12),
                    _buildLegendItem('SQLite DB (3.2 MB)', AppColors.darkSecondary, isDark),
                  ],
                ),
                const SizedBox(height: 16),

                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Offline Lore Archive', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  subtitle: const Text('Store 50+ glossary terms & lore articles locally', style: TextStyle(fontSize: 11)),
                  value: _offlineStorage,
                  activeThumbColor: AppColors.darkSecondary,
                  onChanged: (val) => setState(() => _offlineStorage = val),
                ),
                const SizedBox(height: 8),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.cleaning_services_rounded, size: 16),
                        label: const Text('Clear Cache', style: TextStyle(fontSize: 12)),
                        onPressed: _showClearCacheConfirmDialog,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.file_upload_outlined, size: 16),
                        label: const Text('Export JSON', style: TextStyle(fontSize: 12)),
                        onPressed: _exportBookmarksJson,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // About App Build
          _buildSectionHeader('System & Architecture', isDark),
          GlassContainer(
            padding: const EdgeInsets.all(16),
            borderColor: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            child: Column(
              children: [
                _buildInfoRow('Edition', 'Fandom Verse Pocket Edition v1.0.0', isDark),
                _buildInfoRow('Architecture', 'Clean Architecture + BLoC + Dual Theme', isDark),
                _buildInfoRow('Storage Engine', 'SQLite Offline-First (12 Entities)', isDark),
                _buildInfoRow('Security Model', 'Role-Based Access Control (RBAC)', isDark),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildThemeCard({
    required String title,
    required IconData icon,
    required ThemeMode mode,
    required bool isSelected,
    required bool isDark,
  }) {
    return Expanded(
      child: InkWell(
        onTap: () {
          context.read<ThemeBloc>().add(ToggleThemeModeEvent(mode));
          widget.onThemeChanged?.call(mode);
        },
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? AppColors.darkPrimary : AppColors.lightPrimary).withValues(alpha: 0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? (isDark ? AppColors.darkPrimary : AppColors.lightPrimary)
                  : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
              width: isSelected ? 1.8 : 1.0,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected
                    ? (isDark ? AppColors.darkPrimary : AppColors.lightPrimary)
                    : Colors.grey,
                size: 22,
              ),
              const SizedBox(height: 6),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)
                      : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.8,
          color: isDark ? AppColors.darkSecondary : AppColors.lightSecondary,
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, bool isDark) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
