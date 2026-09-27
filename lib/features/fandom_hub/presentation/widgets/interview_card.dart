import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../domain/entities/interview_entity.dart';

class InterviewCard extends StatelessWidget {
  final InterviewEntity interview;
  final VoidCallback onTap;

  const InterviewCard({
    super.key,
    required this.interview,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassContainer(
      padding: const EdgeInsets.all(16),
      onTap: onTap,
      child: Row(
        children: [
          // Circular Avatar
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.comicYellow.withValues(alpha: 0.5),
                width: 2,
              ),
            ),
            child: ClipOval(
              child: interview.imageUrl != null && interview.imageUrl!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: interview.imageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: AppColors.darkSurface,
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                      errorWidget: (context, url, error) => _buildFallbackAvatar(),
                    )
                  : _buildFallbackAvatar(),
            ),
          ),
          const SizedBox(width: 14),

          // Name, Role, Fandom
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        interview.intervieweeName,
                        style: AppTextStyles.titleMedium.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (interview.fandomCategory.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.comicYellow.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          interview.fandomCategory,
                          style: const TextStyle(
                            color: AppColors.comicYellowDark,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  interview.roleTitle,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (interview.interviewDate.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Iconsax.calendar_1,
                          size: 12, color: AppColors.comicGray),
                      const SizedBox(width: 4),
                      Text(
                        interview.interviewDate,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.comicGray,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(
            Iconsax.arrow_right_3,
            size: 16,
            color: AppColors.comicYellowDark,
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackAvatar() {
    return Container(
      color: AppColors.comicYellow.withValues(alpha: 0.2),
      child: Center(
        child: Text(
          interview.intervieweeName.isNotEmpty
              ? interview.intervieweeName[0].toUpperCase()
              : 'I',
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.comicYellowDark,
          ),
        ),
      ),
    );
  }
}
