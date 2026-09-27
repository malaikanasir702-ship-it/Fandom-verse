import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../domain/entities/advanced_lore_entity.dart';

class AdvancedLoreCard extends StatefulWidget {
  final AdvancedLoreEntity lore;

  const AdvancedLoreCard({
    super.key,
    required this.lore,
  });

  @override
  State<AdvancedLoreCard> createState() => _AdvancedLoreCardState();
}

class _AdvancedLoreCardState extends State<AdvancedLoreCard> {
  bool _isExpanded = false;

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        return AppColors.success;
      case 'intermediate':
        return AppColors.warning;
      case 'expert':
        return AppColors.error;
      default:
        return AppColors.comicYellow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final diffColor = _getDifficultyColor(widget.lore.difficultyLevel);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassContainer(
      padding: const EdgeInsets.all(16),
      borderColor: _isExpanded ? diffColor.withValues(alpha: 0.4) : null,
      onTap: () {
        setState(() {
          _isExpanded = !_isExpanded;
        });
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // Difficulty badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: diffColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: diffColor.withValues(alpha: 0.4),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            widget.lore.difficultyLevel.toUpperCase(),
                            style: TextStyle(
                              color: diffColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        if (widget.lore.fandomCategory.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Text(
                            widget.lore.fandomCategory,
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.lore.title,
                      style: AppTextStyles.titleMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              AnimatedRotation(
                turns: _isExpanded ? 0.5 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  Iconsax.arrow_down_1,
                  size: 18,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
          if (_isExpanded) ...[
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Text(
              widget.lore.contentBody,
              style: AppTextStyles.bodyMedium.copyWith(
                height: 1.6,
                color: isDark ? AppColors.darkText : AppColors.comicBlack,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
