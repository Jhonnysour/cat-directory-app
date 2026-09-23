import 'dart:ui' show SemanticsAction;

import 'package:cat_directory_app/core/theme/theme_controller.dart';
import 'package:cat_directory_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'support/fixtures.dart';
import 'support/mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    // Real font metrics matter for a narrow, large-text header. Ahem (the
    // widget-test default) is not representative of either bundled typeface.
    await (FontLoader(
      'GreatVibes',
    )..addFont(rootBundle.load('assets/fonts/GreatVibes-Regular.ttf'))).load();
    await (FontLoader('NunitoSans')
          ..addFont(rootBundle.load('assets/fonts/NunitoSans-Regular.ttf'))
          ..addFont(rootBundle.load('assets/fonts/NunitoSans-SemiBold.ttf'))
          ..addFont(rootBundle.load('assets/fonts/NunitoSans-Bold.ttf')))
        .load();
  });

  late MockRepository repository;
  late MockNetworkInfo networkInfo;
  late ThemeController themeController;

  setUp(() {
    repository = MockRepository();
    networkInfo = MockNetworkInfo();
    themeController = ThemeController.transient(initialMode: ThemeMode.light);
    when(
      () => repository.watchBreeds(),
    ).thenAnswer((_) => Stream.value(pageOf(last: 1)));
    when(() => networkInfo.hasConnection).thenAnswer((_) async => true);
    when(
      () => networkInfo.onConnectionChanged,
    ).thenAnswer((_) => const Stream.empty());
    addTearDown(themeController.dispose);
  });

  Future<void> openApp(WidgetTester tester) async {
    await tester.pumpWidget(
      MyApp(
        repository: repository,
        networkInfo: networkInfo,
        themeController: themeController,
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('uses Great Vibes only for the brand and Nunito for content', (
    tester,
  ) async {
    await openApp(tester);

    final brand = tester.widget<Text>(find.text('Cat-tionary'));
    expect(brand.style?.fontFamily, 'GreatVibes');
    expect(brand.style?.fontWeight, FontWeight.w400);
    expect(
      find.byWidgetPredicate(
        (widget) => widget is Text && widget.style?.fontFamily == 'GreatVibes',
      ),
      findsOneWidget,
    );
    for (final text in [
      'Tu directorio de razas',
      'Explora y conoce más sobre tus gatos favoritos',
      'Korat',
    ]) {
      expect(
        tester.widget<Text>(find.text(text)).style?.fontFamily,
        'NunitoSans',
      );
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('fits the header at 320 logical pixels and double text scale', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    // Isolate header layout from the independently sized directory cards.
    when(
      () => repository.watchBreeds(),
    ).thenAnswer((_) => Stream.value(pageOf(last: 1, breeds: [])));
    await openApp(tester);

    final brandRect = tester.getRect(find.text('Cat-tionary'));
    final taglineRect = tester.getRect(find.text('Tu directorio de razas'));
    final themeButton = find.byTooltip('Cambiar tema. Actual: Claro');
    final themeRect = tester.getRect(themeButton);
    final searchRect = tester.getRect(find.byType(TextField));

    expect(brandRect.left, greaterThanOrEqualTo(0));
    expect(brandRect.right, lessThanOrEqualTo(themeRect.left));
    expect(taglineRect.top, greaterThanOrEqualTo(brandRect.bottom));
    expect(taglineRect.right, lessThanOrEqualTo(themeRect.left));
    expect(themeRect.right, lessThanOrEqualTo(320));
    expect(searchRect.top, greaterThan(taglineRect.bottom));
    expect(searchRect.bottom, lessThan(800));
    expect(themeButton.hitTestable(), findsOneWidget);
    expect(
      find.bySemanticsLabel('Cat-tionary: Tu directorio de razas'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'announces the brand once and keeps the theme action accessible',
    (tester) async {
      await openApp(tester);

      final heading = find.bySemanticsLabel(
        'Cat-tionary: Tu directorio de razas',
      );
      expect(heading, findsOneWidget);
      expect(
        tester.getSemantics(heading).flagsCollection.isHeader,
        isTrue,
      );
      expect(find.bySemanticsLabel('Cat-tionary'), findsNothing);
      expect(find.bySemanticsLabel('Tu directorio de razas'), findsNothing);

      final themeButton = find.byTooltip('Cambiar tema. Actual: Claro');
      final semantics = tester.getSemantics(themeButton);
      expect(semantics.flagsCollection.isButton, isTrue);
      expect(
        semantics.getSemanticsData().hasAction(SemanticsAction.tap),
        isTrue,
      );
      await tester.tap(themeButton);
      await tester.pumpAndSettle();
      expect(find.text('Apariencia'), findsOneWidget);
      await tester.tap(find.text('Oscuro'));
      await tester.pumpAndSettle();

      expect(themeController.mode, ThemeMode.dark);
      expect(
        Theme.of(tester.element(find.text('Cat-tionary'))).brightness,
        Brightness.dark,
      );
      expect(find.byTooltip('Cambiar tema. Actual: Oscuro'), findsOneWidget);
      expect(heading, findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
