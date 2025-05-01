// ride_confirmation_event.dart

import 'package:equatable/equatable.dart';
import 'package:wayn/features/authentification/domain/entities/user.dart';
import 'package:wayn/features/map/domain/entities/driver.dart';
import 'package:wayn/features/ride/domain/entities/ride_request.dart';

abstract class RideConfirmationEvent extends Equatable {
  const RideConfirmationEvent();

  @override
  List<Object?> get props => [];
}

// Event initial pour démarrer la recherche des drivers
class InitiateRideConfirmation extends RideConfirmationEvent {
  final RideRequest rideRequest;
  final String vehicleType;
  final List<Driver> nearbyDrivers;
  final User user;

  const InitiateRideConfirmation({
    required this.rideRequest,
    required this.vehicleType,
    required this.nearbyDrivers,
    required this.user,
  });

  @override
  List<Object?> get props => [
        rideRequest,
        nearbyDrivers,
      ];
}

// Event pour mettre à jour la liste des drivers (déclenché par MapBloc)
class UpdateAvailableDrivers extends RideConfirmationEvent {
  final List<Driver> updatedDrivers;

  const UpdateAvailableDrivers(this.updatedDrivers);

  @override
  List<Object?> get props => [updatedDrivers];
}

// Event quand un driver accepte la course
class DriverAcceptedRide extends RideConfirmationEvent {
  final Driver acceptedDriver;
  final RideRequest rideRequest;

  const DriverAcceptedRide(this.acceptedDriver, this.rideRequest);

  @override
  List<Object?> get props => [acceptedDriver];
}

//Pour demain implementer cette event ds le bloc
// Event quand un driver arrive chez le client
// Surveillance du statut de la course à "inRide"
//Afficher la view Course en cours de figma pour le client
class ArrivedDriver extends RideConfirmationEvent {
  final RideRequest rideRequest;
  final Driver driver;

  const ArrivedDriver(this.rideRequest, this.driver);

  @override
  List<Object?> get props => [rideRequest];
}

// Event quand un driver refuse la course
class DriverRejectedRide extends RideConfirmationEvent {
  final String driverId;

  const DriverRejectedRide(this.driverId);

  @override
  List<Object?> get props => [driverId];
}

// Event quand aucun driver n'accepte dans le délai
class NoDriversAccepted extends RideConfirmationEvent {}

class NoMoreDriversAvailable extends RideConfirmationEvent {}

// Event pour annuler la recherche
class CancelRideConfirmation extends RideConfirmationEvent {
  final RideRequest rideRequest;
  final String reason;
  final String comment;

  const CancelRideConfirmation(this.rideRequest, this.reason, this.comment);

  @override
  List<Object?> get props => [rideRequest, reason, comment];
}
