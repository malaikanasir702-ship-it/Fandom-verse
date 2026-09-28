import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_display_image.dart';
import '../../../../core/widgets/skewed_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/skeleton_loader.dart';
import '../bloc/admin_bloc.dart';
import '../bloc/admin_event.dart';
import '../bloc/admin_state.dart';
import '../widgets/admin_image_picker_field.dart';

class AdminDeepDivePage extends StatefulWidget {
  const AdminDeepDivePage({super.key});

  @override
  State<AdminDeepDivePage> createState() => _AdminDeepDivePageState();
}

class _AdminDeepDivePageState extends State<AdminDeepDivePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  String _selectedCategory = 'All';

  static const List<Map<String, String>> _categories = [
    {'id': 'All', 'name': 'All Fandoms'},
    {'id': 'cat_anime', 'name': 'Anime & Manga'},
    {'id': 'cat_gaming', 'name': 'Gaming & Esports'},
    {'id': 'cat_scifi', 'name': 'Sci-Fi & Fantasy'},
    {'id': 'cat_comics', 'name': 'Marvel & DC Comics'},
    {'id': 'cat_kpop', 'name': 'K-Pop & Idol Culture'},
    {'id': 'cat_movies', 'name': 'Pop Culture & Movies'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    context.read<AdminBloc>().add(const LoadAdminDashboardStatsEvent());
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminBloc, AdminState>(
      builder: (context, state) {
        final loaded = state is AdminStatsLoaded ? state : null;
        final triviaList = loaded?.triviaList ?? [];
        final advancedLoreList = loaded?.advancedLoreList ?? [];
        final behindScenesList = loaded?.behindScenesList ?? [];
        final interviewsList = loaded?.interviewsList ?? [];

        return Scaffold(
          backgroundColor: AppColors.adminLightBackground,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0.5,
            scrolledUnderElevation: 1,
            leading: IconButton(
              icon: const Icon(Iconsax.arrow_left,
                  color: AppColors.adminLightTextPrimary, size: 20),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: const Text(
              'Deep Dive & Lore Vault',
              style: TextStyle(
                color: AppColors.adminLightTextPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: AppColors.comicRed,
              indicatorWeight: 3,
              labelColor: AppColors.comicRed,
              unselectedLabelColor: AppColors.adminLightTextSecondary,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              tabs: [
                Tab(
                  icon: const Icon(Iconsax.lamp_charge, size: 16),
                  text: 'Trivia (${triviaList.length})',
                ),
                Tab(
                  icon: const Icon(Iconsax.book_saved, size: 16),
                  text: 'Advanced Lore (${advancedLoreList.length})',
                ),
                Tab(
                  icon: const Icon(Iconsax.video_circle, size: 16),
                  text: 'Behind Scenes (${behindScenesList.length})',
                ),
                Tab(
                  icon: const Icon(Iconsax.microphone_2, size: 16),
                  text: 'Interviews (${interviewsList.length})',
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: AppColors.comicRed,
            icon: const Icon(Iconsax.add_circle, color: Colors.white),
            label: Text(
              _getFabLabel(_tabController.index),
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
            ),
            onPressed: () => _openCreateDialog(context, _tabController.index),
          ),
          body: Column(
            children: [
              // Search & Filter header
              _buildSearchAndFilters(),

              // TabBar View for the 4 Sections
              Expanded(
                child: state is AdminLoading
                    ? const SkeletonAdminListPage()
                    : TabBarView(
                        controller: _tabController,
                        children: [
                          _buildTriviaTab(context, triviaList),
                          _buildLoreTab(context, advancedLoreList),
                          _buildBtsTab(context, behindScenesList),
                          _buildInterviewsTab(context, interviewsList),
                        ],
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getFabLabel(int tabIndex) {
    switch (tabIndex) {
      case 0:
        return 'Add Trivia';
      case 1:
        return 'Add Lore Guide';
      case 2:
        return 'Add BTS Media';
      case 3:
        return 'Add Interview';
      default:
        return 'Add Item';
    }
  }

  void _openCreateDialog(BuildContext context, int tabIndex) {
    switch (tabIndex) {
      case 0:
        _showTriviaForm(context);
        break;
      case 1:
        _showLoreForm(context);
        break;
      case 2:
        _showBehindScenesForm(context);
        break;
      case 3:
        _showInterviewForm(context);
        break;
    }
  }

  Widget _buildSearchAndFilters() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            style: const TextStyle(
                color: AppColors.adminLightTextPrimary, fontSize: 13),
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Search questions, lore, creators, scenes...',
              hintStyle: const TextStyle(
                  color: AppColors.adminLightTextMuted, fontSize: 12),
              prefixIcon: const Icon(Iconsax.search_normal,
                  color: AppColors.adminLightTextSecondary, size: 18),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 16),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {});
                      },
                    )
                  : null,
              fillColor: AppColors.adminLightBackground,
              filled: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _categories.map((cat) {
                final isSel = _selectedCategory == cat['id'];
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: ChoiceChip(
                    label: Text(cat['name']!),
                    selected: isSel,
                    selectedColor: AppColors.comicRed,
                    labelStyle: TextStyle(
                      color: isSel ? Colors.white : AppColors.adminLightTextSecondary,
                      fontSize: 11,
                      fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                    ),
                    backgroundColor: Colors.white,
                    side: BorderSide(
                      color: isSel
                          ? AppColors.comicRed
                          : AppColors.adminLightBorder,
                    ),
                    onSelected: (_) =>
                        setState(() => _selectedCategory = cat['id']!),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // TAB 1: TRIVIA QUESTIONS
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildTriviaTab(
      BuildContext context, List<Map<String, dynamic>> items) {
    final query = _searchController.text.toLowerCase().trim();
    final filtered = items.where((t) {
      final matchesCat = _selectedCategory == 'All' ||
          (t['fandom_category'] ?? '') == _selectedCategory;
      final qText = (t['question'] ?? '').toString().toLowerCase();
      final explanation = (t['explanation'] ?? '').toString().toLowerCase();
      final matchesQuery = query.isEmpty ||
          qText.contains(query) ||
          explanation.contains(query);
      return matchesCat && matchesQuery;
    }).toList();

    if (filtered.isEmpty) {
      return _buildEmptyPlaceholder('No trivia questions found.');
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final item = filtered[index];
        List<String> options = [];
        final rawOptions = item['options_json'];
        if (rawOptions is String) {
          try {
            options = (jsonDecode(rawOptions) as List)
                .map((e) => e.toString())
                .toList();
          } catch (_) {}
        }
        final correctIdx = (item['correct_answer_index'] as num?)?.toInt() ?? 0;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          color: Colors.white,
          elevation: 0.5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: AppColors.adminLightBorder),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.comicRed.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Q${index + 1}',
                        style: const TextStyle(
                          color: AppColors.comicRed,
                          fontWeight: FontWeight.w900,
                          fontSize: 11,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _buildCategoryBadge(item['fandom_category']),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Iconsax.edit,
                          size: 18, color: AppColors.heroBlue),
                      onPressed: () => _showTriviaForm(context, existing: item),
                      tooltip: 'Edit Question',
                    ),
                    IconButton(
                      icon: const Icon(Iconsax.trash,
                          size: 18, color: AppColors.comicRed),
                      onPressed: () => _confirmDelete(
                        context: context,
                        title: 'Delete Trivia Question?',
                        message:
                            'Are you sure you want to remove this trivia question?',
                        onConfirm: () {
                          context.read<AdminBloc>().add(
                                DeleteTriviaEvent(item['trivia_id']),
                              );
                        },
                      ),
                      tooltip: 'Delete',
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  item['question'] ?? '',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.adminLightTextPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: options.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final opt = entry.value;
                    final isCorrect = idx == correctIdx;
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: isCorrect
                            ? AppColors.success.withValues(alpha: 0.12)
                            : AppColors.adminLightBackground,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isCorrect
                              ? AppColors.success
                              : AppColors.adminLightBorder,
                          width: isCorrect ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isCorrect) ...[
                            const Icon(Icons.check_circle_rounded,
                                size: 14, color: AppColors.success),
                            const SizedBox(width: 4),
                          ],
                          Flexible(
                            child: Text(
                              opt,
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: isCorrect
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isCorrect
                                    ? AppColors.success
                                    : AppColors.adminLightTextSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
                if ((item['explanation'] ?? '').toString().isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.adminLightBackground,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Iconsax.info_circle,
                            size: 14, color: AppColors.adminLightTextSecondary),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            item['explanation'] ?? '',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.adminLightTextSecondary,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // TAB 2: ADVANCED LORE
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildLoreTab(
      BuildContext context, List<Map<String, dynamic>> items) {
    final query = _searchController.text.toLowerCase().trim();
    final filtered = items.where((l) {
      final matchesCat = _selectedCategory == 'All' ||
          (l['fandom_category'] ?? '') == _selectedCategory;
      final title = (l['title'] ?? '').toString().toLowerCase();
      final body = (l['content_body'] ?? '').toString().toLowerCase();
      final matchesQuery =
          query.isEmpty || title.contains(query) || body.contains(query);
      return matchesCat && matchesQuery;
    }).toList();

    if (filtered.isEmpty) {
      return _buildEmptyPlaceholder('No advanced lore items found.');
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final item = filtered[index];
        final difficulty = (item['difficulty_level'] ?? 'Intermediate').toString();

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          color: Colors.white,
          elevation: 0.5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: AppColors.adminLightBorder),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildDifficultyBadge(difficulty),
                    const SizedBox(width: 8),
                    _buildCategoryBadge(item['fandom_category']),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Iconsax.edit,
                          size: 18, color: AppColors.heroBlue),
                      onPressed: () => _showLoreForm(context, existing: item),
                      tooltip: 'Edit Lore',
                    ),
                    IconButton(
                      icon: const Icon(Iconsax.trash,
                          size: 18, color: AppColors.comicRed),
                      onPressed: () => _confirmDelete(
                        context: context,
                        title: 'Delete Lore Guide?',
                        message: 'Are you sure you want to delete this lore item?',
                        onConfirm: () {
                          context.read<AdminBloc>().add(
                                DeleteAdvancedLoreEvent(item['lore_id']),
                              );
                        },
                      ),
                      tooltip: 'Delete',
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  item['title'] ?? '',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.adminLightTextPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item['content_body'] ?? '',
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.adminLightTextSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // TAB 3: BEHIND THE SCENES
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildBtsTab(
      BuildContext context, List<Map<String, dynamic>> items) {
    final query = _searchController.text.toLowerCase().trim();
    final filtered = items.where((b) {
      final matchesCat = _selectedCategory == 'All' ||
          (b['fandom_category'] ?? '') == _selectedCategory;
      final title = (b['title'] ?? '').toString().toLowerCase();
      final desc = (b['description'] ?? '').toString().toLowerCase();
      final matchesQuery =
          query.isEmpty || title.contains(query) || desc.contains(query);
      return matchesCat && matchesQuery;
    }).toList();

    if (filtered.isEmpty) {
      return _buildEmptyPlaceholder('No behind the scenes media found.');
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final item = filtered[index];
        final mediaUrl = (item['media_url'] ?? '').toString();
        final mediaType = (item['media_type'] ?? 'video').toString();

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          color: Colors.white,
          elevation: 0.5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: AppColors.adminLightBorder),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thumbnail
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: 76,
                    height: 76,
                    color: AppColors.adminLightBackground,
                    child: mediaUrl.isNotEmpty
                        ? AppDisplayImage(
                            pathOrUrl: mediaUrl,
                            fit: BoxFit.cover,
                            placeholder: const Icon(Iconsax.video,
                                color: AppColors.adminLightTextMuted),
                          )
                        : const Icon(Iconsax.video_play,
                            color: AppColors.adminLightTextMuted, size: 28),
                  ),
                ),
                const SizedBox(width: 12),

                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _buildMediaTypeBadge(mediaType),
                          const SizedBox(width: 6),
                          _buildCategoryBadge(item['fandom_category']),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item['title'] ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.adminLightTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item['description'] ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.adminLightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Actions
                Column(
                  children: [
                    IconButton(
                      icon: const Icon(Iconsax.edit,
                          size: 18, color: AppColors.heroBlue),
                      onPressed: () =>
                          _showBehindScenesForm(context, existing: item),
                      tooltip: 'Edit',
                    ),
                    IconButton(
                      icon: const Icon(Iconsax.trash,
                          size: 18, color: AppColors.comicRed),
                      onPressed: () => _confirmDelete(
                        context: context,
                        title: 'Delete BTS Entry?',
                        message: 'Remove this behind the scenes content?',
                        onConfirm: () {
                          context.read<AdminBloc>().add(
                                DeleteBehindScenesEvent(item['scene_id']),
                              );
                        },
                      ),
                      tooltip: 'Delete',
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // TAB 4: EXCLUSIVE INTERVIEWS
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildInterviewsTab(
      BuildContext context, List<Map<String, dynamic>> items) {
    final query = _searchController.text.toLowerCase().trim();
    final filtered = items.where((i) {
      final matchesCat = _selectedCategory == 'All' ||
          (i['fandom_category'] ?? '') == _selectedCategory;
      final name = (i['interviewee_name'] ?? '').toString().toLowerCase();
      final role = (i['role_title'] ?? '').toString().toLowerCase();
      final matchesQuery =
          query.isEmpty || name.contains(query) || role.contains(query);
      return matchesCat && matchesQuery;
    }).toList();

    if (filtered.isEmpty) {
      return _buildEmptyPlaceholder('No interviews found.');
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final item = filtered[index];
        final imageUrl = (item['image_url'] ?? '').toString();
        List<dynamic> qas = [];
        final rawQ = item['questions_json'];
        if (rawQ is String) {
          try {
            qas = jsonDecode(rawQ) as List;
          } catch (_) {}
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          color: Colors.white,
          elevation: 0.5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: AppColors.adminLightBorder),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.comicYellow.withValues(alpha: 0.2),
                  backgroundImage:
                      imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
                  child: imageUrl.isEmpty
                      ? const Icon(Iconsax.user, color: AppColors.comicRed)
                      : null,
                ),
                const SizedBox(width: 12),

                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _buildCategoryBadge(item['fandom_category']),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.adminLightBackground,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${qas.length} Q&As',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.adminLightTextSecondary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item['interviewee_name'] ?? '',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.adminLightTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item['role_title'] ?? '',
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: AppColors.adminLightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Actions
                Column(
                  children: [
                    IconButton(
                      icon: const Icon(Iconsax.edit,
                          size: 18, color: AppColors.heroBlue),
                      onPressed: () =>
                          _showInterviewForm(context, existing: item),
                      tooltip: 'Edit',
                    ),
                    IconButton(
                      icon: const Icon(Iconsax.trash,
                          size: 18, color: AppColors.comicRed),
                      onPressed: () => _confirmDelete(
                        context: context,
                        title: 'Delete Interview?',
                        message:
                            'Are you sure you want to remove this interview?',
                        onConfirm: () {
                          context.read<AdminBloc>().add(
                                DeleteInterviewEvent(item['interview_id']),
                              );
                        },
                      ),
                      tooltip: 'Delete',
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // BADGES & HELPERS
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildEmptyPlaceholder(String text) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Iconsax.document_filter,
                size: 48, color: AppColors.adminLightTextMuted),
            const SizedBox(height: 12),
            Text(
              text,
              style: const TextStyle(
                color: AppColors.adminLightTextSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryBadge(String? categoryId) {
    final clean = (categoryId ?? 'All').replaceAll('cat_', '').toUpperCase();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.adminLightBackground,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: AppColors.adminLightBorder),
      ),
      child: Text(
        clean,
        style: const TextStyle(
          color: AppColors.adminLightTextSecondary,
          fontSize: 9.5,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDifficultyBadge(String difficulty) {
    Color bg;
    Color fg;
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        bg = AppColors.success.withValues(alpha: 0.12);
        fg = AppColors.success;
        break;
      case 'expert':
        bg = AppColors.comicRed.withValues(alpha: 0.12);
        fg = AppColors.comicRed;
        break;
      case 'intermediate':
      default:
        bg = const Color(0xFFF59E0B).withValues(alpha: 0.12);
        fg = const Color(0xFFD97706);
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        difficulty.toUpperCase(),
        style: TextStyle(
          color: fg,
          fontSize: 9.5,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _buildMediaTypeBadge(String mediaType) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.comicRed.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        mediaType.toUpperCase(),
        style: const TextStyle(
          color: AppColors.comicRed,
          fontSize: 9.5,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  void _confirmDelete({
    required BuildContext context,
    required String title,
    required String message,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColors.adminLightTextPrimary)),
        content: Text(message,
            style: const TextStyle(
                fontSize: 13, color: AppColors.adminLightTextSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.adminLightTextSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.comicRed,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              onConfirm();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Item deleted successfully.'),
                  backgroundColor: AppColors.comicRed,
                ),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // FORMS: TRIVIA, LORE, BTS, INTERVIEW
  // ─────────────────────────────────────────────────────────────────────────

  void _showTriviaForm(BuildContext context,
      {Map<String, dynamic>? existing}) {
    final isEdit = existing != null;
    final qController = TextEditingController(text: existing?['question'] ?? '');
    final opt1Controller = TextEditingController();
    final opt2Controller = TextEditingController();
    final opt3Controller = TextEditingController();
    final opt4Controller = TextEditingController();
    final expController =
        TextEditingController(text: existing?['explanation'] ?? '');

    String category = existing?['fandom_category'] ?? 'cat_anime';
    int correctIndex = (existing?['correct_answer_index'] as num?)?.toInt() ?? 0;

    if (existing != null) {
      final raw = existing['options_json'];
      if (raw is String) {
        try {
          final list = (jsonDecode(raw) as List).map((e) => e.toString()).toList();
          if (list.isNotEmpty) opt1Controller.text = list[0];
          if (list.length > 1) opt2Controller.text = list[1];
          if (list.length > 2) opt3Controller.text = list[2];
          if (list.length > 3) opt4Controller.text = list[3];
        } catch (_) {}
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              top: 20,
              left: 20,
              right: 20,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isEdit ? 'Edit Trivia Question' : 'Add Trivia Question',
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.adminLightTextPrimary),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () => Navigator.of(ctx).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: qController,
                    label: 'Question',
                    hintText: 'e.g. In Dragon Ball Z, who was the first mortal to defeat Goku?',
                  ),
                  const SizedBox(height: 12),
                  const Text('Fandom Category',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.adminLightTextSecondary)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppColors.adminLightBackground,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.adminLightBorder),
                    ),
                    child: DropdownButton<String>(
                      value: category,
                      isExpanded: true,
                      underline: const SizedBox(),
                      items: _categories.where((c) => c['id'] != 'All').map((c) {
                        return DropdownMenuItem(
                            value: c['id']!, child: Text(c['name']!));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setModalState(() => category = val);
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text('Answer Options (Select the correct answer button)',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.adminLightTextPrimary)),
                  const SizedBox(height: 8),
                  _buildOptionRow('Option 1', opt1Controller, 0, correctIndex,
                      (idx) => setModalState(() => correctIndex = idx)),
                  const SizedBox(height: 8),
                  _buildOptionRow('Option 2', opt2Controller, 1, correctIndex,
                      (idx) => setModalState(() => correctIndex = idx)),
                  const SizedBox(height: 8),
                  _buildOptionRow('Option 3', opt3Controller, 2, correctIndex,
                      (idx) => setModalState(() => correctIndex = idx)),
                  const SizedBox(height: 8),
                  _buildOptionRow('Option 4', opt4Controller, 3, correctIndex,
                      (idx) => setModalState(() => correctIndex = idx)),
                  const SizedBox(height: 14),
                  CustomTextField(
                    controller: expController,
                    label: 'Explanation',
                    hintText: 'Why is this answer correct? (Optional)',
                    maxLines: 2,
                  ),
                  const SizedBox(height: 20),
                  SkewedButton(
                    text: isEdit ? 'Update Question' : 'Save Question',
                    icon: Iconsax.cloud_add,
                    backgroundColor: AppColors.comicRed,
                    textColor: Colors.white,
                    height: 48,
                    fontSize: 13,
                    onPressed: () {
                      final q = qController.text.trim();
                      final o1 = opt1Controller.text.trim();
                      final o2 = opt2Controller.text.trim();
                      final o3 = opt3Controller.text.trim();
                      final o4 = opt4Controller.text.trim();

                      if (q.isEmpty || o1.isEmpty || o2.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Please enter a question and at least 2 options.')),
                        );
                        return;
                      }

                      final options = [o1, o2];
                      if (o3.isNotEmpty) options.add(o3);
                      if (o4.isNotEmpty) options.add(o4);

                      final data = {
                        'trivia_id': isEdit
                            ? existing['trivia_id']
                            : 'trivia-${DateTime.now().millisecondsSinceEpoch}',
                        'fandom_category': category,
                        'question': q,
                        'options_json': jsonEncode(options),
                        'correct_answer_index': correctIndex < options.length ? correctIndex : 0,
                        'explanation': expController.text.trim(),
                        'created_at': isEdit
                            ? existing['created_at']
                            : DateTime.now().millisecondsSinceEpoch,
                      };

                      context.read<AdminBloc>().add(
                            CreateOrUpdateTriviaEvent(data, isEdit: isEdit),
                          );

                      Navigator.of(ctx).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(isEdit
                              ? 'Trivia question updated!'
                              : 'Trivia question created!'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOptionRow(String label, TextEditingController controller,
      int optionIndex, int selectedIndex, Function(int) onSelect) {
    final isSelected = optionIndex == selectedIndex;
    return Row(
      children: [
        IconButton(
          icon: Icon(
            isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
            color: isSelected ? AppColors.success : AppColors.adminLightTextMuted,
            size: 22,
          ),
          onPressed: () => onSelect(optionIndex),
          tooltip: 'Mark as Correct Answer',
        ),
        Expanded(
          child: TextField(
            controller: controller,
            style: const TextStyle(fontSize: 13, color: AppColors.adminLightTextPrimary),
            decoration: InputDecoration(
              hintText: label,
              hintStyle: const TextStyle(fontSize: 12, color: AppColors.adminLightTextMuted),
              fillColor: AppColors.adminLightBackground,
              filled: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                    color: isSelected ? AppColors.success : AppColors.adminLightBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                    color: isSelected ? AppColors.success : AppColors.adminLightBorder),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showLoreForm(BuildContext context,
      {Map<String, dynamic>? existing}) {
    final isEdit = existing != null;
    final titleController = TextEditingController(text: existing?['title'] ?? '');
    final bodyController = TextEditingController(text: existing?['content_body'] ?? '');
    String category = existing?['fandom_category'] ?? 'cat_anime';
    String difficulty = existing?['difficulty_level'] ?? 'Intermediate';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              top: 20,
              left: 20,
              right: 20,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isEdit ? 'Edit Advanced Lore' : 'Add Advanced Lore',
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.adminLightTextPrimary),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () => Navigator.of(ctx).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: titleController,
                    label: 'Lore Title',
                    hintText: 'e.g. The Will of D. & The Void Century',
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Fandom Category',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.adminLightTextSecondary)),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                color: AppColors.adminLightBackground,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.adminLightBorder),
                              ),
                              child: DropdownButton<String>(
                                value: category,
                                isExpanded: true,
                                underline: const SizedBox(),
                                items: _categories
                                    .where((c) => c['id'] != 'All')
                                    .map((c) => DropdownMenuItem(
                                        value: c['id']!,
                                        child: Text(c['name']!,
                                            style: const TextStyle(fontSize: 12))))
                                    .toList(),
                                onChanged: (val) {
                                  if (val != null) setModalState(() => category = val);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Difficulty Level',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.adminLightTextSecondary)),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                color: AppColors.adminLightBackground,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.adminLightBorder),
                              ),
                              child: DropdownButton<String>(
                                value: difficulty,
                                isExpanded: true,
                                underline: const SizedBox(),
                                items: ['Beginner', 'Intermediate', 'Expert']
                                    .map((d) => DropdownMenuItem(
                                        value: d,
                                        child: Text(d,
                                            style: const TextStyle(fontSize: 12))))
                                    .toList(),
                                onChanged: (val) {
                                  if (val != null) setModalState(() => difficulty = val);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  CustomTextField(
                    controller: bodyController,
                    label: 'Lore Body / Deep Lore Analysis',
                    hintText: 'Detailed canon lore analysis, mysteries, and chronology...',
                    maxLines: 6,
                  ),
                  const SizedBox(height: 20),
                  SkewedButton(
                    text: isEdit ? 'Update Lore Entry' : 'Publish Lore Entry',
                    icon: Iconsax.book_saved,
                    backgroundColor: AppColors.comicRed,
                    textColor: Colors.white,
                    height: 48,
                    fontSize: 13,
                    onPressed: () {
                      final title = titleController.text.trim();
                      final body = bodyController.text.trim();

                      if (title.isEmpty || body.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please fill out title and lore body.')),
                        );
                        return;
                      }

                      final data = {
                        'lore_id': isEdit
                            ? existing['lore_id']
                            : 'lore-${DateTime.now().millisecondsSinceEpoch}',
                        'fandom_category': category,
                        'title': title,
                        'content_body': body,
                        'difficulty_level': difficulty,
                        'created_at': isEdit
                            ? existing['created_at']
                            : DateTime.now().millisecondsSinceEpoch,
                      };

                      context.read<AdminBloc>().add(
                            CreateOrUpdateAdvancedLoreEvent(data, isEdit: isEdit),
                          );

                      Navigator.of(ctx).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              isEdit ? 'Lore guide updated!' : 'Lore guide published!'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showBehindScenesForm(BuildContext context,
      {Map<String, dynamic>? existing}) {
    final isEdit = existing != null;
    final titleController = TextEditingController(text: existing?['title'] ?? '');
    final descController =
        TextEditingController(text: existing?['description'] ?? '');
    String mediaUrl = existing?['media_url'] ?? '';
    String category = existing?['fandom_category'] ?? 'cat_anime';
    String mediaType = existing?['media_type'] ?? 'video';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              top: 20,
              left: 20,
              right: 20,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isEdit ? 'Edit Behind The Scenes' : 'Add Behind The Scenes',
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.adminLightTextPrimary),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () => Navigator.of(ctx).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: titleController,
                    label: 'Title',
                    hintText: 'e.g. StageCraft Virtual Sets in Mandalorian',
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Category',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.adminLightTextSecondary)),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                color: AppColors.adminLightBackground,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.adminLightBorder),
                              ),
                              child: DropdownButton<String>(
                                value: category,
                                isExpanded: true,
                                underline: const SizedBox(),
                                items: _categories
                                    .where((c) => c['id'] != 'All')
                                    .map((c) => DropdownMenuItem(
                                        value: c['id']!,
                                        child: Text(c['name']!,
                                            style: const TextStyle(fontSize: 12))))
                                    .toList(),
                                onChanged: (val) {
                                  if (val != null) setModalState(() => category = val);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Media Type',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.adminLightTextSecondary)),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              decoration: BoxDecoration(
                                color: AppColors.adminLightBackground,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: AppColors.adminLightBorder),
                              ),
                              child: DropdownButton<String>(
                                value: mediaType,
                                isExpanded: true,
                                underline: const SizedBox(),
                                items: ['video', 'image', 'article']
                                    .map((m) => DropdownMenuItem(
                                        value: m,
                                        child: Text(m.toUpperCase(),
                                            style: const TextStyle(fontSize: 12))))
                                    .toList(),
                                onChanged: (val) {
                                  if (val != null) setModalState(() => mediaType = val);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  AdminImagePickerField(
                    label: 'Media Cover / Video Thumbnail',
                    helperText: 'Select media thumbnail from device or Cloudinary',
                    initialImagePathOrUrl: mediaUrl,
                    cloudinaryFolder: 'fandom_verse/bts',
                    onImageSelected: (path) {
                      setModalState(() {
                        mediaUrl = path;
                      });
                    },
                  ),

                  const SizedBox(height: 14),
                  CustomTextField(
                    controller: descController,
                    label: 'Description',
                    hintText: 'Behind the scenes production secrets and details...',
                    maxLines: 4,
                  ),
                  const SizedBox(height: 20),
                  SkewedButton(
                    text: isEdit ? 'Update BTS Entry' : 'Save BTS Entry',
                    icon: Iconsax.video_play,
                    backgroundColor: AppColors.comicRed,
                    textColor: Colors.white,
                    height: 48,
                    fontSize: 13,
                    onPressed: () {
                      final title = titleController.text.trim();
                      final desc = descController.text.trim();

                      if (title.isEmpty || desc.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Please fill out title and description.')),
                        );
                        return;
                      }

                      final data = {
                        'scene_id': isEdit
                            ? existing['scene_id']
                            : 'scene-${DateTime.now().millisecondsSinceEpoch}',
                        'fandom_category': category,
                        'title': title,
                        'description': desc,
                        'media_type': mediaType,
                        'media_url': mediaUrl.trim(),
                        'created_at': isEdit
                            ? existing['created_at']
                            : DateTime.now().millisecondsSinceEpoch,
                      };

                      context.read<AdminBloc>().add(
                            CreateOrUpdateBehindScenesEvent(data, isEdit: isEdit),
                          );

                      Navigator.of(ctx).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              isEdit ? 'BTS entry updated!' : 'BTS entry created!'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showInterviewForm(BuildContext context,
      {Map<String, dynamic>? existing}) {
    final isEdit = existing != null;
    final nameController =
        TextEditingController(text: existing?['interviewee_name'] ?? '');
    final roleController =
        TextEditingController(text: existing?['role_title'] ?? '');
    String category = existing?['fandom_category'] ?? 'cat_anime';
    String imageUrl = existing?['image_url'] ?? '';

    List<Map<String, String>> qaList = [];
    if (existing != null) {
      final raw = existing['questions_json'];
      if (raw is String) {
        try {
          final list = jsonDecode(raw) as List;
          for (final item in list) {
            qaList.add({
              'question': (item['question'] ?? '').toString(),
              'answer': (item['answer'] ?? '').toString(),
            });
          }
        } catch (_) {}
      }
    }

    if (qaList.isEmpty) {
      qaList.add({'question': '', 'answer': ''});
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              top: 20,
              left: 20,
              right: 20,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isEdit ? 'Edit Interview' : 'Add Interview',
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.adminLightTextPrimary),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () => Navigator.of(ctx).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: nameController,
                    label: 'Interviewee Name',
                    hintText: 'e.g. Hidetaka Miyazaki',
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    controller: roleController,
                    label: 'Role / Title',
                    hintText: 'e.g. President & Game Director, FromSoftware',
                  ),
                  const SizedBox(height: 12),
                  const Text('Fandom Category',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.adminLightTextSecondary)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: AppColors.adminLightBackground,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.adminLightBorder),
                    ),
                    child: DropdownButton<String>(
                      value: category,
                      isExpanded: true,
                      underline: const SizedBox(),
                      items: _categories.where((c) => c['id'] != 'All').map((c) {
                        return DropdownMenuItem(
                            value: c['id']!, child: Text(c['name']!));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setModalState(() => category = val);
                      },
                    ),
                  ),
                  const SizedBox(height: 14),

                  AdminImagePickerField(
                    label: 'Interviewee Photo',
                    helperText: 'Pick portrait image from mobile or Cloudinary',
                    initialImagePathOrUrl: imageUrl,
                    cloudinaryFolder: 'fandom_verse/interviews',
                    onImageSelected: (path) {
                      setModalState(() {
                        imageUrl = path;
                      });
                    },
                  ),

                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Interview Questions & Answers',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.adminLightTextPrimary),
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.add, size: 16, color: AppColors.comicRed),
                        label: const Text('Add Q&A',
                            style: TextStyle(color: AppColors.comicRed, fontSize: 12)),
                        onPressed: () {
                          setModalState(() {
                            qaList.add({'question': '', 'answer': ''});
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  ...qaList.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final qa = entry.value;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.adminLightBackground,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.adminLightBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Q&A #${idx + 1}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: AppColors.adminLightTextPrimary)),
                              if (qaList.length > 1)
                                IconButton(
                                  icon: const Icon(Icons.delete_outline,
                                      size: 16, color: AppColors.comicRed),
                                  onPressed: () {
                                    setModalState(() {
                                      qaList.removeAt(idx);
                                    });
                                  },
                                ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            initialValue: qa['question'],
                            style: const TextStyle(fontSize: 12.5),
                            decoration: InputDecoration(
                              hintText: 'Question',
                              fillColor: Colors.white,
                              filled: true,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 8),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                    color: AppColors.adminLightBorder),
                              ),
                            ),
                            onChanged: (val) => qa['question'] = val,
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            initialValue: qa['answer'],
                            maxLines: 2,
                            style: const TextStyle(fontSize: 12.5),
                            decoration: InputDecoration(
                              hintText: 'Answer',
                              fillColor: Colors.white,
                              filled: true,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 8),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(
                                    color: AppColors.adminLightBorder),
                              ),
                            ),
                            onChanged: (val) => qa['answer'] = val,
                          ),
                        ],
                      ),
                    );
                  }),

                  const SizedBox(height: 20),
                  SkewedButton(
                    text: isEdit ? 'Update Interview' : 'Save Interview',
                    icon: Iconsax.microphone_2,
                    backgroundColor: AppColors.comicRed,
                    textColor: Colors.white,
                    height: 48,
                    fontSize: 13,
                    onPressed: () {
                      final name = nameController.text.trim();
                      final role = roleController.text.trim();

                      if (name.isEmpty || role.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Please fill out interviewee name and role.')),
                        );
                        return;
                      }

                      final validQas = qaList
                          .where((q) =>
                              (q['question'] ?? '').trim().isNotEmpty &&
                              (q['answer'] ?? '').trim().isNotEmpty)
                          .toList();

                      final data = {
                        'interview_id': isEdit
                            ? existing['interview_id']
                            : 'interview-${DateTime.now().millisecondsSinceEpoch}',
                        'interviewee_name': name,
                        'role_title': role,
                        'fandom_category': category,
                        'interview_date': isEdit
                            ? (existing['interview_date'] ?? DateTime.now().millisecondsSinceEpoch)
                            : DateTime.now().millisecondsSinceEpoch,
                        'image_url': imageUrl.trim(),
                        'questions_json': jsonEncode(validQas),
                        'created_at': isEdit
                            ? existing['created_at']
                            : DateTime.now().millisecondsSinceEpoch,
                      };

                      context.read<AdminBloc>().add(
                            CreateOrUpdateInterviewEvent(data, isEdit: isEdit),
                          );

                      Navigator.of(ctx).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(isEdit
                              ? 'Interview updated!'
                              : 'Interview created!'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
