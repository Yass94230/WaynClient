import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:wayn/features/authentification/data/models/user_model.dart';
import 'package:wayn/features/ride/domain/entities/ride_request.dart';

abstract class PaymentRemoteDataSource {
  Future<PaymentIntent> createPaymentIntent(
      double amount, String currency, String payementMethodId);
  Future<void> confirmPayment(String clientSecret);
  Future<String> createPaymentMethod(String name, String country);
  Future<void> attachPaymentMethod(String paymentMethodId);
  Future<String> createSetupIntent();
  Future<void> confirmSetup({
    required String clientSecret,
    required String name,
    required String country,
    required CardFieldInputDetails cardDetails,
  });
  Future<List<PaymentMethod>> listSavedCards();
  Future<void> createRideAfterPayment({RideRequest rideRequest});
}

class PaymentRemoteDataSourceImpl implements PaymentRemoteDataSource {
  final Dio dio;
  final String baseUrl;
  final FirebaseFirestore firestore;

  PaymentRemoteDataSourceImpl({
    required this.dio,
    this.baseUrl = 'https://us-central1-wayn-vtc.cloudfunctions.net',
    required this.firestore,
  });

  @override
  Future<PaymentIntent> createPaymentIntent(
    double amount,
    String currency,
    String paymentMethodId,
  ) async {
    try {
      log('📍 Début createPaymentIntent');
      log('Montant: $amount');
      log('Devise: $currency');
      log('PaymentMethod ID: $paymentMethodId');

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Utilisateur non connecté');

      final token = await user.getIdToken(true);
      log('🔐 Token obtenu');

      final response = await dio.post(
        '$baseUrl/createPaymentIntent',
        data: {
          'amount': (amount * 100).round(),
          'currency': currency.toLowerCase(),
          'paymentMethodId': paymentMethodId,
        },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      log('📍 Réponse reçue: ${response.statusCode}');
      log('📍 Données: ${response.data}');

      if (response.statusCode == 200) {
        log('✅ ClientSecret obtenu');

        return await Stripe.instance
            .retrievePaymentIntent(response.data['clientSecret']);
      } else {
        final errorMessage = response.data['error'] ?? 'Erreur inconnue';
        log('❌ Erreur serveur: $errorMessage');
        throw Exception(errorMessage);
      }
    } catch (e) {
      log('❌ Erreur détaillée: $e');
      if (e is DioException) {
        log('Type d\'erreur: ${e.type}');
        log('Message: ${e.message}');
        if (e.response?.data != null) {
          log('Réponse: ${e.response?.data}');
        }
      }
      rethrow;
    }
  }

  @override
  Future<void> confirmPayment(String clientSecret) async {
    try {
      await Stripe.instance.confirmPayment(
        paymentIntentClientSecret: clientSecret,
        data: const PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(),
        ),
      );
    } on StripeException catch (e) {
      throw Exception('Erreur Stripe: ${e.error.localizedMessage}');
    } catch (e) {
      throw Exception('Erreur lors de la confirmation du paiement: $e');
    }
  }

