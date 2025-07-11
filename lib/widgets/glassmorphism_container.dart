import 'dart:ui';
import 'package:flutter/material.dart';

class GlassmorphismContainer extends StatelessWidget {
  final Widget child;
  final double width;
  final double height;
  final BorderRadius? borderRadius;
  final double blur;
  final double opacity;
  final Color? color;

  const GlassmorphismContainer({
    Key? key,
    required this.child,
    required this.width,
    required this.height,
    this.borderRadius,
    this.blur = 20.0,
    this.opacity = 0.1,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = color ?? 
        (isDark ? Colors.white.withOpacity(opacity) : Colors.white.withOpacity(opacity));
    
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: borderRadius ?? BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? Colors.white.withOpacity(0.2) : Colors.white.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
