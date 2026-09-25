import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../widgets/profile_picture_sheet.dart';

class FanProfilePage extends StatefulWidget {
  const FanProfilePage({super.key});

  void _openAvatarPicker(BuildContext context, String? currentAvatarUrl) {
    ProfilePictureSheet.show(
      context: context,
      currentAvatarUrl: currentAvatarUrl,
      onSelectedUrl: (newUrl) {
        context.read<AuthBloc>().add(
          UpdateUserProfileEvent(
            avatarUrl: newUrl,
            removeAvatar: false,
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile picture updated successfully!'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      onRemoveAvatar: () {
        context.read<AuthBloc>().add(
          const UpdateUserProfileEvent(
            removeAvatar: true,
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile picture removed.'),
            backgroundColor: AppColors.comicBlack,
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.comicBorderColor, width: 1.5),
        ),
        title: const Row(
          children: [
            Icon(Iconsax.logout, color: AppColors.comicRed, size: 24),
            SizedBox(width: 10),
            Text(
              'LOG OUT',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w900,
                fontSize: 18,
                color: AppColors.comicBlack,
              ),
            ),
          ],
        ),
        content: const Text(
          'Are you sure you want to log out of Fandom Verse?',
          style: TextStyle(fontSize: 14, color: AppColors.comicBlack, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'CANCEL',
              style: TextStyle(color: AppColors.comicGray, fontWeight: FontWeight.bold),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.comicRed,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              _performLogout(context);
            },
            child: const Text(
              'YES, LOG OUT',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }

  void _performLogout(BuildContext context) {
    // 1. Dispatch LogoutEvent to AuthBloc
    context.read<AuthBloc>().add(const LogoutEvent());

    // 2. Clear entire navigation stack and jump to Login screen immediately
    Navigator.of(context).pushNamedAndRemoveUntil(
      '/login',
      (route) => false,
    );

    // 3. Optional visual feedback
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Logged out successfully.'),
        backgroundColor: AppColors.comicBlack,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authUser = context.watch<AuthBloc>().currentUser;

    final displayName = authUser?.name.isNotEmpty == true ? authUser!.name : '';
    final usernameTag = displayName.isNotEmpty
        ? '@${displayName.toLowerCase().replaceAll(' ', '_')}'
        : '';
    final userEmail = authUser?.email ?? '';

    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, profileState) {
        final profileLoaded = profileState is ProfileLoaded ? profileState : null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fan Profile', style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.setting_2),
            onPressed: () => Navigator.of(context).pushNamed('/settings'),
          ),
          IconButton(
            icon: const Icon(Iconsax.logout, color: AppColors.comicRed),
            tooltip: 'Log Out',
            onPressed: () => _showLogoutDialog(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // ─── Solid Avatar & Name Card ───
            Center(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () => _openAvatarPicker(context, user?.avatarUrl),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 104,
                          height: 104,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.comicRed,
                            border: Border.all(
                              color: AppColors.comicYellow,
                              width: 3.5,
                            ),
                          ),
                          child: ClipOval(
                            child: (user?.avatarUrl != null && user!.avatarUrl!.trim().isNotEmpty)
                                ? Image.network(
                                    user.avatarUrl!,
                                    fit: BoxFit.cover,
                                    width: 104,
                                    height: 104,
                                    loadingBuilder: (context, child, progress) {
                                      if (progress == null) return child;
                                      return const Center(
                                        child: SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        ),
                                      );
                                    },
                                    errorBuilder: (_, __, ___) => Center(
                                      child: Text(
                                        displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U',
                                        style: const TextStyle(
                                          fontSize: 44,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  )
                                : Center(
                                    child: Text(
                                      displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U',
                                      style: const TextStyle(
                                        fontSize: 44,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: AppColors.comicYellow,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isDark ? AppColors.darkBackground : Colors.white,
                                width: 2.5,
                              ),
                            ),
                            child: const Center(
                              child: Icon(Iconsax.camera, size: 16, color: Colors.black),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    displayName,
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$usernameTag • $userEmail',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    alignment: WrapAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.comicYellow,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Iconsax.cup, size: 14, color: AppColors.comicBlack),
                            SizedBox(width: 6),
                            Text(
                              'LORE MASTER TIER III',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                color: AppColors.comicBlack,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pushNamed('/edit-profile'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkSurfaceElevated : AppColors.comicGrayLight,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isDark ? AppColors.darkBorder : AppColors.comicBorderColor,
                              width: 1,
                            ),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Iconsax.edit, size: 13, color: AppColors.comicRed),
                              SizedBox(width: 4),
                              Text(
                                'Edit Profile',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.comicRed,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Profile Stats — real data from ProfileBloc
            Row(
              children: [
                _buildStatItem('Discussions',
                    '${profileLoaded?.discussionCount ?? 0}', isDark),
                const SizedBox(width: 12),
                _buildStatItem(
                    'Orders', '${profileLoaded?.orders.length ?? 0}', isDark),
                const SizedBox(width: 12),
                _buildStatItem('Bookmarks',
                    '${profileLoaded?.bookmarksCount ?? 0}', isDark),
              ],
            ),
            const SizedBox(height: 24),

            // Bio — real data from ProfileBloc
            GlassContainer(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Fandom Bio',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    user?.bio?.isNotEmpty == true
                        ? user!.bio!
                        : 'Die-hard Shonen anime fan, Soulsborne speedrun enthusiast, and Marvel comics archivist. Always looking for new convention meetups!',
                    style: AppTextStyles.bodySmall.copyWith(
                      height: 1.5,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Subscribed Fandoms — real from DB
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'My Selected Fandoms',
                  style:
                      AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w800),
                ),
                TextButton(
                  onPressed: () =>
                      Navigator.of(context).pushNamed('/interest-setup'),
                  child: const Text('Manage',
                      style: TextStyle(
                          color: AppColors.comicRed,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Builder(builder: (context) {
              final rawFandoms = profileLoaded?.user['selected_fandoms']
                      ?.toString() ??
                  authUser?.selectedFandoms.join(', ') ??
                  '';
              final fandoms = rawFandoms
                  .replaceAll('[', '')
                  .replaceAll(']', '')
                  .split(',')
                  .map((f) => f.trim())
                  .where((f) => f.isNotEmpty)
                  .toList();
              if (fandoms.isEmpty) {
                return Text('No fandoms selected yet.',
                    style: TextStyle(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                        fontSize: 12));
              }
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: fandoms
                    .map((f) => Chip(
                          label: Text(f, style: const TextStyle(fontSize: 12)),
                          backgroundColor: isDark
                              ? AppColors.darkSurface
                              : AppColors.lightSurface,
                        ))
                    .toList(),
              );
            }),
            const SizedBox(height: 24),

            // Quick Nav Links
            _buildProfileNavTile(
              context,
              icon: Iconsax.receipt,
              title: 'Order History',
              subtitle: 'Track your merch invoices & bills',
              route: '/order-history',
              color: AppColors.heroBlue,
            ),
            _buildProfileNavTile(
              context,
              icon: Iconsax.heart,
              title: 'Saved Merch Wishlist',
              subtitle: profileLoaded != null
                  ? '${profileLoaded.wishlistCount} items saved'
                  : 'Your wishlist',
              route: '/wishlist',
              color: AppColors.comicRed,
            ),
            _buildProfileNavTile(
              context,
              icon: Iconsax.shop,
              title: 'Official Merch Store',
              subtitle: 'Limited edition drops & anime replicas',
              route: '/store',
              color: AppColors.comicYellowDark,
            ),
            _buildProfileNavTile(
              context,
              icon: Iconsax.cup,
              title: 'Achievements & Badges',
              subtitle: 'View your unlocked badges',
              route: '/badges',
              color: AppColors.comicYellowDark,
            ),
            _buildProfileNavTile(
              context,
              icon: Iconsax.notification,
              title: 'Notifications & Alerts',
              subtitle: 'Upcoming con reminders & replies',
              route: '/notifications',
              color: AppColors.heroCyan,
            ),
            _buildProfileNavTile(
              context,
              icon: Iconsax.bookmark,
              title: 'Bookmarks & Favorites',
              subtitle: profileLoaded != null
                  ? '${profileLoaded.bookmarksCount} saved articles'
                  : 'Saved lore articles & events',
              route: '/bookmarks',
              color: AppColors.heroPurple,
            ),

            const SizedBox(height: 20),

            // Logout Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.comicRed,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                icon: const Icon(Iconsax.logout, size: 20),
                label: const Text(
                  'LOG OUT',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    fontStyle: FontStyle.italic,
                    letterSpacing: 1.2,
                  ),
                ),
                onPressed: () => _showLogoutDialog(context),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
    }); // BlocBuilder
  }

  Widget _buildStatItem(String label, String count, bool isDark) {
    return Expanded(
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Column(
          children: [
            Text(
              count,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileNavTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String route,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: GlassContainer(
        onTap: () => Navigator.of(context).pushNamed(route),
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceElevated : AppColors.comicGrayLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Iconsax.arrow_right_3, size: 14, color: isDark ? Colors.white38 : Colors.black38),
          ],
        ),
      ),
    );
  }
}

