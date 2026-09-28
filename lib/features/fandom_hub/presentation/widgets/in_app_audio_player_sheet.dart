import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../../../core/theme/app_colors.dart';

/// Central singleton to manage active in-app podcast audio playback
class PodcastAudioManager {
  static final PodcastAudioManager instance = PodcastAudioManager._();
  PodcastAudioManager._();

  final AudioPlayer player = AudioPlayer();

  String? currentAudioUrl;
  String? currentTitle;
  String? currentHost;
  String? currentCoverUrl;
  String? currentEpisode;
  String? currentFandom;

  bool isPlaying = false;
  Duration currentPosition = Duration.zero;
  Duration totalDuration = Duration.zero;

  final StreamController<bool> _playStateController = StreamController<bool>.broadcast();
  Stream<bool> get playStateStream => _playStateController.stream;

  bool _isInit = false;

  void init() {
    if (_isInit) return;
    _isInit = true;

    player.onPlayerStateChanged.listen((state) {
      isPlaying = (state == PlayerState.playing);
      _playStateController.add(isPlaying);
    });

    player.onPositionChanged.listen((pos) {
      currentPosition = pos;
    });

    player.onDurationChanged.listen((dur) {
      totalDuration = dur;
    });
  }

  Future<void> playPodcast({
    required String audioUrl,
    required String title,
    required String host,
    required String coverUrl,
    String? episode,
    String? fandom,
  }) async {
    init();

    // If same audio is currently playing, don't restart, just resume
    if (currentAudioUrl == audioUrl && isPlaying) {
      return;
    }

    currentAudioUrl = audioUrl;
    currentTitle = title;
    currentHost = host;
    currentCoverUrl = coverUrl;
    currentEpisode = episode;
    currentFandom = fandom;

    try {
      final url = audioUrl.trim();
      Source source;

      if (url.startsWith('http://') || url.startsWith('https://')) {
        // If it's a Spotify or non-stream web page URL, provide a fallback audio stream
        if (url.contains('spotify.com') || !url.contains('.')) {
          // Sample comic podcast episode stream
          source = UrlSource('https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3');
        } else {
          source = UrlSource(url);
        }
      } else {
        source = DeviceFileSource(url);
      }

      await player.stop();
      await player.play(source);
    } catch (e) {
      debugPrint('[PodcastAudioManager] Error playing audio: $e');
    }
  }

  Future<void> togglePlayPause() async {
    if (isPlaying) {
      await player.pause();
    } else {
      await player.resume();
    }
  }

  Future<void> seek(Duration position) async {
    await player.seek(position);
  }

  Future<void> skip(int seconds) async {
    final target = currentPosition + Duration(seconds: seconds);
    if (target < Duration.zero) {
      await player.seek(Duration.zero);
    } else if (target > totalDuration && totalDuration > Duration.zero) {
      await player.seek(totalDuration);
    } else {
      await player.seek(target);
    }
  }

  Future<void> stop() async {
    await player.stop();
    isPlaying = false;
    currentAudioUrl = null;
    _playStateController.add(false);
  }
}

/// In-App Podcast Audio Player Modal Sheet
class InAppAudioPlayerSheet extends StatefulWidget {
  final String audioUrl;
  final String title;
  final String host;
  final String coverUrl;
  final String? episode;
  final String? fandom;
  final String? durationText;

  const InAppAudioPlayerSheet({
    super.key,
    required this.audioUrl,
    required this.title,
    required this.host,
    required this.coverUrl,
    this.episode,
    this.fandom,
    this.durationText,
  });

  static Future<void> show(
    BuildContext context, {
    required String audioUrl,
    required String title,
    required String host,
    required String coverUrl,
    String? episode,
    String? fandom,
    String? durationText,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => InAppAudioPlayerSheet(
        audioUrl: audioUrl,
        title: title,
        host: host,
        coverUrl: coverUrl,
        episode: episode,
        fandom: fandom,
        durationText: durationText,
      ),
    );
  }

  @override
  State<InAppAudioPlayerSheet> createState() => _InAppAudioPlayerSheetState();
}

class _InAppAudioPlayerSheetState extends State<InAppAudioPlayerSheet> {
  final _manager = PodcastAudioManager.instance;
  StreamSubscription? _posSub;
  StreamSubscription? _durSub;
  StreamSubscription? _stateSub;

  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _isPlaying = false;
  double _playbackSpeed = 1.0;

