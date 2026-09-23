import 'dart:ui' show lerpDouble;

import 'package:cat_directory_app/features/breeds/domain/entities/breed.dart';
import 'package:flutter/material.dart';

/// Shared element for the directory and detail, with no duplicate spoken label.
class BreedAvatar extends StatelessWidget {
  const BreedAvatar({required this.breed, this.expanded = false, super.key});

  final Breed breed;
  final bool expanded;

  static String heroTagFor(String name) =>
      'breed-avatar:${name.trim().toLowerCase()}';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final foreground = expanded ? colors.primary : colors.onPrimaryContainer;
    return HeroMode(
      enabled: !MediaQuery.disableAnimationsOf(context),
      child: Hero(
        tag: heroTagFor(breed.name),
        flightShuttleBuilder: _buildFlight,
        child: _AvatarFace(
          monogram: _monogram(breed.name),
          diameter: expanded ? 68 : 42,
          background: expanded ? colors.surface : colors.primaryContainer,
          textStyle:
              (expanded
                      ? theme.textTheme.titleLarge
                      : theme.textTheme.labelLarge)!
                  .copyWith(fontWeight: FontWeight.w700, color: foreground),
        ),
      ),
    );
  }

  static Widget _buildFlight(
    BuildContext context,
    Animation<double> animation,
    HeroFlightDirection direction,
    BuildContext fromContext,
    BuildContext toContext,
  ) {
    final from = (fromContext.widget as Hero).child as _AvatarFace;
    final to = (toContext.widget as Hero).child as _AvatarFace;
    // On pop the route's animation runs from 1 to 0.
    final begin = direction == HeroFlightDirection.push ? from : to;
    final end = direction == HeroFlightDirection.push ? to : from;
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) => _AvatarFace(
        monogram: to.monogram,
        diameter: lerpDouble(begin.diameter, end.diameter, animation.value)!,
        background: Color.lerp(
          begin.background,
          end.background,
          animation.value,
        )!,
        textStyle: TextStyle.lerp(
          begin.textStyle,
          end.textStyle,
          animation.value,
        )!,
      ),
    );
  }

  static String _monogram(String name) {
    final words = name.trim().split(RegExp(r'\s+'));
    final source = words.length > 1 && words.first.toLowerCase() == 'american'
        ? words[1]
        : words.first;
    return source.substring(0, source.length.clamp(0, 2)).toUpperCase();
  }
}

class _AvatarFace extends StatelessWidget {
  const _AvatarFace({
    required this.monogram,
    required this.diameter,
    required this.background,
    required this.textStyle,
  });

  final String monogram;
  final double diameter;
  final Color background;
  final TextStyle textStyle;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Material(
        color: background,
        animationDuration: Duration.zero,
        shape: const CircleBorder(),
        child: SizedBox.square(
          dimension: diameter,
          child: Center(child: Text(monogram, style: textStyle)),
        ),
      ),
    );
  }
}
