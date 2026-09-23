import 'package:cat_directory_app/core/network/dio_client.dart';
import 'package:cat_directory_app/core/network/network_info.dart';
import 'package:cat_directory_app/features/breeds/data/datasources/breeds_local_datasource.dart';
import 'package:cat_directory_app/features/breeds/data/datasources/breeds_remote_datasource.dart';
import 'package:cat_directory_app/features/breeds/data/repositories/breeds_repository_impl.dart';
import 'package:cat_directory_app/features/breeds/domain/repositories/breeds_repository.dart';
import 'package:cat_directory_app/features/breeds/presentation/bloc/breeds_bloc.dart';
import 'package:cat_directory_app/features/breeds/presentation/pages/breeds_page.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final networkInfo = NetworkInfoImpl(Connectivity());
  final repository = BreedsRepositoryImpl(
    BreedsRemoteDataSourceImpl(DioClient.create()),
    BreedsLocalDataSourceImpl(SharedPreferencesAsync()),
    networkInfo,
  );

  runApp(MyApp(repository: repository, networkInfo: networkInfo));
}

class MyApp extends StatelessWidget {
  const MyApp({
    required this.repository,
    required this.networkInfo,
    super.key,
  });

  static const _terracotta = Color(0xFF9A4F2C);

  final BreedsRepository repository;
  final NetworkInfo networkInfo;

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _terracotta,
      brightness: Brightness.light,
    );

    return MaterialApp(
      title: 'Directorio de razas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: colorScheme,
        scaffoldBackgroundColor: const Color(0xFFFFF8F4),
        useMaterial3: true,
        snackBarTheme: const SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
        ),
      ),
      home: BlocProvider(
        create: (_) => BreedsBloc(repository)..add(const BreedsStarted()),
        child: BreedsPage(networkInfo: networkInfo),
      ),
    );
  }
}
