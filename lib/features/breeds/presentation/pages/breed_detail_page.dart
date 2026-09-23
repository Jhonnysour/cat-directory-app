import 'package:cat_directory_app/core/error/failure.dart';
import 'package:cat_directory_app/features/breeds/domain/entities/breed.dart';
import 'package:cat_directory_app/features/breeds/presentation/bloc/breed_detail_bloc.dart';
import 'package:cat_directory_app/features/breeds/presentation/widgets/breed_detail_sections.dart';
import 'package:cat_directory_app/features/breeds/presentation/widgets/error_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class BreedDetailPage extends StatelessWidget {
  const BreedDetailPage({required this.breedName, super.key});

  final String breedName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => _goToDirectory(context),
          tooltip: 'Volver al directorio',
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text('Detalle de raza'),
      ),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
          child: BlocBuilder<BreedDetailBloc, BreedDetailState>(
            builder: (context, state) => switch (state) {
              BreedDetailInitial() ||
              BreedDetailLoading() => const _DetailLoadingView(),
              BreedDetailNotFound() => _BreedNotFoundView(
                name: state.requestedName,
                onBack: () => _goToDirectory(context),
              ),
              BreedDetailFailure() => ErrorView(
                title: 'No pudimos cargar esta raza',
                message: _failureMessage(state.failure),
                onRetry: () => context.read<BreedDetailBloc>().add(
                  BreedDetailStarted(name: breedName),
                ),
              ),
              BreedDetailLoaded() => _LoadedBreedDetail(state: state),
            },
          ),
        ),
      ),
    );
  }

  void _goToDirectory(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/');
    }
  }

  String _failureMessage(Failure failure) => switch (failure) {
    NoConnectionFailure() =>
      'Conéctate a internet para buscar esta raza y vuelve a intentarlo.',
    TimeoutFailure() =>
      'La búsqueda tardó demasiado. Revisa tu conexión e inténtalo de nuevo.',
    ServerFailure() => 'El servicio no está disponible por el momento.',
    _ => 'Ocurrió un problema inesperado. Inténtalo de nuevo.',
  };
}

class _LoadedBreedDetail extends StatelessWidget {
  const _LoadedBreedDetail({required this.state});

  final BreedDetailLoaded state;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 28),
      children: [
        _BreedHeader(breed: state.breed),
        const SizedBox(height: 18),
        BreedDetailsCard(breed: state.breed),
        const SizedBox(height: 18),
        BreedFactCard(
          status: state.factStatus,
          fact: state.fact,
          failure: state.factFailure,
          onRetry: () =>
              context.read<BreedDetailBloc>().add(const BreedFactRequested()),
        ),
      ],
    );
  }
}

class _BreedHeader extends StatelessWidget {
  const _BreedHeader({required this.breed});

  final Breed breed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 34,
            backgroundColor: colors.surface,
            foregroundColor: colors.primary,
            child: Text(
              _monogram(breed.name),
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  breed.name,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: colors.onPrimaryContainer,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 18,
                      color: colors.onPrimaryContainer,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        breed.country,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colors.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _monogram(String name) {
    final words = name.trim().split(RegExp(r'\s+'));
    final source = words.length > 1 && words.first.toLowerCase() == 'american'
        ? words[1]
        : words.first;
    return source.substring(0, source.length.clamp(0, 2)).toUpperCase();
  }
}

class _DetailLoadingView extends StatelessWidget {
  const _DetailLoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 18),
          Text('Buscando información de la raza…'),
        ],
      ),
    );
  }
}

class _BreedNotFoundView extends StatelessWidget {
  const _BreedNotFoundView({required this.name, required this.onBack});

  final String name;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pets_outlined, size: 60, color: colors.primary),
            const SizedBox(height: 18),
            Text(
              'Raza no encontrada',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'No encontramos “$name” en el directorio.',
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.onSurfaceVariant),
            ),
            const SizedBox(height: 22),
            FilledButton.icon(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_rounded),
              label: const Text('Volver al directorio'),
            ),
          ],
        ),
      ),
    );
  }
}
