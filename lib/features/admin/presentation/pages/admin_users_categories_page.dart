import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/skewed_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../bloc/admin_bloc.dart';
import '../bloc/admin_event.dart';
import '../bloc/admin_state.dart';
import '../widgets/admin_image_picker_field.dart';

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
    String bannerPathOrUrl = 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=800';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text(
              'Add Fandom Pillar Category',
              style: TextStyle(color: AppColors.adminLightTextPrimary, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomTextField(
                    controller: nameCtrl,
                    label: 'Category Name',
                    hintText: 'e.g. Tabletop & D&D Lore',
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: descCtrl,
                    label: 'Description',
                    hintText: 'Campaign books, miniature painting, dice rolls...',
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: colorCtrl,
                    label: 'Hex Color Accent',
                    hintText: '#7C4DFF',
                  ),
                  const SizedBox(height: 12),
                  AdminImagePickerField(
                    label: 'Category Banner Image',
                    helperText: 'Pick from your mobile gallery or camera',
                    previewHeight: 120,
                    initialImagePathOrUrl: bannerPathOrUrl,
                    onImageSelected: (path) {
                      setDialogState(() {
                        bannerPathOrUrl = path;
                      });
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancel', style: TextStyle(color: AppColors.adminLightTextSecondary)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.comicRed,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  final name = nameCtrl.text.trim();
                  if (name.isNotEmpty) {
                    final catData = {
                      'category_id': 'cat_${name.toLowerCase().replaceAll(' ', '_')}',
                      'name': name,
                      'description': descCtrl.text.trim(),
                      'icon_name': 'auto_awesome',
                      'banner_url': bannerPathOrUrl.trim(),
                      'color_hex': colorCtrl.text.trim(),
                    };
                    context.read<AdminBloc>().add(CreateCategoryEvent(catData));
                    Navigator.of(ctx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Created category "$name"!'), backgroundColor: AppColors.success),
                    );
                  }
                },
                child: const Text('Add Category', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.adminLightBackground,
      appBar: AppBar(
        title: const Text(
          'User & Category Moderation',
          style: TextStyle(
            color: AppColors.adminLightTextPrimary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        scrolledUnderElevation: 1,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left, color: AppColors.adminLightTextPrimary, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.comicRed,
          labelColor: AppColors.comicRed,
          unselectedLabelColor: AppColors.adminLightTextSecondary,
          tabs: const [
            Tab(icon: Icon(Iconsax.people, size: 18), text: 'Registered Fans'),
            Tab(icon: Icon(Iconsax.category, size: 18), text: 'Fandom Categories'),
          ],
        ),
      ),
      body: BlocBuilder<AdminBloc, AdminState>(
        builder: (context, state) {
          if (state is AdminLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.comicRed));
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
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isBanned ? AppColors.error.withValues(alpha: 0.4) : AppColors.adminLightBorder,
            ),
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
              CircleAvatar(
                backgroundColor: AppColors.comicRed.withValues(alpha: 0.1),
                child: Text(
                  (u['name'] ?? 'F')[0].toUpperCase(),
                  style: const TextStyle(color: AppColors.comicRed, fontWeight: FontWeight.bold),
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
                          style: const TextStyle(color: AppColors.adminLightTextPrimary, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isBanned
                                ? AppColors.error.withValues(alpha: 0.1)
                                : AppColors.success.withValues(alpha: 0.1),
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
                    Text(u['email'] ?? '', style: const TextStyle(color: AppColors.adminLightTextSecondary, fontSize: 11)),
                    const SizedBox(height: 2),
                    Text(
                      'Role: ${(u['role'] ?? 'fan').toUpperCase()}',
                      style: const TextStyle(color: Color(0xFF2563EB), fontSize: 10, fontWeight: FontWeight.w600),
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
                  child: Text(isBanned ? 'Unban' : 'Suspend', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
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
                style: const TextStyle(color: AppColors.adminLightTextSecondary, fontSize: 12, fontWeight: FontWeight.w500),
              ),
              SkewedButton(
                text: '+ Add Pillar',
                icon: Iconsax.add,
                height: 40,
                fontSize: 11,
                backgroundColor: AppColors.comicRed,
                textColor: Colors.white,
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
                            style: const TextStyle(color: AppColors.adminLightTextPrimary, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            cat['description'] ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: AppColors.adminLightTextSecondary, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Iconsax.tick_circle, color: AppColors.success, size: 18),
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
