import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/skewed_button.dart';
import '../../../../core/widgets/skeleton_loader.dart';
import '../../../../core/services/multimedia_service.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/admin_bloc.dart';
import '../bloc/admin_event.dart';
import '../bloc/admin_state.dart';
import '../widgets/admin_modals.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  int _activeNavIndex = 0;

  @override
  void initState() {
    super.initState();
    context.read<AdminBloc>().add(const LoadAdminDashboardStatsEvent());
    MultimediaService.instance.ensureInitialized();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      extendBody: true,

      // ─── Solid Red & White Clean App Bar (Zero Glow) ────────────────────────
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        scrolledUnderElevation: 1,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        titleSpacing: 16,
        title: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            final adminName = authState is AdminAuthenticated
                ? authState.admin.name
                : 'Fandom Commander';
            final adminEmail = authState is AdminAuthenticated
                ? authState.admin.email
                : 'admin@fandomverse.com';

            return Row(
              children: [
                // Solid Red Avatar Ring (Zero Glow)
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.comicRed, width: 2),
                  ),
                  child: const CircleAvatar(
                    radius: 17,
                    backgroundColor: Colors.white,
                    child: Icon(Iconsax.shield_tick, size: 20, color: AppColors.comicRed),
                  ),
                ),
                const SizedBox(width: 12),

                // Name & Solid Super Admin Tag
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              adminName,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF111216),
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.comicRed,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'SUPER ADMIN',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 8.5,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: AppColors.comicRed,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              adminEmail,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF6B7280),
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
        actions: [
          // Refresh Button
          IconButton(
            icon: const Icon(Iconsax.refresh, color: Color(0xFF111216), size: 20),
            tooltip: 'Refresh Metrics',
            onPressed: () {
              HapticFeedback.lightImpact();
              context.read<AdminBloc>().add(const LoadAdminDashboardStatsEvent());
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('⚡ Syncing platform metrics...'),
                  duration: Duration(milliseconds: 900),
                  backgroundColor: AppColors.comicRed,
                ),
              );
            },
          ),

          // Logout Button
          IconButton(
            icon: const Icon(Iconsax.logout, color: AppColors.comicRed, size: 20),
            tooltip: 'Sign Out',
            onPressed: () => _confirmLogout(context),
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE5E7EB), height: 1),
        ),
      ),

      // ─── Solid Red & White Floating Bottom App Bar (Zero Glow) ───────────────
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: 14 + bottomInset,
        ),
        child: _buildSolidBottomAppBar(context),
      ),

      // ─── Dashboard Body ─────────────────────────────────────────────────────
      body: BlocConsumer<AdminBloc, AdminState>(
        listener: (context, state) {
          if (state is AdminStatsLoaded && state.successMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.successMessage!), backgroundColor: AppColors.comicRed),
            );
          }
        },
        builder: (context, state) {
          if (state is AdminLoading) {
            return const SkeletonAdminDashboardPage();
          }

          final metrics = state is AdminStatsLoaded
              ? state.metrics
              : {
                  'totalFans': 0,
                  'publishedArticles': 0,
                  'upcomingEvents': 0,
                  'storeProducts': 0,
                };

          final logs = state is AdminStatsLoaded ? state.recentLogs : <Map<String, dynamic>>[];

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Solid Red & White System Spotlight Banner (Overflow Fixed & Skewed Buttons)
                _buildSolidSpotlightBanner(context),
                const SizedBox(height: 20),

                // 2. KPI Metrics Grid
                _buildSectionHeader('PLATFORM OVERVIEW', 'LIVE'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildSolidKpiCard(
                        title: 'Total Fans',
                        count: '${metrics['totalFans']}',
                        badge: '+48 this week',
                        icon: Iconsax.people,
                        onTap: () => Navigator.of(context).pushNamed('/admin/users-categories'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSolidKpiCard(
                        title: 'Published Lore',
                        count: '${metrics['publishedArticles']}',
                        badge: '6 Fandoms',
                        icon: Iconsax.book_1,
                        onTap: () => Navigator.of(context).pushNamed('/admin/content'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildSolidKpiCard(
                        title: 'Conventions',
                        count: '${metrics['upcomingEvents']}',
                        badge: 'Radar Live',
                        icon: Iconsax.radar,
                        onTap: () => Navigator.of(context).pushNamed('/admin/events'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSolidKpiCard(
                        title: 'Merch Inventory',
                        count: '${metrics['storeProducts']}',
                        badge: 'Store Catalog',
                        icon: Iconsax.shop,
                        onTap: () => Navigator.of(context).pushNamed('/admin/products'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 3. Management Modules Grid
                _buildSectionHeader('MANAGE', 'OPERATIONS'),
                const SizedBox(height: 12),

                // Content & Lore Moderation
                _buildSolidModuleCard(
                  icon: Iconsax.document_text,
                  title: 'Content & Lore Moderation',
                  subtitle: 'Publish, edit, or delete articles, guides & glossary terms',
                  tag: 'Lore Hub',
                  onTap: () => Navigator.of(context).pushNamed('/admin/content'),
                ),

                // Multimedia Hub (Full CRUD with Cloudinary)
                _buildSolidModuleCard(
                  icon: Iconsax.video_play,
                  title: 'Fan Media Manager',
                  subtitle: 'Upload & manage fan art, cosplay, videos & podcasts',
                  tag: 'Media',
                  isHighlighted: true,
                  onTap: () => Navigator.of(context).pushNamed('/admin/multimedia'),
                ),

                // Convention & Event Radar
                _buildSolidModuleCard(
                  icon: Iconsax.calendar_2,
                  title: 'Convention & Event Radar',
                  subtitle: 'Manage schedules, venue GPS coordinates, ticketing & passes',
                  tag: 'Events',
                  onTap: () => Navigator.of(context).pushNamed('/admin/events'),
                ),

                // Official Merch Store
                _buildSolidModuleCard(
                  icon: Iconsax.box,
                  title: 'Official Merch Management',
                  subtitle: 'Update product prices, stock inventory, discount tags & deals',
                  tag: 'Merchandise',
                  onTap: () => Navigator.of(context).pushNamed('/admin/products'),
                ),

                // User Moderation & Categories
                _buildSolidModuleCard(
                  icon: Iconsax.profile_2user,
                  title: 'User Moderation & Categories',
                  subtitle: 'Inspect fan profiles, manage permissions & configure categories',
                  tag: 'Access',
                  onTap: () => Navigator.of(context).pushNamed('/admin/users-categories'),
                ),

                // Hero Stories & Backstories
                _buildSolidModuleCard(
                  icon: Iconsax.story,
                  title: 'Hero Stories & Backstories',
                  subtitle: 'Publish hero origins, history & powers for user story rings',
                  tag: 'Canon Lore',
                  onTap: () => Navigator.of(context).pushNamed('/admin/stories'),
                ),

                const SizedBox(height: 24),

                // 4. Recent Operations Log
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSectionHeader('RECENT ACTIVITY', 'LOG'),
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () => AdminModals.showAuditLogsSheet(
                        context: context,
                        logs: logs,
                      ),
                      child: const Row(
                        children: [
                          Text(
                            'View All',
                            style: TextStyle(
                              color: AppColors.comicRed,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(Iconsax.arrow_right_3, size: 12, color: AppColors.comicRed),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _buildSolidAuditFeed(logs),
              ],
            ),
          );
        },
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SOLID RED & WHITE BOTTOM APP BAR (Zero Glow, Pure White & Red)
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildSolidBottomAppBar(BuildContext context) {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // 1. Overview Tab
          _buildBottomNavItem(
            icon: Iconsax.element_4,
            label: 'Overview',
            isSelected: _activeNavIndex == 0,
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _activeNavIndex = 0);
            },
          ),

          // 2. Lore Tab
          _buildBottomNavItem(
            icon: Iconsax.document_text,
            label: 'Lore',
            isSelected: _activeNavIndex == 1,
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _activeNavIndex = 1);
              Navigator.of(context).pushNamed('/admin/content');
            },
          ),

          // 3. CENTER SOLID RED FAB (Zero Glow)
          GestureDetector(
            onTap: () {
              HapticFeedback.mediumImpact();
              _showQuickOperationsModal(context);
            },
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.comicRed,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(Iconsax.add, color: Colors.white, size: 28),
              ),
            ),
          ),

          // 4. Media Tab
          _buildBottomNavItem(
            icon: Iconsax.video_play,
            label: 'Media',
            isSelected: _activeNavIndex == 3,
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _activeNavIndex = 3);
              Navigator.of(context).pushNamed('/admin/multimedia');
            },
          ),

          // 5. Store Tab
          _buildBottomNavItem(
            icon: Iconsax.shop,
            label: 'Store',
            isSelected: _activeNavIndex == 4,
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _activeNavIndex = 4);
              Navigator.of(context).pushNamed('/admin/products');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.comicRed.withValues(alpha: 0.1) : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                size: 20,
                color: isSelected ? AppColors.comicRed : const Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                color: isSelected ? AppColors.comicRed : const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // QUICK OPERATIONS MODAL SHEET (Solid Red & White)
  // ─────────────────────────────────────────────────────────────────────────

  void _showQuickOperationsModal(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetCtx) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 20,
                offset: Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Iconsax.flash_1, color: AppColors.comicRed, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Quick Operations Hub',
                        style: TextStyle(
                          color: Color(0xFF111216),
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.comicRed,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'SHORTCUTS',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Create new lore articles, media uploads, events or push a broadcast',
                style: TextStyle(color: Color(0xFF6B7280), fontSize: 12),
              ),
              const SizedBox(height: 20),

              // Quick Actions Grid (Solid Red & White Tiles)
              Row(
                children: [
                  Expanded(
                    child: _buildModalActionTile(
                      label: 'New Article',
                      subtitle: 'Lore & news posts',
                      icon: Iconsax.document_text,
                      onTap: () {
                        Navigator.of(sheetCtx).pop();
                        Navigator.of(ctx).pushNamed('/admin/content-edit');
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildModalActionTile(
                      label: 'New Media',
                      subtitle: 'Cloudinary CDN asset',
                      icon: Iconsax.video_play,
                      onTap: () {
                        Navigator.of(sheetCtx).pop();
                        Navigator.of(ctx).pushNamed('/admin/multimedia-edit');
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildModalActionTile(
                      label: 'New Event',
                      subtitle: 'Convention & GPS',
                      icon: Iconsax.location_add,
                      onTap: () {
                        Navigator.of(sheetCtx).pop();
                        Navigator.of(ctx).pushNamed('/admin/event-edit');
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildModalActionTile(
                      label: 'New Product',
                      subtitle: 'Merchandise item',
                      icon: Iconsax.add_square,
                      onTap: () {
                        Navigator.of(sheetCtx).pop();
                        Navigator.of(ctx).pushNamed('/admin/product-edit');
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildModalActionTile(
                      label: 'Hero Story',
                      subtitle: 'Character origin lore',
                      icon: Iconsax.story,
                      onTap: () {
                        Navigator.of(sheetCtx).pop();
                        Navigator.of(ctx).pushNamed('/admin/story-edit');
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildModalActionTile(
                      label: 'Push Alert',
                      subtitle: 'Broadcast to all fans',
                      icon: Iconsax.notification_bing,
                      onTap: () {
                        Navigator.of(sheetCtx).pop();
                        AdminModals.showBroadcastModal(
                          context: ctx,
                          onBroadcastSent: (title, msg, audience) {
                            ctx.read<AdminBloc>().add(
                                  BroadcastNotificationEvent(
                                    title: title,
                                    message: msg,
                                    audience: audience,
                                  ),
                                );
                            ScaffoldMessenger.of(ctx).showSnackBar(
                              SnackBar(
                                content: Text('Dispatched broadcast "$title" to $audience!'),
                                backgroundColor: AppColors.comicRed,
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildModalActionTile({
    required String label,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.comicRed.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Iconsax.flash_1, color: AppColors.comicRed, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: Color(0xFF111216),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 9.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SOLID RED & WHITE SYSTEM SPOTLIGHT BANNER (Zero Glow, Skewed Buttons)
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildSolidSpotlightBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.comicRed.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Iconsax.cloud, color: AppColors.comicRed, size: 20),
                  ),
                  const SizedBox(width: 10),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Media Storage',
                        style: TextStyle(
                          color: Color(0xFF111216),
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        'Auto-compressed uploads · Always on',
                        style: TextStyle(color: Color(0xFF6B7280), fontSize: 10),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.comicRed,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'ONLINE ⚡',
                  style: TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          const SizedBox(height: 14),

          // Action SkewedButtons
          Row(
            children: [
              Expanded(
                child: SkewedButton(
                  text: 'Media',
                  icon: Iconsax.video_add,
                  height: 42,
                  fontSize: 10,
                  backgroundColor: AppColors.comicRed,
                  textColor: Colors.white,
                  onPressed: () => Navigator.of(context).pushNamed('/admin/multimedia-edit'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SkewedButton(
                  text: 'Lore',
                  icon: Iconsax.document_upload,
                  height: 42,
                  fontSize: 10,
                  backgroundColor: AppColors.comicRed,
                  textColor: Colors.white,
                  onPressed: () => Navigator.of(context).pushNamed('/admin/content-edit'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SkewedButton(
                  text: 'Alert',
                  icon: Iconsax.notification_status,
                  height: 42,
                  fontSize: 10,
                  backgroundColor: AppColors.comicRed,
                  textColor: Colors.white,
                  onPressed: () {
                    AdminModals.showBroadcastModal(
                      context: context,
                      onBroadcastSent: (title, msg, audience) {
                        context.read<AdminBloc>().add(
                              BroadcastNotificationEvent(
                                title: title,
                                message: msg,
                                audience: audience,
                              ),
                            );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Dispatched broadcast "$title" to $audience!'),
                            backgroundColor: AppColors.comicRed,
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SOLID RED & WHITE KPI CARDS (Zero Mix Color, Zero Glow)
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildSolidKpiCard({
    required String title,
    required String count,
    required String badge,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF6B7280),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.comicRed.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: AppColors.comicRed, size: 16),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              count,
              style: const TextStyle(
                color: Color(0xFF111216),
                fontSize: 22,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.comicRed.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                badge,
                style: const TextStyle(
                  color: AppColors.comicRed,
                  fontSize: 9.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SOLID RED & WHITE MODULE CARD (Zero Mix Color, Zero Glow)
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildSolidModuleCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String tag,
    required VoidCallback onTap,
    bool isHighlighted = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isHighlighted ? AppColors.comicRed : const Color(0xFFE5E7EB),
              width: isHighlighted ? 1.5 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isHighlighted ? AppColors.comicRed : AppColors.comicRed.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: isHighlighted ? Colors.white : AppColors.comicRed,
                  size: 20,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF111216),
                              fontSize: 13.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: isHighlighted ? AppColors.comicRed : const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            tag,
                            style: TextStyle(
                              color: isHighlighted ? Colors.white : AppColors.comicRed,
                              fontSize: 8.5,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF6B7280),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Iconsax.arrow_right_3, color: Color(0xFF9CA3AF), size: 14),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // SOLID AUDIT FEED (Red & White, Zero Glow)
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildSolidAuditFeed(List<Map<String, dynamic>> logs) {
    if (logs.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: const Center(
          child: Text(
            'No recent operations logged.',
            style: TextStyle(color: Color(0xFF6B7280), fontSize: 12),
          ),
        ),
      );
    }

    final top3 = logs.take(3).toList();
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: top3.map((l) {
          final isDelete = (l['action_type'] ?? '').toString().toUpperCase() == 'DELETE';
          final actionColor = isDelete ? AppColors.comicRed : const Color(0xFF111216);

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6), width: 1)),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: actionColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l['description'] ?? 'System operation performed',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF111216),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l['admin_email'] ?? 'admin@fandomverse.com',
                        style: const TextStyle(
                          color: Color(0xFF6B7280),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.comicRed.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    l['action_type'] ?? 'INFO',
                    style: const TextStyle(color: AppColors.comicRed, fontSize: 9, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String badge) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF111216),
            fontSize: 11.5,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
          decoration: BoxDecoration(
            color: AppColors.comicRed,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            badge,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 8.5,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ],
    );
  }

  void _confirmLogout(BuildContext ctx) {
    showDialog(
      context: ctx,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Iconsax.logout, color: AppColors.comicRed, size: 20),
            SizedBox(width: 8),
            Text('Exit Console', style: TextStyle(color: Color(0xFF111216), fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          'Are you sure you want to end your administrator session?',
          style: TextStyle(color: Color(0xFF6B7280), fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF6B7280))),
          ),
          SkewedButton(
            text: 'Sign Out',
            height: 40,
            fontSize: 12,
            backgroundColor: AppColors.comicRed,
            textColor: Colors.white,
            onPressed: () {
              Navigator.of(dialogCtx).pop();
              ctx.read<AuthBloc>().add(const LogoutEvent());
              Navigator.of(ctx).pushNamedAndRemoveUntil('/login', (route) => false);
            },
          ),
        ],
      ),
    );
  }
}
