import 'package:wayn/features/search/domain/entities/address.dart';
import 'package:wayn/features/search/domain/repositories/search_repository.dart';

class SearchAddressesUsecase {
  final SearchRepository _repository;

  SearchAddressesUsecase(this._repository);

  Future<List<Address>> call(
    String query,
    double userlat,
    double userlng,
  ) {
    return _repository.searchAddresses(
      query,
      userlat,
      userlng,
    );
  }
}
