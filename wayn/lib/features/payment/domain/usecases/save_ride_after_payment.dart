import 'dart:developer';

import 'package:wayn/features/payment/domain/repositories/payment_repository.dart';
import 'package:wayn/features/ride/domain/entities/ride_request.dart';

class SaveRideAfterPayment {
  final PaymentRepository repository;

  SaveRideAfterPayment(this.repository);

  Future<void> call(RideRequest ride) async {
    log('🔄 UseCase: saving ride...');
    await repository.createRideAfterPayment(rideRequest: ride);
  }
}
