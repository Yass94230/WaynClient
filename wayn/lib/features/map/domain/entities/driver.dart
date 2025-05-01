import 'package:wayn/features/map/domain/entities/vehicle_entity.dart';

class Driver {
  final String driverId;
  final String driverName;
  final String driverPhoneNumber;
  final String driverPhotoUrl;
  final VehicleEntity driverVehicle;
  final double latitude;
  final double longitude;
  final bool isAvailable;
  final String fcmToken;
  final int? estimatedTimeOfArrival; // en minutes

  Driver({
    required this.driverId,
    required this.driverName,
    required this.driverPhoneNumber,
    required this.driverPhotoUrl,
    required this.driverVehicle,
    required this.latitude,
    required this.longitude,
    required this.isAvailable,
    required this.fcmToken,
    this.estimatedTimeOfArrival,
  });

  Driver copyWith({
    String? driverId,
    String? driverName,
    String? driverPhoneNumber,
    String? driverPhotoUrl,
    String? driverVehiclePhotoUrl,
    VehicleEntity? driverVehicle,
    double? latitude,
    double? longitude,
    bool? isAvailable,
    String? fcmToken,
    int? estimatedTimeOfArrival,
  }) {
    return Driver(
      driverId: driverId ?? this.driverId,
      driverName: driverName ?? this.driverName,
      driverPhoneNumber: driverPhoneNumber ?? this.driverPhoneNumber,
      driverPhotoUrl: driverPhotoUrl ?? this.driverPhotoUrl,
      driverVehicle: driverVehicle ?? this.driverVehicle,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isAvailable: isAvailable ?? this.isAvailable,
      fcmToken: fcmToken ?? this.fcmToken,
      estimatedTimeOfArrival:
          estimatedTimeOfArrival ?? this.estimatedTimeOfArrival,
    );
  }

  // Ajout d'une méthode pour obtenir la description du véhicule
  // String get vehicleDescription {
  //   return '$driverVehicleBrand $driverVehicleModel - $driverVehicleColor ($driverVehiclePlateNumber)';
  // }
}
