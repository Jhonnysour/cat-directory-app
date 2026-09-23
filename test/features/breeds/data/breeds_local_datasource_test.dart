import 'dart:convert';
import 'package:cat_directory_app/features/breeds/data/datasources/breeds_local_datasource.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import '../../../support/fixtures.dart';
import '../../../support/mocks.dart';

void main() {
  const key = 'breeds_snapshot_v1';
  late MockPreferences preferences;
  late BreedsLocalDataSourceImpl source;
  late DateTime now;
  String? stored;
  setUp(() {
    now = DateTime.utc(2026, 9, 23, 12);
    stored = null;
    preferences = MockPreferences();
    when(() => preferences.getString(key)).thenAnswer((_) async => stored);
    when(() => preferences.setString(key, any())).thenAnswer((
      invocation,
    ) async {
      stored = invocation.positionalArguments[1] as String;
    });
    when(() => preferences.remove(key)).thenAnswer((_) async {
      stored = null;
    });
    source = BreedsLocalDataSourceImpl(preferences, clock: () => now);
  });
  test('missing cache returns null', () async {
    expect(await source.readBreeds(), isNull);
  });
  test('round trips version, UTC timestamp, catalog and pagination', () async {
    final page = modelPage(page: 2, breeds: [koratModel, siameseModel]);
    await source.writeBreeds(page);
    final envelope = jsonDecode(stored!) as Map<String, dynamic>;
    expect(envelope['version'], 1);
    expect(envelope['cachedAt'], now.millisecondsSinceEpoch);
    final cached = await source.readBreeds();
    expect(cached!.page, page);
    expect(cached.isStale, false);
  });
  for (final age in [
    const Duration(minutes: 59),
    const Duration(hours: 1),
    const Duration(hours: 1, microseconds: 1),
  ]) {
    test('TTL boundary at $age', () async {
      await source.writeBreeds(modelPage());
      now = now.add(age);
      final cached = await source.readBreeds();
      expect(cached!.isStale, age > const Duration(hours: 1));
      expect(cached.page.data, [koratModel]);
      verifyNever(() => preferences.remove(key));
    });
  }
  test('custom TTL and zero TTL are respected', () async {
    source = BreedsLocalDataSourceImpl(
      preferences,
      ttl: Duration.zero,
      clock: () => now,
    );
    await source.writeBreeds(modelPage());
    now = now.add(const Duration(milliseconds: 1));
    expect((await source.readBreeds())!.isStale, true);
  });
  for (final malformed in [
    'not-json',
    '[]',
    '{"version":2}',
    '{"version":1,"cachedAt":"bad","page":{}}',
    '{"version":1,"cachedAt":0,"page":{}}',
  ]) {
    test('invalid snapshot is removed safely: $malformed', () async {
      stored = malformed;
      expect(await source.readBreeds(), isNull);
      verify(() => preferences.remove(key)).called(1);
      expect(stored, isNull);
    });
  }
  test('clear removes only the catalog key', () async {
    await source.clearBreeds();
    verify(() => preferences.remove(key)).called(1);
    verifyNoMoreInteractions(preferences);
  });
  test(
    'storage errors propagate so the repository can apply its fallback',
    () async {
      when(
        () => preferences.getString(key),
      ).thenThrow(StateError('unavailable'));
      await expectLater(source.readBreeds(), throwsStateError);
      verifyNever(() => preferences.remove(key));
    },
  );
}
