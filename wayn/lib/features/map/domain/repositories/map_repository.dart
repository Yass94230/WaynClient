import 'package:wayn/features/map/data/models/vehicule_prices.dart';
import 'package:wayn/features/map/domain/entities/driver.dart';
import 'package:wayn/features/map/domain/entities/user_location.dart';

abstract class MapRepository {
  Future<UserLocation> getCurrentLocation();
  Stream<UserLocation> getLocationStream();
  Future<bool> checkLocationPermission();
  Future<bool> requestLocationPermission();
  //Recupere la position des chauffeurs à proximité ponctuellement (snapshot)
  Future<List<Driver>> getNearbyDriversSnapshot({
    required double latitude,
    required double longitude,
    required double radius, // en kilomètres
    
  });
  //Recupere la position des chauffeurs à proximité en temps réel (stream)
  Stream<List<Driver>> getNearbyDriversStream({
    required double latitude,
    required double longitude,
    required double radius,
    required String userGender,
    required bool isOptionEnabled,
    
  });
  Future<VehiclePrices> getVehiclePrices(String cityName, String vehicleType);
}
