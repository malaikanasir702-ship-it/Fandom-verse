import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../bloc/admin_bloc.dart';
import '../bloc/admin_event.dart';
import '../bloc/admin_state.dart';

class AdminUsersCategoriesPage extends StatefulWidget {
  const AdminUsersCategoriesPage({super.key});

  @override
  State<AdminUsersCategoriesPage> createState() => _AdminUsersCategoriesPageState();
}

class _AdminUsersCategoriesPageState extends State<AdminUsersCategoriesPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<AdminBloc>().add(const LoadAdminDashboardStatsEvent());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddCategoryDialog() {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final colorCtrl = TextEditingController(text: '#7C4DFF');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF161B26),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Add Fandom Pillar Category', style: TextStyle(color: Colors.white, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomTextField(
              controller: nameCtrl,
              label: 'Category Name',
              hintText: 'e.g. Tabletop & D&D Lore',
            ),
            const SizedBox(height: 10),
            CustomTextField(
              controller: descCtrl,
              label: 'Description',
              hintText: 'Campaign books, miniature painting, dice rolls...',
            ),
            const SizedBox(height: 10),
            CustomTextField(
              controller: colorCtrl,
              label: 'Hex Color Accent',
              hintText: '#7C4DFF',
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.darkPrimary),
            onPressed: () {
              final name = nameCtrl.text.trim();
              if (name.isNotEmpty) {
                final catData = {
                  'category_id': 'cat_${name.toLowerCase().replaceAll(' ', '_')}',
                  'name': name,
                  'description': descCtrl.text.trim(),
                  'icon_name': 'auto_awesome',
                  'banner_url': 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=800',
                  'color_hex': colorCtrl.text.trim(),
                };
                context.read<AdminBloc>().add(CreateCategoryEvent(catData));
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Created category "$name"!'), backgroundColor: AppColors.success),
                );
              }
            },
            child: const Text('Add Category', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090C12),
      appBar: AppBar(
        title: const Text('User & Category Moderation', style: TextStyle(color: Colors.white, fontSize: 16)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white70, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.darkSecondary,
          labelColor: AppColors.darkSecondary,
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(icon: Icon(Icons.people_alt_rounded, size: 18), text: 'Registered Fans'),
            Tab(icon: Icon(Icons.category_rounded, size: 18), text: 'Fandom Categories'),
          ],
        ),
      ),
      body: BlocBuilder<AdminBloc, AdminState>(
        builder: (context, state) {
          if (state is AdminLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.darkSecondary));
          }

          final users = state is AdminStatsLoaded ? state.users : <Map<String, dynamic>>[];
          final categories = state is AdminStatsLoaded ? state.categories : <Map<String, dynamic>>[];

          return TabBarView(
            controller: _tabController,
            children: [
              // Tab 1: Fans Moderation
              _buildUsersTab(users),

              // Tab 2: Category Management
              _buildCategoriesTab(categories),
            ],
          );
        },
      ),
    );
  }

  Widget _buildUsersTab(List<Map<String, dynamic>> users) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: users.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final u = users[index];
        final isBanned = u['status'] == 'banned';

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFF131722),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isBanned ? AppColors.error.withValues(alpha: 0.4) : Colors.white10,
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.darkPrimary.withValues(alpha: 0.2),
                child: Text(
                  (u['name'] ?? 'F')[0].toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          u['name'] ?? '',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isBanned
                                ? AppColors.error.withValues(alpha: 0.2)
                                : AppColors.success.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            isBanned ? 'SUSPENDED' : 'ACTIVE',
                            style: TextStyle(
                              color: isBanned ? AppColors.error : AppColors.success,
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(u['email'] ?? '', style: const TextStyle(color: Colors.white60, fontSize: 11)),
                    const SizedBox(height: 2),
                    Text(
                      'Role: ${(u['role'] ?? 'fan').toUpperCase()}',
                      style: const TextStyle(color: AppColors.darkSecondary, fontSize: 10),
                    ),
                  ],
                ),
              ),
              if (u['role'] != 'admin')
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: isBanned ? AppColors.success : AppColors.error,
                  ),
                  onPressed: () {
                    final newStatus = isBanned ? 'active' : 'banned';
                    context.read<AdminBloc>().add(
                          ToggleUserStatusEvent(u['user_id'], newStatus),
                        );
                  },
                  child: Text(isBanned ? 'Unban' : 'Suspend', style: const TextStyle(fontSize: 11)),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoriesTab(List<Map<String, dynamic>> categories) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${categories.length} Fandom Pillars Configured',
                style: const TextStyle(color: Colors.white60, fontSize: 12),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkPrimary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                icon: const Icon(Icons.add, size: 16, color: Colors.white),
                label: const Text('Add Pillar', style: TextStyle(color: Colors.white, fontSize: 11)),
                onPressed: _showAddCategoryDialog,
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final cat = categories[index];
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF131722),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Color(int.tryParse((cat['color_hex'] ?? '#7C4DFF').replaceAll('#', '0xFF')) ?? 0xFF7C4DFF),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cat['name'] ?? '',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            cat['description'] ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white60, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.check_circle_outline, color: AppColors.success, size: 18),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
