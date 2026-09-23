import 'package:cat_directory_app/features/breeds/presentation/pages/breeds_page.dart';
import 'package:cat_directory_app/features/breeds/presentation/widgets/breed_tile.dart';
import 'package:cat_directory_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'support/fixtures.dart';
import 'support/mocks.dart';

void main() {
  testWidgets('opens the detail using the card accessibility action', (
    tester,
  ) async {
    final repository = MockRepository();
    final networkInfo = MockNetworkInfo();
    when(
      () => repository.watchBreeds(),
    ).thenAnswer((_) => Stream.value(pageOf(last: 1, breeds: [korat])));
    when(() => repository.getRandomFact()).thenAnswer((_) async => fact);
    when(() => networkInfo.hasConnection).thenAnswer((_) async => true);
    when(
      () => networkInfo.onConnectionChanged,
    ).thenAnswer((_) => const Stream.empty());

    await tester.pumpWidget(
      MyApp(repository: repository, networkInfo: networkInfo),
    );
    await tester.pumpAndSettle();

    expect(find.bySemanticsLabel('Korat, país Thailand'), findsOneWidget);
    expect(find.bySemanticsLabel('KO'), findsNothing);
    // This dispatches SemanticsAction.tap, not a pointer tap on the screen.
    tester.semantics.tap(find.semantics.byLabel('Korat, país Thailand'));
    await tester.pumpAndSettle();

    expect(find.text('Detalle de raza'), findsOneWidget);
    expect(find.text(fact.text), findsOneWidget);
    verify(() => repository.getRandomFact()).called(1);
    verifyNever(() => repository.findBreedByName(any()));

    final back = tester.getSemantics(find.byTooltip('Volver al directorio'));
    expect(back.getSemanticsData().hasAction(SemanticsAction.tap), isTrue);
    back.owner!.performAction(back.id, SemanticsAction.tap);
    await tester.pumpAndSettle();
    expect(find.byType(BreedsPage), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('exposes a single action and invokes it once', (tester) async {
    var activations = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BreedTile(breed: korat, onTap: () => activations++),
        ),
      ),
    );

    expect(find.bySemanticsLabel('Korat, país Thailand'), findsOneWidget);
    tester.semantics.tap(find.semantics.byLabel('Korat, país Thailand'));
    expect(activations, 1);
  });

  testWidgets('does not expose a tap action without a callback', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: BreedTile(breed: korat)),
      ),
    );
    final node = tester.getSemantics(
      find.bySemanticsLabel('Korat, país Thailand'),
    );
    expect(node.getSemanticsData().hasAction(SemanticsAction.tap), isFalse);
  });
}
