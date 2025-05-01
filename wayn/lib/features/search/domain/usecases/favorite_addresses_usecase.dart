import 'package:wayn/features/search/domain/entities/address.dart';
import 'package:wayn/features/search/domain/repositories/search_repository.dart';

class FavoriteAddressesUsecase {
  final SearchRepository _repository;

  FavoriteAddressesUsecase(this._repository);

  Future<List<Address>> call() {
    return _repository.getFavoriteAddresses();
  }
}
