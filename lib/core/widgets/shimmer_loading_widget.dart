import 'package:flowcash/core/theme/radiuses.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerLoadingWidget extends StatelessWidget {
  final Widget child;
  final bool canShimmer;
  final Duration? period;
  final bool freezeScreen;

  const ShimmerLoadingWidget({
    super.key,
    required this.child,
    required this.canShimmer,
    this.period,
    this.freezeScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    if (!canShimmer) return child;

    final colors = Theme.of(context).colorScheme;

    return Stack(
      children: [
        AbsorbPointer(
          absorbing: true,
          child: Shimmer.fromColors(
            baseColor: colors.surfaceContainerHighest,
            highlightColor: colors.surface,
            period: period ?? const Duration(milliseconds: 600),
            child: child,
          ),
        ),
        if (freezeScreen)
          const Positioned.fill(
            child: ModalBarrier(dismissible: false, color: Colors.transparent),
          ),
      ],
    );
  }
}

class AppShimmer extends StatelessWidget {
  final Widget child;
  const AppShimmer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final colors = ColorScheme.of(context);
    return Shimmer.fromColors(
      baseColor: colors.surfaceContainerHighest,
      highlightColor: colors.surface,
      period: const Duration(milliseconds: 800),
      child: child,
    );
  }
}

class ShimmerPlaceholder extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerPlaceholder({
    super.key,
    this.width = double.infinity,
    this.height = 40.0,
    this.borderRadius = Radiuses.small,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}
