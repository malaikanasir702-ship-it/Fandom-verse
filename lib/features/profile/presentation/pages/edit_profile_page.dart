import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/skewed_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/app_user_avatar.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../widgets/profile_picture_sheet.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _bioController;
  late TextEditingController _cityController;
  late TextEditingController _fanbaseController;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    final authUser = context.read<AuthBloc>().currentUser;
    _bioController = TextEditingController(text: authUser?.bio ?? '');
    _cityController = TextEditingController(text: authUser?.city ?? '');
    _fanbaseController = TextEditingController(text: authUser?.fanbase ?? '');
    
    _bioController.addListener(() => setState(() => _hasChanges = true));
    _cityController.addListener(() => setState(() => _hasChanges = true));
    _fanbaseController.addListener(() => setState(() => _hasChanges = true));
  }

  @override
  void dispose() {
    _bioController.dispose();
    _cityController.dispose();
    _fanbaseController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    final authUser = context.read<AuthBloc>().currentUser;
    if (authUser == null) return;

    context.read<AuthBloc>().add(
      UpdateUserProfileEvent(
        bio: _bioController.text.trim(),
        city: _cityController.text.trim(),
        fanbase: _fanbaseController.text.trim(),
      ),
    );

    if (authUser.id.isNotEmpty) {
      context.read<ProfileBloc>().add(
        UpdateProfileEvent(
          userId: authUser.id,
          bio: _bioController.text.trim(),
          city: _cityController.text.trim(),
          fanbase: _fanbaseController.text.trim(),
        ),
      );
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('? Profile updated successfully!'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authUser = context.watch<AuthBloc>().currentUser;
    final displayName = authUser?.name ?? 'User';
    final userEmail = authUser?.email ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile', style: TextStyle(fontWeight: FontWeight.w800)),
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left),
          onPressed: () {
            if (_hasChanges) {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: isDark ? AppColors.darkSurfaceElevated : Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  title: const Text('Discard Changes?', style: TextStyle(fontWeight: FontWeight.w800)),
                  content: const Text('You have unsaved changes. Do you want to discard them?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text('CANCEL', style: TextStyle(color: AppColors.comicGray)),
                    ),
                    SkewedButton(
                      text: 'Discard',
                      height: 44,
                      fontSize: 12,
                      backgroundColor: AppColors.comicRed,
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ),
              );
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
        actions: [
          if (_hasChanges)
            TextButton(
              onPressed: _saveProfile,
              child: const Text(
                'SAVE',
                style: TextStyle(
                  color: AppColors.comicRed,
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  AppUserAvatar(
                    avatarUrl: authUser?.avatarUrl,
                    displayName: displayName,
                    size: 110,
                    showBorder: true,
                    borderWidth: 3,
                    borderColor: AppColors.comicRed,
                    showEditBadge: true,
                    editBadgeIcon: Iconsax.camera,
                    onTap: () {
                      ProfilePictureSheet.show(
                        context: context,
                        currentAvatarUrl: authUser?.avatarUrl,
                        onSelectedUrl: (url) {
                          context.read<AuthBloc>().add(UpdateUserProfileEvent(avatarUrl: url));
                          if (authUser != null && authUser.id.isNotEmpty) {
                            context.read<ProfileBloc>().add(
                              UpdateAvatarEvent(userId: authUser.id, imagePath: url),
                            );
                          }
                          setState(() => _hasChanges = true);
                        },
                        onRemoveAvatar: () {
                          context.read<AuthBloc>().add(const UpdateUserProfileEvent(removeAvatar: true));
                          if (authUser != null && authUser.id.isNotEmpty) {
                            context.read<ProfileBloc>().add(
                              UpdateAvatarEvent(userId: authUser.id, imagePath: ''),
                            );
                          }
                          setState(() => _hasChanges = true);
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Tap to change profile picture',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            const Text(
              'Display Name',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.comicBorderColor,
                ),
              ),
              child: Row(
                children: [
                  const Icon(Iconsax.user, size: 18, color: AppColors.comicGray),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      displayName,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Name can be changed from Settings',
              style: TextStyle(
                fontSize: 11,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              'Email Address',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.comicBorderColor,
                ),
              ),
              child: Row(
                children: [
                  const Icon(Iconsax.sms, size: 18, color: AppColors.comicGray),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      userEmail,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'Fandom Bio',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            CustomTextField(
              controller: _bioController,
              hintText: 'Tell the fandom community about yourself...',
              maxLines: 4,
            ),
            const SizedBox(height: 24),

            const Text(
              'Home City',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            CustomTextField(
              controller: _cityController,
              hintText: 'e.g. Tokyo, New York, Mumbai',
              prefixIcon: const Icon(Iconsax.location),
            ),
            const SizedBox(height: 24),

            const Text(
              'Favorite Fanbase',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            CustomTextField(
              controller: _fanbaseController,
              hintText: 'e.g. Marvel, Anime, DC Comics',
              prefixIcon: const Icon(Iconsax.heart),
            ),
            const SizedBox(height: 32),

            const Text(
              'Fandom Preferences',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.comicBorderColor,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Iconsax.setting_2, size: 18, color: AppColors.comicRed),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Content Preferences',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pushNamed('/interest-setup'),
                        child: const Text(
                          'MANAGE',
                          style: TextStyle(
                            color: AppColors.comicRed,
                            fontWeight: FontWeight.w900,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Manage your selected fandoms and content preferences to get personalized recommendations.',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: SkewedButton(
                text: 'SAVE PROFILE',
                icon: Iconsax.tick_circle,
                height: 52,
                fontSize: 15,
                backgroundColor: _hasChanges ? AppColors.comicRed : AppColors.comicGray,
                onPressed: _hasChanges ? _saveProfile : null,
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}