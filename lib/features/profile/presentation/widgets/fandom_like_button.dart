import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class FandomLikeButton extends StatelessWidget {
  final String categoryId;
  final bool isLiked;
  final VoidCallback onToggle;
  final double size;

  const FandomLikeButton({
    super.key,
    required this.categoryId,
    required this.isLiked,
    required this.onToggle,
    this.size = 22,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        transitionBuilder: (child, animation) => ScaleTransition(
          scale: animation,
          child: child,
        ),
        child: Icon(
          isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          key: ValueKey(isLiked),
          color: isLiked ? AppColors.comicRed : AppColors.comicGray,
          size: size,
        ),
      ),
    );
  }
}
