import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:wayn/features/payment/domain/repositories/payment_repository.dart';

class ListSavedCards {
  final PaymentRepository repository;

  ListSavedCards(this.repository);

  Future<List<PaymentMethod>> call() async {
    return await repository.listSavedCards();
  }
}
