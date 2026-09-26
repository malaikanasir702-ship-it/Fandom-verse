import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_display_image.dart';
import '../bloc/admin_bloc.dart';
import '../bloc/admin_event.dart';
import '../bloc/admin_state.dart';
import '../widgets/admin_modals.dart';
import 'admin_content_edit_page.dart';

class AdminContentPage extends StatefulWidget {
  const AdminContentPage({super.key});

  @override
  State<AdminContentPage> createState() => _AdminContentPageState();
}

class _AdminContentPageState extends State<AdminContentPage> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.adminLightBackground,
      appBar: AppBar(
        title: const Text(
          'Lore & Content Manager',
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
        backgroundColor: AppColors.comicRed,
        icon: const Icon(Iconsax.add_circle, color: Colors.white),
        label: const Text('New Article', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const AdminContentEditPage(),
            ),
          );
        },
      ),
      body: BlocBuilder<AdminBloc, AdminState>(
        builder: (context, state) {
          if (state is AdminLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.comicRed));
          }

          final allArticles = state is AdminStatsLoaded ? state.articles : [];

          final query = _searchController.text.toLowerCase().trim();
          final filtered = allArticles.where((a) {
            final matchesCat = _selectedCategory == 'All' || a['category_id'] == _selectedCategory;
            final matchesQuery = query.isEmpty ||
                (a['title'] ?? '').toString().toLowerCase().contains(query) ||
                (a['content_body'] ?? '').toString().toLowerCase().contains(query);
            return matchesCat && matchesQuery;
          }).toList();

          return Column(
            children: [
              // Search & Filter Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: AppColors.adminLightTextPrimary, fontSize: 13),
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Search articles, theories, lore guides...',
                    hintStyle: const TextStyle(color: AppColors.adminLightTextMuted, fontSize: 12),
                    prefixIcon: const Icon(Iconsax.search_normal, color: AppColors.adminLightTextSecondary, size: 18),
                    fillColor: Colors.white,
                    filled: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.adminLightBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.adminLightBorder),
                    ),
                  ),
                ),
              ),

              // Categories Filter Row
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    'All',
                    'cat_anime',
                    'cat_gaming',
                    'cat_scifi',
                    'cat_comics',
                    'cat_kpop',
                    'cat_movies',
                  ].map((cat) {
                    final isSel = _selectedCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(cat == 'All' ? 'All Fandoms' : cat.replaceAll('cat_', '').toUpperCase()),
                        selected: isSel,
                        selectedColor: AppColors.comicRed,
                        labelStyle: TextStyle(
                          color: isSel ? Colors.white : AppColors.adminLightTextSecondary,
                          fontSize: 11,
                          fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                        ),
                        backgroundColor: Colors.white,
                        side: BorderSide(
                          color: isSel ? AppColors.comicRed : AppColors.adminLightBorder,
                        ),
                        onSelected: (_) => setState(() => _selectedCategory = cat),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 10),

              // Results Count
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${filtered.length} Articles in Database',
                      style: const TextStyle(color: AppColors.adminLightTextSecondary, fontSize: 11, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Articles List
              Expanded(
                child: filtered.isEmpty
                    ? const Center(
                        child: Text(
                          'No articles found matching filters.',
                          style: TextStyle(color: AppColors.adminLightTextSecondary),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final article = filtered[index];
                          return _buildArticleTile(context, article);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildArticleTile(BuildContext context, Map<String, dynamic> article) {
    return Container(
      padding: const EdgeInsets.all(12),
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: AppDisplayImage(
              pathOrUrl: article['image_url'] ?? '',
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.comicRed.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        (article['category_id'] ?? '').toString().toUpperCase(),
                        style: const TextStyle(color: AppColors.comicRed, fontSize: 9, fontWeight: FontWeight.bold),
                      ),
                    ),
                    if (article['is_trending'] == 1) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD97706).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'TRENDING',
                          style: TextStyle(color: Color(0xFFD97706), fontSize: 8, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  article['title'] ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppColors.adminLightTextPrimary, fontSize: 13, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  'Author: ${article['author_name'] ?? 'Fandom Staff'}',
                  style: const TextStyle(color: AppColors.adminLightTextSecondary, fontSize: 10),
                ),
              ],
            ),
          ),
          Column(
            children: [
              IconButton(
                icon: const Icon(Iconsax.edit_2, color: Color(0xFF2563EB), size: 18),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => AdminContentEditPage(existingArticle: article),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Iconsax.trash, color: AppColors.error, size: 18),
                onPressed: () {
                  AdminModals.showDeleteBarrierDialog(
                    context: context,
                    itemName: article['title'] ?? 'Article',
                    onConfirmed: () {
                      context.read<AdminBloc>().add(DeleteArticleEvent(article['post_id']));
                    },
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
