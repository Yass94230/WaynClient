import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:wayn/features/ride/domain/entities/ride_request.dart';

abstract class PaymentRepository {
  Future<PaymentIntent> createPaymentIntent(
    double amount,
    String currency,
    String paymentMethodId,
  );
  Future<void> attachPaymentMethod(String paymentMethodId);
  Future<void> confirmPayment(String clientSecret);
  Future<String> createPaymentMethod(String name, String country);
  Future<String>
      createSetupIntent(); // Nouvelle méthode pour créer un SetupIntent
  Future<void> confirmSetup({
    required String clientSecret,
    required String name,
    required String country,
    required CardFieldInputDetails cardDetails,
  });
  Future<List<PaymentMethod>> listSavedCards();

  Future<void> createRideAfterPayment({
    required RideRequest rideRequest,
  });
}
