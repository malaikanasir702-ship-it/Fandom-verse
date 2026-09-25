import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../widgets/profile_picture_sheet.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late final TextEditingController _nameController;
  late final TextEditingController _handleController;
  late final TextEditingController _bioController;
  late final TextEditingController _cityController;
  String? _avatarUrl;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthBloc>().currentUser;
    _nameController = TextEditingController(text: user?.name ?? 'Alex Rivera');
    _handleController = TextEditingController(
      text: user?.name.isNotEmpty == true
          ? user!.name.toLowerCase().replaceAll(' ', '_')
          : 'OtakuMaster_99',
    );
    _bioController = TextEditingController(
      text: user?.bio ??
          'Die-hard Shonen anime fan, Soulsborne speedrun enthusiast, and Marvel comics archivist.',
    );
    _cityController = TextEditingController(text: 'Los Angeles, CA');
    _avatarUrl = user?.avatarUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _handleController.dispose();
    _bioController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  void _openAvatarPicker() {
    ProfilePictureSheet.show(
      context: context,
      currentAvatarUrl: _avatarUrl,
      onSelectedUrl: (url) {
        setState(() {
          _avatarUrl = url;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Avatar selected! Tap "Save Changes" to commit.'),
            backgroundColor: AppColors.comicYellowDark,
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      onRemoveAvatar: () {
        setState(() {
          _avatarUrl = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile picture removed. Tap "Save Changes" to commit.'),
            backgroundColor: AppColors.comicBlack,
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
    );
  }

  Future<void> _saveProfile() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a display name.'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      context.read<AuthBloc>().add(
        UpdateUserProfileEvent(
          name: name,
          bio: _bioController.text.trim(),
          avatarUrl: _avatarUrl,
          removeAvatar: _avatarUrl == null || _avatarUrl!.trim().isEmpty,
        ),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile picture & details updated successfully!'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasAvatar = _avatarUrl != null && _avatarUrl!.trim().isNotEmpty;
    final displayName = _nameController.text.trim();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Interactive Avatar Selector ───
            Center(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _openAvatarPicker,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 104,
                          height: 104,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.comicRed,
                            border: Border.all(
                              color: AppColors.comicYellow,
                              width: 3.5,
                            ),
                          ),
                          child: ClipOval(
                            child: hasAvatar
                                ? Image.network(
                                    _avatarUrl!,
                                    fit: BoxFit.cover,
                                    width: 104,
                                    height: 104,
                                    loadingBuilder: (context, child, progress) {
                                      if (progress == null) return child;
                                      return const Center(
                                        child: SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        ),
                                      );
                                    },
                                    errorBuilder: (_, __, ___) => const Center(
                                      child: Icon(Iconsax.profile_circle, size: 54, color: Colors.white),
                                    ),
                                  )
                                : Center(
                                    child: Text(
                                      displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U',
                                      style: const TextStyle(
                                        fontSize: 44,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                        // Camera icon action button
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: AppColors.comicYellow,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isDark ? AppColors.darkBackground : Colors.white,
                                width: 2.5,
                              ),
                            ),
                            child: const Center(
                              child: Icon(Iconsax.camera, size: 16, color: Colors.black),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Quick Action Buttons (Add/Change/Remove)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton.icon(
                        onPressed: _openAvatarPicker,
                        icon: const Icon(Iconsax.gallery_edit, size: 16, color: AppColors.comicRed),
                        label: Text(
                          hasAvatar ? 'Change Photo' : 'Add Photo',
                          style: const TextStyle(
                            color: AppColors.comicRed,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      if (hasAvatar) ...[
                        const SizedBox(width: 8),
                        TextButton.icon(
                          onPressed: () {
                            setState(() => _avatarUrl = null);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Photo marked for removal. Tap "Save Changes" to confirm.'),
                                backgroundColor: AppColors.comicBlack,
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          icon: const Icon(Iconsax.trash, size: 16, color: AppColors.comicGray),
                          label: const Text(
                            'Remove',
                            style: TextStyle(
                              color: AppColors.comicGray,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            _buildInputField('Display Name', _nameController),
            const SizedBox(height: 16),
            _buildInputField('Fandom Handle (@username)', _handleController),
            const SizedBox(height: 16),
            _buildInputField('Home City / Base Region', _cityController),
            const SizedBox(height: 16),
            _buildInputField('Bio & Favorite Universes', _bioController, maxLines: 4),
            const SizedBox(height: 32),

            CustomButton(
              text: _isSaving ? 'Saving...' : 'Save Changes',
              onPressed: _isSaving ? null : _saveProfile,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }
}
