import 'package:cat_directory_app/core/error/failure.dart';
import 'package:cat_directory_app/features/breeds/domain/entities/breed.dart';
import 'package:cat_directory_app/features/breeds/domain/entities/cat_fact.dart';
import 'package:cat_directory_app/features/breeds/presentation/bloc/breed_detail_bloc.dart';
import 'package:flutter/material.dart';

class BreedDetailsCard extends StatelessWidget {
  const BreedDetailsCard({required this.breed, super.key});

  final Breed breed;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Información de la raza',
      child: Column(
        children: [
          _DetailRow(label: 'Raza', value: breed.name),
          _DetailRow(label: 'País', value: breed.country),
          _DetailRow(label: 'Origen', value: breed.origin),
          _DetailRow(label: 'Pelaje', value: breed.coat),
          _DetailRow(label: 'Patrón', value: breed.pattern, showDivider: false),
        ],
      ),
    );
  }
}

class BreedFactCard extends StatelessWidget {
  const BreedFactCard({
    required this.status,
    required this.fact,
    required this.failure,
    required this.onRetry,
    super.key,
  });

  final BreedFactStatus status;
  final CatFact? fact;
  final Failure? failure;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Dato curioso aleatorio',
      leading: Icons.lightbulb_outline_rounded,
      child: switch (status) {
        BreedFactStatus.initial ||
        BreedFactStatus.loading => const _FactLoading(),
        BreedFactStatus.success => _FactSuccess(
          fact: fact,
          onAnotherFact: onRetry,
        ),
        BreedFactStatus.failure => _FactFailure(
          message: _failureMessage(failure),
          onRetry: onRetry,
        ),
      },
    );
  }

  String _failureMessage(Failure? failure) => switch (failure) {
    NoConnectionFailure() => 'Sin conexión para obtener el dato curioso.',
    TimeoutFailure() => 'El dato curioso tardó demasiado en responder.',
    _ => 'No pudimos obtener el dato curioso.',
  };
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child, this.leading});

  final String title;
  final Widget child;
  final IconData? leading;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              if (leading != null) ...[
                Icon(leading, size: 21, color: colors.primary),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.showDivider = true,
  });

  final String label;
  final String value;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      container: true,
      label: '$label: $value',
      child: ExcludeSemantics(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 76,
                    child: Text(
                      label,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      value,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (showDivider) Divider(height: 1, color: colors.outlineVariant),
          ],
        ),
      ),
    );
  }
}

class _FactLoading extends StatelessWidget {
  const _FactLoading();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      liveRegion: true,
      label: 'Buscando un dato curioso',
      child: ExcludeSemantics(
        child: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Expanded(child: Text('Buscando un dato curioso…')),
          ],
        ),
      ),
    );
  }
}

class _FactSuccess extends StatelessWidget {
  const _FactSuccess({required this.fact, required this.onAnotherFact});

  final CatFact? fact;
  final VoidCallback onAnotherFact;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(fact?.text ?? ''),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: onAnotherFact,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Otro dato'),
          ),
        ),
      ],
    );
  }
}

class _FactFailure extends StatelessWidget {
  const _FactFailure({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          container: true,
          liveRegion: true,
          label: message,
          child: ExcludeSemantics(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.cloud_off_outlined, color: colors.primary),
                const SizedBox(width: 10),
                Expanded(child: Text(message)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        TextButton(onPressed: onRetry, child: const Text('Reintentar')),
      ],
    );
  }
}
