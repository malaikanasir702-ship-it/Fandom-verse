import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../bloc/admin_bloc.dart';
import '../bloc/admin_event.dart';

class AdminContentEditPage extends StatefulWidget {
  final Map<String, dynamic>? existingArticle;

  const AdminContentEditPage({super.key, this.existingArticle});

  @override
  State<AdminContentEditPage> createState() => _AdminContentEditPageState();
}

class _AdminContentEditPageState extends State<AdminContentEditPage> {
  final _titleController = TextEditingController();
  final _authorController = TextEditingController(text: 'Fandom Editorial Team');
  final _bodyController = TextEditingController();
  final _imageController = TextEditingController();
  String _category = 'cat_anime';
  bool _isTrending = false;
  bool _isDeepDive = false;

  final List<Map<String, String>> _categories = [
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
    if (widget.existingArticle != null) {
      final a = widget.existingArticle!;
      _titleController.text = a['title'] ?? '';
      _authorController.text = a['author_name'] ?? 'Fandom Editorial Team';
      _bodyController.text = a['content_body'] ?? '';
      _imageController.text = a['image_url'] ?? '';
      _category = a['category_id'] ?? 'cat_anime';
      _isTrending = a['is_trending'] == 1;
      _isDeepDive = a['is_deep_dive'] == 1;
    } else {
      _imageController.text = 'https://images.unsplash.com/photo-1578632767115-351597cf2477?w=800';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _bodyController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existingArticle != null;

    return Scaffold(
      backgroundColor: const Color(0xFF090C12),
      appBar: AppBar(
        title: Text(
          isEdit ? 'Edit Lore Article' : 'Create Lore Article',
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left, color: Colors.white70, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTextField(
              controller: _titleController,
              label: 'Article Headline',
              hintText: 'e.g. Complete Shonen Chronology & Hidden Easter Eggs',
            ),
            const SizedBox(height: 14),

            const Text(
              'Fandom Pillar Category',
              style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: const Color(0xFF131722),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white12),
              ),
              child: DropdownButton<String>(
                value: _category,
                isExpanded: true,
                dropdownColor: const Color(0xFF131722),
                underline: const SizedBox(),
                style: const TextStyle(color: Colors.white, fontSize: 13),
                items: _categories.map((c) {
                  return DropdownMenuItem(value: c['id']!, child: Text(c['name']!));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _category = val);
                },
              ),
            ),
            const SizedBox(height: 14),

            CustomTextField(
              controller: _authorController,
              label: 'Author Byline',
              hintText: 'e.g. Alex Mercer (Senior Lore Archivist)',
            ),
            const SizedBox(height: 14),

            CustomTextField(
              controller: _imageController,
              label: 'Cover Image URL',
              hintText: 'https://images.unsplash.com/...',
            ),
            const SizedBox(height: 14),

            CustomTextField(
              controller: _bodyController,
              label: 'Markdown Lore Content Body',
              hintText: 'Write in markdown format: # Heading, **bold**, lists, lore quotes...',
              maxLines: 8,
            ),
            const SizedBox(height: 14),

            // Toggles
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF131722),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Highlight as Trending', style: TextStyle(color: Colors.white, fontSize: 13)),
                    subtitle: const Text('Displays in Home Feed hero carousel', style: TextStyle(color: Colors.white54, fontSize: 11)),
                    value: _isTrending,
                    activeThumbColor: AppColors.darkPrimary,
                    onChanged: (val) => setState(() => _isTrending = val),
                  ),
                  const Divider(color: Colors.white10),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Deep Dive Trivia & Easter Eggs', style: TextStyle(color: Colors.white, fontSize: 13)),
                    subtitle: const Text('Categorizes under Deep Dive Lore section', style: TextStyle(color: Colors.white54, fontSize: 11)),
                    value: _isDeepDive,
                    activeThumbColor: AppColors.darkSecondary,
                    onChanged: (val) => setState(() => _isDeepDive = val),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            CustomButton(
              text: isEdit ? 'Update Article' : 'Publish Article to Universe',
              icon: Iconsax.cloud_notif,
              backgroundColor: AppColors.darkPrimary,
              onPressed: () {
                final title = _titleController.text.trim();
                final body = _bodyController.text.trim();

                if (title.isEmpty || body.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter headline and body.')),
                  );
                  return;
                }

                final postData = {
                  'post_id': isEdit
                      ? widget.existingArticle!['post_id']
                      : 'post-${DateTime.now().millisecondsSinceEpoch}',
                  'category_id': _category,
                  'title': title,
                  'content_body': body,
                  'author_name': _authorController.text.trim(),
                  'image_url': _imageController.text.trim(),
                  'is_trending': _isTrending ? 1 : 0,
                  'is_deep_dive': _isDeepDive ? 1 : 0,
                  'timestamp': DateTime.now().millisecondsSinceEpoch,
                  'is_bookmarked': 0,
                };

                context.read<AdminBloc>().add(
                      CreateOrUpdateArticleEvent(postData, isEdit: isEdit),
                    );

                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(isEdit ? 'Article updated!' : 'Article published!'),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}


