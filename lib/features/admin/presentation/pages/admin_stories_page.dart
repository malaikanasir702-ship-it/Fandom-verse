import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_display_image.dart';
import '../bloc/admin_bloc.dart';
import '../bloc/admin_event.dart';
import '../bloc/admin_state.dart';
import 'admin_story_edit_page.dart';

class AdminStoriesPage extends StatefulWidget {
  const AdminStoriesPage({super.key});

  @override
  State<AdminStoriesPage> createState() => _AdminStoriesPageState();
}

class _AdminStoriesPageState extends State<AdminStoriesPage> {
  final _searchController = TextEditingController();
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    context.read<AdminBloc>().add(const LoadAdminDashboardStatsEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Color _parseHex(String? hex) {
    if (hex == null || hex.isEmpty) return const Color(0xFFE51924);
    try {
      final clean = hex.replaceAll('#', '').trim();
      if (clean.length == 6) return Color(int.parse('FF$clean', radix: 16));
      if (clean.length == 8) return Color(int.parse(clean, radix: 16));
    } catch (_) {}
    return const Color(0xFFE51924);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.adminLightBackground,
      appBar: AppBar(
        title: const Text(
          'Hero Stories & Lore Manager',
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
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF8B5CF6),
        icon: const Icon(Iconsax.add_circle, color: Colors.white),
        label: const Text('Add Hero Story', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const AdminStoryEditPage(),
            ),
          );
        },
      ),
      body: BlocBuilder<AdminBloc, AdminState>(
        builder: (context, state) {
          if (state is AdminLoading) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF8B5CF6)));
          }

          final allStories = state is AdminStatsLoaded ? state.heroStories : <Map<String, dynamic>>[];

          final query = _searchController.text.toLowerCase().trim();
          final filtered = allStories.where((s) {
            final matchesCat = _selectedCategory == 'All' ||
                (s['category'] ?? '').toString().toLowerCase() == _selectedCategory.toLowerCase();
            final matchesQuery = query.isEmpty ||
                (s['hero_name'] ?? '').toString().toLowerCase().contains(query) ||
                (s['tagline'] ?? '').toString().toLowerCase().contains(query) ||
                (s['origin_backstory'] ?? '').toString().toLowerCase().contains(query);
            return matchesCat && matchesQuery;
          }).toList();

          return Column(
            children: [
              // Search & Filter header
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      onChanged: (_) => setState(() {}),
                      style: const TextStyle(color: AppColors.adminLightTextPrimary, fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'Search hero by name, origin or tagline...',
                        hintStyle: const TextStyle(color: AppColors.adminLightTextSecondary, fontSize: 13),
                        prefixIcon: const Icon(Iconsax.search_normal_1, color: AppColors.adminLightTextSecondary, size: 18),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 16, color: AppColors.adminLightTextSecondary),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {});
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: AppColors.adminLightBackground,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: ['All', 'Marvel', 'DC', 'Anime', 'Sci-Fi', 'Gaming'].map((cat) {
                          final isSelected = _selectedCategory == cat;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(cat),
                              selected: isSelected,
                              selectedColor: const Color(0xFF8B5CF6).withValues(alpha: 0.15),
                              backgroundColor: AppColors.adminLightBackground,
                              labelStyle: TextStyle(
                                color: isSelected ? const Color(0xFF8B5CF6) : AppColors.adminLightTextSecondary,
                                fontSize: 12,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              ),
                              side: BorderSide(
                                color: isSelected ? const Color(0xFF8B5CF6) : AppColors.adminLightBorder,
                              ),
                              onSelected: (_) => setState(() => _selectedCategory = cat),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),

              // Stories List
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Iconsax.story, size: 48, color: Colors.grey.shade400),
                            const SizedBox(height: 12),
                            Text(
                              query.isEmpty ? 'No hero stories registered yet' : 'No heroes match your search',
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final story = filtered[index];
                          final ringColor = _parseHex(story['ring_color_hex']);
                          final heroName = (story['hero_name'] ?? 'Unnamed Hero').toString();
                          final category = (story['category'] ?? 'Marvel').toString();
                          final tagline = (story['tagline'] ?? '').toString();
                          final origin = (story['origin_backstory'] ?? '').toString();
                          final lifeHistory = (story['life_history'] ?? '').toString();
                          final powers = (story['powers_abilities'] ?? '').toString();
                          final avatarUrl = (story['avatar_url'] ?? '').toString();

                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.adminLightBorder),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.03),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Avatar with Hero Story Ring
                                      Container(
                                        padding: const EdgeInsets.all(2.5),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(color: ringColor, width: 2.5),
                                        ),
                                        child: AppDisplayImage(
                                          pathOrUrl: avatarUrl,
                                          width: 50,
                                          height: 50,
                                          borderRadius: BorderRadius.circular(25),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    heroName,
                                                    style: const TextStyle(
                                                      color: AppColors.adminLightTextPrimary,
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                  decoration: BoxDecoration(
                                                    color: ringColor.withValues(alpha: 0.12),
                                                    borderRadius: BorderRadius.circular(6),
                                                  ),
                                                  child: Text(
                                                    category,
                                                    style: TextStyle(
                                                      color: ringColor,
                                                      fontSize: 11,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            if (tagline.isNotEmpty) ...[
                                              const SizedBox(height: 3),
                                              Text(
                                                tagline,
                                                style: const TextStyle(
                                                  color: AppColors.adminLightTextSecondary,
                                                  fontSize: 12,
                                                  fontStyle: FontStyle.italic,
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Divider(height: 20, color: AppColors.adminLightBorder),

                                  // Origin Backstory snippet
                                  if (origin.isNotEmpty) ...[
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          '📖 Origin: ',
                                          style: TextStyle(
                                            color: AppColors.adminLightTextPrimary,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            origin,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              color: AppColors.adminLightTextSecondary,
                                              fontSize: 12,
                                              height: 1.3,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                  ],

                                  // Life history snippet
                                  if (lifeHistory.isNotEmpty) ...[
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          '📜 Lore: ',
                                          style: TextStyle(
                                            color: AppColors.adminLightTextPrimary,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            lifeHistory,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              color: AppColors.adminLightTextSecondary,
                                              fontSize: 12,
                                              height: 1.3,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                  ],

                                  // Powers & Abilities snippet
                                  if (powers.isNotEmpty) ...[
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          '⚡ Powers: ',
                                          style: TextStyle(
                                            color: AppColors.adminLightTextPrimary,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            powers,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              color: AppColors.adminLightTextSecondary,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],

                                  const SizedBox(height: 12),

                                  // Action buttons
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      TextButton.icon(
                                        icon: const Icon(Iconsax.edit, size: 16, color: Color(0xFF2563EB)),
                                        label: const Text('Edit Story & Lore', style: TextStyle(color: Color(0xFF2563EB), fontSize: 13)),
                                        onPressed: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (_) => AdminStoryEditPage(existingStory: story),
                                            ),
                                          );
                                        },
                                      ),
                                      const SizedBox(width: 8),
                                      IconButton(
                                        icon: const Icon(Iconsax.trash, size: 18, color: AppColors.error),
                                        tooltip: 'Delete Story',
                                        onPressed: () => _confirmDelete(context, story),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, Map<String, dynamic> story) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Delete Hero Story?', style: TextStyle(color: AppColors.adminLightTextPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
        content: Text(
          'Are you sure you want to delete the hero story and lore for "${story['hero_name']}"? This action cannot be undone.',
          style: const TextStyle(color: AppColors.adminLightTextSecondary, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Cancel', style: TextStyle(color: AppColors.adminLightTextSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.of(dialogCtx).pop();
              context.read<AdminBloc>().add(DeleteHeroStoryEvent(story['story_id']));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Deleted story for "${story['hero_name']}"'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
