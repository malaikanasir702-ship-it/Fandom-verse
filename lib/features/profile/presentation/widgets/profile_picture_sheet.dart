import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/skewed_button.dart';
import '../../../../core/services/cloudinary_service.dart';

class FandomAvatarPreset {
  final String title;
  final String category;
  final String url;

  const FandomAvatarPreset({
    required this.title,
    required this.category,
    required this.url,
  });
}

class ProfilePictureSheet extends StatefulWidget {
  final String? currentAvatarUrl;
  final ValueChanged<String> onSelectedUrl;
  final VoidCallback onRemoveAvatar;

  const ProfilePictureSheet({
    super.key,
    required this.currentAvatarUrl,
    required this.onSelectedUrl,
    required this.onRemoveAvatar,
  });

  static const List<FandomAvatarPreset> presets = [
    FandomAvatarPreset(
      title: 'Anime Hero',
      category: 'Anime',
      url: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=400',
    ),
    FandomAvatarPreset(
      title: 'Cyber Ronin',
      category: 'Gaming',
      url: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=400',
    ),
    FandomAvatarPreset(
      title: 'Spider Hero',
      category: 'Marvel',
      url: 'https://images.unsplash.com/photo-1635805737707-575885ab0820?w=400',
    ),
    FandomAvatarPreset(
      title: 'Dark Knight',
      category: 'DC / Comics',
      url: 'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?w=400',
    ),
    FandomAvatarPreset(
      title: 'Mercenary',
      category: 'Comics',
      url: 'https://images.unsplash.com/photo-1607604276583-eef5d076aa5f?w=400',
    ),
    FandomAvatarPreset(
      title: 'Star Nomad',
      category: 'Sci-Fi',
      url: 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=400',
    ),
    FandomAvatarPreset(
      title: 'Speedrunner',
      category: 'Gaming',
      url: 'https://images.unsplash.com/photo-1522075469751-3a6694fb2f61?w=400',
    ),
    FandomAvatarPreset(
      title: 'Lore Scholar',
      category: 'Lore',
      url: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
    ),
    FandomAvatarPreset(
      title: 'Manga Artist',
      category: 'Cosplay',
      url: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=400',
    ),
  ];

  static Future<void> show({
    required BuildContext context,
    required String? currentAvatarUrl,
    required ValueChanged<String> onSelectedUrl,
    required VoidCallback onRemoveAvatar,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => ProfilePictureSheet(
        currentAvatarUrl: currentAvatarUrl,
        onSelectedUrl: onSelectedUrl,
        onRemoveAvatar: onRemoveAvatar,
      ),
    );
  }

  @override
  State<ProfilePictureSheet> createState() => _ProfilePictureSheetState();
}

