import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Fandom Like Button with heart burst particle animation.
/// Double-tap or single-tap to toggle like.
class FandomLikeButton extends StatefulWidget {
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
  State<FandomLikeButton> createState() => _FandomLikeButtonState();
}

class _FandomLikeButtonState extends State<FandomLikeButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  final List<_Particle> _particles = [];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scale = Tween<double>(begin: 1.0, end: 1.6).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _handleTap() {
    widget.onToggle();
    // Only animate when liking (not unliking)
    if (!widget.isLiked) {
      _particles.clear();
      final rng = math.Random();
      for (int i = 0; i < 7; i++) {
        _particles.add(_Particle(
          angle: rng.nextDouble() * 2 * math.pi,
          distance: 18 + rng.nextDouble() * 22,
        ));
      }
      _ctrl.forward(from: 0);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: widget.size * 2.8,
        height: widget.size * 2.4,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Heart icon with scale animation
            AnimatedBuilder(
              animation: _ctrl,
              builder: (_, __) => Transform.scale(
                scale: widget.isLiked ? _scale.value : 1.0,
                child: Icon(
                  widget.isLiked
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: widget.isLiked
                      ? AppColors.comicRed
                      : AppColors.comicGray,
                  size: widget.size,
                ),
              ),
            ),

            // Burst particles — only shown when freshly liked
            if (widget.isLiked)
              ...List.generate(_particles.length, (i) {
                final p = _particles[i];
                return AnimatedBuilder(
                  animation: _ctrl,
                  builder: (_, __) {
                    final progress = _ctrl.value;
                    final dist = p.distance * progress;
                    final opacity = (1.0 - progress * 1.2).clamp(0.0, 1.0);
                    return Positioned(
                      left: widget.size * 1.4 + dist * math.cos(p.angle) - 5,
                      top: widget.size * 1.2 + dist * math.sin(p.angle) - 5,
                      child: Opacity(
                        opacity: opacity,
                        child: Icon(
                          Icons.favorite_rounded,
                          color: AppColors.comicRed,
                          size: widget.size * 0.5,
                        ),
                      ),
                    );
                  },
                );
              }),
          ],
        ),
      ),
    );
  }
}

class _Particle {
  final double angle;
  final double distance;
  _Particle({required this.angle, required this.distance});
}
