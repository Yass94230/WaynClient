import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:wayn/features/authentification/domain/entities/user.dart';
import 'package:wayn/features/map/directions/domain/entities/route_coordinate.dart';
import 'package:wayn/features/map/domain/entities/driver.dart';
import 'package:wayn/features/payment/domain/usecases/confirm_payment.dart';
import 'package:wayn/features/payment/domain/usecases/create_payment_intent.dart';
import 'package:wayn/features/payment/domain/usecases/get_saved_card.dart';
import 'package:wayn/features/payment/domain/usecases/save_card.dart';
import 'package:wayn/features/payment/domain/usecases/save_ride_after_payment.dart';
import 'package:wayn/features/ride/domain/entities/ride_id_generator.dart';
import 'package:wayn/features/ride/domain/entities/ride_request.dart';
import 'package:wayn/features/ride/domain/entities/ride_status.dart';

abstract class PaymentEvent {}

class CreatePaymentIntentEvent extends PaymentEvent {
  final double amount;
  final String currency;
  final String? paymentMethodId;

  CreatePaymentIntentEvent({
    required this.amount,
    required this.currency,
    required this.paymentMethodId, // Changez en required
  });
}

class ConfirmPaymentEvent extends PaymentEvent {
  final String clientSecret;
  final PaymentIntentsStatus?
      status; // Changé de String? à PaymentIntentsStatus?
  final String vehicleType;
  final double price;
  final RouteCoordinates route;
  final String originAddress;
  final String destinationAddress;
  final Position origin;
  final Position destination;
  final User user;

  final List<Driver> nearbyDrivers;

  ConfirmPaymentEvent(
      {required this.clientSecret,
      this.status,
      required this.vehicleType,
      required this.price,
      required this.route,
      required this.originAddress,
      required this.destinationAddress,
      required this.nearbyDrivers,
      required this.origin,
      required this.destination,
      required this.user});
}

class SaveCardEvent extends PaymentEvent {
  final String name;
  final String country;
  final CardFieldInputDetails cardDetails;
  // Ajoutez ce champ

  SaveCardEvent({
    required this.name,
    required this.country,
    required this.cardDetails,
    // Optionnel pour compatibilité
  });
}

class LoadSavedCardsEvent extends PaymentEvent {}

// lib/features/payment/presentation/bloc/payment_state.dart
abstract class PaymentState {}

class PaymentInitial extends PaymentState {}

class PaymentLoading extends PaymentState {}

class PaymentInitialized extends PaymentState {
  final String clientSecret;
  final PaymentIntentsStatus?
      status; // Changé de String? à PaymentIntentsStatus?
  PaymentInitialized(this.clientSecret, {this.status});
}

class CardSaved extends PaymentState {}

class SavedCardsLoaded extends PaymentState {
  final List<PaymentMethod> cards;
  SavedCardsLoaded(this.cards);
}

class PaymentSuccess extends PaymentState {
  final RideRequest rideRequest;
  PaymentSuccess({required this.rideRequest});
}

class PaymentError extends PaymentState {
  final String message;
  PaymentError(this.message);
}

// lib/features/payment/presentation/bloc/payment_bloc.dart
class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  final CreatePaymentIntent createPaymentIntentUseCase;
  final ConfirmPayment confirmPaymentUseCase;
  final SaveCard saveCard;
  final ListSavedCards listSavedCards;
  final SaveRideAfterPayment saveRideAfterPayment;

  PaymentBloc(
      {required this.createPaymentIntentUseCase,
      required this.confirmPaymentUseCase,
      required this.saveCard,
      required this.listSavedCards,
      required this.saveRideAfterPayment})
      : super(PaymentInitial()) {
    on<CreatePaymentIntentEvent>(_onCreatePaymentIntent);
    on<ConfirmPaymentEvent>(_onConfirmPayment);
    on<SaveCardEvent>(_onSaveCard);
    on<LoadSavedCardsEvent>(_onLoadSavedCards);
  }

  Future<void> _onCreatePaymentIntent(
    CreatePaymentIntentEvent event,
    Emitter<PaymentState> emit,
  ) async {
    log('📥 CreatePaymentIntent reçu dans le bloc');
    log('💰 Montant: ${event.amount}, Currency: ${event.currency}, PaymentMethodId: ${event.paymentMethodId}');

    emit(PaymentLoading());
    log('⏳ État PaymentLoading émis');

    try {
      final paymentIntent = await createPaymentIntentUseCase(
        event.amount,
        event.currency,
        event.paymentMethodId!,
      );
      log('✅ PaymentIntent créé avec statut: ${paymentIntent.status}');

      emit(PaymentInitialized(paymentIntent.clientSecret,
          status: paymentIntent.status));
      log('📤 État PaymentInitialized émis');
    } catch (e) {
      log('❌ Erreur dans _onCreatePaymentIntent: ${e.toString()}');
      emit(PaymentError(e.toString()));
    }
  }

  Future<void> _onConfirmPayment(
    ConfirmPaymentEvent event,
    Emitter<PaymentState> emit,
  ) async {
    log('📥 ConfirmPaymentEvent reçu avec status: ${event.status}');

    emit(PaymentLoading());
    try {
      // Même si le paiement est déjà Succeeded, on veut quand même créer la course
      if (event.status == PaymentIntentsStatus.Succeeded) {
        log('💳 Paiement déjà confirmé, création de la course...');
      } else {
        log('💳 Confirmation du paiement...');
        await confirmPaymentUseCase(event.clientSecret);
      }

      log('🚗 Création de la RideRequest...');
      final rideRequest = RideRequest(
        id: RideIdGenerator.generate(),
        pickupAddress: event.originAddress,
        destinationAddress: event.destinationAddress,
        grossPrice: event.price,
        netPrice: event.price * 0.75,
        totalRideTime: Duration(minutes: (event.route.duration / 60).round()),
        timeToPickup: Duration(minutes: (event.route.duration / 60).round()),
        distance: event.route.distance,
        createdAt: DateTime.now(),
        status: RideStatus.created,
        origin: event.origin,
        destination: event.destination,
        user: event.user,
      );

      log('💾 Sauvegarde de la course...');
      await saveRideAfterPayment(rideRequest);

      // log('✅ Course créée avec succès');
      emit(PaymentSuccess(rideRequest: rideRequest));
    } catch (e) {
      log('❌ Erreur dans _onConfirmPayment: ${e.toString()}');
      emit(PaymentError(e.toString()));
    }
  }

  Future<void> _onSaveCard(
    SaveCardEvent event,
    Emitter<PaymentState> emit,
  ) async {
    log('🚀 _onSaveCard started');
    log('Name: ${event.name}');
    log('Country: ${event.country}');

    try {
      emit(PaymentLoading());
      log('📍 État émis: PaymentLoading');

      await saveCard(
        name: event.name,
        country: event.country,
        cardDetails: event.cardDetails,
        // Passez le controller
      );
      log('✅ SaveCard use case completed');

      emit(CardSaved());
      log('📍 État émis: CardSaved');
    } catch (e) {
      log('❌ Error in _onSaveCard: $e');
      emit(PaymentError(e.toString()));
      log('📍 État émis: PaymentError');
    }
  }

  Future<void> _onLoadSavedCards(
    LoadSavedCardsEvent event,
    Emitter<PaymentState> emit,
  ) async {
    try {
      emit(PaymentLoading());
      final cards = await listSavedCards();
      emit(SavedCardsLoaded(cards));
    } catch (e) {
      emit(PaymentError(e.toString()));
    }
  }
}
