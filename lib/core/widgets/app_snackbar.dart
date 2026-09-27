import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum SnackbarType { success, error, warning, info }

/// Skewed, comic-style SnackBar with proper dark/light text contrast.
///
/// Usage:
/// ```dart
/// AppSnackbar.show(context, 'Account created!', type: SnackbarType.success);
/// ```
class AppSnackbar {
  AppSnackbar._();

  static void show(
    BuildContext context,
    String message, {
    SnackbarType type = SnackbarType.info,
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    _insertOverlayEntry(
      Overlay.of(context),
      message,
      colors: _colorsFor(type),
      duration: duration,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  static void showError(BuildContext context, String message, {Duration duration = const Duration(seconds: 4)}) {
    show(context, message, type: SnackbarType.error, duration: duration);
  }

  static void showSuccess(BuildContext context, String message, {Duration duration = const Duration(seconds: 3)}) {
    show(context, message, type: SnackbarType.success, duration: duration);
  }

  /// Safe to use after async gaps — capture `Overlay.of(context)` before the gap.
  static void showOnOverlay(
    OverlayState overlay,
    String message, {
    SnackbarType type = SnackbarType.info,
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    _insertOverlayEntry(
      overlay,
      message,
      colors: _colorsFor(type),
      duration: duration,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  static void _insertOverlayEntry(
    OverlayState overlay,
    String message, {
    required _SnackbarColors colors,
    required Duration duration,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (_) => _SkewedSnackbarOverlay(
        message: message,
        colors: colors,
        duration: duration,
        actionLabel: actionLabel,
        onAction: onAction,
        onDismiss: () => entry.remove(),
      ),
    );

    overlay.insert(entry);
  }

  static _SnackbarColors _colorsFor(SnackbarType type) {
    switch (type) {
      case SnackbarType.success:
        return const _SnackbarColors(
          background: Color(0xFF1B5E20),
          accent: Color(0xFF4CAF50),
          text: Colors.white,
          icon: Icons.check_circle_rounded,
        );
      case SnackbarType.error:
        return const _SnackbarColors(
          background: Color(0xFF7F0000),
          accent: AppColors.comicRed,
          text: Colors.white,
          icon: Icons.error_rounded,
        );
      case SnackbarType.warning:
        return const _SnackbarColors(
          background: Color(0xFF4A2E00),
          accent: Color(0xFFFFA000),
          text: Colors.white,
          icon: Icons.warning_rounded,
        );
      case SnackbarType.info:
        return const _SnackbarColors(
          background: Color(0xFF0D2240),
          accent: Color(0xFF2196F3),
          text: Colors.white,
          icon: Icons.info_rounded,
        );
    }
  }
}

class _SnackbarColors {
  final Color background;
  final Color accent;
  final Color text;
  final IconData icon;

  const _SnackbarColors({
    required this.background,
    required this.accent,
    required this.text,
    required this.icon,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Overlay widget — actual skewed snackbar UI
// ─────────────────────────────────────────────────────────────────────────────

class _SkewedSnackbarOverlay extends StatefulWidget {
  final String message;
  final _SnackbarColors colors;
  final Duration duration;
  final String? actionLabel;
  final VoidCallback? onAction;
  final VoidCallback onDismiss;

  const _SkewedSnackbarOverlay({
    required this.message,
    required this.colors,
    required this.duration,
    required this.onDismiss,
    this.actionLabel,
    this.onAction,
  });

  @override
  State<_SkewedSnackbarOverlay> createState() => _SkewedSnackbarOverlayState();
}

class _SkewedSnackbarOverlayState extends State<_SkewedSnackbarOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnim;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
      reverseDuration: const Duration(milliseconds: 220),
    );

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 1.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0, 0.6)),
    );

    _controller.forward();

    // Auto-dismiss
    Future.delayed(widget.duration, _dismiss);
  }

  Future<void> _dismiss() async {
    if (!mounted) return;
    await _controller.reverse();
    if (mounted) widget.onDismiss();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    return Positioned(
      left: 12,
      right: 12,
      bottom: mq.padding.bottom + 16,
      child: SlideTransition(
        position: _slideAnim,
        child: FadeTransition(
          opacity: _fadeAnim,
          child: GestureDetector(
            onHorizontalDragEnd: (d) => _dismiss(),
            onTap: _dismiss,
            child: _SkewedSnackbarBody(
              message: widget.message,
              colors: widget.colors,
              actionLabel: widget.actionLabel,
              onAction: widget.onAction != null
                  ? () {
                      widget.onAction!();
                      _dismiss();
                    }
                  : null,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Painted skewed body
// ─────────────────────────────────────────────────────────────────────────────

class _SkewedSnackbarBody extends StatelessWidget {
  final String message;
  final _SnackbarColors colors;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _SkewedSnackbarBody({
    required this.message,
    required this.colors,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _SkewedPainter(
        background: colors.background,
        accent: colors.accent,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 14),
        child: Row(
          children: [
            // Accent icon
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: colors.accent.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(colors.icon, color: colors.accent, size: 20),
            ),
            const SizedBox(width: 12),
            // Message
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: colors.text,
                  fontWeight: FontWeight.w700,
                  fontSize: 13.5,
                  letterSpacing: 0.2,
                  height: 1.35,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Optional action button
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onAction,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: colors.accent.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: colors.accent.withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    actionLabel!.toUpperCase(),
                    style: TextStyle(
                      color: colors.accent,
                      fontWeight: FontWeight.w900,
                      fontSize: 11,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CustomPainter — skewed (parallelogram) background with left accent stripe
// ─────────────────────────────────────────────────────────────────────────────

class _SkewedPainter extends CustomPainter {
  final Color background;
  final Color accent;

  const _SkewedPainter({required this.background, required this.accent});

  @override
  void paint(Canvas canvas, Size size) {
    const skew = 8.0; // horizontal pixel shift for the skew

    // Shadow
    final shadowPath = Path()
      ..moveTo(skew + 3, 3)
      ..lineTo(size.width + 3, 3)
      ..lineTo(size.width - skew + 3, size.height + 3)
      ..lineTo(3, size.height + 3)
      ..close();
    canvas.drawPath(
      shadowPath,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    // Body
    final bodyPath = Path()
      ..moveTo(skew, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width - skew, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(bodyPath, Paint()..color = background);

    // Left accent stripe
    final stripePath = Path()
      ..moveTo(skew, 0)
      ..lineTo(skew + 5, 0)
      ..lineTo(5, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(stripePath, Paint()..color = accent);
  }

  @override
  bool shouldRepaint(_SkewedPainter old) =>
      old.background != background || old.accent != accent;
}
