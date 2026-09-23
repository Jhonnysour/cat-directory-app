import 'package:flutter/material.dart';

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background = isDark
        ? const Color(0xFF3B292E)
        : const Color(0xFFF8E4E6);
    final border = isDark ? const Color(0xFF76525B) : const Color(0xFFDDB9BC);
    final foreground = isDark
        ? const Color(0xFFFFDAD1)
        : const Color(0xFF9A4F2C);
    final bodyColor = isDark
        ? const Color(0xFFF3DCE0)
        : const Color(0xFF5E4035);

    return Semantics(
      container: true,
      liveRegion: true,
      label: 'Sin conexión. Mostrando datos guardados.',
      child: ExcludeSemantics(
        child: Container(
          constraints: const BoxConstraints(minHeight: 58),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: border),
          ),
          child: Row(
            children: [
              Icon(Icons.cloud_done_outlined, color: foreground, size: 24),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Mostrando datos guardados',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: bodyColor),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF513940)
                      : Colors.white.withValues(alpha: 0.82),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: border),
                ),
                child: Text(
                  'Sin conexión',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: foreground,
                    fontWeight: FontWeight.w700,
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
