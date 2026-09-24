import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/firestore_seeder.dart';
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
      backgroundColor: const Color(0xFF090C12), // High-security dark console theme
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(10),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.darkPrimary.withValues(alpha: 0.2),
              border: Border.all(color: AppColors.darkPrimary),
            ),
            child: const Center(
              child: Icon(Icons.security_rounded, size: 16, color: AppColors.darkPrimary),
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
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  '$adminEmail • $adminName',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 10),
                ),
              ],
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.refresh, color: Colors.white70, size: 20),
            tooltip: 'Refresh Metrics',
            onPressed: () => context.read<AdminBloc>().add(const LoadAdminDashboardStatsEvent()),
          ),
          // ── Seed Firestore Button ──
          IconButton(
            icon: const Icon(Iconsax.cloud_connection, color: AppColors.darkSecondary, size: 20),
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
            return const Center(child: CircularProgressIndicator(color: AppColors.darkSecondary));
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Quick Broadcast & Action Hub Banner
                _buildQuickActionBanner(context),
                const SizedBox(height: 20),

                // Real-time KPI Metric Grid (4 Cards)
                Text(
                  'REAL-TIME PLATFORM METRICS',
                  style: TextStyle(
                    color: AppColors.darkSecondary.withValues(alpha: 0.9),
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
                        icon: Icons.people_alt_rounded,
                        color: AppColors.darkSecondary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildMetricCard(
                        title: 'Published Lore',
                        count: '${metrics['publishedArticles']}',
                        subtext: 'Across 6 fandoms',
                        icon: Icons.auto_stories_rounded,
                        color: AppColors.darkPrimary,
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
                        icon: Icons.radar_rounded,
                        color: AppColors.darkAccentGold,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildMetricCard(
                        title: 'Store Inventory',
                        count: '${metrics['storeProducts']}',
                        subtext: '4 Low Stock items',
                        icon: Icons.storefront_rounded,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Operations Navigation Grid
                Text(
                  'MANAGEMENT MODULES',
                  style: TextStyle(
                    color: AppColors.darkSecondary.withValues(alpha: 0.9),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 10),
                _buildModuleTile(
                  icon: Icons.article_rounded,
                  title: 'Content & Lore Moderation',
                  subtitle: 'Add, edit, or delete articles, guides & glossary terms',
                  route: '/admin/content',
                  accentColor: AppColors.darkPrimary,
                ),
                _buildModuleTile(
                  icon: Icons.event_available_rounded,
                  title: 'Convention & Event Radar',
                  subtitle: 'Manage convention schedules, venues, GPS & ticketing',
                  route: '/admin/events',
                  accentColor: AppColors.darkAccentGold,
                ),
                _buildModuleTile(
                  icon: Icons.inventory_2_rounded,
                  title: 'Official Merch Management',
                  subtitle: 'Update product prices, stock counters & catalog deals',
                  route: '/admin/products',
                  accentColor: AppColors.success,
                ),
                _buildModuleTile(
                  icon: Icons.manage_accounts_rounded,
                  title: 'User Moderation & Categories',
                  subtitle: 'Inspect fan profiles, ban users & configure categories',
                  route: '/admin/users-categories',
                  accentColor: AppColors.darkSecondary,
                ),
                const SizedBox(height: 24),

                // Recent Operations Audit Log Strip
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'RECENT AUDIT ACTIVITY',
                      style: TextStyle(
                        color: AppColors.darkSecondary.withValues(alpha: 0.9),
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
                      child: const Text('View All', style: TextStyle(color: AppColors.darkSecondary, fontSize: 12)),
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
        color: const Color(0xFF131722),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.bolt_rounded, color: AppColors.darkAccentGold, size: 20),
              SizedBox(width: 8),
              Text(
                'Quick Operations Hub',
                style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
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
                  icon: Icons.post_add_rounded,
                  color: AppColors.darkPrimary,
                  onTap: () => Navigator.of(context).pushNamed('/admin/content-edit'),
                ),
                const SizedBox(width: 8),
                _buildQuickChip(
                  label: '+ New Event',
                  icon: Icons.add_location_alt_rounded,
                  color: AppColors.darkAccentGold,
                  onTap: () => Navigator.of(context).pushNamed('/admin/event-edit'),
                ),
                const SizedBox(width: 8),
                _buildQuickChip(
                  label: '+ New Product',
                  icon: Icons.add_box_rounded,
                  color: AppColors.success,
                  onTap: () => Navigator.of(context).pushNamed('/admin/product-edit'),
                ),
                const SizedBox(width: 8),
                _buildQuickChip(
                  label: 'Push Alert',
                  icon: Icons.campaign_rounded,
                  color: AppColors.darkSecondary,
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
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.4)),
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
        color: const Color(0xFF131722),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(color: Colors.white60, fontSize: 11)),
              Icon(icon, color: color, size: 18),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            count,
            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Text(subtext, style: TextStyle(color: color.withValues(alpha: 0.8), fontSize: 10)),
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
            color: const Color(0xFF131722),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white10),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: accentColor, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: const TextStyle(color: Colors.white60, fontSize: 11)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white30, size: 14),
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
          color: const Color(0xFF131722),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Center(
          child: Text('No recent operations logged.', style: TextStyle(color: Colors.white38, fontSize: 12)),
        ),
      );
    }

    final top3 = logs.take(3).toList();
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF131722),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: top3.map((l) {
          return ListTile(
            dense: true,
        leading: const Icon(Icons.commit_rounded, color: AppColors.darkSecondary, size: 16),
            title: Text(l['description'] ?? '', style: const TextStyle(color: Colors.white, fontSize: 11)),
            subtitle: Text(l['admin_email'] ?? '', style: const TextStyle(color: Colors.white38, fontSize: 9)),
          );
        }).toList(),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // FIRESTORE SEED DIALOG
  // ─────────────────────────────────────────────────────────────────────────

  void _showSeedDialog(BuildContext ctx) {
    showDialog(
      context: ctx,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: const Color(0xFF131722),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.cloud_upload_rounded, color: AppColors.darkSecondary),
            SizedBox(width: 10),
            Text('Seed Firestore Database',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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
          style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.darkSecondary,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            icon: const Icon(Icons.rocket_launch_rounded, size: 16),
            label: const Text('Seed Now', style: TextStyle(fontWeight: FontWeight.bold)),
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
            color: Color(0xFF131722),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: AppColors.darkSecondary),
                  SizedBox(height: 20),
                  Text(
                    'Seeding Firestore...',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Creating collections & Auth accounts',
                    style: TextStyle(color: Colors.white54, fontSize: 11),
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
              success ? Icons.check_circle_rounded : Icons.error_rounded,
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
      // Reload metrics
      if (ctx.mounted) {
        ctx.read<AdminBloc>().add(const LoadAdminDashboardStatsEvent());
      }
    }
  }
}

