import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/firestore_seeder.dart';
import '../../../../core/widgets/skewed_button.dart';
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
  @override
  void initState() {
    super.initState();
    context.read<AdminBloc>().add(const LoadAdminDashboardStatsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.adminLightBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        scrolledUnderElevation: 1,
        leading: Padding(
          padding: const EdgeInsets.all(10),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.comicRed.withValues(alpha: 0.1),
              border: Border.all(color: AppColors.comicRed.withValues(alpha: 0.3)),
            ),
            child: const Center(
              child: Icon(Iconsax.shield_tick, size: 16, color: AppColors.comicRed),
            ),
          ),
        ),
        title: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            final adminName = authState is AdminAuthenticated
                ? authState.admin.name
                : 'Administrator';
            final adminEmail = authState is AdminAuthenticated
                ? authState.admin.email
                : 'admin@fandomverse.com';
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Command Console',
                  style: TextStyle(
                    color: AppColors.adminLightTextPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '$adminEmail • $adminName',
                  style: const TextStyle(color: AppColors.adminLightTextSecondary, fontSize: 10),
                ),
              ],
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.refresh, color: AppColors.adminLightTextSecondary, size: 20),
            tooltip: 'Refresh Metrics',
            onPressed: () => context.read<AdminBloc>().add(const LoadAdminDashboardStatsEvent()),
          ),
          // ── Seed Firestore Button ──
          IconButton(
            icon: const Icon(Iconsax.cloud_connection, color: Color(0xFF2563EB), size: 20),
            tooltip: 'Seed Firestore Database',
            onPressed: () => _showSeedDialog(context),
          ),
          IconButton(
            icon: const Icon(Iconsax.logout, color: AppColors.error, size: 20),
            tooltip: 'Exit Console',
            onPressed: () {
              context.read<AuthBloc>().add(const LogoutEvent());
              Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocConsumer<AdminBloc, AdminState>(
        listener: (context, state) {
          if (state is AdminStatsLoaded && state.successMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.successMessage!), backgroundColor: AppColors.success),
            );
          }
        },
        builder: (context, state) {
          if (state is AdminLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.comicRed));
          }

          final metrics = state is AdminStatsLoaded
              ? state.metrics
              : {
                  'totalFans': 1240,
                  'publishedArticles': 84,
                  'upcomingEvents': 16,
                  'storeProducts': 42,
                };

          final logs = state is AdminStatsLoaded ? state.recentLogs : <Map<String, dynamic>>[];

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Quick Broadcast & Action Hub Banner
                _buildQuickActionBanner(context),
                const SizedBox(height: 20),

                // Real-time KPI Metric Grid (4 Cards)
                const Text(
                  'REAL-TIME PLATFORM METRICS',
                  style: TextStyle(
                    color: AppColors.adminLightTextSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        title: 'Total Fans',
                        count: '${metrics['totalFans']}',
                        subtext: '+48 this week',
                        icon: Iconsax.people,
                        color: const Color(0xFF2563EB),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildMetricCard(
                        title: 'Published Lore',
                        count: '${metrics['publishedArticles']}',
                        subtext: 'Across 6 fandoms',
                        icon: Iconsax.book_1,
                        color: AppColors.comicRed,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        title: 'Upcoming Events',
                        count: '${metrics['upcomingEvents']}',
                        subtext: 'Tokyo, SDCC, Seoul',
                        icon: Iconsax.radar,
                        color: const Color(0xFFD97706),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildMetricCard(
                        title: 'Store Inventory',
                        count: '${metrics['storeProducts']}',
                        subtext: '4 Low Stock items',
                        icon: Iconsax.shop,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Operations Navigation Grid
                const Text(
                  'MANAGEMENT MODULES',
                  style: TextStyle(
                    color: AppColors.adminLightTextSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 10),
                _buildModuleTile(
                  icon: Iconsax.document_text,
                  title: 'Content & Lore Moderation',
                  subtitle: 'Add, edit, or delete articles, guides & glossary terms',
                  route: '/admin/content',
                  accentColor: AppColors.comicRed,
                ),
                _buildModuleTile(
                  icon: Iconsax.calendar_2,
                  title: 'Convention & Event Radar',
                  subtitle: 'Manage convention schedules, venues, GPS & ticketing',
                  route: '/admin/events',
                  accentColor: const Color(0xFFD97706),
                ),
                _buildModuleTile(
                  icon: Iconsax.box,
                  title: 'Official Merch Management',
                  subtitle: 'Update product prices, stock counters & catalog deals',
                  route: '/admin/products',
                  accentColor: AppColors.success,
                ),
                _buildModuleTile(
                  icon: Iconsax.profile_2user,
                  title: 'User Moderation & Categories',
                  subtitle: 'Inspect fan profiles, ban users & configure categories',
                  route: '/admin/users-categories',
                  accentColor: const Color(0xFF2563EB),
                ),
                const SizedBox(height: 24),

                // Recent Operations Audit Log Strip
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'RECENT AUDIT ACTIVITY',
                      style: TextStyle(
                        color: AppColors.adminLightTextSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                    TextButton(
                      onPressed: () => AdminModals.showAuditLogsSheet(
                        context: context,
                        logs: logs,
                      ),
                      child: const Text('View All', style: TextStyle(color: Color(0xFF2563EB), fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                _buildAuditSummary(logs),
                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuickActionBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.adminLightBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Iconsax.flash_1, color: Color(0xFFD97706), size: 20),
              SizedBox(width: 8),
              Text(
                'Quick Operations Hub',
                style: TextStyle(color: AppColors.adminLightTextPrimary, fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildQuickChip(
                  label: '+ New Article',
                  icon: Iconsax.document_text,
                  color: AppColors.comicRed,
                  onTap: () => Navigator.of(context).pushNamed('/admin/content-edit'),
                ),
                const SizedBox(width: 8),
                _buildQuickChip(
                  label: '+ New Event',
                  icon: Iconsax.location_add,
                  color: const Color(0xFFD97706),
                  onTap: () => Navigator.of(context).pushNamed('/admin/event-edit'),
                ),
                const SizedBox(width: 8),
                _buildQuickChip(
                  label: '+ New Product',
                  icon: Iconsax.add_square,
                  color: AppColors.success,
                  onTap: () => Navigator.of(context).pushNamed('/admin/product-edit'),
                ),
                const SizedBox(width: 8),
                _buildQuickChip(
                  label: 'Push Alert',
                  icon: Iconsax.notification_bing,
                  color: const Color(0xFF2563EB),
                  onTap: () {
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
                            backgroundColor: AppColors.success,
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickChip({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String count,
    required String subtext,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.adminLightBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
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
              Text(title, style: const TextStyle(color: AppColors.adminLightTextSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            count,
            style: const TextStyle(color: AppColors.adminLightTextPrimary, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Text(subtext, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildModuleTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required String route,
    required Color accentColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () => Navigator.of(context).pushNamed(route),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.adminLightBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: accentColor, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(color: AppColors.adminLightTextPrimary, fontSize: 13, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: const TextStyle(color: AppColors.adminLightTextSecondary, fontSize: 11)),
                  ],
                ),
              ),
              const Icon(Iconsax.arrow_right_1, color: AppColors.adminLightTextMuted, size: 14),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAuditSummary(List<Map<String, dynamic>> logs) {
    if (logs.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.adminLightBorder),
        ),
        child: const Center(
          child: Text('No recent operations logged.', style: TextStyle(color: AppColors.adminLightTextSecondary, fontSize: 12)),
        ),
      );
    }

    final top3 = logs.take(3).toList();
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.adminLightBorder),
      ),
      child: Column(
        children: top3.map((l) {
          return ListTile(
            dense: true,
            leading: const Icon(Iconsax.activity, color: Color(0xFF2563EB), size: 16),
            title: Text(l['description'] ?? '', style: const TextStyle(color: AppColors.adminLightTextPrimary, fontSize: 12, fontWeight: FontWeight.w600)),
            subtitle: Text(l['admin_email'] ?? '', style: const TextStyle(color: AppColors.adminLightTextSecondary, fontSize: 10)),
          );
        }).toList(),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // FIRESTORE SEED DIALOG (Light Theme)
  // ─────────────────────────────────────────────────────────────────────────

  void _showSeedDialog(BuildContext ctx) {
    showDialog(
      context: ctx,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Iconsax.cloud_notif, color: Color(0xFF2563EB)),
            SizedBox(width: 10),
            Text('Seed Firestore Database',
                style: TextStyle(color: AppColors.adminLightTextPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          'This will populate all Firestore collections with:\n\n'
          '• 6 Fandom Categories\n'
          '• 2 User Accounts (Admin + Fan)\n'
          '• 8 Lore Posts & News Articles\n'
          '• 8 Glossary Terms\n'
          '• 3 Convention Events\n'
          '• 8 Store Products\n'
          '• 5 Community Discussions\n'
          '• 6 Star Profiles\n'
          '• 2 Demo Orders\n'
          '• 3 Audit Logs\n\n'
          'Firebase Auth accounts will also be created.\n'
          'Existing documents will be merged (safe).',
          style: TextStyle(color: AppColors.adminLightTextSecondary, fontSize: 12, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Cancel', style: TextStyle(color: AppColors.adminLightTextSecondary)),
          ),
          SkewedButton(
            text: 'Seed Now',
            icon: Iconsax.send_2,
            height: 44,
            fontSize: 12,
            backgroundColor: const Color(0xFF2563EB),
            textColor: Colors.white,
            onPressed: () async {
              Navigator.of(dialogCtx).pop();
              await _runSeeding(ctx);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _runSeeding(BuildContext ctx) async {
    // Show loading overlay
    showDialog(
      context: ctx,
      barrierDismissible: false,
      builder: (_) => const PopScope(
        canPop: false,
        child: Center(
          child: Card(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: Color(0xFF2563EB)),
                  SizedBox(height: 20),
                  Text(
                    'Seeding Firestore...',
                    style: TextStyle(color: AppColors.adminLightTextPrimary, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Creating collections & Auth accounts',
                    style: TextStyle(color: AppColors.adminLightTextSecondary, fontSize: 11),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    final result = await FirestoreSeeder.seedAll();

    // Close loading dialog
    if (ctx.mounted) Navigator.of(ctx, rootNavigator: true).pop();

    if (!ctx.mounted) return;

    final success = result['success'] as bool? ?? false;
    final message = result['message'] as String? ?? 'Done';
    final count = result['count'] as int? ?? 0;

    ScaffoldMessenger.of(ctx).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              success ? Iconsax.tick_circle : Iconsax.close_circle,
              color: Colors.white,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                success ? '✅ $count documents seeded! Refresh Firestore Console.' : '❌ $message',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: success ? AppColors.success : AppColors.error,
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
      ),
    );

    if (success) {
      if (ctx.mounted) {
        ctx.read<AdminBloc>().add(const LoadAdminDashboardStatsEvent());
      }
    }
  }
}
