import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../../core/theme/app_colors.dart';

class AdminImagePickerField extends StatefulWidget {
  final String? initialImagePathOrUrl;
  final ValueChanged<String> onImageSelected;
  final String label;
  final String? helperText;
  final double previewHeight;

  const AdminImagePickerField({
    super.key,
    this.initialImagePathOrUrl,
    required this.onImageSelected,
    this.label = 'Image / Banner',
    this.helperText,
    this.previewHeight = 180,
  });

  @override
  State<AdminImagePickerField> createState() => _AdminImagePickerFieldState();
}

class _AdminImagePickerFieldState extends State<AdminImagePickerField> {
  final ImagePicker _picker = ImagePicker();
  String? _currentImagePath;
  bool _showUrlInput = false;
  late TextEditingController _urlController;

  @override
  void initState() {
    super.initState();
    _currentImagePath = widget.initialImagePathOrUrl;
    _urlController = TextEditingController(text: widget.initialImagePathOrUrl ?? '');
  }

  @override
  void didUpdateWidget(covariant AdminImagePickerField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialImagePathOrUrl != widget.initialImagePathOrUrl &&
        widget.initialImagePathOrUrl != _currentImagePath) {
      setState(() {
        _currentImagePath = widget.initialImagePathOrUrl;
        _urlController.text = widget.initialImagePathOrUrl ?? '';
      });
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _currentImagePath = image.path;
          _urlController.text = image.path;
          _showUrlInput = false;
        });
        widget.onImageSelected(image.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showImageSourceModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Select Image Source',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Choose image from your mobile device or capture new',
                  style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.comicRed.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Iconsax.gallery, color: AppColors.comicRed, size: 22),
                  ),
                  title: const Text('Choose from Gallery', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
                  subtitle: const Text('Select a photo from device storage', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _pickImage(ImageSource.gallery);
                  },
                ),
                const Divider(height: 1, color: Color(0xFFE2E8F0)),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Iconsax.camera, color: Color(0xFF2563EB), size: 22),
                  ),
                  title: const Text('Take a Photo', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
                  subtitle: const Text('Capture new photo with mobile camera', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _pickImage(ImageSource.camera);
                  },
                ),
                const Divider(height: 1, color: Color(0xFFE2E8F0)),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Iconsax.link, color: Color(0xFFF59E0B), size: 22),
                  ),
                  title: const Text('Enter Web Image URL', style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
                  subtitle: const Text('Paste direct URL to an online image', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                  onTap: () {
                    Navigator.of(ctx).pop();
                    setState(() {
                      _showUrlInput = true;
                    });
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _clearImage() {
    setState(() {
      _currentImagePath = null;
      _urlController.clear();
      _showUrlInput = false;
    });
    widget.onImageSelected('');
  }

  Widget _buildPreview(String pathOrUrl) {
    final bool isNetwork = pathOrUrl.startsWith('http://') || pathOrUrl.startsWith('https://');

    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            height: widget.previewHeight,
            color: const Color(0xFFF1F5F9),
            child: isNetwork
                ? Image.network(
                    pathOrUrl,
                    width: double.infinity,
                    height: widget.previewHeight,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildErrorPlaceholder(),
                  )
                : Image.file(
                    File(pathOrUrl),
                    width: double.infinity,
                    height: widget.previewHeight,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _buildErrorPlaceholder(),
                  ),
          ),
        ),
        // Source tag
        Positioned(
          top: 10,
          left: 10,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isNetwork ? Iconsax.global : Iconsax.mobile,
                  size: 12,
                  color: Colors.white,
                ),
                const SizedBox(width: 4),
                Text(
                  isNetwork ? 'Web Image' : 'Device Image',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Change & Remove actions
        Positioned(
          top: 10,
          right: 10,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: _showImageSourceModal,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: const Icon(Iconsax.edit, size: 16, color: Color(0xFF0F172A)),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: _clearImage,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: const Icon(Iconsax.trash, size: 16, color: AppColors.error),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorPlaceholder() {
    return Container(
      color: const Color(0xFFF8FAFC),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Iconsax.gallery_slash, size: 36, color: Color(0xFF94A3B8)),
            SizedBox(height: 6),
            Text(
              'Could not load preview',
              style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyPlaceholder() {
    return InkWell(
      onTap: _showImageSourceModal,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFFCBD5E1),
            style: BorderStyle.solid,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.comicRed.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Iconsax.gallery_add, size: 28, color: AppColors.comicRed),
            ),
            const SizedBox(height: 10),
            const Text(
              'Select Image from Mobile',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Tap to choose from Gallery or take with Camera',
              style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  icon: const Icon(Iconsax.gallery, size: 14),
                  label: const Text('Gallery', style: TextStyle(fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF0F172A),
                    side: const BorderSide(color: Color(0xFFCBD5E1)),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera),
                  icon: const Icon(Iconsax.camera, size: 14),
                  label: const Text('Camera', style: TextStyle(fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF0F172A),
                    side: const BorderSide(color: Color(0xFFCBD5E1)),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasImage = _currentImagePath != null && _currentImagePath!.trim().isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF475569),
              ),
            ),
            if (!hasImage)
              TextButton(
                onPressed: () {
                  setState(() {
                    _showUrlInput = !_showUrlInput;
                  });
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  _showUrlInput ? 'Hide URL input' : 'Use image URL instead',
                  style: const TextStyle(fontSize: 11, color: AppColors.comicRed),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (hasImage)
          _buildPreview(_currentImagePath!)
        else
          _buildEmptyPlaceholder(),

        if (_showUrlInput && !hasImage) ...[
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _urlController,
                  style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
                  decoration: InputDecoration(
                    hintText: 'https://images.unsplash.com/...',
                    hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F172A),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  final text = _urlController.text.trim();
                  if (text.isNotEmpty) {
                    setState(() {
                      _currentImagePath = text;
                      _showUrlInput = false;
                    });
                    widget.onImageSelected(text);
                  }
                },
                child: const Text('Apply', style: TextStyle(color: Colors.white, fontSize: 12)),
              ),
            ],
          ),
        ],

        if (widget.helperText != null) ...[
          const SizedBox(height: 6),
          Text(
            widget.helperText!,
            style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
          ),
        ],
      ],
    );
  }
}
