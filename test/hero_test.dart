import 'dart:async';

import 'package:cat_directory_app/features/breeds/domain/entities/breed.dart';
import 'package:cat_directory_app/features/breeds/domain/entities/cat_fact.dart';
import 'package:cat_directory_app/features/breeds/presentation/widgets/breed_avatar.dart';
import 'package:cat_directory_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'support/fixtures.dart';
import 'support/mocks.dart';

void main() {
  late MockRepository repository;
  late MockNetworkInfo networkInfo;

  setUp(() {
    repository = MockRepository();
    networkInfo = MockNetworkInfo();
    when(() => repository.watchBreeds()).thenAnswer(
      (_) => Stream.value(pageOf(last: 1, breeds: [korat, siamese])),
    );
    when(() => repository.getRandomFact()).thenAnswer((_) async => fact);
    when(() => networkInfo.hasConnection).thenAnswer((_) async => true);
    when(
      () => networkInfo.onConnectionChanged,
    ).thenAnswer((_) => const Stream.empty());
  });

  Future<void> openApp(WidgetTester tester, {String? initialLocation}) async {
    await tester.pumpWidget(
      MyApp(
        repository: repository,
        networkInfo: networkInfo,
        initialLocation: initialLocation,
      ),
    );
    await tester.pumpAndSettle();
  }

  for (final brightness in Brightness.values) {
    testWidgets('flies to detail and back in ${brightness.name} theme', (
      tester,
    ) async {
      tester.binding.platformDispatcher.platformBrightnessTestValue =
          brightness;
      addTearDown(
        tester.binding.platformDispatcher.clearPlatformBrightnessTestValue,
      );
      await openApp(tester);
      final source = tester.getRect(find.text('KO'));
      expect(
        Theme.of(tester.element(find.text('Directorio de razas'))).brightness,
        brightness,
      );

      await tester.tap(find.text('Korat'));
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // A Hero widget on each page alone does not prove a flight happened.
      // During a real flight its child moves into the Navigator overlay,
      // outside either Hero, with an intermediate on-screen position.
      expect(_flyingMonogram('KO'), findsOneWidget);
      final outgoing = tester.getRect(_flyingMonogram('KO'));
      await tester.pumpAndSettle();
      final destination = tester.getRect(find.text('KO'));
      _expectIntermediate(outgoing, source, destination);
      expect(_flyingMonogram('KO'), findsNothing);
      expect(_heroFor('Korat'), findsOneWidget);
      expect(find.text('Detalle de raza'), findsOneWidget);
      verifyNever(() => repository.findBreedByName(any()));

      await tester.tap(find.byTooltip('Volver al directorio'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(_flyingMonogram('KO'), findsOneWidget);
      final returning = tester.getRect(_flyingMonogram('KO'));
      _expectIntermediate(returning, destination, source);
      await tester.pumpAndSettle();

      expect(_flyingMonogram('KO'), findsNothing);
      expect(tester.getRect(find.text('KO')), source);
      expect(find.text('Directorio de razas'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('keeps the search filter after a round trip with Hero', (
    tester,
  ) async {
    await openApp(tester);
    await tester.enterText(find.byType(TextField), 'Kor');
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();
    expect(find.text('1 raza encontrada'), findsOneWidget);
    expect(find.text('Siamese'), findsNothing);
    expect(find.byType(Hero), findsOneWidget);

    await tester.tap(find.text('Korat'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(_flyingMonogram('KO'), findsOneWidget);
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Volver al directorio'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(_flyingMonogram('KO'), findsOneWidget);
    await tester.pumpAndSettle();

    expect(
      tester.widget<TextField>(find.byType(TextField)).controller?.text,
      'Kor',
    );
    expect(find.text('1 raza encontrada'), findsOneWidget);
    expect(find.text('Siamese'), findsNothing);
    expect(find.byType(Hero), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('uses distinct Hero tags for breeds with the same monogram', (
    tester,
  ) async {
    const korean = Breed(
      name: 'Korean Bobtail',
      country: 'Korea',
      origin: 'Natural',
      coat: 'Short',
      pattern: 'All',
    );
    when(
      () => repository.watchBreeds(),
    ).thenAnswer((_) => Stream.value(pageOf(last: 1, breeds: [korat, korean])));
    await openApp(tester);

    expect(find.text('KO'), findsNWidgets(2));
    final tags = tester
        .widgetList<Hero>(find.byType(Hero))
        .map((hero) => hero.tag);
    expect(tags.toSet().length, 2);
    expect(tags, contains(BreedAvatar.heroTagFor('Korat')));
    expect(tags, contains(BreedAvatar.heroTagFor('Korean Bobtail')));

    await tester.tap(find.text('Korean Bobtail'));
    await tester.pumpAndSettle();
    expect(_heroFor('Korean Bobtail'), findsOneWidget);
    expect(find.text('Korea'), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });

  testWidgets('opens a cold detail link without a source Hero', (tester) async {
    when(
      () => repository.findBreedByName('Korat'),
    ).thenAnswer((_) async => korat);
    await openApp(tester, initialLocation: '/breed/Korat');

    expect(find.text('Detalle de raza'), findsOneWidget);
    expect(_heroFor('Korat'), findsOneWidget);
    expect(_flyingMonogram('KO'), findsNothing);
    verify(() => repository.findBreedByName('Korat')).called(1);
    verifyNever(() => repository.watchBreeds());
    expect(tester.takeException(), isNull);

    await tester.tap(find.byTooltip('Volver al directorio'));
    await tester.pumpAndSettle();
    expect(find.text('Directorio de razas'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('starts the Hero flight even while the random fact is pending', (
    tester,
  ) async {
    final pendingFact = Completer<CatFact>();
    when(
      () => repository.getRandomFact(),
    ).thenAnswer((_) => pendingFact.future);
    await openApp(tester);

    await tester.tap(find.text('Korat'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(_flyingMonogram('KO'), findsOneWidget);
    expect(find.text('Buscando un dato curioso…'), findsOneWidget);
    verifyNever(() => repository.findBreedByName(any()));

    pendingFact.complete(fact);
    await tester.pumpAndSettle();
    expect(find.text(fact.text), findsOneWidget);
    expect(_heroFor('Korat'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('disables the shared-element flight for reduced motion', (
    tester,
  ) async {
    tester.binding.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(
      tester.binding.platformDispatcher.clearAccessibilityFeaturesTestValue,
    );
    await openApp(tester);
    final sourceMode = find
        .ancestor(of: _heroFor('Korat'), matching: find.byType(HeroMode))
        .first;
    expect(tester.widget<HeroMode>(sourceMode).enabled, isFalse);

    await tester.tap(find.text('Korat'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(_flyingMonogram('KO'), findsNothing);
    await tester.pumpAndSettle();
    expect(find.text('Detalle de raza'), findsOneWidget);

    final destinationMode = find
        .ancestor(of: _heroFor('Korat'), matching: find.byType(HeroMode))
        .first;
    expect(tester.widget<HeroMode>(destinationMode).enabled, isFalse);
    await tester.tap(find.byTooltip('Volver al directorio'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(_flyingMonogram('KO'), findsNothing);
    await tester.pumpAndSettle();
    expect(find.text('Directorio de razas'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('does not expose the decorative monogram during a Hero flight', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    try {
      await openApp(tester);
      expect(find.bySemanticsLabel('Korat, país Thailand'), findsOneWidget);
      expect(find.bySemanticsLabel('KO'), findsNothing);

      await tester.tap(find.text('Korat'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(_flyingMonogram('KO'), findsOneWidget);
      expect(find.bySemanticsLabel('KO'), findsNothing);
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel('Korat, país Thailand'), findsOneWidget);
      expect(find.bySemanticsLabel('KO'), findsNothing);

      await tester.tap(find.byTooltip('Volver al directorio'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.bySemanticsLabel('KO'), findsNothing);
      await tester.pumpAndSettle();
      expect(find.bySemanticsLabel('Korat, país Thailand'), findsOneWidget);
      expect(tester.takeException(), isNull);
    } finally {
      semantics.dispose();
    }
  });
}

Finder _heroFor(String name) => find.byWidgetPredicate(
  (widget) => widget is Hero && widget.tag == BreedAvatar.heroTagFor(name),
);

Finder _flyingMonogram(String monogram) => find.byElementPredicate((element) {
  if (element.widget case Text(data: final text) when text == monogram) {
    var isInsideHero = false;
    element.visitAncestorElements((ancestor) {
      if (ancestor.widget is Hero) {
        isInsideHero = true;
        return false;
      }
      return true;
    });
    return !isInsideHero;
  }
  return false;
});

void _expectIntermediate(Rect intermediate, Rect from, Rect to) {
  expect((intermediate.center - from.center).distance, greaterThan(0.1));
  expect((intermediate.center - to.center).distance, greaterThan(0.1));
  expect(
    intermediate.center.dy,
    inExclusiveRange(
      from.center.dy < to.center.dy ? from.center.dy : to.center.dy,
      from.center.dy > to.center.dy ? from.center.dy : to.center.dy,
    ),
  );
}
