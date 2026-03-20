import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// 顶部微弱光晕，营造大气纵深
class GradientBackground extends StatelessWidget {
  const GradientBackground({
    super.key,
    required this.accent,
    required this.child,
  });

  final Color accent;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(0, -1.1),
              radius: 1.15,
              colors: [
                accent.withValues(alpha: 0.14),
                AppColors.scaffold,
                AppColors.scaffold,
              ],
              stops: const [0.0, 0.45, 1.0],
            ),
          ),
        ),
        child,
      ],
    );
  }
}
