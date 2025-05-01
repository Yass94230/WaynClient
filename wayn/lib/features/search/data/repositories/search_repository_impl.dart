import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:mapbox_search/mapbox_search.dart';
import 'package:mapbox_search/models/location.dart';
import 'package:wayn/features/search/data/datasources/geocoding_data_source.dart';
import 'package:wayn/features/search/domain/entities/address.dart';
import 'package:wayn/features/search/domain/entities/address_to_lat_lng.dart';
import 'package:wayn/features/search/domain/repositories/search_repository.dart';

class SearchRepositoryImpl implements SearchRepository {
  final FirebaseFirestore _firestore;
  final GeocodingDataSource _geocodingDataSource;

  SearchRepositoryImpl(this._firestore, this._geocodingDataSource);

  @override
  Future<List<Address>> getFavoriteAddresses() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final snapshot = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('favorite_addresses')
          .get();

      return snapshot.docs.map((doc) {
        final data = doc.data();
        return Address(
          placeId: doc.id,
          mainText: data['title'] as String,
          secondaryText: data['subtitle'] as String,
          // Si vous n'avez pas encore les coordonnées dans Firestore,
          // ajoutez ces champs dans votre base de données
          coordinates:
              Point(coordinates: Position(data['latitude'], data['longitude'])),
        );
      }).toList();
    }
    return [];
  }

  @override
  Future<List<Address>> searchAddresses(
      String query, double userlat, double userlng) async {
    try {
      final results =
          await _geocodingDataSource.searchAddresses(query, userlat, userlng);

      return results.map((data) {
        final coordinates = data['geometry']['coordinates'] as List;
        return Address(
          placeId: data['id'] as String,
          mainText: data['text'] as String,
          secondaryText: data['place_name'] as String,
          coordinates:
              Point(coordinates: Position(coordinates[1], coordinates[0])),
        );
      }).toList();
    } catch (e) {
      throw Exception('Erreur lors de la recherche d\'adresses: $e');
    }
  }

  @override
  Future<AddressToLatLng> getCoordinates(String address) async {
    try {
      final result = await _geocodingDataSource.geocodeAddress(address);
      final coordinates = result['geometry']['coordinates'] as List;

      // Mapbox renvoie les coordonnées au format [longitude, latitude]
      return AddressToLatLng(
        latitude: coordinates[1],
        longitude: coordinates[0],
      );
    } catch (e) {
      throw Exception('Erreur lors de la récupération des coordonnées: $e');
    }
  }

  // @override
  // Future<Address> getInitialUserAddress(
  //   String query, double userlat, double userlng
  // ) async{
  //   try{
  //     final results =
  //         await _geocodingDataSource.searchAddresses(query, userlat, userlng);
  //     return results.map((data) {
  //       final coordinates = data['geometry']['coordinates'] as List;
  //       return Address(
  //         placeId: data['id'] as String,
  //         mainText: data['text'] as String,
  //         secondaryText: data['place_name'] as String,
  //         coordinates:
  //             Point(coordinates: Position(coordinates[1], coordinates[0])),
  //       );
  //     }).toList().first;

  //   }catch(e){
  //     throw Exception('Erreur lors de la récupération de l\'adresse de l\'utilisateur: $e');
  //   }
  // }
}
