import 'package:wayn/features/ride/domain/entities/ride_request.dart';
import 'package:wayn/features/ride/domain/repositories/ride_repository.dart';

class CreateRideRequest {
  final IRideRepository repository;

  CreateRideRequest(this.repository);

  Future<void> call(RideRequest ride) async {
    return await repository.createRideRequest(ride);
  }
}
