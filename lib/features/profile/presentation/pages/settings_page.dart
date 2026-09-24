import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
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
  late ThemeMode _themeMode;
  bool _pushNotifications = true;
  bool _eventReminders = true;
  bool _offlineStorage = true;
  bool _hapticFeedback = true;

  @override
  void initState() {
    super.initState();
    _themeMode = widget.currentThemeMode;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('App Settings', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          // Theme Settings Section
          _buildSectionHeader('Appearance & Theme'),
          GlassContainer(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Theme Mode',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildThemeOption(
                      title: 'Dark Neon',
                      icon: Icons.dark_mode_rounded,
                      mode: ThemeMode.dark,
                    ),
                    const SizedBox(width: 12),
                    _buildThemeOption(
                      title: 'Daylight',
                      icon: Icons.light_mode_rounded,
                      mode: ThemeMode.light,
                    ),
                    const SizedBox(width: 12),
                    _buildThemeOption(
                      title: 'System',
                      icon: Icons.phone_android_rounded,
                      mode: ThemeMode.system,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Notification Preferences
          _buildSectionHeader('Notifications & Radar Alerts'),
          GlassContainer(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Push Notifications', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  subtitle: const Text('Breaking fandom announcements & trailer drops', style: TextStyle(fontSize: 12)),
                  value: _pushNotifications,
                  activeColor: AppColors.darkSecondary,
                  onChanged: (val) => setState(() => _pushNotifications = val),
                ),
                const Divider(),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Event Radar Reminders', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  subtitle: const Text('Countdown alerts for RSVP events & panel times', style: TextStyle(fontSize: 12)),
                  value: _eventReminders,
                  activeColor: AppColors.darkSecondary,
                  onChanged: (val) => setState(() => _eventReminders = val),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Offline & Cache Management
          _buildSectionHeader('Storage & Offline'),
          GlassContainer(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Offline Lore Archive', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  subtitle: const Text('Pre-cache glossary and beginner guides for flights', style: TextStyle(fontSize: 12)),
                  value: _offlineStorage,
                  activeColor: AppColors.darkSecondary,
                  onChanged: (val) => setState(() => _offlineStorage = val),
                ),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Clear Media Cache', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  subtitle: const Text('Free up local image cache (approx. 42 MB)', style: TextStyle(fontSize: 12)),
                  trailing: TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('🧹 Cache cleared successfully!')),
                      );
                    },
                    child: const Text('Clear', style: TextStyle(color: AppColors.darkSecondary)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Account & Session
          _buildSectionHeader('Account & Session'),
          GlassContainer(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined),
                  title: const Text('Privacy & Fandom Verse Rules', style: TextStyle(fontSize: 14)),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                  onTap: () {},
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.logout_rounded, color: AppColors.error),
                  title: const Text('Sign Out', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w700, fontSize: 14)),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Sign Out?'),
                        content: const Text('Are you sure you want to sign out of Fandom Verse Pocket Edition?'),
                        actions: [
                          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                            onPressed: () {
                              Navigator.of(ctx).pop();
                              Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
                            },
                            child: const Text('Sign Out'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.darkSecondary),
      ),
    );
  }

  Widget _buildThemeOption({
    required String title,
    required IconData icon,
    required ThemeMode mode,
  }) {
    final isSelected = _themeMode == mode;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _themeMode = mode;
          });
          widget.onThemeChanged?.call(mode);
          try {
            (context.findAncestorStateOfType<State<StatefulWidget>>() as dynamic)?.setThemeMode(mode);
          } catch (_) {}
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.darkSecondary.withValues(alpha: 0.2)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.darkSecondary : Colors.grey.withValues(alpha: 0.3),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? AppColors.darkSecondary : Colors.grey,
                size: 24,
              ),
              const SizedBox(height: 6),
              Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? AppColors.darkSecondary : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
