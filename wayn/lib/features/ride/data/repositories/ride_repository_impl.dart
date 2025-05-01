import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geotypes/src/geojson.dart';
import 'package:wayn/features/ride/data/models/ride_request_model.dart';
import 'package:wayn/features/ride/domain/entities/ride_request.dart';
import 'package:wayn/features/ride/domain/entities/ride_status.dart';
import 'package:wayn/features/ride/domain/repositories/ride_repository.dart';

class RideRepositoryImpl implements IRideRepository {
  final FirebaseFirestore _firestore;

  RideRepositoryImpl(this._firestore);

  @override
  Future<void> createRideRequest(RideRequest ride) async {
    log('📝 Création d\'une nouvelle course avec ID: ${ride.id}');
    final rideModel = RideRequestModel(
      id: ride.id,
      pickupAddress: ride.pickupAddress,
      destinationAddress: ride.destinationAddress,
      grossPrice: ride.grossPrice,
      timeToPickup: ride.timeToPickup,
      totalRideTime: ride.totalRideTime,
      distance: ride.distance,
      status: ride.status,
      createdAt: ride.createdAt,
      origin: ride.origin,
      destination: ride.destination,
      user: ride.user,
    );

    // On utilise toString() pour convertir le RideIdGenerator en string pour Firestore
    await _firestore.collection('rides').doc(ride.id.toString()).set(
          rideModel.toJson(),
        );
  }

  @override
  Future<void> updateRideStatus(String rideId, RideStatus newStatus) async {
    log('🔄 Mise à jour du statut pour la course: $rideId vers: ${newStatus.name}');
    // On gère le rideId comme une string car c'est comme ça qu'il est stocké dans Firestore
    await _firestore
        .collection('rides')
        .doc(rideId)
        .update({'status': newStatus.name});
  }

  @override
  Stream<RideRequest> watchRideStatus(String rideId) {
    log('⏳ Démarrage du watchRideStatus pour rideId: $rideId');

    return _firestore
        .collection('rides')
        .doc(rideId)
        .snapshots()
        .where((snapshot) => snapshot.exists && snapshot.data() != null)
        .map((snapshot) {
      log('📥 Snapshot reçu - exists: ${snapshot.exists}');

      final data = snapshot.data()!;
      log('📦 Données reçues: $data');

      try {
        final model = RideRequestModel.fromJson(data);
        log('✅ Conversion en RideRequestModel réussie');
        final rideRequest = model.toDomain();
        log('🚗 Status actuel: ${rideRequest.status}');
        return rideRequest;
      } catch (e) {
        log('⚠️ Erreur lors de la conversion: $e');
        rethrow;
      }
    });
  }

  @override
  Stream<Position> watchDriverPosition(String driverId,
      {bool isTestMode = false}) {
    return _firestore
        .collection('users')
        .doc(driverId)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists || !snapshot.data()!.containsKey('position')) {
        throw Exception('Position non disponible');
      }

      final GeoPoint geoPoint = snapshot.data()!['position'] as GeoPoint;
      log('Position reçue de Firestore - Latitude: ${geoPoint.latitude}, Longitude: ${geoPoint.longitude}');

      Position position;
      if (isTestMode) {
        position =
            Position(geoPoint.longitude + 0.001, geoPoint.latitude + 0.001);
        log('Mode test : Position simulée: $position');
      } else {
        position = Position(geoPoint.longitude, geoPoint.latitude);
        log('Mode production : Position réelle: $position');
      }

      return position;
    }).handleError((error) {
      log('Erreur dans watchDriverPosition: $error');
      throw error;
    }).where((position) => position != null);
  }

  @override
  Future<void> cancelRide(RideRequest ride) {
    try {
      log('🚫 Annulation de la course: ${ride.id}');
      return _firestore
          .collection('users')
          .doc(ride.user.id)
          .collection('cancelRide')
          .doc(ride.id.toString())
          .update({'status': 'cancelled'});
    } catch (e) {
      log('Erreur lors de l\'annulation de la course: $e');
      rethrow;
    }
  }
}
