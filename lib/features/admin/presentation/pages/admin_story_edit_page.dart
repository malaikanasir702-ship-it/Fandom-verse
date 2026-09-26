import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/skewed_button.dart';
import '../bloc/admin_bloc.dart';
import '../bloc/admin_event.dart';
import '../widgets/admin_image_picker_field.dart';

class AdminStoryEditPage extends StatefulWidget {
  final Map<String, dynamic>? existingStory;

  const AdminStoryEditPage({super.key, this.existingStory});

  @override
  State<AdminStoryEditPage> createState() => _AdminStoryEditPageState();
}

class _AdminStoryEditPageState extends State<AdminStoryEditPage> {
  final _formKey = GlobalKey<FormState>();

  final _heroNameController = TextEditingController();
  final _taglineController = TextEditingController();
  final _originBackstoryController = TextEditingController();
  final _lifeHistoryController = TextEditingController();
  final _powersController = TextEditingController();
  final _firstAppearanceController = TextEditingController();
  final _ringColorHexController = TextEditingController(text: '#E51924');

  String _avatarImagePath = '';
  String _category = 'Marvel';
  String _selectedRingColorHex = '#E51924';

  List<Map<String, String>> _slides = [];

  final List<String> _categories = [
    'Marvel',
    'DC',
    'Anime',
    'Sci-Fi',
    'Gaming',
    'Star Wars',
  ];

  final List<Map<String, dynamic>> _ringColorPresets = [
    {'name': 'Spider Red', 'hex': '#E51924', 'color': Color(0xFFE51924)},
    {'name': 'Batman Dark', 'hex': '#2563EB', 'color': Color(0xFF2563EB)},
    {'name': 'Wolverine Gold', 'hex': '#EAB308', 'color': Color(0xFFEAB308)},
    {'name': 'Wonder Gold', 'hex': '#F59E0B', 'color': Color(0xFFF59E0B)},
    {'name': 'Deadpool Crimson', 'hex': '#DC2626', 'color': Color(0xFFDC2626)},
    {'name': 'Arc Cyan', 'hex': '#06B6D4', 'color': Color(0xFF06B6D4)},
    {'name': 'Hulk Green', 'hex': '#10B981', 'color': Color(0xFF10B981)},
    {'name': 'Mystic Purple', 'hex': '#8B5CF6', 'color': Color(0xFF8B5CF6)},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.existingStory != null) {
      final s = widget.existingStory!;
      _heroNameController.text = s['hero_name'] ?? '';
      _taglineController.text = s['tagline'] ?? '';
      _originBackstoryController.text = s['origin_backstory'] ?? '';
      _lifeHistoryController.text = s['life_history'] ?? '';
      _powersController.text = s['powers_abilities'] ?? '';
      _firstAppearanceController.text = s['first_appearance'] ?? '';
      _avatarImagePath = s['avatar_url'] ?? '';
      _category = s['category'] ?? 'Marvel';
      _selectedRingColorHex = (s['ring_color_hex'] ?? '#E51924').toString();
      _ringColorHexController.text = _selectedRingColorHex;

      final rawSlides = s['slides_json'] ?? s['slides'];
      if (rawSlides is String && rawSlides.isNotEmpty) {
        try {
          final decoded = jsonDecode(rawSlides);
          if (decoded is List) {
            _slides = decoded.map((item) {
              final map = Map<String, dynamic>.from(item as Map);
              return {
                'title': (map['title'] ?? '').toString(),
                'caption': (map['caption'] ?? '').toString(),
                'imageUrl': (map['imageUrl'] ?? map['image_url'] ?? '').toString(),
              };
            }).toList();
          }
        } catch (_) {}
      } else if (rawSlides is List) {
        _slides = rawSlides.map((item) {
          final map = Map<String, dynamic>.from(item as Map);
          return {
            'title': (map['title'] ?? '').toString(),
            'caption': (map['caption'] ?? '').toString(),
            'imageUrl': (map['imageUrl'] ?? map['image_url'] ?? '').toString(),
          };
        }).toList();
      }
    }

