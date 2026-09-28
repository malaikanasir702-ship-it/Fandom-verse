import 'dart:io';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:video_player/video_player.dart';
import '../../../../core/theme/app_colors.dart';

class InAppVideoPlayerModal extends StatefulWidget {
  final String videoUrl;
  final String title;
  final String channel;
  final String? views;
  final String? fandom;
  final String? thumbnailUrl;

  const InAppVideoPlayerModal({
    super.key,
    required this.videoUrl,
    required this.title,
    required this.channel,
    this.views,
    this.fandom,
    this.thumbnailUrl,
  });

  static Future<void> show(
    BuildContext context, {
    required String videoUrl,
    required String title,
    required String channel,
    String? views,
    String? fandom,
    String? thumbnailUrl,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => InAppVideoPlayerModal(
        videoUrl: videoUrl,
        title: title,
        channel: channel,
        views: views,
        fandom: fandom,
        thumbnailUrl: thumbnailUrl,
      ),
    );
  }

  @override
  State<InAppVideoPlayerModal> createState() => _InAppVideoPlayerModalState();
}

class _InAppVideoPlayerModalState extends State<InAppVideoPlayerModal> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  String _errorMessage = '';
  bool _showControls = true;
  bool _isMuted = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    final url = widget.videoUrl.trim();
    if (url.isEmpty) {
      setState(() {
        _hasError = true;
        _errorMessage = 'No video URL provided';
      });
      return;
    }

    try {
      if (url.startsWith('http://') || url.startsWith('https://')) {
        _controller = VideoPlayerController.networkUrl(Uri.parse(url));
      } else {
        _controller = VideoPlayerController.file(File(url));
      }

      await _controller!.initialize();
      _controller!.addListener(_onControllerUpdate);
      await _controller!.play();

      if (mounted) {
        setState(() {
          _isInitialized = true;
          _hasError = false;
        });
      }
    } catch (e) {
      debugPrint('[InAppVideoPlayer] Error initializing video: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = 'Failed to load video: ${e.toString()}';
        });
      }
    }
  }

  void _onControllerUpdate() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller?.removeListener(_onControllerUpdate);
    _controller?.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    if (duration.inHours > 0) {
      return '${duration.inHours}:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  void _togglePlayPause() {
    if (_controller == null || !_isInitialized) return;
    if (_controller!.value.isPlaying) {
      _controller!.pause();
    } else {
      _controller!.play();
    }
  }

  void _seekRelative(int seconds) {
    if (_controller == null || !_isInitialized) return;
    final current = _controller!.value.position;
    final target = current + Duration(seconds: seconds);
    final max = _controller!.value.duration;
    if (target < Duration.zero) {
      _controller!.seekTo(Duration.zero);
    } else if (target > max) {
      _controller!.seekTo(max);
    } else {
      _controller!.seekTo(target);
    }
  }

  void _toggleMute() {
    if (_controller == null || !_isInitialized) return;
    setState(() {
      _isMuted = !_isMuted;
      _controller!.setVolume(_isMuted ? 0.0 : 1.0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final maxHeight = mediaQuery.size.height * 0.88;

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: const BoxDecoration(
        color: Color(0xFF111216),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle bar
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 10, bottom: 8),
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Top Bar with Title and Close
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.comicRed,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      widget.fandom?.toUpperCase() ?? 'VIDEO',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70, size: 22),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Video Player Container
            AspectRatio(
              aspectRatio: _isInitialized && _controller!.value.aspectRatio > 0
                  ? _controller!.value.aspectRatio
                  : (16 / 9),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Video or Placeholder
                  if (_isInitialized && _controller != null)
                    GestureDetector(
                      onTap: () {
                        setState(() => _showControls = !_showControls);
                      },
                      child: VideoPlayer(_controller!),
                    )
                  else if (_hasError)
                    Container(
                      color: Colors.black87,
                      padding: const EdgeInsets.all(16),
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Iconsax.video, color: AppColors.comicRed, size: 44),
                            const SizedBox(height: 10),
                            const Text(
                              'Unable to stream video in-app',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _errorMessage,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: Colors.white60, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Container(
                      color: Colors.black,
                      child: const Center(
                        child: CircularProgressIndicator(color: AppColors.comicRed),
                      ),
                    ),

                  // Overlay Controls
                  if (_isInitialized && _showControls)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.4),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.replay_10, color: Colors.white, size: 34),
                                onPressed: () => _seekRelative(-10),
                              ),
                              const SizedBox(width: 24),
                              GestureDetector(
                                onTap: _togglePlayPause,
                                child: Container(
                                  width: 58,
                                  height: 58,
                                  decoration: BoxDecoration(
                                    color: AppColors.comicRed.withValues(alpha: 0.9),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.comicRed.withValues(alpha: 0.5),
                                        blurRadius: 16,
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    _controller!.value.isPlaying ? Icons.pause : Icons.play_arrow,
                                    color: Colors.white,
                                    size: 36,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 24),
                              IconButton(
                                icon: const Icon(Icons.forward_10, color: Colors.white, size: 34),
                                onPressed: () => _seekRelative(10),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  // Buffering indicator
                  if (_isInitialized && _controller!.value.isBuffering)
                    const Center(
                      child: CircularProgressIndicator(color: AppColors.comicRed),
                    ),

                  // Mute toggle top right
                  if (_isInitialized && _showControls)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: IconButton(
                        icon: Icon(
                          _isMuted ? Iconsax.volume_cross : Iconsax.volume_high,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed: _toggleMute,
                      ),
                    ),
                ],
              ),
            ),

            // Video Timeline Progress Slider
            if (_isInitialized && _controller != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  children: [
                    Text(
                      _formatDuration(_controller!.value.position),
                      style: const TextStyle(color: Colors.white70, fontSize: 11, fontFamily: 'monospace'),
                    ),
                    Expanded(
                      child: SliderTheme(
                        data: SliderTheme.of(context).copyWith(
                          trackHeight: 3,
                          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                          overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                          activeTrackColor: AppColors.comicRed,
                          inactiveTrackColor: Colors.white24,
                          thumbColor: AppColors.comicRed,
                        ),
                        child: Slider(
                          value: _controller!.value.position.inMilliseconds
                              .clamp(0, _controller!.value.duration.inMilliseconds)
                              .toDouble(),
                          max: (_controller!.value.duration.inMilliseconds > 0
                                  ? _controller!.value.duration.inMilliseconds
                                  : 1)
                              .toDouble(),
                          onChanged: (val) {
                            _controller!.seekTo(Duration(milliseconds: val.toInt()));
                          },
                        ),
                      ),
                    ),
                    Text(
                      _formatDuration(_controller!.value.duration),
                      style: const TextStyle(color: Colors.white70, fontSize: 11, fontFamily: 'monospace'),
                    ),
                  ],
                ),
              ),
            ],

            // Video Details Footer
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Iconsax.video, size: 14, color: AppColors.comicRed),
                      const SizedBox(width: 5),
                      Text(
                        widget.channel,
                        style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                      if (widget.views != null && widget.views!.isNotEmpty) ...[
                        const SizedBox(width: 14),
                        const Icon(Iconsax.eye, size: 14, color: Colors.white38),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.views} views',
                          style: const TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
