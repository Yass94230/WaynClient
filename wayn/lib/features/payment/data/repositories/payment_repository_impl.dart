// lib/features/payment/data/repositories/payment_repository_impl.dart
import 'dart:developer';

import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:wayn/features/payment/data/datasources/payment_remote_data_source.dart';
import 'package:wayn/features/payment/domain/repositories/payment_repository.dart';
import 'package:wayn/features/ride/domain/entities/ride_request.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final PaymentRemoteDataSource remoteDataSource;

  PaymentRepositoryImpl(this.remoteDataSource);

  @override
  Future<PaymentIntent> createPaymentIntent(
    double amount,
    String currency,
    String paymentMethodId,
  ) {
    return remoteDataSource.createPaymentIntent(
      amount,
      currency,
      paymentMethodId,
    );
  }

  @override
  Future<void> confirmPayment(String clientSecret) {
    return remoteDataSource.confirmPayment(clientSecret);
  }

  //Methode pour sauvegarder la carte
  @override
  Future<String> createPaymentMethod(String name, String country) {
    return remoteDataSource.createPaymentMethod(name, country);
  }

  @override
  Future<void> attachPaymentMethod(String paymentMethodId) {
    return remoteDataSource.attachPaymentMethod(paymentMethodId);
  }

  @override
  Future<void> confirmSetup({
    required String clientSecret,
    required String name,
    required String country,
    required CardFieldInputDetails cardDetails,
  }) {
    return remoteDataSource.confirmSetup(
      clientSecret: clientSecret,
      name: name,
      country: country,
      cardDetails: cardDetails,
    );
  }

  @override
  Future<String> createSetupIntent() {
    return remoteDataSource.createSetupIntent();
  }

  @override
  Future<List<PaymentMethod>> listSavedCards() {
    return remoteDataSource.listSavedCards();
  }

  @override
  Future<void> createRideAfterPayment({required RideRequest rideRequest}) {
    log('💾 Repository: creating ride...');
    return remoteDataSource.createRideAfterPayment(rideRequest: rideRequest);
  }
}
