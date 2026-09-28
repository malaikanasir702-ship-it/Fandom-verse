import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../../core/widgets/skewed_button.dart';
import '../../../../core/widgets/skeleton_loader.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';
import '../../../../core/widgets/app_user_avatar.dart';
import '../widgets/profile_picture_sheet.dart';

class FanProfilePage extends StatefulWidget {
  const FanProfilePage({super.key});

  @override
  State<FanProfilePage> createState() => _FanProfilePageState();
}

class _FanProfilePageState extends State<FanProfilePage> {
  @override
  void initState() {
    super.initState();
    final userId = context.read<AuthBloc>().currentUser?.id;
    if (userId != null && userId.isNotEmpty) {
      context.read<ProfileBloc>().add(LoadUserProfileEvent(userId: userId));
    }
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
            Text('LOG OUT',
                style: TextStyle(
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    color: AppColors.comicBlack)),
          ],
        ),
        content: const Text('Are you sure you want to log out of Fandom Verse?',
            style: TextStyle(
                fontSize: 14, color: AppColors.comicBlack, height: 1.4)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('CANCEL',
                style: TextStyle(
                    color: AppColors.comicGray,
                    fontWeight: FontWeight.bold)),
          ),
          SkewedButton(
            text: 'Yes, Log Out',
            height: 44,
            fontSize: 12,
            backgroundColor: AppColors.comicRed,
            icon: Iconsax.logout,
            onPressed: () {
              Navigator.of(ctx).pop();
              _performLogout(context);
            },
          ),
        ],
      ),
    );
  }

  void _performLogout(BuildContext context) {
    context.read<AuthBloc>().add(const LogoutEvent());
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (r) => false);
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

    final displayName =
        authUser?.name.isNotEmpty == true ? authUser!.name : '';
    final usernameTag = displayName.isNotEmpty
        ? '@${displayName.toLowerCase().replaceAll(' ', '_')}'
        : '';
    final userEmail = authUser?.email ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fan Profile',
            style: TextStyle(fontWeight: FontWeight.w800)),
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
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, profileState) {
          // Show skeleton while profile data loads
          if (profileState is ProfileLoading) {
            return const SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  SkeletonProfileHeader(),
                  SizedBox(height: 20),
                  SkeletonLoader(width: double.infinity, height: 80, borderRadius: 14),
                  SizedBox(height: 14),
                  SkeletonLoader(width: double.infinity, height: 56, borderRadius: 14),
                  SizedBox(height: 10),
                  SkeletonLoader(width: double.infinity, height: 56, borderRadius: 14),
                  SizedBox(height: 10),
                  SkeletonLoader(width: double.infinity, height: 56, borderRadius: 14),
                ],
              ),
            );
          }

          final profileLoaded =
              profileState is ProfileLoaded ? profileState : null;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                // ── Avatar & Name ──────────────────────────────────────────
                Center(
                  child: Column(
                    children: [
                      AppUserAvatar(
                        avatarUrl: authUser?.avatarUrl,
                        displayName: displayName,
                        size: 96,
                        showBorder: true,
                        borderWidth: 3,
                        borderColor: isDark ? AppColors.comicYellow : AppColors.comicRed,
                        showEditBadge: true,
                        editBadgeIcon: Iconsax.camera,
                        onTap: () {
                          ProfilePictureSheet.show(
                            context: context,
                            currentAvatarUrl: authUser?.avatarUrl,
                            onSelectedUrl: (url) {
                              context.read<AuthBloc>().add(UpdateUserProfileEvent(avatarUrl: url));
                              if (authUser != null) {
                                context.read<ProfileBloc>().add(
                                      UpdateAvatarEvent(userId: authUser.id, imagePath: url),
                                    );
                              }
                            },
                            onRemoveAvatar: () {
                              context.read<AuthBloc>().add(const UpdateUserProfileEvent(removeAvatar: true));
                              if (authUser != null) {
                                context.read<ProfileBloc>().add(
                                      UpdateAvatarEvent(userId: authUser.id, imagePath: ''),
                                    );
                              }
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      Text(displayName,
                          style: const TextStyle(
                              fontWeight: FontWeight.w800, fontSize: 20)),
                      const SizedBox(height: 4),
                      Text(
                        '$usernameTag • $userEmail',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                      _PremiumBadge(
                        badgeTitle: (authUser?.badges.isNotEmpty == true)
                            ? authUser!.badges.first
                            : 'Recruit',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ── Stats ──────────────────────────────────────────────────
                Row(
                  children: [
                    _buildStatItem('Discussions',
                        '${profileLoaded?.discussionCount ?? 0}', isDark),
                    const SizedBox(width: 12),
                    _buildStatItem('Orders',
                        '${profileLoaded?.orders.length ?? 0}', isDark),
                    const SizedBox(width: 12),
                    _buildStatItem('Bookmarks',
                        '${profileLoaded?.bookmarksCount ?? 0}', isDark),
                  ],
                ),
                const SizedBox(height: 24),

                // ── Bio ────────────────────────────────────────────────────
                GlassContainer(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Fandom Bio',
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 13)),
                      const SizedBox(height: 6),
                      Text(
                        profileLoaded?.user['bio']?.toString().isNotEmpty ==
                                true
                            ? profileLoaded!.user['bio'].toString()
                            : authUser?.bio?.isNotEmpty == true
                                ? authUser!.bio!
                                : 'No bio added yet. Tap edit to add one.',
                        style: AppTextStyles.bodySmall.copyWith(
                          height: 1.5,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () => Navigator.of(context).pushNamed('/edit-profile'),
                          icon: const Icon(Iconsax.edit_2, size: 14, color: AppColors.comicRed),
                          label: const Text(
                            'Edit Profile',
                            style: TextStyle(
                              color: AppColors.comicRed,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ── Fandoms ────────────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('My Selected Fandoms',
                        style: AppTextStyles.titleMedium
                            .copyWith(fontWeight: FontWeight.w800)),
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
                  final rawFandoms =
                      profileLoaded?.user['selected_fandoms']?.toString() ??
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
                              label:
                                  Text(f, style: const TextStyle(fontSize: 12)),
                              backgroundColor: isDark
                                  ? AppColors.darkSurface
                                  : AppColors.lightSurface,
                            ))
                        .toList(),
                  );
                }),
                const SizedBox(height: 20),

                // ── Liked Fandoms ──────────────────────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Liked Fandoms',
                        style: AppTextStyles.titleMedium
                            .copyWith(fontWeight: FontWeight.w800)),
                  ],
                ),
                const SizedBox(height: 8),
                Builder(builder: (context) {
                  final likedFandoms = profileLoaded?.likedFandoms ?? authUser?.likedFandoms ?? [];
                  if (likedFandoms.isEmpty) {
                    return Text(
                      'No liked fandoms yet. Explore and like your favorites!',
                      style: TextStyle(
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                          fontSize: 12),
                    );
                  }
                  return Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: likedFandoms
                        .map((f) => Chip(
                              avatar: const Icon(Icons.favorite_rounded,
                                  size: 14, color: AppColors.comicRed),
                              label: Text(f, style: const TextStyle(fontSize: 12)),
                              backgroundColor: isDark
                                  ? AppColors.darkSurface
                                  : AppColors.lightSurface,
                            ))
                        .toList(),
                  );
                }),
                const SizedBox(height: 24),

                // ── Nav Tiles ──────────────────────────────────────────────
                _buildProfileNavTile(context,
                    icon: Iconsax.receipt,
                    title: 'Order History',
                    subtitle: 'Track your merch invoices & bills',
                    route: '/order-history',
                    color: AppColors.heroBlue),
                _buildProfileNavTile(context,
                    icon: Iconsax.wifi_square,
                    title: 'Offline Content',
                    subtitle: profileLoaded != null
                        ? '${profileLoaded.offlinePostsCount} articles · ${profileLoaded.offlineEventsCount} events · ${profileLoaded.cacheSizeMB} MB cached'
                        : 'Cached articles, events & glossary',
                    route: '/offline-content',
                    color: AppColors.heroGreen),
                _buildProfileNavTile(context,
                    icon: Iconsax.heart,
                    title: 'Saved Merch Wishlist',
                    subtitle: profileLoaded != null
                        ? '${profileLoaded.wishlistCount} items saved'
                        : 'Your wishlist',
                    route: '/wishlist',
                    color: AppColors.comicRed),
                _buildProfileNavTile(context,
                    icon: Iconsax.shop,
                    title: 'Official Merch Store',
                    subtitle: 'Limited edition drops & anime replicas',
                    route: '/store',
                    color: AppColors.comicYellowDark),
                _buildProfileNavTile(context,
                    icon: Iconsax.ticket,
                    title: 'My Event Tickets',
                    subtitle: 'View convention passes, QR codes & booking history',
                    route: '/ticket-history',
                    color: AppColors.comicRed),
                _buildProfileNavTile(context,
                    icon: Iconsax.cup,
                    title: 'Achievements & Badges',
                    subtitle: 'View your unlocked badges',
                    route: '/badges',
                    color: AppColors.comicYellowDark),
                _buildProfileNavTile(context,
                    icon: Iconsax.notification,
                    title: 'Notifications & Alerts',
                    subtitle: 'Upcoming con reminders & replies',
                    route: '/notifications',
                    color: AppColors.heroCyan),
                _buildProfileNavTile(context,
                    icon: Iconsax.bookmark,
                    title: 'Bookmarks & Favorites',
                    subtitle: profileLoaded != null
                        ? '${profileLoaded.bookmarksCount} saved articles'
                        : 'Saved lore articles & events',
                    route: '/bookmarks',
                    color: AppColors.heroPurple),
                _buildProfileNavTile(context,
                    icon: Iconsax.people,
                    title: 'About Us',
                    subtitle: 'Meet the Fandom Verse team',
                    route: '/about-us',
                    color: AppColors.heroGreen),
                _buildProfileNavTile(context,
                    icon: Iconsax.message_question,
                    title: 'Contact Us',
                    subtitle: 'Submit enquiries & feedback',
                    route: '/contact-us',
                    color: AppColors.comicYellowDark),
                _buildProfileNavTile(context,
                    icon: Iconsax.info_circle,
                    title: 'FAQ',
                    subtitle: 'Frequently asked questions',
                    route: '/faq',
                    color: AppColors.heroBlue),

                const SizedBox(height: 20),

                // ── Logout ─────────────────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  child: SkewedButton(
                    text: 'LOG OUT',
                    icon: Iconsax.logout,
                    height: 52,
                    fontSize: 15,
                    backgroundColor: AppColors.comicRed,
                    onPressed: () => _showLogoutDialog(context),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatItem(String label, String count, bool isDark) {
    return Expanded(
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Column(
          children: [
            Text(count,
                style: const TextStyle(
                    fontWeight: FontWeight.w800, fontSize: 18)),
            const SizedBox(height: 2),
            Text(label,
                style: TextStyle(
                    fontSize: 11,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary)),
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
                color: isDark
                    ? AppColors.darkSurfaceElevated
                    : AppColors.comicGrayLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: TextStyle(
                          fontSize: 11,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary)),
                ],
              ),
            ),
            Icon(Iconsax.arrow_right_3,
                size: 14,
                color: isDark ? Colors.white38 : Colors.black38),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Premium solid badge widget (Zero glow, solid comic aesthetic)
// ─────────────────────────────────────────────────────────────────────────────

class _PremiumBadge extends StatelessWidget {
  final String badgeTitle;
  const _PremiumBadge({required this.badgeTitle});

  String _iconFor(String title) {
    final t = title.toLowerCase();
    if (t.contains('lore')) return '📖';
    if (t.contains('master') || t.contains('architect')) return '👑';
    if (t.contains('legend') || t.contains('speedrun')) return '⚡';
    if (t.contains('hero') || t.contains('commander')) return '🛡️';
    if (t.contains('scout') || t.contains('recruit') || t.contains('otaku')) return '⭐';
    if (t.contains('collector')) return '🗂️';
    if (t.contains('keeper')) return '🗝️';
    if (t.contains('scholar') || t.contains('pioneer')) return '🚀';
    if (t.contains('warrior')) return '⚔️';
    if (t.contains('guardian')) return '🛡️';
    if (t.contains('con') || t.contains('veteran')) return '🎟️';
    return '🏅';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final emojiIcon = _iconFor(badgeTitle);

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.pushNamed(context, '/badges'),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurfaceElevated : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? AppColors.comicYellow : AppColors.comicBlack,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark ? Colors.black54 : AppColors.comicBlack,
                  offset: const Offset(2, 2),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Solid comic accent icon container
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.comicYellow,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.comicBlack,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(emojiIcon, style: const TextStyle(fontSize: 12)),
                      const SizedBox(width: 3),
                      const Icon(
                        Iconsax.verify,
                        size: 11,
                        color: AppColors.comicBlack,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Badge title
                Flexible(
                  child: Text(
                    badgeTitle.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.1,
                      color: isDark ? Colors.white : AppColors.comicBlack,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  Iconsax.arrow_right_3,
                  size: 11,
                  color: isDark ? AppColors.comicYellow : AppColors.comicGray,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


