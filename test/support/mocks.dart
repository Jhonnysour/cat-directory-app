import 'package:cat_directory_app/core/network/network_info.dart';
import 'package:cat_directory_app/features/breeds/data/datasources/breeds_local_datasource.dart';
import 'package:cat_directory_app/features/breeds/data/datasources/breeds_remote_datasource.dart';
import 'package:cat_directory_app/features/breeds/domain/repositories/breeds_repository.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockRepository extends Mock implements BreedsRepository {}

class MockLocalSource extends Mock implements BreedsLocalDataSource {}

class MockRemoteSource extends Mock implements BreedsRemoteDataSource {}

class MockNetworkInfo extends Mock implements NetworkInfo {}

class MockPreferences extends Mock implements SharedPreferencesAsync {}

class MockConnectivity extends Mock implements Connectivity {}
