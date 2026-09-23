import 'dart:async';

import 'package:cat_directory_app/core/error/failure.dart';
import 'package:cat_directory_app/core/network/network_info.dart';
import 'package:cat_directory_app/core/theme/theme_controller.dart';
import 'package:cat_directory_app/features/breeds/domain/entities/breed.dart';
import 'package:cat_directory_app/features/breeds/domain/entities/breeds_page.dart';
import 'package:cat_directory_app/features/breeds/domain/entities/cat_fact.dart';
import 'package:cat_directory_app/features/breeds/domain/repositories/breeds_repository.dart';
import 'package:cat_directory_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shows the breeds directory', (tester) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MyApp(
        repository: _FakeBreedsRepository(),
        networkInfo: _FakeNetworkInfo(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Directorio de razas'), findsOneWidget);
    expect(
      find.text('Explora y conoce más sobre tus gatos favoritos'),
      findsOneWidget,
    );
    expect(find.text('Abyssinian'), findsOneWidget);
    expect(find.text('Egypt'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('exposes semantic labels for search and breed list', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();

    await tester.pumpWidget(
      MyApp(
        repository: _FakeBreedsRepository(),
        networkInfo: _FakeNetworkInfo(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel(RegExp('Buscador de razas')), findsOneWidget);
    expect(
      find.bySemanticsLabel(RegExp('Lista de razas, 1 elementos')),
      findsOneWidget,
    );
    expect(
      find.bySemanticsLabel(RegExp('Abyssinian, país Egypt')),
      findsOneWidget,
    );

    await tester.enterText(find.byType(TextField), 'Aby');
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.byTooltip('Limpiar búsqueda'), findsOneWidget);
    expect(find.text('1 raza encontrada'), findsOneWidget);
    expect(
      find.bySemanticsLabel(RegExp('Abyssinian, país Egypt')),
      findsOneWidget,
    );

    await tester.tap(find.byTooltip('Limpiar búsqueda'));
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.byTooltip('Limpiar búsqueda'), findsNothing);
    expect(find.text('1 raza encontrada'), findsNothing);
    semantics.dispose();
  });

  testWidgets('uses Nunito Sans and follows the system dark theme', (
    tester,
  ) async {
    tester.binding.platformDispatcher.platformBrightnessTestValue =
        Brightness.dark;
    addTearDown(
      tester.binding.platformDispatcher.clearPlatformBrightnessTestValue,
    );

    await tester.pumpWidget(
      MyApp(
        repository: _FakeBreedsRepository(),
        networkInfo: _FakeNetworkInfo(),
      ),
    );
    await tester.pumpAndSettle();

    final context = tester.element(find.text('Directorio de razas'));
    final theme = Theme.of(context);

    expect(theme.brightness, Brightness.dark);
    expect(theme.textTheme.bodyMedium?.fontFamily, 'NunitoSans');
  });

  testWidgets('lets the user override the system theme', (tester) async {
    tester.binding.platformDispatcher.platformBrightnessTestValue =
        Brightness.dark;
    addTearDown(
      tester.binding.platformDispatcher.clearPlatformBrightnessTestValue,
    );
    final themeController = ThemeController.transient();
    addTearDown(themeController.dispose);

    await tester.pumpWidget(
      MyApp(
        repository: _FakeBreedsRepository(),
        networkInfo: _FakeNetworkInfo(),
        themeController: themeController,
      ),
    );
    await tester.pumpAndSettle();

    expect(
      Theme.of(tester.element(find.text('Directorio de razas'))).brightness,
      Brightness.dark,
    );

    await tester.tap(find.byTooltip(RegExp('Cambiar tema')));
    await tester.pumpAndSettle();
    expect(find.text('Apariencia'), findsOneWidget);
    expect(find.text('Sistema'), findsOneWidget);
    expect(find.text('Claro'), findsOneWidget);
    expect(find.text('Oscuro'), findsOneWidget);

    await tester.tap(find.text('Claro'));
    await tester.pumpAndSettle();

    expect(themeController.mode, ThemeMode.light);
    expect(
      Theme.of(tester.element(find.text('Directorio de razas'))).brightness,
      Brightness.light,
    );
  });

  testWidgets('opens breed detail while the random fact loads independently', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    final factCompleter = Completer<CatFact>();
    final repository = _FakeBreedsRepository(factCompleter: factCompleter);

    await tester.pumpWidget(
      MyApp(repository: repository, networkInfo: _FakeNetworkInfo()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Abyssinian'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Detalle de raza'), findsOneWidget);
    expect(find.text('Información de la raza'), findsOneWidget);
    expect(find.text('Natural'), findsOneWidget);
    expect(find.text('Short'), findsOneWidget);
    expect(find.text('Ticked'), findsOneWidget);
    expect(find.text('Buscando un dato curioso…'), findsOneWidget);
    expect(find.bySemanticsLabel('Buscando un dato curioso'), findsOneWidget);
    expect(repository.findCalls, 0);

    factCompleter.complete(
      const CatFact(text: 'Los gatos duermen muchas horas.', length: 32),
    );
    await tester.pumpAndSettle();

    expect(find.text('Los gatos duermen muchas horas.'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('resolves a cold breed deep link through the repository', (
    tester,
  ) async {
    final repository = _FakeBreedsRepository();

    await tester.pumpWidget(
      MyApp(
        repository: repository,
        networkInfo: _FakeNetworkInfo(),
        initialLocation: '/breed/Abyssinian',
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Detalle de raza'), findsOneWidget);
    expect(find.text('Abyssinian'), findsWidgets);
    expect(repository.findCalls, 1);
    expect(repository.watchCalls, 0);
  });

  testWidgets('shows not found only after a successful cold lookup', (
    tester,
  ) async {
    await tester.pumpWidget(
      MyApp(
        repository: _FakeBreedsRepository(resolvedBreed: null),
        networkInfo: _FakeNetworkInfo(),
        initialLocation: '/breed/Unknown%20Cat',
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Raza no encontrada'), findsOneWidget);
    expect(find.text('Volver al directorio'), findsWidgets);
  });

  testWidgets('does not report not found when a cold lookup loses connection', (
    tester,
  ) async {
    await tester.pumpWidget(
      MyApp(
        repository: _FakeBreedsRepository(
          findFailure: const Failure.noConnection(),
        ),
        networkInfo: _FakeNetworkInfo(),
        initialLocation: '/breed/Abyssinian',
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No pudimos cargar esta raza'), findsOneWidget);
    expect(find.text('Raza no encontrada'), findsNothing);
    expect(find.text('Reintentar'), findsOneWidget);
  });

  testWidgets('pagination snackbar expires and keeps loaded breeds', (
    tester,
  ) async {
    await tester.pumpWidget(
      MyApp(
        repository: _PaginationFailureRepository(),
        networkInfo: _FakeNetworkInfo(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.drag(find.byType(ListView), const Offset(0, -700));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('No se pudieron cargar más razas'), findsOneWidget);
    expect(find.text('Breed 7'), findsOneWidget);

    await tester.pump(const Duration(seconds: 6));
    await tester.pumpAndSettle();

    expect(find.text('No se pudieron cargar más razas'), findsNothing);
    expect(find.text('Breed 7'), findsOneWidget);
  });
}

final class _FakeNetworkInfo implements NetworkInfo {
  @override
  Future<bool> get hasConnection async => true;

  @override
  Stream<bool> get onConnectionChanged => const Stream.empty();
}

final class _FakeBreedsRepository implements BreedsRepository {
  _FakeBreedsRepository({
    this.resolvedBreed = _breed,
    this.findFailure,
    this.factCompleter,
  });

  static const _breed = Breed(
    name: 'Abyssinian',
    country: 'Egypt',
    origin: 'Natural',
    coat: 'Short',
    pattern: 'Ticked',
  );

  final Breed? resolvedBreed;
  final Failure? findFailure;
  final Completer<CatFact>? factCompleter;
  int findCalls = 0;
  int watchCalls = 0;

  @override
  Stream<BreedsPage> watchBreeds({int limit = 10}) async* {
    watchCalls++;
    yield BreedsPage(
      breeds: const [_breed],
      currentPage: 1,
      lastPage: 1,
      perPage: 10,
      total: 1,
    );
  }

  @override
  Future<Breed?> findBreedByName(String name, {int limit = 10}) async {
    findCalls++;
    if (findFailure case final failure?) {
      throw failure;
    }
    return resolvedBreed;
  }

  @override
  Future<BreedsPage> getBreedsPage({required int page, int limit = 10}) {
    throw UnimplementedError();
  }

  @override
  Future<CatFact> getRandomFact() =>
      factCompleter?.future ??
      Future.value(
        const CatFact(text: 'Los gatos duermen muchas horas.', length: 32),
      );

  @override
  Future<BreedsPage> refreshBreeds({int limit = 10}) {
    throw UnimplementedError();
  }
}

final class _PaginationFailureRepository implements BreedsRepository {
  static final _breeds = List<Breed>.generate(
    7,
    (index) => Breed(
      name: 'Breed ${index + 1}',
      country: 'Country ${index + 1}',
      origin: 'Origin',
      coat: 'Short',
      pattern: 'Solid',
    ),
    growable: false,
  );

  @override
  Stream<BreedsPage> watchBreeds({int limit = 10}) async* {
    yield BreedsPage(
      breeds: _breeds,
      currentPage: 1,
      lastPage: 2,
      perPage: 10,
      total: 14,
    );
  }

  @override
  Future<BreedsPage> getBreedsPage({required int page, int limit = 10}) async {
    throw const Failure.noConnection();
  }

  @override
  Future<Breed?> findBreedByName(String name, {int limit = 10}) async => null;

  @override
  Future<CatFact> getRandomFact() {
    throw UnimplementedError();
  }

  @override
  Future<BreedsPage> refreshBreeds({int limit = 10}) {
    throw UnimplementedError();
  }
}
