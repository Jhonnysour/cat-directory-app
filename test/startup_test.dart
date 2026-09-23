import 'dart:async';

import 'package:cat_directory_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('holds the first frame for 500 ms while async data can load', (
    tester,
  ) async {
    final binding = tester.binding;
    binding.resetFirstFrameSent();
    final data = Completer<String>();

    runAppWithSplash(
      MaterialApp(
        home: FutureBuilder<String>(
          future: data.future,
          builder: (context, snapshot) => Text(snapshot.data ?? 'Cargando'),
        ),
      ),
    );
    expect(binding.sendFramesToEngine, isFalse);
    await tester.pump();
    expect(find.text('Cargando'), findsOneWidget);

    data.complete('Datos preparados');
    await tester.pump(const Duration(milliseconds: 499));
    expect(find.text('Datos preparados'), findsOneWidget);
    expect(binding.sendFramesToEngine, isFalse);

    await tester.pump(const Duration(milliseconds: 1));
    expect(binding.sendFramesToEngine, isTrue);

    binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(binding.sendFramesToEngine, isTrue);
    expect(find.text('Datos preparados'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
