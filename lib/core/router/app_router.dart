import 'package:cat_directory_app/core/network/network_info.dart';
import 'package:cat_directory_app/core/theme/theme_controller.dart';
import 'package:cat_directory_app/features/breeds/domain/entities/breed.dart';
import 'package:cat_directory_app/features/breeds/domain/repositories/breeds_repository.dart';
import 'package:cat_directory_app/features/breeds/presentation/bloc/breed_detail_bloc.dart';
import 'package:cat_directory_app/features/breeds/presentation/bloc/breeds_bloc.dart';
import 'package:cat_directory_app/features/breeds/presentation/pages/breed_detail_page.dart';
import 'package:cat_directory_app/features/breeds/presentation/pages/breeds_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

GoRouter createAppRouter({
  required BreedsRepository repository,
  required NetworkInfo networkInfo,
  required ThemeController themeController,
  String? initialLocation,
}) {
  return GoRouter(
    initialLocation: initialLocation,
    overridePlatformDefaultLocation: initialLocation != null,
    routes: [
      GoRoute(
        path: '/',
        pageBuilder: (context, state) => MaterialPage<void>(
          key: state.pageKey,
          child: BlocProvider(
            create: (_) => BreedsBloc(repository)..add(const BreedsStarted()),
            child: BreedsPage(
              networkInfo: networkInfo,
              themeController: themeController,
            ),
          ),
        ),
      ),
      GoRoute(
        name: 'breedDetail',
        path: '/breed/:name',
        pageBuilder: (context, state) {
          final name = state.pathParameters['name'] ?? '';
          final initialBreed = switch (state.extra) {
            final Breed breed => breed,
            _ => null,
          };

          return MaterialPage<void>(
            key: state.pageKey,
            child: BlocProvider(
              create: (_) => BreedDetailBloc(repository)
                ..add(
                  BreedDetailStarted(name: name, initialBreed: initialBreed),
                ),
              child: BreedDetailPage(
                breedName: name,
                initialBreed: initialBreed,
              ),
            ),
          );
        },
      ),
    ],
  );
}
