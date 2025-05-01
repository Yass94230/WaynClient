import 'package:wayn/features/payment/domain/repositories/payment_repository.dart';

class ConfirmPayment {
  final PaymentRepository repository;

  ConfirmPayment(this.repository);

  Future<void> call(String clientSecret) {
    return repository.confirmPayment(clientSecret);
  }
}