  @override
  void initState() {
    super.initState();
    _manager.init();

    // Start playing this podcast if not already active
    if (_manager.currentAudioUrl != widget.audioUrl) {
      _manager.playPodcast(
        audioUrl: widget.audioUrl,
        title: widget.title,
        host: widget.host,
        coverUrl: widget.coverUrl,
        episode: widget.episode,
        fandom: widget.fandom,
      );
    }

    _isPlaying = _manager.isPlaying;
    _position = _manager.currentPosition;
    _duration = _manager.totalDuration;

    _posSub = _manager.player.onPositionChanged.listen((p) {
      if (mounted) setState(() => _position = p);
    });

    _durSub = _manager.player.onDurationChanged.listen((d) {
      if (mounted) setState(() => _duration = d);
    });

    _stateSub = _manager.playStateStream.listen((playing) {
      if (mounted) setState(() => _isPlaying = playing);
    });
  }

  @override
  void dispose() {
    _posSub?.cancel();
    _durSub?.cancel();
    _stateSub?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    if (d.inHours > 0) {
      return '${d.inHours}:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  void _cycleSpeed() {
    final speeds = [1.0, 1.25, 1.5, 2.0];
    final nextIndex = (speeds.indexOf(_playbackSpeed) + 1) % speeds.length;
    final nextSpeed = speeds[nextIndex];
    setState(() => _playbackSpeed = nextSpeed);
    _manager.player.setPlaybackRate(nextSpeed);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF14171E) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 20,
            offset: Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.white24 : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 14),

            // Header row with category badge & close
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.comicRed,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        (widget.episode ?? 'EPISODE').toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.fandom ?? 'Fandom Podcast',
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.black87,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(Icons.close, color: isDark ? Colors.white70 : Colors.black54, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Large Album / Cover Art
            Container(
              width: 170,
              height: 170,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.18),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: widget.coverUrl.startsWith('http')
                    ? Image.network(
                        widget.coverUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildCoverPlaceholder(),
                      )
                    : Image.file(
                        File(widget.coverUrl),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildCoverPlaceholder(),
                      ),
              ),
            ),
            const SizedBox(height: 18),

            // Title & Host
            Text(
              widget.title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isDark ? Colors.white : const Color(0xFF111216),
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Iconsax.microphone_2, size: 14, color: AppColors.comicRed),
                const SizedBox(width: 4),
                Text(
                  widget.host,
                  style: TextStyle(
                    color: isDark ? Colors.white60 : Colors.grey.shade600,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Audio Progress Slider
            Column(
              children: [
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 4,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                    activeTrackColor: AppColors.comicRed,
                    inactiveTrackColor: isDark ? Colors.white12 : Colors.grey.shade200,
                    thumbColor: AppColors.comicRed,
                  ),
                  child: Slider(
                    value: _duration.inMilliseconds > 0
                        ? _position.inMilliseconds.clamp(0, _duration.inMilliseconds).toDouble()
                        : 0.0,
                    max: _duration.inMilliseconds > 0 ? _duration.inMilliseconds.toDouble() : 1.0,
                    onChanged: (val) {
                      _manager.seek(Duration(milliseconds: val.toInt()));
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDuration(_position),
                        style: TextStyle(
                          color: isDark ? Colors.white54 : Colors.grey.shade600,
                          fontSize: 11,
                          fontFamily: 'monospace',
                        ),
                      ),
                      Text(
                        _duration.inMilliseconds > 0
                            ? _formatDuration(_duration)
                            : (widget.durationText ?? '45:00'),
                        style: TextStyle(
                          color: isDark ? Colors.white54 : Colors.grey.shade600,
                          fontSize: 11,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Controls Row (Speed, Rewind 10, Play/Pause, Forward 10, Stop)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Playback speed
                TextButton(
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  onPressed: _cycleSpeed,
                  child: Text(
                    '${_playbackSpeed}x',
                    style: const TextStyle(
                      color: AppColors.comicRed,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),

                // Rewind 10s
                IconButton(
                  icon: Icon(Icons.replay_10, color: isDark ? Colors.white : Colors.black87, size: 28),
                  onPressed: () => _manager.skip(-10),
                ),

                // Main Play/Pause Button
                GestureDetector(
                  onTap: () => _manager.togglePlayPause(),
                  child: Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: AppColors.comicRed,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.comicRed.withValues(alpha: 0.4),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      _isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                      size: 34,
                    ),
                  ),
                ),

                // Forward 10s
                IconButton(
                  icon: Icon(Icons.forward_10, color: isDark ? Colors.white : Colors.black87, size: 28),
                  onPressed: () => _manager.skip(10),
                ),

                // Stop / Dismiss
                IconButton(
                  icon: Icon(Icons.stop, color: isDark ? Colors.white54 : Colors.grey.shade500, size: 24),
                  onPressed: () {
                    _manager.stop();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoverPlaceholder() {
    return Container(
      color: const Color(0xFF1E293B),
      child: const Center(
        child: Icon(Iconsax.microphone_2, color: Colors.white38, size: 48),
      ),
    );
  }
}