class _ProfilePictureSheetState extends State<ProfilePictureSheet> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _urlController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  String? _previewUrl;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    if (widget.currentAvatarUrl != null && widget.currentAvatarUrl!.isNotEmpty) {
      _urlController.text = widget.currentAvatarUrl!;
      _previewUrl = widget.currentAvatarUrl!;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  // ── Pick image from camera/gallery and upload to Cloudinary ──
  Future<void> _pickAndUploadAvatar(ImageSource source) async {
    final XFile? pickedFile;
    try {
      pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 88,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return;
    }
    if (pickedFile == null) return;
    final XFile image = pickedFile;

    setState(() {
      _previewUrl = image.path; // show local preview instantly
      _isUploading = true;
    });

    try {
      final cloudUrl = await CloudinaryService.instance.uploadImage(
        File(image.path),
        folder: CloudinaryService.folderAvatars,
      );

      if (mounted) {
        setState(() {
          _previewUrl = cloudUrl;
          _urlController.text = cloudUrl;
          _isUploading = false;
        });
        widget.onSelectedUrl(cloudUrl);
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Avatar uploaded to Cloudinary!'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploading = false);
        // Fallback to local image file so user avatar always updates instantly!
        widget.onSelectedUrl(image.path);
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Avatar updated from device!'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _applyUrl(String url) {
    final trimmed = url.trim();
    if (trimmed.isEmpty) return;
    widget.onSelectedUrl(trimmed);
    Navigator.of(context).pop();
  }

  void _handleRemove() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(ctx).brightness == Brightness.dark
            ? AppColors.darkSurfaceElevated
            : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Iconsax.trash, color: AppColors.comicRed, size: 22),
            SizedBox(width: 8),
            Text(
              'Remove Photo?',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
            ),
          ],
        ),
        content: const Text(
          'Your profile picture will be removed and reset to default initials.',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('CANCEL', style: TextStyle(color: AppColors.comicGray)),
          ),
          SkewedButton(
            text: 'Remove',
            height: 44,
            fontSize: 12,
            backgroundColor: AppColors.comicRed,
            icon: Iconsax.trash,
            onPressed: () {
              Navigator.of(ctx).pop(); // pop confirm dialog
              widget.onRemoveAvatar();
              Navigator.of(context).pop(); // pop bottom sheet
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasAvatar = widget.currentAvatarUrl != null && widget.currentAvatarUrl!.trim().isNotEmpty;

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[700] : Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PROFILE PICTURE',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                      color: isDark ? AppColors.comicYellow : AppColors.comicRed,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Update Avatar',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
              if (hasAvatar)
                TextButton.icon(
                  onPressed: _handleRemove,
                  icon: const Icon(Iconsax.trash, size: 16, color: AppColors.comicRed),
                  label: const Text(
                    'Remove',
                    style: TextStyle(
                      color: AppColors.comicRed,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Tab Bar
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurfaceElevated : AppColors.comicGrayLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                color: AppColors.comicRed,
                borderRadius: BorderRadius.circular(12),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: isDark ? AppColors.darkTextSecondary : AppColors.comicGray,
              labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              tabs: const [
                Tab(
                  icon: Icon(Iconsax.link, size: 16),
                  text: 'Image URL',
                ),
                Tab(
                  icon: Icon(Iconsax.magicpen, size: 16),
                  text: 'Fandom Presets',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Tab Views
          SizedBox(
            height: 330,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildUrlInputView(isDark),
                _buildPresetGridView(isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUrlInputView(bool isDark) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Upload from Device to Cloudinary ──
          const Text(
            'Upload from Device',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: SkewedButton(
                  text: _isUploading ? 'Uploading...' : 'Gallery',
                  height: 46,
                  fontSize: 12,
                  backgroundColor: AppColors.comicRed,
                  icon: Iconsax.gallery,
                  onPressed: _isUploading
                      ? null
                      : () => _pickAndUploadAvatar(ImageSource.gallery),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SkewedButton(
                  text: _isUploading ? 'Uploading...' : 'Camera',
                  height: 46,
                  fontSize: 12,
                  backgroundColor: const Color(0xFF2563EB),
                  icon: Iconsax.camera,
                  onPressed: _isUploading
                      ? null
                      : () => _pickAndUploadAvatar(ImageSource.camera),
                ),
              ),
            ],
          ),
          if (_isUploading) ...[
            const SizedBox(height: 10),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 16, height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.comicRed),
                ),
                SizedBox(width: 8),
                Text('Uploading to Cloudinary CDN...', style: TextStyle(fontSize: 12)),
              ],
            ),
          ],
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 8),

          // ── Paste URL (fallback) ──
          const Text(
            'Or Paste Image URL',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            'Enter any direct public image link (JPEG, PNG, WebP) or a Cloudinary URL.',
            style: TextStyle(
              fontSize: 11,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _urlController,
            decoration: InputDecoration(
              hintText: 'https://res.cloudinary.com/... or any URL',
              prefixIcon: const Icon(Iconsax.link_21, size: 18),
              suffixIcon: _urlController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        setState(() {
                          _urlController.clear();
                          _previewUrl = null;
                        });
                      },
                    )
                  : null,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: isDark ? AppColors.darkSurfaceElevated : AppColors.lightBackground,
            ),
            onChanged: (val) {
              setState(() {
                _previewUrl = val.trim();
              });
            },
          ),
          const SizedBox(height: 16),

          // Live Preview
          Center(
            child: Column(
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDark ? AppColors.darkSurfaceElevated : Colors.grey[200],
                    border: Border.all(color: AppColors.comicYellow, width: 2.5),
                  ),
                  child: ClipOval(
                    child: (_previewUrl != null && _previewUrl!.isNotEmpty)
                        ? Image.network(
                            _previewUrl!,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const Center(
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.comicRed),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Icon(Iconsax.warning_2, color: AppColors.comicRed, size: 30),
                              );
                            },
                          )
                        : const Center(
                            child: Icon(Iconsax.user, size: 36, color: AppColors.comicGray),
                          ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  (_previewUrl != null && _previewUrl!.isNotEmpty)
                      ? 'Preview'
                      : 'Avatar Preview',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.comicGray,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Action Button
          SkewedButton(
            text: 'Save Image URL',
            icon: Iconsax.tick_circle,
            height: 48,
            fontSize: 13,
            backgroundColor: AppColors.comicRed,
            onPressed: (_previewUrl != null && _previewUrl!.isNotEmpty)
                ? () => _applyUrl(_previewUrl!)
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildPresetGridView(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tap any hero avatar to apply:',
          style: TextStyle(
            fontSize: 12,
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: GridView.builder(
            itemCount: ProfilePictureSheet.presets.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            itemBuilder: (context, index) {
              final preset = ProfilePictureSheet.presets[index];
              final isSelected = widget.currentAvatarUrl == preset.url;

              return GestureDetector(
                onTap: () => _applyUrl(preset.url),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurfaceElevated : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? AppColors.comicRed : (isDark ? AppColors.darkBorder : AppColors.comicBorderColor),
                      width: isSelected ? 2.5 : 1.0,
                    ),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundImage: NetworkImage(preset.url),
                            backgroundColor: AppColors.comicRed,
                          ),
                          if (isSelected)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  color: AppColors.comicRed,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.check, size: 14, color: Colors.white),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        preset.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
                      ),
                      Text(
                        preset.category,
                        style: TextStyle(
                          fontSize: 9,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.comicGray,
                        ),
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
  }
}
