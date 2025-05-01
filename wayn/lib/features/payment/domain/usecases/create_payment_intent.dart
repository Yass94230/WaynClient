import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:wayn/features/payment/domain/entities/payment_intent_result.dart';
import 'package:wayn/features/payment/domain/repositories/payment_repository.dart';

class CreatePaymentIntent {
  final PaymentRepository repository;
  CreatePaymentIntent(this.repository);

  Future<PaymentIntent> call(
    double amount,
    String currency,
    String paymentMethodId,
  ) async {
    return await repository.createPaymentIntent(
      amount,
      currency,
      paymentMethodId,
    );
  }
}
