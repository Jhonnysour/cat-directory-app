import 'dart:async';

import 'package:cat_directory_app/core/network/dio_client.dart';
import 'package:cat_directory_app/core/network/network_info.dart';
import 'package:cat_directory_app/core/router/app_router.dart';
import 'package:cat_directory_app/core/theme/app_theme.dart';
import 'package:cat_directory_app/core/theme/theme_controller.dart';
import 'package:cat_directory_app/features/breeds/data/datasources/breeds_local_datasource.dart';
import 'package:cat_directory_app/features/breeds/data/datasources/breeds_remote_datasource.dart';
import 'package:cat_directory_app/features/breeds/data/repositories/breeds_repository_impl.dart';
import 'package:cat_directory_app/features/breeds/domain/repositories/breeds_repository.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final preferences = SharedPreferencesAsync();
  final themeController = ThemeController(preferences);
  await themeController.load();

  final networkInfo = NetworkInfoImpl(Connectivity());
  final repository = BreedsRepositoryImpl(
    BreedsRemoteDataSourceImpl(DioClient.create()),
    BreedsLocalDataSourceImpl(preferences),
    networkInfo,
  );

  runAppWithSplash(
    MyApp(
      repository: repository,
      networkInfo: networkInfo,
      themeController: themeController,
    ),
  );
}

/// Keeps the native splash for 500 ms after building the first app frame.
/// Data loading continues underneath; no extra Flutter splash route is added.
void runAppWithSplash(Widget app) {
  final binding = WidgetsFlutterBinding.ensureInitialized();
  binding.deferFirstFrame();
  runApp(app);
  binding.addPostFrameCallback((_) {
    Timer(const Duration(milliseconds: 500), binding.allowFirstFrame);
  });
}

class MyApp extends StatefulWidget {
  const MyApp({
    required this.repository,
    required this.networkInfo,
    this.initialLocation,
    this.themeController,
    super.key,
  });

  final BreedsRepository repository;
  final NetworkInfo networkInfo;
  final String? initialLocation;
  final ThemeController? themeController;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final GoRouter _router;
  late final ThemeController _themeController;
  late final bool _ownsThemeController;

  @override
  void initState() {
    super.initState();
    _ownsThemeController = widget.themeController == null;
    _themeController = widget.themeController ?? ThemeController.transient();
    _router = createAppRouter(
      repository: widget.repository,
      networkInfo: widget.networkInfo,
      themeController: _themeController,
      initialLocation: widget.initialLocation,
    );
  }

  @override
  void dispose() {
    _router.dispose();
    if (_ownsThemeController) {
      _themeController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _themeController,
      builder: (context, child) => MaterialApp.router(
        title: 'Cat-tionary',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: _themeController.mode,
        routerConfig: _router,
      ),
    );
  }
}
