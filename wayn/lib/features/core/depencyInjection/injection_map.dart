import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:wayn/features/map/directions/domain/usecases/stream_route_coordinate_usescase.dart';
import 'package:wayn/features/map/presentation/bloc/map_bloc.dart';
import 'package:wayn/features/map/data/datasources/location_data_source.dart';
import 'package:wayn/features/map/data/repositories/map_repository_impl.dart';
import 'package:wayn/features/map/directions/data/datasources/directions_remote_data_sources.dart';
import 'package:wayn/features/map/directions/data/repositories/direction_repository_impl.dart';
import 'package:wayn/features/map/directions/domain/repositories/direction_repository.dart';
import 'package:wayn/features/map/directions/domain/usecases/get_route_coordinate_usecase.dart';
import 'package:wayn/features/map/domain/repositories/map_repository.dart';

final mapInjection = GetIt.I;

Future<void> initMapDependencies() async {
  // External
  mapInjection.registerLazySingleton(() => Dio());

  // Data sources
  mapInjection.registerLazySingleton<LocationDataSource>(
    () => LocationDataSourceImpl(),
  );

  mapInjection.registerLazySingleton<DirectionsRemoteDataSource>(
    () => DirectionsRemoteDataSourceImpl(
      dio: mapInjection(),
    ),
  );

  // Repositories
  mapInjection.registerLazySingleton<MapRepository>(
    () => MapRepositoryImpl(
      locationDataSource: mapInjection(),
      firestore: FirebaseFirestore.instance,
    ),
  );

  mapInjection.registerLazySingleton<DirectionsRepository>(
    () => DirectionsRepositoryImpl(
      remoteDataSource: mapInjection(),
    ),
  );

  // Use cases
  mapInjection.registerLazySingleton(
    () => GetRouteCoordinatesUseCase(
      mapInjection(),
    ),
  );
  mapInjection.registerLazySingleton(
    () => StreamRouteCoordinateUsescase(
      mapInjection(),
    ),
  );

  // Bloc
  mapInjection.registerFactory(
    () => MapBloc(
      mapRepository: mapInjection(),
      getRouteCoordinatesUseCase: mapInjection(),
      streamRouteCoordinateUsescase: mapInjection(),
    ),
  );
}
