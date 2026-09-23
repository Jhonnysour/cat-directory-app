import 'package:cat_directory_app/core/network/network_info.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import '../../support/mocks.dart';

void main() {
  for (final (results, expected) in <(List<ConnectivityResult>, bool)>[
    ([], false),
    ([ConnectivityResult.none], false),
    ([ConnectivityResult.wifi], true),
    ([ConnectivityResult.mobile], true),
    ([ConnectivityResult.ethernet], true),
    ([ConnectivityResult.vpn], true),
    ([ConnectivityResult.none, ConnectivityResult.wifi], true),
  ]) {
    test('connection detection for $results', () async {
      final connectivity = MockConnectivity();
      when(
        () => connectivity.checkConnectivity(),
      ).thenAnswer((_) async => results);
      expect(await NetworkInfoImpl(connectivity).hasConnection, expected);
    });
  }
  test('deduplicates connectivity changes by online/offline state', () async {
    final connectivity = MockConnectivity();
    when(() => connectivity.onConnectivityChanged).thenAnswer(
      (_) => Stream.fromIterable([
        [ConnectivityResult.none],
        [ConnectivityResult.none],
        [ConnectivityResult.wifi],
        [ConnectivityResult.mobile],
        [ConnectivityResult.none],
      ]),
    );
    await expectLater(
      NetworkInfoImpl(connectivity).onConnectionChanged,
      emitsInOrder([false, true, false, emitsDone]),
    );
  });
}
