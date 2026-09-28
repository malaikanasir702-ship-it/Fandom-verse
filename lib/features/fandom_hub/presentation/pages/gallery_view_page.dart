import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:math' as math;
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class GalleryItem {
  final String id;
  final String title;
  final String imageUrl;
  final String artistName;
  final int likeCount;
  final String? fandom;
  final bool isLiked;

  const GalleryItem({
    required this.id,
    required this.title,
    required this.imageUrl,
    required this.artistName,
    this.likeCount = 0,
    this.fandom,
    this.isLiked = false,
  });

  factory GalleryItem.fromMap(Map<String, dynamic> map) {
    int parsedLikes = 0;
    final likesVal = map['likes'] ?? map['likeCount'] ?? 0;
    if (likesVal is int) {
      parsedLikes = likesVal;
    } else if (likesVal is String) {
      final cleaned = likesVal.replaceAll('k', '000').replaceAll('.', '').replaceAll('K', '000');
      parsedLikes = int.tryParse(cleaned) ?? 0;
    }

    return GalleryItem(
      id: (map['id'] ?? map['title'] ?? '').toString(),
      title: (map['title'] ?? map['character'] ?? 'Artwork').toString(),
      imageUrl: (map['imageUrl'] ?? map['img'] ?? '').toString(),
      artistName: (map['artist'] ?? map['cosplayer'] ?? map['artistName'] ?? 'Community Artist').toString(),
      likeCount: parsedLikes,
      fandom: map['fandom']?.toString() ?? map['event']?.toString(),
      isLiked: map['isLiked'] == true,
    );
  }
}

class GalleryViewPage extends StatefulWidget {
  final GalleryItem item;

  const GalleryViewPage({
    super.key,
    required this.item,
  });

  @override
  State<GalleryViewPage> createState() => _GalleryViewPageState();
}

class _GalleryViewPageState extends State<GalleryViewPage>
    with TickerProviderStateMixin {
  late bool _isLiked;
  late int _likeCount;

  late AnimationController _heartCtrl;
  late Animation<double> _heartScale;
  final List<_GalleryParticle> _particles = [];

  @override
  void initState() {
    super.initState();
    _isLiked = widget.item.isLiked;
    _likeCount = widget.item.likeCount;
    _heartCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _heartScale = Tween<double>(begin: 1.0, end: 1.6).animate(
      CurvedAnimation(parent: _heartCtrl, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _heartCtrl.dispose();
    super.dispose();
  }

  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
      _likeCount += _isLiked ? 1 : -1;
      if (_isLiked) {
        _particles.clear();
        final rng = math.Random();
        for (int i = 0; i < 8; i++) {
          _particles.add(_GalleryParticle(
            angle: rng.nextDouble() * 2 * math.pi,
            distance: 20 + rng.nextDouble() * 30,
          ));
        }
        _heartCtrl.forward(from: 0);
      }
    });
  }

  void _share() {
    Share.share(
      '🎨 Check out this amazing fan art on Fandom Verse!\n\n'
      '"${widget.item.title}" by ${widget.item.artistName}\n\n'
      '📲 Download Fandom Verse — Your fandom pocket companion!',
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.item.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
            // Share button
            IconButton(
              icon: const Icon(Iconsax.share, color: Colors.white70),
              onPressed: _share,
            ),
            // Like with burst animation
            Stack(
              alignment: Alignment.center,
              children: [
                AnimatedBuilder(
                  animation: _heartCtrl,
                  builder: (_, __) => Transform.scale(
                    scale: _isLiked ? _heartScale.value : 1.0,
                    child: IconButton(
                      icon: Icon(
                        _isLiked
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        color: _isLiked ? AppColors.comicRed : Colors.white70,
                      ),
                      onPressed: _toggleLike,
                    ),
                  ),
                ),
                if (_isLiked)
                  ...List.generate(_particles.length, (i) {
                    final p = _particles[i];
                    return AnimatedBuilder(
                      animation: _heartCtrl,
                      builder: (_, __) {
                        final progress = _heartCtrl.value;
                        final dist = p.distance * progress;
                        final opacity =
                            (1.0 - progress * 1.2).clamp(0.0, 1.0);
                        return Positioned(
                          left: 20 + dist * math.cos(p.angle) - 5,
                          top: 20 + dist * math.sin(p.angle) - 5,
                          child: IgnorePointer(
                            child: Opacity(
                              opacity: opacity,
                              child: const Icon(Icons.favorite_rounded,
                                  color: AppColors.comicRed, size: 10),
                            ),
                          ),
                        );
                      },
                    );
                  }),
              ],
            ),
          ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Zoomable artwork view
            Expanded(
              child: Center(
                child: InteractiveViewer(
                  minScale: 0.8,
                  maxScale: 4.0,
                  child: CachedNetworkImage(
                    imageUrl: widget.item.imageUrl,
                    fit: BoxFit.contain,
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.comicRed,
                      ),
                    ),
                    errorWidget: (context, url, error) => Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Iconsax.image,
                          size: 64,
                          color: AppColors.comicGray,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Unable to load artwork',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Bottom Artist and details overlay
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : const Color(0xFF1E1E1E),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                border: Border(
                  top: BorderSide(
                    color: Colors.white.withValues(alpha: 0.1),
                  ),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppColors.comicRed.withValues(alpha: 0.2),
                    child: Text(
                      widget.item.artistName.isNotEmpty
                          ? widget.item.artistName[0].toUpperCase()
                          : 'A',
                      style: const TextStyle(
                        color: AppColors.comicRed,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.item.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'By ${widget.item.artistName}${widget.item.fandom != null ? " • ${widget.item.fandom}" : ""}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: GestureDetector(
                      onTap: _toggleLike,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedBuilder(
                            animation: _heartCtrl,
                            builder: (_, __) => Transform.scale(
                              scale: _isLiked ? _heartScale.value : 1.0,
                              child: Icon(
                                _isLiked
                                    ? Icons.favorite_rounded
                                    : Icons.favorite_border_rounded,
                                size: 14,
                                color: _isLiked
                                    ? AppColors.comicRed
                                    : Colors.white70,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$_likeCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
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

class _GalleryParticle {
  final double angle;
  final double distance;
  _GalleryParticle({required this.angle, required this.distance});
}