    if (_slides.isEmpty) {
      _slides.add({
        'title': 'Hero Origin',
        'caption': 'The defining catalyst moment.',
        'imageUrl': _avatarImagePath.isNotEmpty
            ? _avatarImagePath
            : 'https://images.unsplash.com/photo-1635805737707-575885ab0820?w=800',
      });
    }
  }

  @override
  void dispose() {
    _heroNameController.dispose();
    _taglineController.dispose();
    _originBackstoryController.dispose();
    _lifeHistoryController.dispose();
    _powersController.dispose();
    _firstAppearanceController.dispose();
    _ringColorHexController.dispose();
    super.dispose();
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;

    if (_avatarImagePath.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select or upload a hero avatar image.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final isEdit = widget.existingStory != null;
    final storyId = isEdit
        ? widget.existingStory!['story_id']
        : 'story-${_heroNameController.text.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_')}-${DateTime.now().millisecondsSinceEpoch}';

    final slidesJson = jsonEncode(_slides);

    final storyMap = {
      'story_id': storyId,
      'hero_name': _heroNameController.text.trim(),
      'category': _category,
      'avatar_url': _avatarImagePath.trim(),
      'ring_color_hex': _selectedRingColorHex.trim(),
      'tagline': _taglineController.text.trim(),
      'origin_backstory': _originBackstoryController.text.trim(),
      'life_history': _lifeHistoryController.text.trim(),
      'powers_abilities': _powersController.text.trim(),
      'first_appearance': _firstAppearanceController.text.trim(),
      'slides_json': slidesJson,
      'created_at': isEdit
          ? (widget.existingStory!['created_at'] ?? DateTime.now().millisecondsSinceEpoch)
          : DateTime.now().millisecondsSinceEpoch,
    };

    context.read<AdminBloc>().add(CreateOrUpdateHeroStoryEvent(storyMap, isEdit: isEdit));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isEdit ? 'Hero story updated!' : 'Hero story published!'),
        backgroundColor: AppColors.success,
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existingStory != null;

    return Scaffold(
      backgroundColor: AppColors.adminLightBackground,
      appBar: AppBar(
        title: Text(
          isEdit ? 'Edit Hero Story & Lore' : 'New Hero Story & Lore',
          style: const TextStyle(
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
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Identity Card
              _buildSectionCard(
                title: 'HERO IDENTITY & BRANDING',
                icon: Iconsax.user_octagon,
                accentColor: const Color(0xFF8B5CF6),
                children: [
                  CustomTextField(
                    controller: _heroNameController,
                    label: 'Hero Name',
                    hintText: 'e.g., Spider-Man (Peter Parker)',
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Hero name is required' : null,
                  ),
                  const SizedBox(height: 12),

                  // Category dropdown
                  DropdownButtonFormField<String>(
                    initialValue: _category,
                    dropdownColor: Colors.white,
                    style: const TextStyle(color: AppColors.adminLightTextPrimary, fontSize: 14),
                    decoration: InputDecoration(
                      labelText: 'Fandom Category',
                      labelStyle: const TextStyle(color: AppColors.adminLightTextSecondary, fontSize: 13),
                      filled: true,
                      fillColor: AppColors.adminLightBackground,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: AppColors.adminLightBorder),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: AppColors.adminLightBorder),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFF8B5CF6), width: 1.5),
                      ),
                    ),
                    items: _categories.map((cat) {
                      return DropdownMenuItem(value: cat, child: Text(cat));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _category = val);
                    },
                  ),
                  const SizedBox(height: 12),

                  CustomTextField(
                    controller: _taglineController,
                    label: 'Hero Tagline / Alias',
                    hintText: 'e.g., Your Friendly Neighborhood Spider-Man',
                  ),
                  const SizedBox(height: 12),

                  CustomTextField(
                    controller: _firstAppearanceController,
                    label: 'First Appearance / Debut',
                    hintText: 'e.g., Amazing Fantasy #15 (August 1962)',
                  ),
                  const SizedBox(height: 16),

                  // Avatar Image Picker
                  AdminImagePickerField(
                    label: 'Hero Profile Avatar',
                    helperText: 'Pick hero portrait from mobile gallery or paste image URL',
                    initialImagePathOrUrl: _avatarImagePath.isEmpty ? null : _avatarImagePath,
                    onImageSelected: (path) {
                      setState(() => _avatarImagePath = path);
                    },
                  ),
                  const SizedBox(height: 16),

                  // Ring Color selector
                  const Text(
                    'Story Ring Aura Color',
                    style: TextStyle(
                      color: AppColors.adminLightTextPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _ringColorPresets.map((preset) {
                      final isSelected = _selectedRingColorHex.toUpperCase() == (preset['hex'] as String).toUpperCase();
                      final color = preset['color'] as Color;
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedRingColorHex = preset['hex'];
                            _ringColorHexController.text = preset['hex'];
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSelected ? color.withValues(alpha: 0.15) : AppColors.adminLightBackground,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected ? color : AppColors.adminLightBorder,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 14,
                                height: 14,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                preset['name'],
                                style: TextStyle(
                                  color: isSelected ? color : AppColors.adminLightTextSecondary,
                                  fontSize: 11,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Deep Origin & Life History Card
              _buildSectionCard(
                title: 'DEEP LORE, ORIGIN & HISTORY',
                icon: Iconsax.book_1,
                accentColor: AppColors.comicRed,
                children: [
                  const Text(
                    'This lore will be shown when fans click "Read Origin & Backstory" in the story viewer!',
                    style: TextStyle(color: AppColors.adminLightTextSecondary, fontSize: 12),
                  ),
                  const SizedBox(height: 12),

                  // Origin Backstory
                  const Text(
                    'Hero Origin Backstory',
                    style: TextStyle(color: AppColors.adminLightTextPrimary, fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _originBackstoryController,
                    maxLines: 5,
                    style: const TextStyle(color: AppColors.adminLightTextPrimary, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Describe how they gained their powers, early life, tragedy, or defining catalyst...',
                      hintStyle: const TextStyle(color: AppColors.adminLightTextSecondary, fontSize: 12),
                      filled: true,
                      fillColor: AppColors.adminLightBackground,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: AppColors.adminLightBorder),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: AppColors.adminLightBorder),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: AppColors.comicRed, width: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Whole Life History
                  const Text(
                    'Whole Life History & Lore',
                    style: TextStyle(color: AppColors.adminLightTextPrimary, fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _lifeHistoryController,
                    maxLines: 6,
                    style: const TextStyle(color: AppColors.adminLightTextPrimary, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Comprehensive timeline of major battles, key allies, heroic sacrifices, character evolution...',
                      hintStyle: const TextStyle(color: AppColors.adminLightTextSecondary, fontSize: 12),
                      filled: true,
                      fillColor: AppColors.adminLightBackground,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: AppColors.adminLightBorder),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: AppColors.adminLightBorder),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: AppColors.comicRed, width: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Powers & Abilities
                  const Text(
                    'Powers, Abilities & Equipment',
                    style: TextStyle(color: AppColors.adminLightTextPrimary, fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _powersController,
                    maxLines: 3,
                    style: const TextStyle(color: AppColors.adminLightTextPrimary, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'e.g., Wall-crawling, Spider-Sense, Web-Shooters, Genius-level intellect...',
                      hintStyle: const TextStyle(color: AppColors.adminLightTextSecondary, fontSize: 12),
                      filled: true,
                      fillColor: AppColors.adminLightBackground,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: AppColors.adminLightBorder),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: AppColors.adminLightBorder),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: AppColors.comicRed, width: 1.5),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Story Slides Builder
              _buildSectionCard(
                title: 'STORY REEL SLIDES (${_slides.length})',
                icon: Iconsax.gallery,
                accentColor: const Color(0xFF2563EB),
                children: [
                  const Text(
                    'Slides rotate automatically in the fan story viewer with captions and comic art.',
                    style: TextStyle(color: AppColors.adminLightTextSecondary, fontSize: 12),
                  ),
                  const SizedBox(height: 14),

                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _slides.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final slide = _slides[index];
                      return Container(
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
                                Text(
                                  'Slide #${index + 1}',
                                  style: const TextStyle(
                                    color: AppColors.adminLightTextPrimary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (_slides.length > 1)
                                  IconButton(
                                    icon: const Icon(Iconsax.trash, size: 16, color: AppColors.error),
                                    onPressed: () {
                                      setState(() {
                                        _slides.removeAt(index);
                                      });
                                    },
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // Slide Title
                            TextFormField(
                              initialValue: slide['title'],
                              style: const TextStyle(color: AppColors.adminLightTextPrimary, fontSize: 13),
                              decoration: InputDecoration(
                                labelText: 'Slide Title / Chapter',
                                labelStyle: const TextStyle(color: AppColors.adminLightTextSecondary, fontSize: 12),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: AppColors.adminLightBorder),
                                ),
                              ),
                              onChanged: (val) => slide['title'] = val,
                            ),
                            const SizedBox(height: 8),

                            // Slide Caption
                            TextFormField(
                              initialValue: slide['caption'],
                              maxLines: 2,
                              style: const TextStyle(color: AppColors.adminLightTextPrimary, fontSize: 13),
                              decoration: InputDecoration(
                                labelText: 'Slide Caption Narrative',
                                labelStyle: const TextStyle(color: AppColors.adminLightTextSecondary, fontSize: 12),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: AppColors.adminLightBorder),
                                ),
                              ),
                              onChanged: (val) => slide['caption'] = val,
                            ),
                            const SizedBox(height: 10),

                            // Slide Image Picker
                            AdminImagePickerField(
                              label: 'Slide Image',
                              helperText: 'Select comic slide artwork',
                              initialImagePathOrUrl: (slide['imageUrl'] ?? '').toString().isEmpty
                                  ? null
                                  : slide['imageUrl'],
                              onImageSelected: (path) {
                                slide['imageUrl'] = path;
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),

                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF2563EB),
                      side: const BorderSide(color: Color(0xFF2563EB)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    ),
                    icon: const Icon(Iconsax.add_circle, size: 18),
                    label: const Text('Add Another Story Slide'),
                    onPressed: () {
                      setState(() {
                        _slides.add({
                          'title': 'Chapter ${_slides.length + 1}',
                          'caption': 'Heroic moment in history.',
                          'imageUrl': 'https://images.unsplash.com/photo-1607604276583-eef5d076aa5f?w=800',
                        });
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Submit Skewed Button
              SkewedButton(
                text: isEdit ? 'UPDATE HERO STORY & LORE' : 'PUBLISH HERO STORY & LORE',
                backgroundColor: AppColors.comicRed,
                onPressed: _onSave,
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color accentColor,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.adminLightBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: accentColor, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.adminLightTextSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}
