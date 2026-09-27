import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../../profile/presentation/widgets/fandom_like_button.dart';

export '../../../profile/presentation/widgets/fandom_like_button.dart';

class FandomCard extends StatelessWidget {
  final String categoryId;
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Color? color;
  final String? imageUrl;
  final bool isLiked;
  final VoidCallback onToggleLike;
  final VoidCallback? onTap;

  const FandomCard({
    super.key,
    required this.categoryId,
    required this.title,
    this.subtitle,
    this.icon,
    this.color,
    this.imageUrl,
    required this.isLiked,
    required this.onToggleLike,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final themeColor = color ?? AppColors.comicRed;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassContainer(
      padding: const EdgeInsets.all(16),
      borderColor: themeColor.withValues(alpha: 0.25),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: themeColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: themeColor.withValues(alpha: 0.3)),
            ),
            child: Center(
              child: Icon(icon ?? Icons.category_rounded, size: 24, color: themeColor),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.w700),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    subtitle!,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          FandomLikeButton(
            categoryId: categoryId,
            isLiked: isLiked,
            onToggle: onToggleLike,
          ),
        ],
      ),
    );
  }
}
