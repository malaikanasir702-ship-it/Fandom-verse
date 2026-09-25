import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/bloc/theme_bloc.dart';
import '../../../../core/theme/bloc/theme_event.dart';
import '../../../../core/theme/bloc/theme_state.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/services/notification_service.dart';

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
  bool _communityReplies = true;

  @override
  void initState() {
    super.initState();
    _loadNotificationPrefs();
  }

  Future<void> _loadNotificationPrefs() async {
    final prefs = await NotificationService.getPreferences();
    if (mounted) {
      setState(() {
        _pushNotifications = prefs['pushNotifications'] ?? true;
        _eventReminders = prefs['eventReminders'] ?? true;
        _priceDropAlerts = prefs['priceDropAlerts'] ?? true;
        _communityReplies = prefs['communityReplies'] ?? true;
      });
    }
  }

  Future<void> _updatePref(String key, bool value) async {
    await NotificationService.savePreference(key, value);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Settings',
            style: TextStyle(fontWeight: FontWeight.w800)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          // ── Appearance ──────────────────────────────────────────────
          _buildSectionHeader('Appearance', isDark),
          BlocBuilder<ThemeBloc, ThemeState>(
            builder: (context, themeState) {
              final activeMode = themeState.themeMode;
              return GlassContainer(
                padding: const EdgeInsets.all(16),
                borderColor:
                    isDark ? AppColors.darkBorder : AppColors.lightBorder,
                backgroundColor:
                    isDark ? AppColors.darkSurface : AppColors.lightSurface,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Theme',
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 14)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _buildThemeCard(
                          title: 'Dark',
                          icon: Iconsax.moon,
                          mode: ThemeMode.dark,
                          isSelected: activeMode == ThemeMode.dark,
                          isDark: isDark,
                        ),
                        const SizedBox(width: 10),
                        _buildThemeCard(
                          title: 'Light',
                          icon: Iconsax.sun_1,
                          mode: ThemeMode.light,
                          isSelected: activeMode == ThemeMode.light,
                          isDark: isDark,
                        ),
                        const SizedBox(width: 10),
                        _buildThemeCard(
                          title: 'System',
                          icon: Iconsax.mobile,
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

          // ── Notifications ───────────────────────────────────────────
          _buildSectionHeader('Notifications', isDark),
          GlassContainer(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            borderColor: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            backgroundColor:
                isDark ? AppColors.darkSurface : AppColors.lightSurface,
            child: Column(
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Push Notifications',
                      style: TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 13)),
                  subtitle: const Text(
                      'Breaking news, trailer drops & announcements',
                      style: TextStyle(fontSize: 11)),
                  value: _pushNotifications,
                  activeThumbColor: AppColors.darkSecondary,
                  onChanged: (val) {
                    setState(() => _pushNotifications = val);
                    _updatePref('pushNotifications', val);
                    if (val) {
                      NotificationService.showTestNotification(
                        title: 'Notifications Enabled',
                        body: 'You\'ll now receive updates from Fandom Verse.',
                      );
                    }
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Event Reminders',
                      style: TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 13)),
                  subtitle: const Text(
                      'Countdown alerts before convention openings',
                      style: TextStyle(fontSize: 11)),
                  value: _eventReminders,
                  activeThumbColor: AppColors.darkSecondary,
                  onChanged: (val) {
                    setState(() => _eventReminders = val);
                    _updatePref('eventReminders', val);
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Price Drop Alerts',
                      style: TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 13)),
                  subtitle: const Text(
                      'Get notified when wishlist items go on sale',
                      style: TextStyle(fontSize: 11)),
                  value: _priceDropAlerts,
                  activeThumbColor: AppColors.darkSecondary,
                  onChanged: (val) {
                    setState(() => _priceDropAlerts = val);
                    _updatePref('priceDropAlerts', val);
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Community Replies',
                      style: TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 13)),
                  subtitle: const Text(
                      'Alerts when someone replies to your discussions',
                      style: TextStyle(fontSize: 11)),
                  value: _communityReplies,
                  activeThumbColor: AppColors.darkSecondary,
                  onChanged: (val) {
                    setState(() => _communityReplies = val);
                    _updatePref('communityReplies', val);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── About ────────────────────────────────────────────────────
          _buildSectionHeader('About', isDark),
          GlassContainer(
            padding: const EdgeInsets.all(16),
            borderColor: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            backgroundColor:
                isDark ? AppColors.darkSurface : AppColors.lightSurface,
            child: Column(
              children: [
                _buildInfoRow('App', 'Fandom Verse v1.0.0', isDark),
                _buildInfoRow('Platform', 'Android / iOS', isDark),
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
                ? (isDark ? AppColors.darkPrimary : AppColors.lightPrimary)
                    .withValues(alpha: 0.15)
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
                  fontWeight:
                      isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? (isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary)
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

  Widget _buildInfoRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(fontSize: 12, color: Colors.grey)),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.darkTextPrimary
                  : AppColors.lightTextPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
