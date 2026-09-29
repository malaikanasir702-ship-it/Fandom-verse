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
  final double? width;
  final double fontSize;
  final IconData? icon;
  /// Optional custom leading widget (e.g. Google logo painter, Apple icon)
  final Widget? leadingWidget;
  /// When true, shows a loading spinner and disables interaction
  final bool isLoading;

  const SkewedButton({
    super.key,
    required this.text,
    this.onPressed,
    this.backgroundColor = AppColors.comicRed,
    this.textColor = Colors.white,
    this.skewAngle = 0.18,
    this.height = 46,
    this.width,
    this.fontSize = 13,
    this.icon,
    this.leadingWidget,
    this.isLoading = false,
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

    final content = widget.isLoading
        ? SizedBox(
            width: widget.height * 0.44,
            height: widget.height * 0.44,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(
                widget.textColor.withValues(alpha: 0.9),
              ),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.leadingWidget != null) ...[
                widget.leadingWidget!,
                const SizedBox(width: 6),
              ] else if (widget.icon != null) ...[
                Icon(
                  widget.icon,
                  size: widget.fontSize < 12 ? 13 : 14,
                  color: widget.textColor,
                ),
                const SizedBox(width: 4),
              ],
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    widget.text.toUpperCase(),
                    maxLines: 1,
                    style: TextStyle(
                      color: widget.textColor,
                      fontSize: widget.fontSize,
                      fontWeight: FontWeight.w900,
                      fontStyle: FontStyle.italic,
                      letterSpacing: widget.fontSize < 12 ? 0.3 : 0.6,
                    ),
                  ),
                ),
              ),
            ],
          );

    return AnimatedBuilder(
      animation: _scaleAnim,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnim.value,
          child: child,
        );
      },
      child: GestureDetector(
        onTapDown: (widget.onPressed != null && !widget.isLoading) ? _onTapDown : null,
        onTapUp: (widget.onPressed != null && !widget.isLoading) ? _onTapUp : null,
        onTapCancel: (widget.onPressed != null && !widget.isLoading) ? _onTapCancel : null,
        child: SizedBox(
          width: widget.width,
          height: widget.height,
          child: Stack(
            fit: widget.width != null ? StackFit.expand : StackFit.loose,
            children: [
              // ── 3D depth shadow layer (positioned behind) ───────────
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.only(left: 4, top: 4),
                  child: ClipPath(
                    clipper: _SkewClipper(skew: widget.skewAngle),
                    child: Container(color: shadowColor),
                  ),
                ),
              ),

              // ── Main button face (non-positioned: determines natural size!) ──
              Padding(
                padding: const EdgeInsets.only(right: 4, bottom: 4),
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
                      child: Container(
                        height: widget.height - 4,
                        padding: EdgeInsets.symmetric(
                          horizontal: widget.fontSize < 12 ? 10 : 14,
                        ),
                        alignment: Alignment.center,
                        child: content,
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
