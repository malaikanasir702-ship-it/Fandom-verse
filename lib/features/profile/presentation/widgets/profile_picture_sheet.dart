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

class _ProfilePictureSheetState extends State<ProfilePictureSheet> {
  final ImagePicker _picker = ImagePicker();
  String? _uploadedPreviewUrl;
  bool _isUploading = false;
  bool _showPresets = false;

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
      _uploadedPreviewUrl = image.path;
      _isUploading = true;
    });

    try {
      final cloudUrl = await CloudinaryService.instance.uploadImage(
        File(image.path),
        folder: CloudinaryService.folderAvatars,
      );

      if (mounted) {
        setState(() {
          _uploadedPreviewUrl = cloudUrl;
          _isUploading = false;
        });
        widget.onSelectedUrl(cloudUrl);
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('? Profile picture updated!'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploading = false);
        widget.onSelectedUrl(image.path);
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('? Profile picture updated!'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _applyPreset(String url) {
    widget.onSelectedUrl(url);
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('? Avatar preset applied!'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
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
              Navigator.of(ctx).pop();
              widget.onRemoveAvatar();
              Navigator.of(context).pop();
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

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
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
          const SizedBox(height: 20),

          if (!_showPresets) ...[
            const Text(
              'Upload from Your Device',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: SkewedButton(
                    text: _isUploading ? 'Uploading...' : 'Gallery',
                    height: 52,
                    fontSize: 13,
                    backgroundColor: AppColors.comicRed,
                    icon: Iconsax.gallery,
                    onPressed: _isUploading
                        ? null
                        : () => _pickAndUploadAvatar(ImageSource.gallery),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SkewedButton(
                    text: _isUploading ? 'Uploading...' : 'Camera',
                    height: 52,
                    fontSize: 13,
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
              const SizedBox(height: 16),
              Center(
                child: Column(
                  children: [
                    const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: AppColors.comicRed,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Uploading to cloud...',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 16),

            Center(
              child: TextButton.icon(
                onPressed: () => setState(() => _showPresets = true),
                icon: const Icon(Iconsax.magicpen, size: 18, color: AppColors.comicRed),
                label: const Text(
                  'Browse Fandom Presets',
                  style: TextStyle(
                    color: AppColors.comicRed,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ] else ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Fandom Avatar Presets',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                ),
                TextButton(
                  onPressed: () => setState(() => _showPresets = false),
                  child: const Text(
                    'Upload Instead',
                    style: TextStyle(
                      color: AppColors.comicRed,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Tap any hero avatar to apply:',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 380,
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
                    onTap: () => _applyPreset(preset.url),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurfaceElevated : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.comicRed
                              : (isDark ? AppColors.darkBorder : AppColors.comicBorderColor),
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
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}