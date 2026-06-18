import 'package:flutter/material.dart';
import '../theme/obsidian_theme.dart';

class MeshBackground extends StatelessWidget {
  final Widget child;

  const MeshBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? ObsidianTheme.background : Theme.of(context).scaffoldBackgroundColor;
    final primaryColor = isDark ? ObsidianTheme.primary : Theme.of(context).colorScheme.primary;
    final tertiaryColor = isDark ? ObsidianTheme.tertiary : Theme.of(context).colorScheme.secondary;

    return Stack(
      children: [
        // Base Background
        Container(color: bgColor),
        // Top-Left Primary Radial Gradient
        Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.topLeft,
              radius: 1.2,
              colors: [
                primaryColor.withValues(alpha: isDark ? 0.05 : 0.03),
                Colors.transparent,
              ],
              stops: const [0.0, 1.0],
            ),
          ),
        ),
        // Bottom-Right Tertiary Radial Gradient
        Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.bottomRight,
              radius: 1.2,
              colors: [
                tertiaryColor.withValues(alpha: isDark ? 0.03 : 0.02),
                Colors.transparent,
              ],
              stops: const [0.0, 1.0],
            ),
          ),
        ),
        // Animated/Static Atmospheric Background Elements (from HTML)
        Positioned(
          top: -100,
          left: -100,
          child: _buildBlurCircle(primaryColor.withValues(alpha: isDark ? 0.1 : 0.05), 300),
        ),
        Positioned(
          bottom: -100,
          right: -100,
          child: _buildBlurCircle(tertiaryColor.withValues(alpha: isDark ? 0.05 : 0.03), 300),
        ),
        // Content
        Positioned.fill(child: child),
      ],
    );
  }

  Widget _buildBlurCircle(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color,
            blurRadius: 120,
            spreadRadius: 20,
          ),
        ],
      ),
    );
  }
}
