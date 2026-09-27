import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/theme/app_colors.dart';

class ProfilePicturePicker extends StatefulWidget {
  final String? currentAvatarUrl;
  final String displayName;
  final void Function(String imagePath) onImageSelected;

  const ProfilePicturePicker({
    super.key,
    this.currentAvatarUrl,
    required this.displayName,
    required this.onImageSelected,
  });

  @override
  State<ProfilePicturePicker> createState() => _ProfilePicturePickerState();
}

class _ProfilePicturePickerState extends State<ProfilePicturePicker> {
  String? _localImagePath;
  final ImagePicker _picker = ImagePicker();

  String get _initial =>
      widget.displayName.isNotEmpty ? widget.displayName[0].toUpperCase() : 'U';

  Future<void> _showImageSourceSheet() async {
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: AppColors.darkCard,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Choose Profile Photo',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            _sourceOption(
              icon: Icons.photo_library_rounded,
              label: 'Gallery',
              onTap: () => _pickImage(ImageSource.gallery),
            ),
            const SizedBox(height: 12),
            _sourceOption(
              icon: Icons.camera_alt_rounded,
              label: 'Camera',
              onTap: () => _pickImage(ImageSource.camera),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _sourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pop();
        onTap();
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.darkAccent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.comicYellow, size: 22),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 512,
        maxHeight: 512,
      );

      if (file == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Image selection cancelled.'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      }

      setState(() => _localImagePath = file.path);
      widget.onImageSelected(file.path);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString().contains('permission')
                  ? 'Permission denied. Please allow camera/gallery access in Settings.'
                  : 'Failed to pick image. Please try again.',
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showImageSourceSheet,
      child: Stack(
        children: [
          CircleAvatar(
            radius: 46,
            backgroundColor: AppColors.comicRed,
            backgroundImage: _localImagePath != null
                ? FileImage(File(_localImagePath!))
                : (widget.currentAvatarUrl != null &&
                        widget.currentAvatarUrl!.isNotEmpty
                    ? NetworkImage(widget.currentAvatarUrl!) as ImageProvider
                    : null),
            child: (_localImagePath == null &&
                    (widget.currentAvatarUrl == null ||
                        widget.currentAvatarUrl!.isEmpty))
                ? Text(
                    _initial,
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  )
                : null,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: AppColors.comicYellow,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.camera_alt_rounded,
                  size: 16, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
