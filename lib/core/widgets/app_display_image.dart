import 'dart:io';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class AppDisplayImage extends StatelessWidget {
  final String? pathOrUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;

  const AppDisplayImage({
    super.key,
    required this.pathOrUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    Widget content;
    final src = pathOrUrl?.trim() ?? '';

    if (src.isEmpty) {
      content = placeholder ?? _defaultPlaceholder();
    } else if (src.startsWith('http://') || src.startsWith('https://')) {
      content = Image.network(
        src,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) => placeholder ?? _defaultPlaceholder(),
      );
    } else {
      try {
        final file = File(src);
        content = Image.file(
          file,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (_, __, ___) => placeholder ?? _defaultPlaceholder(),
        );
      } catch (_) {
        content = placeholder ?? _defaultPlaceholder();
      }
    }

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: content);
    }
    return content;
  }

  Widget _defaultPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: const Color(0xFFF1F5F9),
      child: const Center(
        child: Icon(Iconsax.image, color: Color(0xFF94A3B8), size: 24),
      ),
    );
  }
}
