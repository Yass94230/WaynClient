// lib/features/map/data/datasources/location_data_source.dart

import 'package:geolocator/geolocator.dart' as geo;
import '../../domain/entities/user_location.dart';

abstract class LocationDataSource {
  Future<UserLocation> getCurrentPosition();
  Stream<UserLocation> getPositionStream();
  Future<bool> checkPermission();
  Future<bool> requestPermission();
}

class LocationDataSourceImpl implements LocationDataSource {
  @override
  Future<UserLocation> getCurrentPosition() async {
    try {
      final position = await geo.Geolocator.getCurrentPosition(
        // ignore: deprecated_member_use
        desiredAccuracy: geo.LocationAccuracy.high,
      );

      return UserLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
      );
    } catch (e) {
      throw Exception('Impossible d\'obtenir la position actuelle: $e');
    }
  }

  @override
  Stream<UserLocation> getPositionStream() {
    return geo.Geolocator.getPositionStream(
      locationSettings: const geo.LocationSettings(
        accuracy: geo.LocationAccuracy.high,
        distanceFilter: 10, // En mètres
      ),
    ).map((position) => UserLocation(
          latitude: position.latitude,
          longitude: position.longitude,
          accuracy: position.accuracy,
        ));
  }

  @override
  Future<bool> checkPermission() async {
    try {
      final permission = await geo.Geolocator.checkPermission();
      return permission == geo.LocationPermission.always ||
          permission == geo.LocationPermission.whileInUse;
    } catch (e) {
      throw Exception('Erreur lors de la vérification des permissions: $e');
    }
  }

  @override
  Future<bool> requestPermission() async {
    try {
      // Vérifier si le service est activé
      bool serviceEnabled = await geo.Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return false;
      }

      // Vérifier la permission actuelle
      var permission = await geo.Geolocator.checkPermission();

      // Si la permission n'a pas encore été demandée ou a été refusée
      if (permission == geo.LocationPermission.denied) {
        // Demander la permission
        permission = await geo.Geolocator.requestPermission();
      }

      return permission == geo.LocationPermission.always ||
          permission == geo.LocationPermission.whileInUse;
    } catch (e) {
      return false;
    }
  }
}
