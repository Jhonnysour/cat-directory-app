import 'dart:async';

import 'package:cat_directory_app/core/error/failure.dart';
import 'package:cat_directory_app/core/network/network_info.dart';
import 'package:cat_directory_app/core/theme/theme_controller.dart';
import 'package:cat_directory_app/features/breeds/presentation/bloc/breeds_bloc.dart';
import 'package:cat_directory_app/features/breeds/presentation/widgets/breed_tile.dart';
import 'package:cat_directory_app/features/breeds/presentation/widgets/error_view.dart';
import 'package:cat_directory_app/features/breeds/presentation/widgets/offline_banner.dart';
import 'package:cat_directory_app/features/breeds/presentation/widgets/skeleton_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class BreedsPage extends StatefulWidget {
  const BreedsPage({
    required this.networkInfo,
    required this.themeController,
    super.key,
  });

  final NetworkInfo networkInfo;
  final ThemeController themeController;

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
                  _DirectoryHeader(themeController: widget.themeController),
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
            semanticsLabel: 'Actualizar directorio de razas',
            child: Semantics(
              container: true,
              label: 'Lista de razas, ${state.visibleBreeds.length} elementos',
              child: ListView.builder(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                semanticChildCount: state.visibleBreeds.length,
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
  const _DirectoryHeader({required this.themeController});

  final ThemeController themeController;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
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
          ),
        ),
        const SizedBox(width: 12),
        ListenableBuilder(
          listenable: themeController,
          builder: (context, child) => IconButton.filledTonal(
            onPressed: () => _showThemePicker(context),
            tooltip:
                'Cambiar tema. Actual: ${_themeModeLabel(themeController.mode)}',
            icon: const Icon(Icons.brightness_6_rounded),
          ),
        ),
      ],
    );
  }

  Future<void> _showThemePicker(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Text(
                  'Apariencia',
                  style: Theme.of(
                    sheetContext,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              _ThemeOptionTile(
                icon: Icons.settings_brightness_rounded,
                title: 'Sistema',
                subtitle: 'Sigue la configuración del dispositivo',
                selected: themeController.mode == ThemeMode.system,
                onTap: () => _selectTheme(sheetContext, ThemeMode.system),
              ),
              _ThemeOptionTile(
                icon: Icons.light_mode_rounded,
                title: 'Claro',
                subtitle: 'Usa siempre el tema claro',
                selected: themeController.mode == ThemeMode.light,
                onTap: () => _selectTheme(sheetContext, ThemeMode.light),
              ),
              _ThemeOptionTile(
                icon: Icons.dark_mode_rounded,
                title: 'Oscuro',
                subtitle: 'Usa siempre el tema oscuro',
                selected: themeController.mode == ThemeMode.dark,
                onTap: () => _selectTheme(sheetContext, ThemeMode.dark),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _selectTheme(BuildContext context, ThemeMode mode) {
    themeController.setMode(mode);
    Navigator.of(context).pop();
  }

  String _themeModeLabel(ThemeMode mode) => switch (mode) {
    ThemeMode.system => 'Sistema',
    ThemeMode.light => 'Claro',
    ThemeMode.dark => 'Oscuro',
  };
}

class _ThemeOptionTile extends StatelessWidget {
  const _ThemeOptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ListTile(
      leading: Icon(icon, color: selected ? colors.primary : null),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: selected
          ? Icon(Icons.check_circle_rounded, color: colors.primary)
          : const Icon(Icons.circle_outlined),
      selected: selected,
      selectedColor: colors.primary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      onTap: onTap,
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
    return Semantics(
      textField: true,
      label: 'Buscador de razas',
      hint: 'Escribe el nombre de una raza para filtrar la lista',
      child: TextField(
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
            Semantics(
              container: true,
              liveRegion: true,
              label: hasQuery
                  ? 'No encontramos razas. Prueba con otro nombre.'
                  : 'No hay razas disponibles. Desliza hacia abajo para volver a intentarlo.',
              child: ExcludeSemantics(
                child: Column(
                  children: [
                    Icon(
                      Icons.search_off_rounded,
                      size: 56,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      hasQuery
                          ? 'No encontramos razas'
                          : 'No hay razas disponibles',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      hasQuery
                          ? 'Prueba con otro nombre.'
                          : 'Desliza hacia abajo para volver a intentarlo.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
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
    return Semantics(
      container: true,
      liveRegion: true,
      label: 'Cargando más razas',
      child: ExcludeSemantics(
        child: SizedBox(
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
        ),
      ),
    );
  }
}
