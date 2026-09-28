import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:video_player/video_player.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/glass_container.dart';
import '../../domain/entities/behind_scenes_entity.dart';

class BehindScenesDetailPage extends StatelessWidget {
  final BehindScenesEntity scene;

  const BehindScenesDetailPage({
    super.key,
    required this.scene,
  });

  Widget _buildMediaContent(BuildContext context) {
    final type = scene.mediaType.toLowerCase();

    if (type == 'image' && scene.mediaUrl != null && scene.mediaUrl!.isNotEmpty) {
      return SizedBox(
        height: 280,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: InteractiveViewer(
            maxScale: 3.0,
            child: CachedNetworkImage(
              imageUrl: scene.mediaUrl!,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: AppColors.darkSurface,
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => Container(
                color: AppColors.darkSurface,
                child: const Center(
                  child: Icon(Iconsax.image, size: 48, color: Colors.white24),
                ),
              ),
            ),
          ),
        ),
      );
    } else if (type == 'video') {
      return _InAppVideoPlayer(videoUrl: scene.mediaUrl ?? '');
    } else {
      // Article type
      return GlassContainer(
        padding: const EdgeInsets.all(16),
        borderColor: AppColors.comicYellow.withValues(alpha: 0.3),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.comicYellow.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Iconsax.document_text,
                  size: 28, color: AppColors.comicYellowDark),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'EXCLUSIVE ARCHIVE ARTICLE',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.comicYellowDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Curated Production Documentation',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          scene.title,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Header Badge
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.comicRed.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  scene.fandomCategory.toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.comicRed,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
                child: Text(
                  scene.mediaType.toUpperCase(),
                  style: TextStyle(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Title
          Text(
            scene.title,
            style: AppTextStyles.displaySmall.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),

          // Media Content Viewer
          _buildMediaContent(context),
          const SizedBox(height: 20),

          // Description Section
          Text(
            'BEHIND THE SCENES DETAILS',
            style: AppTextStyles.comicSectionHeader.copyWith(
              fontSize: 13,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 8),
          GlassContainer(
            padding: const EdgeInsets.all(18),
            child: Text(
              scene.description,
              style: AppTextStyles.bodyMedium.copyWith(
                height: 1.6,
                fontSize: 15,
                color: isDark ? AppColors.darkTextPrimary : AppColors.comicBlack,
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

/// In-app video player using video_player package.
/// Plays network videos directly inside the app.
class _InAppVideoPlayer extends StatefulWidget {
  final String videoUrl;
  const _InAppVideoPlayer({required this.videoUrl});

  @override
  State<_InAppVideoPlayer> createState() => _InAppVideoPlayerState();
}

class _InAppVideoPlayerState extends State<_InAppVideoPlayer> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    if (widget.videoUrl.isNotEmpty) {
      _controller = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl),
      )..initialize().then((_) {
          if (mounted) setState(() => _isInitialized = true);
        }).catchError((_) {
          if (mounted) setState(() => _hasError = true);
        });
    } else {
      _hasError = true;
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _togglePlay() {
    if (_controller == null) return;
    setState(() {
      _isPlaying = !_isPlaying;
      _isPlaying ? _controller!.play() : _controller!.pause();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        color: Colors.black,
        child: AspectRatio(
          aspectRatio: _isInitialized
              ? _controller!.value.aspectRatio
              : 16 / 9,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (_isInitialized && !_hasError)
                VideoPlayer(_controller!)
              else if (_hasError)
                const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.videocam_off_rounded,
                          color: Colors.white38, size: 40),
                      SizedBox(height: 8),
                      Text('Video unavailable',
                          style: TextStyle(color: Colors.white54, fontSize: 13)),
                    ],
                  ),
                )
              else
                const CircularProgressIndicator(
                    color: AppColors.comicRed, strokeWidth: 2),

              // Play/Pause overlay
              if (_isInitialized && !_hasError)
                GestureDetector(
                  onTap: _togglePlay,
                  child: AnimatedOpacity(
                    opacity: _isPlaying ? 0.0 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: AppColors.comicRed,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.comicRed.withValues(alpha: 0.5),
                            blurRadius: 16,
                          ),
                        ],
                      ),
                      child: Icon(
                        _isPlaying
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        size: 36,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

              // VIDEO CONTENT badge
              Positioned(
                bottom: 10,
                right: 12,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'VIDEO CONTENT',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
