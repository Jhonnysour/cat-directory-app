import 'dart:convert';

import 'package:cat_directory_app/features/breeds/data/models/breeds_page_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef CacheClock = DateTime Function();

final class CachedBreedsSnapshot {
  const CachedBreedsSnapshot({required this.page, required this.isStale});

  final BreedsPageModel page;
  final bool isStale;
}

abstract interface class BreedsLocalDataSource {
  Future<CachedBreedsSnapshot?> readBreeds();

  Future<void> writeBreeds(BreedsPageModel page);

  Future<void> clearBreeds();
}

final class BreedsLocalDataSourceImpl implements BreedsLocalDataSource {
  BreedsLocalDataSourceImpl(
    this._preferences, {
    this.ttl = const Duration(hours: 1),
    CacheClock? clock,
  }) : assert(!ttl.isNegative),
       _clock = clock ?? DateTime.now;

  static const _cacheKey = 'breeds_snapshot_v1';
  static const _schemaVersion = 1;

  final SharedPreferencesAsync _preferences;
  final Duration ttl;
  final CacheClock _clock;

  @override
  Future<CachedBreedsSnapshot?> readBreeds() async {
    final rawSnapshot = await _preferences.getString(_cacheKey);
    if (rawSnapshot == null) {
      return null;
    }

    try {
      final envelope = jsonDecode(rawSnapshot) as Map<String, dynamic>;
      if (envelope['version'] != _schemaVersion) {
        await clearBreeds();
        return null;
      }

      final cachedAtMilliseconds = envelope['cachedAt'] as int;
      final pageJson = Map<String, dynamic>.from(envelope['page'] as Map);
      final cachedAt = DateTime.fromMillisecondsSinceEpoch(
        cachedAtMilliseconds,
        isUtc: true,
      );
      final age = _clock().toUtc().difference(cachedAt);

      return CachedBreedsSnapshot(
        page: BreedsPageModel.fromJson(pageJson),
        isStale: age > ttl,
      );
    } on FormatException catch (_) {
      await clearBreeds();
      return null;
    } on TypeError catch (_) {
      await clearBreeds();
      return null;
    }
  }

  @override
  Future<void> writeBreeds(BreedsPageModel page) {
    final envelope = <String, Object?>{
      'version': _schemaVersion,
      'cachedAt': _clock().toUtc().millisecondsSinceEpoch,
      'page': page.toJson(),
    };
    return _preferences.setString(_cacheKey, jsonEncode(envelope));
  }

  @override
  Future<void> clearBreeds() => _preferences.remove(_cacheKey);
}
