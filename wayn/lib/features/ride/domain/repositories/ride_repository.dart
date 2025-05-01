import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:wayn/features/ride/domain/entities/ride_request.dart';
import 'package:wayn/features/ride/domain/entities/ride_status.dart';

abstract class IRideRepository {
  Future<void> createRideRequest(RideRequest ride);
  Future<void> updateRideStatus(String rideId, RideStatus newStatus);
  Future<void> cancelRide(RideRequest ride);
  Stream<RideRequest> watchRideStatus(String rideId);
  Stream<Position> watchDriverPosition(String driverId);
}
