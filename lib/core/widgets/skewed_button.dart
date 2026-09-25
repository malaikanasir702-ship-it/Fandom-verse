import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Comic-style parallelogram/skewed button — matches the "READ NOW" design.
/// Uses a skewed ClipPath so the shape is truly angled, not just rotated.
class SkewedButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color textColor;
  final double skewAngle;
  final double height;
  final double fontSize;
  final IconData? icon;

  const SkewedButton({
    super.key,
    required this.text,
    this.onPressed,
    this.backgroundColor = AppColors.comicRed,
    this.textColor = Colors.white,
    this.skewAngle = 0.18,
    this.height = 46,
    this.fontSize = 13,
    this.icon,
  });

  @override
  State<SkewedButton> createState() => _SkewedButtonState();
}

class _SkewedButtonState extends State<SkewedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(_) {
    setState(() => _pressed = true);
    _controller.forward();
  }

  void _onTapUp(_) {
    setState(() => _pressed = false);
    _controller.reverse();
    widget.onPressed?.call();
  }

  void _onTapCancel() {
    setState(() => _pressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final shadowColor = widget.backgroundColor == AppColors.comicRed
        ? const Color(0xFF8B0000)
        : widget.backgroundColor.withValues(alpha: 0.6);

    return AnimatedBuilder(
      animation: _scaleAnim,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnim.value,
          child: child,
        );
      },
      child: GestureDetector(
        onTapDown: widget.onPressed != null ? _onTapDown : null,
        onTapUp: widget.onPressed != null ? _onTapUp : null,
        onTapCancel: widget.onPressed != null ? _onTapCancel : null,
        child: SizedBox(
          height: widget.height,
          child: Stack(
            children: [
              // ── 3D depth shadow layer ──────────────────────────────
              Positioned(
                left: 4,
                top: 4,
                right: 0,
                bottom: 0,
                child: ClipPath(
                  clipper: _SkewClipper(skew: widget.skewAngle),
                  child: Container(color: shadowColor),
                ),
              ),

              // ── Main button face ───────────────────────────────────
              Positioned(
                left: 0,
                top: 0,
                right: 4,
                bottom: 4,
                child: ClipPath(
                  clipper: _SkewClipper(skew: widget.skewAngle),
                  child: Material(
                    color: _pressed
                        ? widget.backgroundColor.withValues(alpha: 0.88)
                        : widget.backgroundColor,
                    child: InkWell(
                      splashColor: Colors.white.withValues(alpha: 0.15),
                      highlightColor: Colors.white.withValues(alpha: 0.08),
                      onTap: null, // handled by GestureDetector
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (widget.icon != null) ...[
                                Icon(widget.icon,
                                    size: 15, color: widget.textColor),
                                const SizedBox(width: 6),
                              ],
                              Text(
                                widget.text.toUpperCase(),
                                style: TextStyle(
                                  color: widget.textColor,
                                  fontSize: widget.fontSize,
                                  fontWeight: FontWeight.w900,
                                  fontStyle: FontStyle.italic,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
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

/// Custom clipper that creates the parallelogram/skewed shape.
class _SkewClipper extends CustomClipper<Path> {
  final double skew;
  const _SkewClipper({required this.skew});

  @override
  Path getClip(Size size) {
    final offset = size.height * skew;
    return Path()
      ..moveTo(offset, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width - offset, size.height)
      ..lineTo(0, size.height)
      ..close();
  }

  @override
  bool shouldReclip(_SkewClipper old) => old.skew != skew;
}
