import 'package:wayn/features/search/domain/entities/address.dart';
import 'package:wayn/features/search/domain/entities/address_to_lat_lng.dart';

abstract class SearchRepository {
  Future<List<Address>> getFavoriteAddresses();
  // implementer cette methode ds la classe GeocodingDataSource
  // Pour verifier si l'endroit ou se trouve l'user est en ile de france,
  // Si oui on utilise son adresse comme point de départ, sinon on lui signal que
  //L'application n'est pas disponible dans sa région pour le moment
  //A faire à la fin de la creation de l'application  => getInitialUserAddress
  // Future<Address> getInitialUserAddress();
  Future<List<Address>> searchAddresses(
      String query, double userlat, double userlng);
  Future<AddressToLatLng> getCoordinates(String address);
}
