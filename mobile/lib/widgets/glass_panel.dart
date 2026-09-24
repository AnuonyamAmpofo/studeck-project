import 'dart:ui';
import 'package:flutter/material.dart';

/// Frosted-glass surface: blurs whatever sits behind it, then lays a
/// translucent tint + hairline highlight border on top. Used for the
/// bottom nav, insight cards, and the landing-screen logo backdrop.
class GlassPanel extends StatelessWidget {
  const GlassPanel({
    super.key,
    required this.child,
    this.borderRadius = 20,
    this.blurSigma = 18,
    this.tintColor = Colors.white,
    this.tintOpacity = 0.12,
    this.borderColor,
    this.padding,
  });

  final Widget child;
  final double borderRadius;
  final double blurSigma;
  final Color tintColor;
  final double tintOpacity;
  final Color? borderColor;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: tintColor.withOpacity(tintOpacity),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: borderColor ?? Colors.white.withOpacity(0.14)),
          ),
          child: child,
        ),
      ),
    );
  }
}
