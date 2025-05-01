import 'package:geolocator/geolocator.dart';
import 'package:wayn/features/map/domain/entities/user_location.dart';

class UserLocationModel extends UserLocation {
  UserLocationModel({
    required super.latitude,
    required super.longitude,
    required super.accuracy,
  });

  factory UserLocationModel.fromPosition(Position position) {
    return UserLocationModel(
      latitude: position.latitude,
      longitude: position.longitude,
      accuracy: position.accuracy,
    );
  }
}
