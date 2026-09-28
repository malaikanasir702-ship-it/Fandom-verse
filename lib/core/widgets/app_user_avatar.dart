import 'dart:io';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../theme/app_colors.dart';

/// Universal user avatar widget supporting local files, network URLs, asset paths,
/// and stylized initial badges with error fallbacks.
class AppUserAvatar extends StatelessWidget {
  final String? avatarUrl;
  final String displayName;
  final double size;
  final bool showBorder;
  final Color? borderColor;
  final double borderWidth;
  final bool showEditBadge;
  final IconData editBadgeIcon;
  final VoidCallback? onTap;

  const AppUserAvatar({
    super.key,
    this.avatarUrl,
    this.displayName = 'User',
    this.size = 40,
    this.showBorder = true,
    this.borderColor,
    this.borderWidth = 1.5,
    this.showEditBadge = false,
    this.editBadgeIcon = Iconsax.camera,
    this.onTap,
  });

  String get _initial {
    final clean = displayName.trim();
    if (clean.isEmpty) return 'U';
    return clean[0].toUpperCase();
  }

  Widget _buildFallback(BuildContext context, bool isDark) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFFE53935), Color(0xFFD32F2F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Text(
          _initial,
          style: TextStyle(
            fontSize: size * 0.42,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildImage(BuildContext context, bool isDark) {
    final url = avatarUrl?.trim();
    if (url == null || url.isEmpty) {
      return _buildFallback(context, isDark);
    }

    // 1. Network image
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return Image.network(
        url,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildFallback(context, isDark),
      );
    }

    // 2. Asset image
    if (url.startsWith('assets/')) {
      return Image.asset(
        url,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildFallback(context, isDark),
      );
    }

    // 3. Local file
    try {
      final file = File(url);
      if (file.existsSync()) {
        return Image.file(
          file,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildFallback(context, isDark),
        );
      }
    } catch (_) {}

    return _buildFallback(context, isDark);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final resolvedBorderColor = borderColor ?? (isDark ? AppColors.comicYellow : AppColors.comicRed);

    Widget avatarWidget = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: showBorder
            ? Border.all(
                color: resolvedBorderColor,
                width: borderWidth,
              )
            : null,
        boxShadow: showBorder
            ? [
                BoxShadow(
                  color: resolvedBorderColor.withValues(alpha: 0.25),
                  blurRadius: 6,
                  spreadRadius: 0,
                ),
              ]
            : null,
      ),
      child: ClipOval(
        child: _buildImage(context, isDark),
      ),
    );

    if (showEditBadge) {
      final badgeSize = (size * 0.32).clamp(24.0, 36.0);
      final iconSize = badgeSize * 0.55;

      avatarWidget = Stack(
        clipBehavior: Clip.none,
        children: [
          avatarWidget,
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: badgeSize,
              height: badgeSize,
              decoration: BoxDecoration(
                color: AppColors.comicYellow,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? AppColors.darkSurface : Colors.white,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  editBadgeIcon,
                  size: iconSize,
                  color: AppColors.comicBlack,
                ),
              ),
            ),
          ),
        ],
      );
    }

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: avatarWidget,
      );
    }

    return avatarWidget;
  }
}
