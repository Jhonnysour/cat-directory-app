import 'dart:async';

import 'package:cat_directory_app/core/error/failure.dart';
import 'package:cat_directory_app/core/network/network_info.dart';
import 'package:cat_directory_app/features/breeds/presentation/bloc/breeds_bloc.dart';
import 'package:cat_directory_app/features/breeds/presentation/widgets/breed_tile.dart';
import 'package:cat_directory_app/features/breeds/presentation/widgets/error_view.dart';
import 'package:cat_directory_app/features/breeds/presentation/widgets/offline_banner.dart';
import 'package:cat_directory_app/features/breeds/presentation/widgets/skeleton_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class BreedsPage extends StatefulWidget {
  const BreedsPage({required this.networkInfo, super.key});

  final NetworkInfo networkInfo;

  @override
  State<BreedsPage> createState() => _BreedsPageState();
}

class _BreedsPageState extends State<BreedsPage> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  StreamSubscription<bool>? _connectionSubscription;
  bool? _hasConnection;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_requestNextPageNearEnd);
    _searchController.addListener(_refreshSearchDecoration);
    _loadConnectionStatus();
    _connectionSubscription = widget.networkInfo.onConnectionChanged.listen(
      _setConnectionStatus,
    );
  }

  @override
  void dispose() {
    _connectionSubscription?.cancel();
    _searchController
      ..removeListener(_refreshSearchDecoration)
      ..dispose();
    _scrollController
      ..removeListener(_requestNextPageNearEnd)
      ..dispose();
    super.dispose();
  }

  Future<void> _loadConnectionStatus() async {
    try {
      _setConnectionStatus(await widget.networkInfo.hasConnection);
    } on Object {
      // Dio remains the source of truth when connectivity detection fails.
    }
  }

  void _setConnectionStatus(bool hasConnection) {
    if (!mounted || _hasConnection == hasConnection) {
      return;
    }

    final connectionWasLost = _hasConnection == false;
    setState(() => _hasConnection = hasConnection);

    if (connectionWasLost && hasConnection) {
      final bloc = context.read<BreedsBloc>();
      if (bloc.state.failureSource == BreedsFailureSource.nextPage) {
        bloc.add(const BreedsNextPageRequested());
      }
    }
  }

  void _refreshSearchDecoration() {
    if (mounted) {
      setState(() {});
    }
  }

  void _requestNextPageNearEnd() {
    if (!_scrollController.hasClients ||
        _scrollController.position.extentAfter > 280) {
      return;
    }
    final bloc = context.read<BreedsBloc>();
    if (bloc.state.query.trim().isEmpty &&
        bloc.state.failureSource != BreedsFailureSource.nextPage) {
      bloc.add(const BreedsNextPageRequested());
    }
  }

  Future<void> _refresh() async {
    final bloc = context.read<BreedsBloc>()..add(const BreedsRefreshed());
    await bloc.stream.firstWhere((state) => !state.isRefreshing);
  }

  void _clearSearch() {
    _searchController.clear();
    context.read<BreedsBloc>().add(const BreedsSearchChanged(''));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<BreedsBloc, BreedsState>(
          listenWhen: (previous, current) =>
              previous.failure != current.failure ||
              previous.failureSource != current.failureSource,
          listener: _handleFailureFeedback,
          builder: (context, state) {
            final showOfflineBanner =
                state.isFromCache && _hasConnection == false;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  const _DirectoryHeader(),
                  const SizedBox(height: 18),
                  _SearchField(
                    controller: _searchController,
                    enabled:
                        !state.isInitialLoading &&
                        state.status != BreedsStatus.failure,
                    onChanged: (query) => context.read<BreedsBloc>().add(
                      BreedsSearchChanged(query),
                    ),
                    onClear: _clearSearch,
                  ),
                  if (showOfflineBanner) ...[
                    const SizedBox(height: 12),
                    const OfflineBanner(),
                  ],
                  const SizedBox(height: 14),
                  Expanded(child: _buildContent(state)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(BreedsState state) {
    if (state.isInitialLoading || state.status == BreedsStatus.initial) {
      return const SkeletonList();
    }
    if (state.status == BreedsStatus.failure && !state.hasData) {
      return ErrorView(
        title: 'No pudimos cargar el directorio',
        message: _initialFailureMessage(state.failure),
        onRetry: () => context.read<BreedsBloc>().add(const BreedsStarted()),
      );
    }
    if (state.visibleBreeds.isEmpty) {
      return _EmptySearchView(
        hasQuery: state.query.trim().isNotEmpty,
        onClear: _clearSearch,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (state.query.trim().isNotEmpty) ...[
          Text(
            '${state.visibleBreeds.length} ${state.visibleBreeds.length == 1 ? 'raza encontrada' : 'razas encontradas'}',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 10),
        ],
        Expanded(
          child: RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount:
                  state.visibleBreeds.length +
                  (state.isLoadingNextPage ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == state.visibleBreeds.length) {
                  return const _PaginationLoader();
                }
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: BreedTile(
                    breed: state.visibleBreeds[index],
                    onTap: () {
                      final breed = state.visibleBreeds[index];
                      context.pushNamed(
                        'breedDetail',
                        pathParameters: {'name': breed.name},
                        extra: breed,
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  void _handleFailureFeedback(BuildContext context, BreedsState state) {
    final failure = state.failure;
    final source = state.failureSource;
    if (failure == null) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      return;
    }
    if (source == null ||
        source == BreedsFailureSource.initialLoad ||
        (state.isFromCache && failure is NoConnectionFailure)) {
      return;
    }

    final isPagination = source == BreedsFailureSource.nextPage;
    final message = isPagination
        ? 'No se pudieron cargar más razas'
        : 'No se pudo actualizar el directorio';

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 5),
          persist: MediaQuery.accessibleNavigationOf(context),
          content: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(child: Text(message)),
            ],
          ),
          action: SnackBarAction(
            label: 'Reintentar',
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              context.read<BreedsBloc>().add(
                isPagination
                    ? const BreedsNextPageRequested()
                    : const BreedsRefreshed(),
              );
            },
          ),
        ),
      );
  }

  String _initialFailureMessage(Failure? failure) => switch (failure) {
    NoConnectionFailure() => 'Revisa tu conexión e inténtalo de nuevo.',
    TimeoutFailure() => 'La conexión tardó demasiado. Inténtalo de nuevo.',
    ServerFailure() => 'El servicio no está disponible por el momento.',
    _ => 'Ocurrió un problema inesperado. Inténtalo de nuevo.',
  };
}

class _DirectoryHeader extends StatelessWidget {
  const _DirectoryHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Directorio de razas',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'Explora y conoce sus orígenes',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.enabled,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final bool enabled;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return TextField(
      controller: controller,
      enabled: enabled,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Buscar por raza',
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: controller.text.isEmpty
            ? null
            : IconButton(
                onPressed: onClear,
                tooltip: 'Limpiar búsqueda',
                icon: const Icon(Icons.close_rounded),
              ),
        filled: true,
        fillColor: colors.surfaceContainer,
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: BorderSide(color: colors.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: BorderSide(color: colors.primary, width: 1.5),
        ),
      ),
    );
  }
}

class _EmptySearchView extends StatelessWidget {
  const _EmptySearchView({required this.hasQuery, required this.onClear});

  final bool hasQuery;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 56,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              hasQuery ? 'No encontramos razas' : 'No hay razas disponibles',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              hasQuery
                  ? 'Prueba con otro nombre.'
                  : 'Desliza hacia abajo para volver a intentarlo.',
              textAlign: TextAlign.center,
            ),
            if (hasQuery) ...[
              const SizedBox(height: 20),
              FilledButton.tonal(
                onPressed: onClear,
                child: const Text('Limpiar búsqueda'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PaginationLoader extends StatelessWidget {
  const _PaginationLoader();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 56,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 10),
          Text('Cargando más razas…'),
        ],
      ),
    );
  }
}