  @override
  Future<String> createPaymentMethod(String name, String country) async {
    try {
      final paymentMethod = await Stripe.instance.createPaymentMethod(
        params: PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(
            billingDetails: BillingDetails(
              name: name,
            ),
          ),
        ),
      );
      return paymentMethod.id;
    } on StripeException catch (e) {
      throw Exception('Erreur Stripe: ${e.error.localizedMessage}');
    } catch (e) {
      throw Exception('Erreur lors de la création du PaymentMethod: $e');
    }
  }

  @override
  Future<void> attachPaymentMethod(String paymentMethodId) async {
    try {
      final response = await dio.post(
        'https://us-central1-wayn-vtc.cloudfunctions.net/attachPaymentMethod',
        data: {
          'paymentMethodId': paymentMethodId,
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Erreur lors de l\'attachement du PaymentMethod');
      }
    } catch (e) {
      if (e is DioException) {
        throw Exception('Erreur réseau: ${e.message}');
      }
      throw Exception('Erreur lors de l\'attachement du PaymentMethod: $e');
    }
  }

  @override
  Future<String> createSetupIntent() async {
    try {
      log('📍 Making API call to create SetupIntent...');

      // Obtenir le token d'authentification
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Utilisateur non connecté');

      final token = await user.getIdToken();

      const url =
          'https://us-central1-wayn-vtc.cloudfunctions.net/createSetupIntent';
      log('URL: $url');

      final response = await dio.post(
        url,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),
      );

      log('📍 API Response: ${response.data}');

      if (response.statusCode == 200 && response.data['clientSecret'] != null) {
        log('✅ SetupIntent created successfully');
        return response.data['clientSecret'];
      } else {
        log('❌ Error response: ${response.statusCode}');
        throw Exception('Erreur lors de la création du SetupIntent');
      }
    } catch (e) {
      log('❌ Exception in createSetupIntent: $e');
      throw Exception('Erreur lors de la création du SetupIntent: $e');
    }
  }

  @override
  Future<void> confirmSetup({
    required String clientSecret,
    required String name,
    required String country,
    required CardFieldInputDetails cardDetails,
  }) async {
    try {
      log('📍 Confirming setup with Stripe SDK...');
      log('ClientSecret length: ${clientSecret.length}');

      // Ne pas utiliser cardDetails directement, mais plutôt passer directement
      // à la méthode de paiement par carte
      await Stripe.instance.confirmSetupIntent(
        paymentIntentClientSecret: clientSecret,
        params: const PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(),
        ),
      );

      log('✅ Setup confirmed successfully with Stripe');
    } catch (e) {
      log('❌ Exception in confirmSetup: $e');
      throw Exception('Erreur lors de la confirmation du setup: $e');
    }
  }

  // @override
  // Future<void> confirmSetup({
  //   required String clientSecret,
  //   required String name,
  //   required String country,
  //   required CardFieldInputDetails cardDetails,
  // }) async {
  //   try {
  //     log('📍 Confirming setup with Stripe SDK...');
  //     log('ClientSecret length: ${clientSecret.length}');

  //     await Stripe.instance.confirmSetupIntent(
  //       paymentIntentClientSecret: clientSecret,
  //       params: PaymentMethodParams.card(
  //         paymentMethodData: PaymentMethodData(
  //           billingDetails: BillingDetails(
  //             name: name,
  //           ),
  //         ),
  //       ),
  //     );
  //     log('✅ Setup confirmed successfully with Stripe');
  //   } catch (e) {
  //     log('❌ Exception in confirmSetup: $e');
  //     throw Exception('Erreur lors de la confirmation du setup: $e');
  //   }
  // }

  @override
  Future<List<PaymentMethod>> listSavedCards() async {
    try {
      log('📍 Getting saved cards...');

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Utilisateur non connecté');

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final customerId = userDoc.data()?['stripeCustomerId'];
      if (customerId == null) throw Exception('Customer ID non trouvé');

      const url =
          'https://us-central1-wayn-vtc.cloudfunctions.net/listPaymentMethods';

      final response = await dio.get(
        url,
        options: Options(
          headers: {
            'Authorization': 'Bearer ${await user.getIdToken()}',
            'Content-Type': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final List<dynamic> paymentMethodsJson =
            response.data['paymentMethods'];
        log('Received payment methods: $paymentMethodsJson');

        return paymentMethodsJson.map((json) {
          return PaymentMethod(
            id: json['id'],
            livemode: json['livemode'] ?? false,
            paymentMethodType: json['type'] ?? '',
            billingDetails: BillingDetails(
              name: json['billing_details']['name'],
              email: json['billing_details']['email'],
              phone: json['billing_details']['phone'],
              address: Address(
                city: json['billing_details']['address']['city'],
                country: json['billing_details']['address']['country'],
                line1: json['billing_details']['address']['line1'],
                line2: json['billing_details']['address']['line2'],
                postalCode: json['billing_details']['address']['postal_code'],
                state: json['billing_details']['address']['state'],
              ),
            ),
            card: Card(
              brand: json['card']['brand'],
              country: json['card']['country'],
              expMonth: json['card']['exp_month'],
              expYear: json['card']['exp_year'],
              funding: json['card']['funding'],
              last4: json['card']['last4'],
            ),
            sepaDebit: SepaDebit(
              bankCode: json['bank_code'],
              country: json['sepaDebit'],
              fingerprint: json['sepaDebit'],
              last4: json['sepaDebit'],
            ),
            bacsDebit: BacsDebit(
              fingerprint: json['bacsDebit'],
              last4: json['bacsDebit'],
              sortCode: json['bacsDebit'],
            ),
            auBecsDebit: AuBecsDebit(
              bsbNumber: json['auBecsDebit'],
              fingerprint: json['auBecsDebit'],
              last4: json['auBecsDebit'],
            ),
            sofort: Sofort(
              country: json['sofort'],
            ),
            ideal: Ideal(
              bank: json['ideal'],
              bankIdentifierCode: json['ideal'],
            ),
            fpx: Fpx(
              bank: json['fpx'],
            ),
            upi: Upi(
              vpa: json['upi'],
            ),
            usBankAccount: UsBankAccount(
              accountHolderType: json['usBankAccount'],
              bankName: json['usBankAccount'],
              fingerprint: json['usBankAccount'],
              last4: json['usBankAccount'],
              routingNumber: json['usBankAccount'],
            ),
            customerId: customerId,
          );
        }).toList();
      } else {
        throw Exception('Erreur lors de la récupération des cartes');
      }
    } catch (e) {
      log('❌ Exception in listSavedCards: $e');
      throw Exception('Erreur lors de la récupération des cartes: $e');
    }
  }

  @override
  Future<void> createRideAfterPayment({RideRequest? rideRequest}) async {
    log('📍 Saving ride after payment...');

    // Convertir l'utilisateur en Map
    final userData = (rideRequest!.user is UserModel)
        ? (rideRequest.user as UserModel).toMap()
        : {
            'id': rideRequest.user.id,
            'email': rideRequest.user.email,
            'phoneNumber': rideRequest.user.phoneNumber,
            'firstName': rideRequest.user.firstName,
            'lastName': rideRequest.user.lastName,
            'sexe': rideRequest.user.sexe,
            'choices': rideRequest.user.choices,
            'createdAt': rideRequest.user.createdAt,
            'preferedDepart': rideRequest.user.preferedDepart,
            'preferedArrival': rideRequest.user.preferedArrival,
            'firebaseToken': rideRequest.user.firebaseToken,
            'stripeId': rideRequest.user.stripeId,
          };

    await firestore.collection('rides').doc(rideRequest.id.toString()).set({
      'id': rideRequest.id.toString(),
      'pickupAddress': rideRequest.pickupAddress,
      'destinationAddress': rideRequest.destinationAddress,
      'grossPrice': rideRequest.grossPrice,
      'netPrice': rideRequest.netPrice,
      'totalRideTime': rideRequest.totalRideTime.inMinutes,
      'timeToPickup': rideRequest.timeToPickup.inMinutes,
      'distance': rideRequest.distance,
      'createdAt': rideRequest.createdAt,
      'status': rideRequest.status.name,
      'origin': GeoPoint(
          rideRequest.origin.lat as double, rideRequest.origin.lng as double),
      'destination': GeoPoint(rideRequest.destination.lat as double,
          rideRequest.destination.lng as double),
      'user': userData, // Ajout des données utilisateur
    });
  }
}
