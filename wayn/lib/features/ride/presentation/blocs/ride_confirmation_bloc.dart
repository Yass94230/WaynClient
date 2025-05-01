// ride_confirmation_bloc.dart

// ignore_for_file: constant_identifier_names, unrelated_type_equality_checks

import 'dart:async';
import 'dart:developer' as l;
import 'dart:math';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:rxdart/rxdart.dart';
import 'package:wayn/features/map/domain/entities/driver.dart';
import 'package:wayn/features/map/presentation/bloc/map_bloc.dart';
import 'package:wayn/features/notification/domain/repositories/notification_repository.dart';
import 'package:wayn/features/notification/domain/usescases/notify_driver_arrival_usecase.dart';
import 'package:wayn/features/ride/domain/entities/ride_request.dart';
import 'package:wayn/features/ride/domain/entities/ride_status.dart';
import 'package:wayn/features/ride/domain/repositories/ride_repository.dart';

import 'package:wayn/features/ride/presentation/blocs/ride_confirmation_event.dart';
import 'package:wayn/features/ride/presentation/blocs/ride_confirmation_state.dart';

class RideConfirmationBloc
    extends Bloc<RideConfirmationEvent, RideConfirmationState> {
  static const int SEARCH_TIMEOUT_SECONDS = 10;
  final MapBloc mapBloc;
  final INotificationRepository notificationRepository;
  final IRideRepository rideRepository;
  final NotifyDriverArrivalUseCase notifyDriverArrival;

  static const int DRIVER_RESPONSE_TIMEOUT = 10; // 10 secondes par chauffeur

  Timer? _driverResponseTimer;
  int _currentDriverIndex = 0;

  // Subscriptions
  StreamSubscription? _driversSubscription;
  StreamSubscription? _rideStatusSubscription;
  StreamSubscription<Position>? _acceptedDriverPositionSubscription;
  StreamSubscription? _watchRideStatusSubscription;

  RideConfirmationBloc({
    required this.mapBloc,
    required this.notificationRepository,
    required this.rideRepository,
    required this.notifyDriverArrival,
  }) : super(RideConfirmationInitial()) {
    on<InitiateRideConfirmation>(_onInitiateRideConfirmation);
    on<UpdateAvailableDrivers>(_onUpdateAvailableDrivers);
    on<DriverAcceptedRide>(_onDriverAcceptedRide);
    on<ArrivedDriver>(_onArrivedDriver);
    on<DriverRejectedRide>(_onDriverRejectedRide);
    on<NoDriversAccepted>(_onNoDriversAccepted);
    on<CancelRideConfirmation>(_onCancelRideConfirmation);

    on<NoMoreDriversAvailable>((event, emit) {
      emit(const NoDriversFound('Aucun chauffeur disponible'));
    });
  }

  Future<void> _onInitiateRideConfirmation(
    InitiateRideConfirmation event,
    Emitter<RideConfirmationState> emit,
  ) async {
    try {
      _currentDriverIndex = 0;

      // 1. Émettre l'état initial
      emit(SearchingDrivers(
        availableDrivers: event.nearbyDrivers,
        vehicleType: event.vehicleType,
        remainingTimeInSeconds: SEARCH_TIMEOUT_SECONDS,
        rideRequest: event.rideRequest,
      ));

      // 2. Écouter les mises à jour des chauffeurs depuis mapBloc
      if (mapBloc.state is MapRouteDrawnWithPrices) {
        await _driversSubscription?.cancel();
        _driversSubscription = mapBloc.stream.listen((mapState) {
          if (mapState is MapRouteDrawnWithPrices && !emit.isDone) {
            // Mettre à jour la liste des chauffeurs disponibles
            add(UpdateAvailableDrivers(mapState.nearbyDrivers));
          }
        });
      }

      // 3. Commencer à contacter les chauffeurs un par un
      await _tryNextDriver(event.nearbyDrivers, event.rideRequest, emit);
    } catch (e) {
      if (!emit.isDone) {
        emit(RideConfirmationError(e.toString()));
      }
    }
  }

  void _onUpdateAvailableDrivers(
    UpdateAvailableDrivers event,
    Emitter<RideConfirmationState> emit,
  ) {
    if (state is SearchingDrivers &&
        _currentDriverIndex < event.updatedDrivers.length) {
      final currentState = state as SearchingDrivers;
      emit(currentState.copyWith(
        availableDrivers: event.updatedDrivers,
      ));
    }
  }

  Future<void> _tryNextDriver(
    List<Driver> drivers,
    RideRequest rideRequest,
    Emitter<RideConfirmationState> emit,
  ) async {
    l.log('------ DÉBUT CYCLE ------');
    l.log(
        'Index actuel: $_currentDriverIndex sur ${drivers.length} chauffeurs');

    // Vérification initiale
    if (_currentDriverIndex >= drivers.length) {
      l.log(
          'ARRÊT FINAL: Index $_currentDriverIndex dépasse le nombre de chauffeurs ${drivers.length}');
      await _cleanupAllSubscriptions();
      if (!emit.isDone) {
        l.log('Émission de NoDriversFound');
        emit(const NoDriversFound('Aucun chauffeur disponible'));
      }
      return;
    }

    try {
      final currentDriver = drivers[_currentDriverIndex];
      l.log(
          'Tentative avec chauffeur ${currentDriver.driverId} (index: $_currentDriverIndex)');

      // Nettoyer les anciennes souscriptions
      _driverResponseTimer?.cancel();
      await _rideStatusSubscription?.cancel();

      if (!emit.isDone) {
        await notificationRepository.sendRideRequestNotification(
          driverToken: currentDriver.fcmToken,
          rideRequest: rideRequest,
        );
        l.log('Notification envoyée au chauffeur ${currentDriver.driverId}');

        _driverResponseTimer = Timer(
          const Duration(seconds: DRIVER_RESPONSE_TIMEOUT),
          () async {
            // Ajout de async
            l.log(
                'TIMEOUT: Pas de réponse du chauffeur ${currentDriver.driverId}');

            // On arrête d'abord les souscriptions avant d'émettre l'état
            await _cleanupAllSubscriptions();

            _currentDriverIndex++;
            l.log('Index incrémenté à: $_currentDriverIndex');

            if (_currentDriverIndex >= drivers.length) {
              l.log('ARRÊT : Plus de chauffeurs disponibles après timeout');

              // On utilise add au lieu de emit directement
              add(NoMoreDriversAvailable()); // Nouvel événement à créer
            } else {
              l.log('Passage au chauffeur suivant');
              _tryNextDriver(drivers, rideRequest, emit);
            }
          },
        );
      }
    } catch (e) {
      l.log('ERREUR: $e');
      await _cleanupAllSubscriptions();
      if (!emit.isDone) {
        emit(RideConfirmationError(e.toString()));
      }
    }
  }

  Future<void> _cleanupAllSubscriptions() async {
    l.log('Nettoyage de toutes les souscriptions');
    _driverResponseTimer?.cancel();
    await _rideStatusSubscription?.cancel();
    await _driversSubscription?.cancel();
    _driversSubscription = null;
  }

  Future<void> _onDriverAcceptedRide(
    DriverAcceptedRide event,
    Emitter<RideConfirmationState> emit,
  ) async {
    try {
      await _cleanupSubscriptions();
      await _acceptedDriverPositionSubscription?.cancel();

      emit(TrackingStarted(
          driver: event.acceptedDriver, rideRequest: event.rideRequest));

      bool hasNotifiedArrival = false;

      await emit.forEach<RideConfirmationState>(
        rideRepository
            .watchDriverPosition(event.acceptedDriver.driverId)
            .debounceTime(const Duration(seconds: 3))
            .takeWhile((_) =>
                !hasNotifiedArrival) // Arrête le stream quand hasNotifiedArrival devient true
            .map((position) {
          l.log(
              'Position actuelle du conducteur: lat=${position.lat}, lng=${position.lng}');

          if (isDriverArrived(position, event.rideRequest.origin) &&
              !hasNotifiedArrival) {
            hasNotifiedArrival = true;

            notifyDriverArrival.execute().then(
                  (_) => l.log('Notification d\'arrivée envoyée'),
                  onError: (e) =>
                      l.log('Erreur lors de l\'envoi de la notification: $e'),
                );

            return DriverArrived(
              position: position,
              driver: event.acceptedDriver,
              rideRequest: event.rideRequest,
            );
          }

          return DriverPositionUpdated(
            position: position,
            driver: event.acceptedDriver,
            rideRequest: event.rideRequest,
          );
        }),
        onData: (state) => state,
      );
    } catch (e) {
      l.log('Erreur dans _onDriverAcceptedRide: $e');
      if (!emit.isDone) {
        emit(RideConfirmationError(e.toString()));
      }
    }
  }

  //Cette event se declenche quand le driver clique sur le button "Commencer la course"
  //_watchRideStatusSubscription est un StreamSubscription qui permet de suivre le status de la course
  //Des que le status est à inRide, on envoie un event FullRideStarted
  Future<void> _onArrivedDriver(
    ArrivedDriver event,
    Emitter<RideConfirmationState> emit,
  ) async {
    try {
      l.log('Dans _onArrivedDriver');

      await emit.forEach<RideRequest>(
        rideRepository.watchRideStatus('test'),
        onData: (rideRequest) {
          l.log(
              'Ride status reçu: ${rideRequest.status}, raw status: ${rideRequest.status.toDisplayString()}');

          if (rideRequest.status == RideStatus.started) {
            l.log('Status started détecté - émission de FullRideStarted');
            return FullRideStarted(
              rideRequest: event.rideRequest,
              driver: event.driver,
            );
          }
          l.log(
              'Status non started (${rideRequest.status}) - conservation de l\'état actuel: $state');
          return state;
        },
      );
    } catch (e) {
      l.log('Erreur dans _onArrivedDriver: $e');
      emit(RideConfirmationError(e.toString()));
    }
  }

  void _onDriverRejectedRide(
    DriverRejectedRide event,
    Emitter<RideConfirmationState> emit,
  ) {
    if (state is SearchingDrivers) {
      final currentState = state as SearchingDrivers;
      // Retirer le driver qui a refusé de la liste
      final updatedDrivers = currentState.availableDrivers
          .where((driver) => driver.driverId != event.driverId)
          .toList();

      if (updatedDrivers.isEmpty) {
        _cleanupSubscriptions();
        emit(const NoDriversFound('Tous les chauffeurs ont refusé la course'));
      } else {
        emit(currentState.copyWith(
          availableDrivers: updatedDrivers,
        ));
      }
    }
  }

  void _onNoDriversAccepted(
    NoDriversAccepted event,
    Emitter<RideConfirmationState> emit,
  ) {
    _cleanupSubscriptions();
    emit(const NoDriversFound('Aucun chauffeur disponible pour le moment'));
  }

  Future<void> _onCancelRideConfirmation(
    CancelRideConfirmation event,
    Emitter<RideConfirmationState> emit,
  ) async {
    try {
      _cleanupSubscriptions();
      await rideRepository.updateRideStatus(event.rideRequest.id.toString(),
          RideStatus.cancelled); // Utilisation du rideRequest
      await rideRepository.cancelRide(event.rideRequest);
      emit(RideConfirmationCancelled());
    } catch (e) {
      emit(RideConfirmationError(e.toString()));
    }

    emit(RideConfirmationCancelled());
  }

  // Dans ride_confirmation_bloc.dart
  // Dans ride_confirmation_bloc.dart

  Future<void> _cleanupSubscriptions() async {
    _driverResponseTimer?.cancel();
    _rideStatusSubscription?.cancel();
    _driversSubscription?.cancel();
  }

  bool isDriverArrived(Position driverPosition, Position pickupPosition) {
    // Votre logique de calcul de distance
    final distance = calculateDistance(driverPosition, pickupPosition);
    return distance <= 150; // 50 mètres de seuil
  }

  double calculateDistance(Position pos1, Position pos2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((pos2.lat - pos1.lat) * p) / 2 +
        c(pos1.lat * p) *
            c(pos2.lat * p) *
            (1 - c((pos2.lng - pos1.lng) * p)) /
            2;
    return 12742 *
        asin(sqrt(a)) *
        1000; // 2 * R; R = 6371 km, résultat en mètres
  }

  @override
  Future<void> close() {
    _cleanupSubscriptions();
    return super.close();
  }
}
