import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/skewed_button.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../widgets/profile_picture_picker.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late final TextEditingController _nameController;
  late final TextEditingController _bioController;
  late String _userId;
  String? _pendingAvatarPath;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthBloc>().currentUser;
    _userId = user?.id ?? 'fan-01';
    _nameController = TextEditingController(text: user?.name ?? '');
    _bioController = TextEditingController(text: user?.bio ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);

    // Dispatch avatar update if a new image was selected
    if (_pendingAvatarPath != null) {
      context.read<ProfileBloc>().add(
            UpdateAvatarEvent(
              userId: _userId,
              imagePath: _pendingAvatarPath!,
            ),
          );
    }

    context.read<ProfileBloc>().add(
          UpdateProfileDetailsEvent(
            userId: _userId,
            name: _nameController.text.trim(),
            bio: _bioController.text.trim(),
            avatarUrl: _pendingAvatarPath ?? context.read<AuthBloc>().currentUser?.avatarUrl ?? '',
            selectedFandoms:
                context.read<AuthBloc>().currentUser?.selectedFandoms ?? [],
          ),
        );
    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthBloc>().currentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile',
            style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar with ProfilePicturePicker
            Center(
              child: ProfilePicturePicker(
                currentAvatarUrl: user?.avatarUrl,
                displayName: _nameController.text,
                onImageSelected: (path) {
                  setState(() => _pendingAvatarPath = path);
                },
              ),
            ),
            const SizedBox(height: 8),
            const Center(
              child: Text(
                'Tap to change profile photo',
                style: TextStyle(fontSize: 12, color: AppColors.comicGray),
              ),
            ),
            const SizedBox(height: 24),

            _buildInputField('Display Name', _nameController),
            const SizedBox(height: 16),
            _buildBioField(),
            const SizedBox(height: 32),

            SkewedButton(
              text: _isSaving ? 'Saving...' : 'Save Changes',
              height: 52,
              fontSize: 14,
              icon: Icons.check_circle_outline_rounded,
              onPressed: _isSaving ? null : _saveProfile,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller,
      {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.w700, fontSize: 13)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  Widget _buildBioField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Bio',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
        const SizedBox(height: 8),
        TextFormField(
          controller: _bioController,
          maxLines: 4,
          maxLength: 200,
          decoration: InputDecoration(
            hintText: 'Tell other fans about yourself...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }
}
