import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/skewed_button.dart';
import '../../../../core/widgets/skeleton_loader.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../bloc/admin_bloc.dart';
import '../bloc/admin_event.dart';
import '../bloc/admin_state.dart';
import '../widgets/admin_image_picker_field.dart';
import '../widgets/admin_modals.dart';

class AdminUsersCategoriesPage extends StatefulWidget {
  final bool isEmbedded;
  const AdminUsersCategoriesPage({super.key, this.isEmbedded = false});

  @override
  State<AdminUsersCategoriesPage> createState() => _AdminUsersCategoriesPageState();
}

class _AdminUsersCategoriesPageState extends State<AdminUsersCategoriesPage> {
  final _searchUserCtrl = TextEditingController();
  String _selectedUserFilter = 'All';
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    context.read<AdminBloc>().add(const LoadAdminDashboardStatsEvent());
  }

  @override
  void dispose() {
    _searchUserCtrl.dispose();
    super.dispose();
  }

  void _showAddUserDialog() {
    _showUserDialog(existingUser: null);
  }

  void _showEditUserDialog(Map<String, dynamic> user) {
    _showUserDialog(existingUser: user);
  }

  void _showUserDialog({Map<String, dynamic>? existingUser}) {
    final isEdit = existingUser != null;
    final nameCtrl = TextEditingController(text: isEdit ? existingUser['name'] ?? '' : '');
    final emailCtrl = TextEditingController(text: isEdit ? existingUser['email'] ?? '' : '');
    final passCtrl = TextEditingController();
    final bioCtrl = TextEditingController(text: isEdit ? existingUser['bio'] ?? '' : '');
    String role = isEdit ? (existingUser['role'] ?? 'fan') : 'fan';
    String status = isEdit ? (existingUser['status'] ?? 'active') : 'active';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: [
                Icon(
                  isEdit ? Iconsax.user_edit : Iconsax.user_add,
                  color: AppColors.comicRed,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  isEdit ? 'Edit User Profile' : 'Register New User',
                  style: const TextStyle(
                    color: AppColors.adminLightTextPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomTextField(
                    controller: nameCtrl,
                    label: 'Full Name',
                    hintText: 'e.g. Peter Parker',
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: emailCtrl,
                    label: 'Email Address',
                    hintText: 'e.g. peter@dailybugle.com',
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: passCtrl,
                    label: isEdit ? 'New Password (Optional)' : 'Password',
                    hintText: isEdit ? 'Leave blank to keep existing' : 'Minimum 6 characters (default: 123456)',
                    obscureText: true,
                  ),
                  const SizedBox(height: 12),
                  const Text('Account Role', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF374151))),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: role,
                        isExpanded: true,
                        items: const [
                          DropdownMenuItem(value: 'fan', child: Text('Fan (Standard User)')),
                          DropdownMenuItem(value: 'admin', child: Text('Admin (Administrator)')),
                        ],
                        onChanged: (val) {
                          if (val != null) setDialogState(() => role = val);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text('Account Status', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF374151))),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: status,
                        isExpanded: true,
                        items: const [
                          DropdownMenuItem(value: 'active', child: Text('Active')),
                          DropdownMenuItem(value: 'banned', child: Text('Suspended / Banned')),
                        ],
                        onChanged: (val) {
                          if (val != null) setDialogState(() => status = val);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: bioCtrl,
                    label: 'Bio / Notes (Optional)',
                    hintText: 'Favorite superhero, bio snippet...',
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancel', style: TextStyle(color: AppColors.adminLightTextSecondary)),
              ),
              SkewedButton(
                text: isEdit ? 'Save Changes' : 'Create User',
                height: 42,
                fontSize: 12,
                backgroundColor: AppColors.comicRed,
                icon: isEdit ? Iconsax.tick_circle : Iconsax.user_add,
                onPressed: () {
                  final name = nameCtrl.text.trim();
                  final email = emailCtrl.text.trim();
                  if (name.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter a name'), backgroundColor: AppColors.error),
                    );
                    return;
                  }
                  if (email.isEmpty || !email.contains('@')) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter a valid email address'), backgroundColor: AppColors.error),
                    );
                    return;
                  }

                  if (isEdit) {
                    final updatedUser = Map<String, dynamic>.from(existingUser);
                    updatedUser['name'] = name;
                    updatedUser['email'] = email;
                    updatedUser['role'] = role;
                    updatedUser['status'] = status;
                    updatedUser['bio'] = bioCtrl.text.trim();
                    context.read<AdminBloc>().add(UpdateUserEvent(
                          updatedUser,
                          newPassword: passCtrl.text.trim().isNotEmpty ? passCtrl.text.trim() : null,
                        ));
                    Navigator.of(ctx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Updated user "$name"!'), backgroundColor: AppColors.success),
                    );
                  } else {
                    final newUser = {
                      'user_id': 'user_${DateTime.now().millisecondsSinceEpoch}',
                      'name': name,
                      'email': email,
                      'role': role,
                      'status': status,
                      'bio': bioCtrl.text.trim(),
                    };
                    context.read<AdminBloc>().add(CreateUserEvent(
                          newUser,
                          password: passCtrl.text.trim().isNotEmpty ? passCtrl.text.trim() : '123456',
                        ));
                    Navigator.of(ctx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Created user "$name"!'), backgroundColor: AppColors.success),
                    );
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }

  void _confirmDeleteUser(Map<String, dynamic> user) {
    final userName = user['name'] ?? 'User';
    final userEmail = user['email'] ?? '';
    final userId = user['user_id'];

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Iconsax.trash, color: AppColors.error, size: 20),
            SizedBox(width: 8),
            Text('Delete User', style: TextStyle(color: Color(0xFF111216), fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          'Are you sure you want to permanently delete "$userName" ($userEmail)? This action cannot be reversed.',
          style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF6B7280))),
          ),
          SkewedButton(
            text: 'Delete',
            height: 40,
            fontSize: 12,
            backgroundColor: AppColors.error,
            textColor: Colors.white,
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<AdminBloc>().add(DeleteUserEvent(userId));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('User "$userName" deleted'), backgroundColor: AppColors.comicRed),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showAddCategoryDialog() {
    _showCategoryDialog(existingCategory: null);
  }

  void _showCategoryDialog({Map<String, dynamic>? existingCategory}) {
    final isEdit = existingCategory != null;
    final nameCtrl = TextEditingController(text: isEdit ? existingCategory['name'] ?? '' : '');
    final descCtrl = TextEditingController(text: isEdit ? existingCategory['description'] ?? '' : '');
    final colorCtrl = TextEditingController(text: isEdit ? existingCategory['color_hex'] ?? '#7C4DFF' : '#7C4DFF');
    String bannerPathOrUrl = isEdit
        ? (existingCategory['banner_url'] ?? 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=800')
        : 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=800';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text(
              isEdit ? 'Edit Fandom Category' : 'Add Fandom Pillar Category',
              style: const TextStyle(color: AppColors.adminLightTextPrimary, fontSize: 16, fontWeight: FontWeight.bold),
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
                    cloudinaryFolder: 'fandom_verse/categories',
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
              SkewedButton(
                text: isEdit ? 'Save Changes' : 'Add Category',
                height: 44,
                fontSize: 12,
                backgroundColor: AppColors.comicRed,
                icon: isEdit ? Iconsax.edit : Iconsax.add,
                onPressed: () {
                  final name = nameCtrl.text.trim();
                  if (name.isNotEmpty) {
                    if (isEdit) {
                      final catData = Map<String, dynamic>.from(
                          existingCategory);
                      catData['name'] = name;
                      catData['description'] = descCtrl.text.trim();
                      catData['banner_url'] = bannerPathOrUrl.trim();
                      catData['color_hex'] = colorCtrl.text.trim();
                      context.read<AdminBloc>().add(UpdateCategoryEvent(catData));
                      Navigator.of(ctx).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Updated category "$name"!'), backgroundColor: AppColors.success),
                      );
                    } else {
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
                  }
                },
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
        automaticallyImplyLeading: !widget.isEmbedded,
        leading: widget.isEmbedded
            ? null
            : IconButton(
                icon: const Icon(Iconsax.arrow_left, color: AppColors.adminLightTextPrimary, size: 20),
                onPressed: () => Navigator.of(context).pop(),
              ),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.refresh, color: AppColors.comicRed, size: 20),
            tooltip: 'Sync Users from Database',
            onPressed: () {
              context.read<AdminBloc>().add(const LoadAdminDashboardStatsEvent());
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('⚡ Syncing users from database...'),
                  duration: Duration(milliseconds: 1000),
                  backgroundColor: AppColors.comicRed,
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildHeaderTabItem(
                      icon: Iconsax.people,
                      label: 'Registered Fans',
                      isSelected: _selectedTab == 0,
                      onTap: () => setState(() => _selectedTab = 0),
                    ),
                  ),
                  Expanded(
                    child: _buildHeaderTabItem(
                      icon: Iconsax.category,
                      label: 'Fandom Categories',
                      isSelected: _selectedTab == 1,
                      onTap: () => setState(() => _selectedTab = 1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: BlocBuilder<AdminBloc, AdminState>(
        builder: (context, state) {
          if (state is AdminLoading) {
            return const SkeletonAdminListPage();
          }

          if (state is AdminError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Iconsax.warning_2, size: 48, color: AppColors.comicRed),
                    const SizedBox(height: 12),
                    Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppColors.adminLightTextSecondary, fontSize: 13),
                    ),
                    const SizedBox(height: 16),
                    SkewedButton(
                      text: 'Retry Loading Users',
                      icon: Iconsax.refresh,
                      backgroundColor: AppColors.comicRed,
                      textColor: Colors.white,
                      onPressed: () => context.read<AdminBloc>().add(const LoadAdminDashboardStatsEvent()),
                    ),
                  ],
                ),
              ),
            );
          }

          final users = state is AdminStatsLoaded ? state.users : <Map<String, dynamic>>[];
          final categories = state is AdminStatsLoaded ? state.categories : <Map<String, dynamic>>[];

          return _selectedTab == 0
              ? _buildUsersTab(users)
              : _buildCategoriesTab(categories);
        },
      ),
    );
  }

  Widget _buildHeaderTabItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 15,
              color: isSelected ? AppColors.comicRed : AppColors.adminLightTextSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? AppColors.comicRed : AppColors.adminLightTextSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsersTab(List<Map<String, dynamic>> users) {
    final query = _searchUserCtrl.text.trim().toLowerCase();

    final filteredUsers = users.where((u) {
      final name = (u['name'] ?? '').toString().toLowerCase();
      final email = (u['email'] ?? '').toString().toLowerCase();
      final role = (u['role'] ?? 'fan').toString().toLowerCase();
      final status = (u['status'] ?? 'active').toString().toLowerCase();

      final matchesQuery = query.isEmpty ||
          name.contains(query) ||
          email.contains(query) ||
          role.contains(query);

      if (!matchesQuery) return false;

      switch (_selectedUserFilter) {
        case 'Active':
          return status == 'active';
        case 'Suspended':
          return status == 'banned';
        case 'Admin':
          return role == 'admin';
        case 'Fan':
          return role == 'fan';
        default:
          return true;
      }
    }).toList();

    final activeCount = users.where((u) => u['status'] != 'banned').length;
    final suspendedCount = users.where((u) => u['status'] == 'banned').length;

    return RefreshIndicator(
      color: AppColors.comicRed,
      onRefresh: () async {
        context.read<AdminBloc>().add(const LoadAdminDashboardStatsEvent());
        await Future.delayed(const Duration(milliseconds: 600));
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(16, 16, 16, widget.isEmbedded ? 100 : 32),
        children: [
        // ── Search & Filter Bar ──
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.adminLightBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(Iconsax.search_normal_1, size: 18, color: AppColors.adminLightTextSecondary),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _searchUserCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Search users by name, email, or role...',
                    hintStyle: TextStyle(fontSize: 13, color: AppColors.adminLightTextSecondary),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                  style: const TextStyle(fontSize: 13, color: AppColors.adminLightTextPrimary),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              if (_searchUserCtrl.text.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.close, size: 16, color: AppColors.adminLightTextSecondary),
                  onPressed: () {
                    _searchUserCtrl.clear();
                    setState(() {});
                  },
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // ── Filter Chips Row ──
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildFilterChip('All (${users.length})', 'All'),
              const SizedBox(width: 8),
              _buildFilterChip('Active ($activeCount)', 'Active'),
              const SizedBox(width: 8),
              _buildFilterChip('Suspended ($suspendedCount)', 'Suspended'),
              const SizedBox(width: 8),
              _buildFilterChip('Admins', 'Admin'),
              const SizedBox(width: 8),
              _buildFilterChip('Fans', 'Fan'),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // ── Header with Actions ──
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Showing ${filteredUsers.length} of ${users.length} users',
              style: const TextStyle(
                color: AppColors.adminLightTextSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            SkewedButton(
              text: '+ Add User',
              icon: Iconsax.user_add,
              height: 38,
              fontSize: 11,
              backgroundColor: AppColors.comicRed,
              textColor: Colors.white,
              onPressed: _showAddUserDialog,
            ),
          ],
        ),
        const SizedBox(height: 14),

        // ── Users List ──
        if (filteredUsers.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.adminLightBorder),
            ),
            child: Column(
              children: [
                const Icon(Iconsax.user_search, size: 40, color: AppColors.adminLightTextSecondary),
                const SizedBox(height: 12),
                const Text(
                  'No users found',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.adminLightTextPrimary),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Try adjusting your search or filter criteria',
                  style: TextStyle(fontSize: 12, color: AppColors.adminLightTextSecondary),
                ),
                const SizedBox(height: 16),
                SkewedButton(
                  text: 'Register New User',
                  icon: Iconsax.user_add,
                  height: 36,
                  fontSize: 11,
                  backgroundColor: AppColors.comicRed,
                  textColor: Colors.white,
                  onPressed: _showAddUserDialog,
                ),
              ],
            ),
          )
        else
          ...filteredUsers.map((u) {
            final isBanned = u['status'] == 'banned';
            final isAdmin = u['role'] == 'admin';
            final bio = u['bio'] as String?;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isBanned
                      ? AppColors.error.withValues(alpha: 0.3)
                      : AppColors.adminLightBorder,
                  width: isBanned ? 1.2 : 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Avatar
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: isAdmin
                            ? AppColors.comicRed.withValues(alpha: 0.12)
                            : const Color(0xFF6B7280).withValues(alpha: 0.1),
                        child: Text(
                          ((u['name'] ?? 'Fan').toString().trim().isNotEmpty
                                  ? (u['name'] ?? 'Fan').toString().trim()[0]
                                  : 'F')
                              .toUpperCase(),
                          style: TextStyle(
                            color: isAdmin ? AppColors.comicRed : const Color(0xFF374151),
                            fontWeight: FontWeight.w900,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // User Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    u['name'] ?? '',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: AppColors.adminLightTextPrimary,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14,
                                    ),
                                  ),
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
                                      fontSize: 8.5,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              u['email'] ?? '',
                              style: const TextStyle(
                                color: AppColors.adminLightTextSecondary,
                                fontSize: 11.5,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Role Tag
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isAdmin ? AppColors.comicRed : const Color(0xFFF3F4F6),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isAdmin ? AppColors.comicRed : const Color(0xFFE5E7EB),
                          ),
                        ),
                        child: Text(
                          (u['role'] ?? 'fan').toUpperCase(),
                          style: TextStyle(
                            color: isAdmin ? Colors.white : const Color(0xFF4B5563),
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Bio if present
                  if (bio != null && bio.trim().isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        bio,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF4B5563),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],

                  const Divider(height: 18, color: Color(0xFFF3F4F6)),

                  // ── Action Buttons Row ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Edit Button
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF374151),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          visualDensity: VisualDensity.compact,
                        ),
                        icon: const Icon(Iconsax.edit_2, size: 15),
                        label: const Text('Edit', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                        onPressed: () => _showEditUserDialog(u),
                      ),
                      const SizedBox(width: 4),

                      // Suspend / Unban Toggle Button
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          foregroundColor: isBanned ? AppColors.success : AppColors.comicRed,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          visualDensity: VisualDensity.compact,
                        ),
                        icon: Icon(isBanned ? Iconsax.user_tick : Iconsax.user_minus, size: 15),
                        label: Text(
                          isBanned ? 'Unban' : 'Suspend',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                        onPressed: () {
                          final newStatus = isBanned ? 'active' : 'banned';
                          context.read<AdminBloc>().add(
                                ToggleUserStatusEvent(u['user_id'], newStatus),
                              );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(isBanned ? 'User "${u['name']}" unbanned' : 'User "${u['name']}" suspended'),
                              backgroundColor: isBanned ? AppColors.success : AppColors.comicRed,
                              duration: const Duration(milliseconds: 1500),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 4),

                      // Delete Button
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.error,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          visualDensity: VisualDensity.compact,
                        ),
                        icon: const Icon(Iconsax.trash, size: 15),
                        label: const Text('Delete', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                        onPressed: () => _confirmDeleteUser(u),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
      ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedUserFilter == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedUserFilter = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.comicRed : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.comicRed : const Color(0xFFE5E7EB),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF4B5563),
          ),
        ),
      ),
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
              final catColor = Color(
                int.tryParse((cat['color_hex'] ?? '#7C4DFF').replaceAll('#', '0xFF')) ?? 0xFF7C4DFF,
              );
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
                        color: catColor,
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
                            style: const TextStyle(
                              color: AppColors.adminLightTextPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            cat['description'] ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.adminLightTextSecondary,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Edit button
                    IconButton(
                      icon: const Icon(Iconsax.edit_2, color: AppColors.comicRed, size: 18),
                      tooltip: 'Edit Category',
                      onPressed: () => _showCategoryDialog(existingCategory: cat),
                    ),
                    // Delete button
                    IconButton(
                      icon: const Icon(Iconsax.trash, color: AppColors.error, size: 18),
                      tooltip: 'Delete Category',
                      onPressed: () {
                        AdminModals.showDeleteBarrierDialog(
                          context: context,
                          itemName: cat['name'] ?? 'Category',
                          onConfirmed: () {
                            context.read<AdminBloc>().add(
                                  DeleteCategoryEvent(cat['category_id'] ?? ''),
                                );
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Deleted "${cat['name']}"'),
                                backgroundColor: AppColors.error,
                              ),
                            );
                          },
                        );
                      },
                    ),
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
