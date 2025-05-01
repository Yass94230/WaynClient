import 'package:get_it/get_it.dart';
import 'package:wayn/features/search/data/datasources/geocoding_data_source.dart';
import 'package:wayn/features/search/data/repositories/search_repository_impl.dart';
import 'package:wayn/features/search/domain/repositories/search_repository.dart';
import 'package:wayn/features/search/domain/usecases/favorite_addresses_usecase.dart';
import 'package:wayn/features/search/domain/usecases/get_coordinates_usescase.dart';
import 'package:wayn/features/search/domain/usecases/search_addresses_usecase.dart';
import 'package:wayn/features/search/presentation/blocs/search_bloc.dart';

final searchInjection = GetIt.I;

Future<void> initSearchDependencies() async {
  // Http Client
  // searchInjection.registerLazySingleton(() => Dio());

  // Data Sources

  searchInjection.registerLazySingleton<GeocodingDataSource>(
    () => GeocodingDataSource(searchInjection()),
  );

  // Repositories
  searchInjection.registerLazySingleton<SearchRepository>(
    () => SearchRepositoryImpl(
      searchInjection(), // FirebaseFirestore
      searchInjection(), // GeocodingDataSource
    ),
  );

  // Use Cases
  searchInjection.registerLazySingleton<FavoriteAddressesUsecase>(
    () => FavoriteAddressesUsecase(searchInjection()),
  );

  searchInjection.registerLazySingleton<SearchAddressesUsecase>(
    () => SearchAddressesUsecase(searchInjection()),
  );

  searchInjection.registerLazySingleton<GetCoordinatesUseCase>(
    () => GetCoordinatesUseCase(searchInjection()),
  );

  // Bloc
  searchInjection.registerFactory<SearchBloc>(
    () => SearchBloc(
      getFavoriteAddressesUseCase: searchInjection(),
      searchAddressesUseCase: searchInjection(),
      getCoordinatesUseCase: searchInjection(),
    ),
  );
}
