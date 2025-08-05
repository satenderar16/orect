
import 'package:flutter/material.dart';

import '../../../widgets/components/circular_progress.dart';

class DashboardCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String subSubtitle;
  final IconData icon;
  final Color iconColor;

  const DashboardCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.subSubtitle,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Card(
          elevation: 0,
          color: iconColor.withAlpha(10), // light tinted background
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title row
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subSubtitle,
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ],
            ),
          ),
        ),

        // Decorative icon
        Positioned(
          top: 0,
          right: 0,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: iconColor.withAlpha(25),
            ),
            padding: const EdgeInsets.all(12),
            child: Icon(
              icon,
              color: iconColor.withAlpha(200),
            ),
          ),
        ),
      ],
    );
  }
}

class CircularPercentage extends StatelessWidget {
  final double cash; // Amount collected as cash
  final double collection; // Total amount (cash + cashless)
  final double? stroke;
  final Widget? imageChild;

  const CircularPercentage({
    super.key,
    required this.cash,
    required this.collection,
    this.stroke,
    this.imageChild,
  });

  @override
  Widget build(BuildContext context) {
    final double percent =
    collection == 0 ? 0 : (cash / collection).clamp(0.0, 1.0);

    return LayoutBuilder(
      builder: (context, constraints) {
        final double diameter = constraints.biggest.shortestSide;
        final double resolvedStroke = stroke ?? diameter * 0.08;
        final double imageSize = diameter - (resolvedStroke * 2);

        return SizedBox(
          width: diameter,
          height: diameter,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (imageChild != null)
                Container(
                  width: imageSize,
                  height: imageSize,
                  clipBehavior: Clip.hardEdge,
                  decoration: const BoxDecoration(shape: BoxShape.circle),
                  child: imageChild,
                ),

              CustomPaint(
                size: Size.square(diameter),
                painter: CircularProgressPainter(
                  percent: percent,
                  color: Theme.of(context).colorScheme.primary,
                  backgroundColor:
                  Theme.of(context).colorScheme.surfaceContainerHighest,
                  strokeWidth: resolvedStroke,
                ),
              ),

              if (imageChild == null)
                Text(
                  "${(percent * 100).toStringAsFixed(1)}%",
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
            ],
          ),
        );
      },
    );
  }
}
