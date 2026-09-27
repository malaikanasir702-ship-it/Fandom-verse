import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/behind_scenes_entity.dart';

class BehindScenesCard extends StatelessWidget {
  final BehindScenesEntity scene;
  final VoidCallback onTap;

  const BehindScenesCard({
    super.key,
    required this.scene,
    required this.onTap,
  });

  IconData _getMediaIcon(String type) {
    switch (type.toLowerCase()) {
      case 'video':
        return Iconsax.video_play;
      case 'image':
        return Iconsax.gallery;
      case 'article':
      default:
        return Iconsax.document_text;
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaIcon = _getMediaIcon(scene.mediaType);

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Thumbnail Image
            if (scene.mediaUrl != null && scene.mediaUrl!.isNotEmpty)
              CachedNetworkImage(
                imageUrl: scene.mediaUrl!,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: AppColors.darkSurface,
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: AppColors.darkSurface,
                  child: const Icon(Iconsax.image, color: Colors.white24),
                ),
              )
            else
              Container(
                color: AppColors.darkSurface,
                child: const Icon(Iconsax.image, color: Colors.white24),
              ),

            // Top-Right Media Type Badge
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(mediaIcon, size: 12, color: AppColors.comicYellow),
                    const SizedBox(width: 4),
                    Text(
                      scene.mediaType.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Title & Fandom Overlay
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.85),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      scene.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (scene.fandomCategory.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        scene.fandomCategory,
                        style: const TextStyle(
                          color: AppColors.comicYellow,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
