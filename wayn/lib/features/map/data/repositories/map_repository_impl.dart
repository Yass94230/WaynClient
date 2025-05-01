// lib/features/map/data/repositories/map_repository_impl.dart

import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wayn/features/map/data/models/vehicule_prices.dart';
import 'package:wayn/features/map/domain/entities/driver.dart';
import 'package:wayn/features/map/domain/entities/vehicle_entity.dart';
import 'package:wayn/features/utils/geo_utils.dart';

import '../../domain/entities/user_location.dart';
import '../../domain/repositories/map_repository.dart';
import '../datasources/location_data_source.dart';

class MapRepositoryImpl implements MapRepository {
  final LocationDataSource locationDataSource;
  final FirebaseFirestore firestore;

  MapRepositoryImpl(
      {required this.locationDataSource, required this.firestore});

  @override
  Future<UserLocation> getCurrentLocation() async {
    try {
      return await locationDataSource.getCurrentPosition();
    } catch (e) {
      throw Exception('Erreur lors de la récupération de la position: $e');
    }
  }

  @override
  Stream<UserLocation> getLocationStream() {
    try {
      return locationDataSource.getPositionStream();
    } catch (e) {
      throw Exception('Erreur lors du suivi de la position: $e');
    }
  }

  @override
  Future<bool> checkLocationPermission() async {
    try {
      return await locationDataSource.checkPermission();
    } catch (e) {
      throw Exception('Erreur lors de la vérification des permissions: $e');
    }
  }

  @override
  Future<bool> requestLocationPermission() async {
    try {
      return await locationDataSource.requestPermission();
    } catch (e) {
      throw Exception('Erreur lors de la demande de permissions: $e');
    }
  }

  @override
  Stream<List<Driver>> getNearbyDriversStream({
    required double latitude,
    required double longitude,
    required double radius,
    required bool isOptionEnabled,
    required String userGender,
  }) {
    try {
      final bounds = GeoUtils.calculateBoundingBox(latitude, longitude, radius);
      log('Querying drivers with bounds: $bounds');

      Query query = firestore
          .collection('users')
          .where('isDriver', isEqualTo: true)
          .where('isAvailable', isEqualTo: true)
          .where('position', isGreaterThan: bounds['southwest'])
          .where('position', isLessThan: bounds['northeast']);

      if (isOptionEnabled) {
        query = query.where('gender', isEqualTo: userGender);
      }

      return query.snapshots().asyncMap((snapshot) async {
        log('Snapshot size: ${snapshot.docs.length}');
        final List<Driver> drivers = [];

        for (var doc in snapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          final GeoPoint position = data['position'] as GeoPoint;

          final vehicleSnapshot = await firestore
              .collection('users')
              .doc(doc.id)
              .collection('vehicule')
              .get();

          if (vehicleSnapshot.docs.isNotEmpty) {
            final vehicleData = vehicleSnapshot.docs.first.data();
            final vehicle = VehicleEntity(
              vehicleType: vehicleData['type'] as String,
              vehicleModel: vehicleData['modele'] as String,
              vehicleBrand: vehicleData['marque'] as String,
              plateNumber: vehicleData['imatriculation'] as String,
            );

            final driver = await firestore
                .collection('users')
                .doc(doc.id)
                .collection('driverMode')
                .doc('profile')
                .get();

            drivers.add(Driver(
              driverId: doc.id,
              driverName: driver['firstName'] as String,
              driverPhoneNumber: data['phoneNumber'] as String,
              driverPhotoUrl: driver['photoUrl'] as String,
              driverVehicle: vehicle,
              latitude: position.latitude,
              longitude: position.longitude,
              isAvailable: data['isAvailable'] as bool,
              fcmToken: data['firebaseToken'] as String,
              estimatedTimeOfArrival: null,
            ));
            log('Driver added: ${driver['firstName']}');
            log('Driver vehicle: ${vehicleData['type']}');
            log('Driver position: ${position.latitude}, ${position.longitude}');
            log('Driver is available: ${data['isAvailable']}');
          }
        }

        log('Mapped drivers: ${drivers.length}');
        return drivers;
      });
    } catch (e) {
      log('Error in getNearbyDriversStream: $e');
      rethrow;
    }
  }

  @override
  Future<List<Driver>> getNearbyDriversSnapshot({
    required double latitude,
    required double longitude,
    required double radius,
  }) async {
    try {
      final bounds = GeoUtils.calculateBoundingBox(latitude, longitude, radius);

      Query query = firestore
          .collection('users')
          .where('isAvailable', isEqualTo: true)
          .where('position', isGreaterThan: bounds['southwest'])
          .where('position', isLessThan: bounds['northeast']);

      final QuerySnapshot snapshot = await query.get();
      List<Driver> drivers = [];

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final GeoPoint position = data['position'] as GeoPoint;

        // Calculer la distance réelle
        final distance = GeoUtils.calculateDistance(
          latitude,
          longitude,
          position.latitude,
          position.longitude,
        );

        // Ne garder que les chauffeurs dans le rayon spécifié
        if (distance <= radius) {
          // Récupérer le véhicule du chauffeur
          final vehicleSnapshot = await firestore
              .collection('users')
              .doc(doc.id)
              .collection('vehicule')
              .get();

          if (vehicleSnapshot.docs.isNotEmpty) {
            final vehicleData = vehicleSnapshot.docs.first.data();

            final vehicle = VehicleEntity(
              vehicleType: vehicleData['type'] as String,
              vehicleModel: vehicleData['modele'] as String,
              vehicleBrand: vehicleData['marque'] as String,
              plateNumber: vehicleData['imatriculation'] as String,
            );

            drivers.add(Driver(
              driverId: doc.id,
              driverName: data['firstName'] as String,
              driverPhoneNumber: data['phoneNumber'] as String,
              driverPhotoUrl: data['photoUrl'] as String,
              driverVehicle: vehicle,
              latitude: position.latitude,
              longitude: position.longitude,
              isAvailable: data['isAvailable'] as bool,
              fcmToken: data['firebaseToken'] as String,
              estimatedTimeOfArrival: null,
            ));
          }
        }
      }

      return drivers;
    } catch (e) {
      log('Erreur lors de la récupération des chauffeurs: $e');
      rethrow;
    }
  }

  @override
  Future<VehiclePrices> getVehiclePrices(
      String cityName, String vehicleType) async {
    try {
      final docSnapshot =
          await firestore.collection('city').doc(cityName).get();

      if (!docSnapshot.exists) {
        throw Exception('Prix non trouvés pour la ville: $cityName');
      }

      final data = docSnapshot.data()!;
      if (!data.containsKey(vehicleType)) {
        throw Exception('Type de véhicule non trouvé: $vehicleType');
      }

      final vehicleData = data[vehicleType] as Map<String, dynamic>;

      return VehiclePrices.fromFirestore(
        vehicleData,
        vehicleType,
      );
    } catch (e) {
      log('Erreur lors de la récupération des prix pour $cityName / $vehicleType: $e');
      rethrow;
    }
  }
}
