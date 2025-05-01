import 'package:wayn/features/search/domain/entities/address_to_lat_lng.dart';
import 'package:wayn/features/search/domain/repositories/search_repository.dart';

class GetCoordinatesUseCase {
  final SearchRepository _repository;

  GetCoordinatesUseCase(this._repository);

  Future<AddressToLatLng> call(String address) async {
    try {
      return await _repository.getCoordinates(address);
    } catch (e) {
      throw Exception('Erreur dans GetCoordinatesUseCase: $e');
    }
  }
}
