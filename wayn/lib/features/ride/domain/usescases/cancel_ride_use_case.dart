import 'package:wayn/features/ride/domain/entities/ride_request.dart';
import 'package:wayn/features/ride/domain/repositories/ride_repository.dart';

class CancelRideUseCase {
  final IRideRepository _rideRepository;

  CancelRideUseCase(this._rideRepository);

  Future<void> call(RideRequest ride) async {
    return _rideRepository.cancelRide(ride);
  }
}
