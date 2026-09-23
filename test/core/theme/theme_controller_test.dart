import 'package:cat_directory_app/core/theme/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import '../../support/mocks.dart';

void main() {
  late MockPreferences preferences;
  late ThemeController controller;
  setUp(() {
    preferences = MockPreferences();
    controller = ThemeController(preferences);
    when(() => preferences.setString(any(), any())).thenAnswer((_) async {});
  });
  tearDown(() => controller.dispose());
  test('defaults to system before loading', () {
    expect(controller.mode, ThemeMode.system);
  });
  final storedModes = <String?, ThemeMode>{
    null: ThemeMode.system,
    'system': ThemeMode.system,
    'light': ThemeMode.light,
    'dark': ThemeMode.dark,
    'invalid': ThemeMode.system,
  };
  for (final entry in storedModes.entries) {
    test('loads stored preference ${entry.key}', () async {
      when(
        () => preferences.getString('theme_mode'),
      ).thenAnswer((_) async => entry.key);
      await controller.load();
      expect(controller.mode, entry.value);
    });
  }
  test('read error falls back to system', () async {
    when(
      () => preferences.getString('theme_mode'),
    ).thenThrow(StateError('unavailable'));
    await controller.load();
    expect(controller.mode, ThemeMode.system);
  });
  test(
    'changing mode notifies and persists, reselecting it does neither',
    () async {
      var notifications = 0;
      controller.addListener(() {
        notifications++;
      });
      await controller.setMode(ThemeMode.dark);
      await controller.setMode(ThemeMode.dark);
      expect(notifications, 1);
      expect(controller.mode, ThemeMode.dark);
      verify(() => preferences.setString('theme_mode', 'dark')).called(1);
      await controller.setMode(ThemeMode.system);
      verify(() => preferences.setString('theme_mode', 'system')).called(1);
      expect(notifications, 2);
    },
  );
  test(
    'write failure still applies the theme for the current session',
    () async {
      when(
        () => preferences.setString(any(), any()),
      ).thenThrow(StateError('unavailable'));
      var notifications = 0;
      controller.addListener(() {
        notifications++;
      });
      await controller.setMode(ThemeMode.light);
      expect(controller.mode, ThemeMode.light);
      expect(notifications, 1);
    },
  );
  test('a new controller restores the saved selection', () async {
    String? stored;
    when(() => preferences.setString('theme_mode', any())).thenAnswer((
      i,
    ) async {
      stored = i.positionalArguments[1] as String;
    });
    when(
      () => preferences.getString('theme_mode'),
    ).thenAnswer((_) async => stored);
    await controller.setMode(ThemeMode.dark);
    final reopened = ThemeController(preferences);
    addTearDown(reopened.dispose);
    await reopened.load();
    expect(reopened.mode, ThemeMode.dark);
  });
  test('transient controller works without platform storage', () async {
    final transient = ThemeController.transient(initialMode: ThemeMode.dark);
    addTearDown(transient.dispose);
    await transient.load();
    expect(transient.mode, ThemeMode.dark);
    await transient.setMode(ThemeMode.light);
    expect(transient.mode, ThemeMode.light);
    verifyZeroInteractions(preferences);
  });
}
