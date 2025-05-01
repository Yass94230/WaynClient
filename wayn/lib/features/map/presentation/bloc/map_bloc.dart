// Events
// ignore_for_file: void_checks

import 'dart:async';
import 'dart:developer' as l;
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rxdart/rxdart.dart';
import 'package:wayn/features/map/data/managers/polyline_manager.dart';
import 'package:wayn/features/map/data/models/user_location_model.dart';
import 'package:wayn/features/map/directions/domain/entities/route_coordinate.dart';
import 'package:wayn/features/map/directions/domain/usecases/get_route_coordinate_usecase.dart';
import 'package:wayn/features/map/directions/domain/usecases/stream_route_coordinate_usescase.dart';
import 'package:wayn/features/map/domain/entities/driver.dart';
import 'package:wayn/features/map/domain/entities/user_location.dart';
import 'package:wayn/features/map/domain/repositories/map_repository.dart';
import 'package:wayn/features/map/presentation/bloc/utils/cache_route_update_driver.dart';
import 'package:wayn/features/ride/domain/entities/ride_request.dart';
import 'package:wayn/features/utils/ride_price_calculator.dart';

// Events
abstract class MapEvent {}

class InitializeMap extends MapEvent {
  final MapboxMap controller;

  InitializeMap(this.controller);
}

class BackToInitial extends MapEvent {
  //final MapboxMap controller;
  BackToInitial();
}

class RequestLocationPermission extends MapEvent {}

class UpdateSelectedIndex extends MapEvent {
  final int index;
  UpdateSelectedIndex(this.index);
}

class EnableUserLocation extends MapEvent {}

class UpdateUserLocation extends MapEvent {
  final UserLocationModel location;
  UpdateUserLocation(this.location);
}

class StartLocationTracking extends MapEvent {}

class DrawRouteEvent extends MapEvent {
  final Point origin;
  final Point destination;
  final String? originAddress;
  final String? destinationAddress;
  final bool? isOptionEnable;
  final String? userGender;
  DrawRouteEvent(this.origin, this.destination, this.originAddress,
      this.destinationAddress, this.isOptionEnable, this.userGender);
}

class ReturnToPreviousScreen extends MapEvent {
  final BuildContext context;
  ReturnToPreviousScreen(this.context);
}

class UpdateDriversEvent extends MapEvent {
  final List<Driver> drivers;

  UpdateDriversEvent(this.drivers);

  List<Object?> get props => [drivers];
}

class UpdateSelectedVehicleType extends MapEvent {
  final String vehicleType;
  UpdateSelectedVehicleType(this.vehicleType);
}

class RemoveRouteEvent extends MapEvent {}

class StartConfirmationEvent extends MapEvent {
  final RouteCoordinates route;
  final List<Driver> nearbyDrivers;

  final String selectedVehicleType;
  final double price;

  StartConfirmationEvent({
    required this.route,
    required this.nearbyDrivers,
    required this.selectedVehicleType,
    required this.price,
  });

  List<Object?> get props => [
        route,
        nearbyDrivers,
        selectedVehicleType,
        price,
      ];
}

class DriverFoundComing extends MapEvent {
  final Position position;
  final Driver driver;
  final RideRequest rideRequest;

  DriverFoundComing({
    required this.position,
    required this.driver,
    required this.rideRequest,
  });
}

class FullRideStartedInMap extends MapEvent {
  final Driver driver;
  final RideRequest rideRequest;

  FullRideStartedInMap({
    required this.driver,
    required this.rideRequest,
  });
}

// States
abstract class MapState {}

class MapInitial extends MapState {}

class MapLoading extends MapState {}

class MapReady extends MapState {
  final int selectedIndex;
  final UserLocation? userLocation;

  MapReady({
    this.selectedIndex = 0,
    this.userLocation,
  });

  MapReady copyWith({
    int? selectedIndex,
    UserLocationModel? userLocation,
  }) {
    return MapReady(
      selectedIndex: selectedIndex ?? this.selectedIndex,
      userLocation: userLocation ?? this.userLocation,
    );
  }
}

class MapNoDriversAvailable extends MapState {
  final RouteCoordinates route;
  final Point origin;
  final Point destination;
  final Map<String, double> prices;
  final String stringOrigin;
  final String stringDestination;

  MapNoDriversAvailable({
    required this.route,
    required this.origin,
    required this.destination,
    required this.prices,
    required this.stringOrigin,
    required this.stringDestination,
  });

  List<Object?> get props => [
        route,
        origin,
        destination,
        prices,
        stringOrigin,
        stringDestination,
      ];
}

class MapRouteDrawn extends MapState {
  final RouteCoordinates route;
  MapRouteDrawn(this.route);
}

class MapError extends MapState {
  final String message;
  MapError(this.message);
}

class MapRouteDrawnWithPrices extends MapState {
  final RouteCoordinates route;
  final Point origin; // Ajouter cette ligne
  final Point destination;
  final List<Driver> nearbyDrivers;
  final Map<String, double> prices;
  final String selectedVehicleType;
  final String stringOrigin;
  final String stringDestination;

  MapRouteDrawnWithPrices({
    required this.route,
    required this.origin, // Ajouter cette ligne
    required this.destination,
    required this.nearbyDrivers,
    required this.prices,
    required this.selectedVehicleType,
    required this.stringOrigin,
    required this.stringDestination,
  });

  MapRouteDrawnWithPrices copyWith({
    RouteCoordinates? route,
    Point? origin, // Ajouter cette ligne
    Point? destination,
    List<Driver>? nearbyDrivers,
    Map<String, double>? prices,
    String? selectedVehicleType,
    String? stringOrigin,
    String? stringDestination,
  }) {
    return MapRouteDrawnWithPrices(
      route: route ?? this.route,
      origin: origin ?? this.origin, // Ajouter cette ligne
      destination: destination ?? this.destination,
      nearbyDrivers: nearbyDrivers ?? this.nearbyDrivers,
      prices: prices ?? this.prices,
      selectedVehicleType: selectedVehicleType ?? this.selectedVehicleType,
      stringOrigin: stringOrigin ?? this.stringOrigin,
      stringDestination: stringDestination ?? this.stringDestination,
    );
  }
}

class MapDriverLocationUpdated extends MapState {
  final Position driverPosition;
  final Driver acceptedDriver;
  final RideRequest rideRequest;
  final double distance; // Ajout de la distance
  final double duration; // Ajout de la durée

  MapDriverLocationUpdated({
    required this.driverPosition,
    required this.acceptedDriver,
    required this.rideRequest,
    required this.distance, // Nouveau paramètre
    required this.duration, // Nouveau paramètre
  });
}

class MapFullRideUpdated extends MapState {
  final Position driverPosition;
  final Driver driver;
  final RideRequest rideRequest;
  final double distance; // distance en mètres
  final double duration; // durée en secondes
  final DateTime estimatedArrival;

  MapFullRideUpdated(
      {required this.driverPosition,
      required this.driver,
      required this.rideRequest,
      required this.distance,
      required this.duration,
      required this.estimatedArrival});

  List<Object?> get props => [
        driverPosition,
        driver,
        rideRequest,
        distance,
        duration,
        estimatedArrival
      ];
}

class LocationPermissionDenied extends MapState {}

class LocationPermissionGranted extends MapState {}

class LocationPermissionPermanentlyDenied extends MapState {}

// Bloc

class MapBloc extends Bloc<MapEvent, MapState> {
  MapboxMap? mapController;
  final MapRepository mapRepository;
  final GetRouteCoordinatesUseCase getRouteCoordinatesUseCase;
  final StreamRouteCoordinateUsescase streamRouteCoordinateUsescase;
  final Map<String, ETACacheEntry> _etaCache = {};

  // Subscriptions
  StreamSubscription<UserLocation>? _positionStreamSubscription;
  StreamSubscription<List<Driver>>? _driversSubscription;
  StreamSubscription<RouteCoordinates>? _routeStreamSubscription;

  // Map elements

  PolylineManager? _polylineManager;

  PointAnnotationManager? _pointAnnotationManager;
  PointAnnotation? _driverMarker;

  PolylineAnnotation? _routePolyline;

  final Set<String> _driverMarkerIds = {};

  late MbxImage _driverMarkerImage;

  MapBloc(
      {required this.mapRepository,
      required this.getRouteCoordinatesUseCase,
      required this.streamRouteCoordinateUsescase})
      : super(MapInitial()) {
    on<InitializeMap>(_onInitializeMap);
    on<RequestLocationPermission>(_onRequestLocationPermission);
    on<EnableUserLocation>(_onEnableUserLocation);
    on<UpdateUserLocation>(_onUpdateUserLocation);
    on<BackToInitial>(_onBackToInitial);
    on<StartLocationTracking>(_onStartLocationTracking);
    on<DrawRouteEvent>(_onDrawRoute);
    on<UpdateDriversEvent>(_onUpdateDrivers);
    on<DriverFoundComing>(_onDriverFoundComing);
    on<FullRideStartedInMap>(_onFullRideStartedInMap);

    on<ReturnToPreviousScreen>((event, emit) {
      if (state is MapRouteDrawnWithPrices) {
        final currentState = state as MapRouteDrawnWithPrices;

        // On ferme d'abord la bottom sheet actuelle
        Navigator.of(event.context, rootNavigator: true).pop();

        // On émet le même état mais avec la liste de drivers vidée
        // pour déclencher l'affichage de la bottom sheet précédente
        emit(MapRouteDrawnWithPrices(
          route: currentState.route,
          origin: currentState.origin,
          destination: currentState.destination,
          nearbyDrivers: currentState.nearbyDrivers, // Garder les drivers
          prices: currentState.prices,
          selectedVehicleType: currentState.selectedVehicleType,
          stringOrigin: currentState.stringOrigin,
          stringDestination: currentState.stringDestination,
        ));
      }
    });
  }

  Future<void> _initializeMapController(MapboxMap controller) async {
    try {
      l.log('Début de _initializeMapController');
      mapController = controller;

      // Ensuite configurer le marker
      await _setupAllAnnotionManager();
      l.log('Driver marker configuré');
    } catch (e) {
      l.log('Erreur dans _initializeMapController: $e');
      rethrow;
    }
  }

  // Setup du marker manager
  Future<void> _setupAllAnnotionManager() async {
    _pointAnnotationManager =
        await mapController?.annotations.createPointAnnotationManager();
    _polylineManager = PolylineManager(mapController!);
    await _polylineManager!.initialize();
  }

  Future<void> _onInitializeMap(
    InitializeMap event,
    Emitter<MapState> emit,
  ) async {
    try {
      l.log('Initialisation de la carte et du marker manager');
      await _initializeMapController(event.controller);
      emit(MapReady());
    } catch (e) {
      l.log('Erreur lors de l\'initialisation: $e');
      emit(MapError(e.toString()));
    }
  }

  Future<void> _onBackToInitial(
    BackToInitial event,
    Emitter<MapState> emit,
  ) async {
    try {
      await _cleanupExistingResources();
      await _removeExistingDriverMarkers();
      // add(InitializeMap());
      add(RequestLocationPermission());
      emit(MapReady());
    } catch (e) {
      l.log('Erreur lors du retour à l\'état initial: $e');
      emit(MapError(e.toString()));
    }
  }

  Future<void> _onRequestLocationPermission(
    RequestLocationPermission event,
    Emitter<MapState> emit,
  ) async {
    try {
      final isPermissionGranted =
          await mapRepository.requestLocationPermission();
      if (isPermissionGranted) {
        emit(LocationPermissionGranted());

        final currentLocation = await mapRepository.getCurrentLocation();

        if (!emit.isDone) {
          if (state is MapReady) {
            final currentState = state as MapReady;
            emit(MapReady(
              selectedIndex: currentState.selectedIndex,
              userLocation: currentLocation,
            ));
          } else {
            emit(MapReady(userLocation: currentLocation));
          }
        }

        if (!emit.isDone) {
          add(EnableUserLocation());
        }
      } else {
        final status = await Permission.location.status;
        if (!emit.isDone) {
          if (status.isPermanentlyDenied) {
            emit(LocationPermissionPermanentlyDenied());
          } else {
            emit(LocationPermissionDenied());
          }
        }
      }
    } catch (e) {
      if (!emit.isDone) {
        emit(LocationPermissionDenied());
      }
    }
  }

  Future<void> _onEnableUserLocation(
    EnableUserLocation event,
    Emitter<MapState> emit,
  ) async {
    try {
      // Activer la localisation
      mapController?.location.updateSettings(
        LocationComponentSettings(
          enabled: true,
          pulsingEnabled: false,
          showAccuracyRing: false,
        ),
      );

      // Obtenir la position actuelle
      final currentLocation = await mapRepository.getCurrentLocation();

      if (mapController == null) {
        l.log('Controller perdu dans _onEnableUserLocation');
        throw Exception('MapController est null');
      }

      // Mettre à jour la caméra pour centrer sur l'utilisateur

      // Émettre le nouvel état
      if (!emit.isDone) {
        if (state is MapReady) {
          final currentState = state as MapReady;
          await mapController?.setCamera(
            CameraOptions(
              center: Point(
                coordinates: Position(
                  currentLocation.longitude,
                  currentLocation.latitude,
                ),
              ),
              zoom: 17.0,
            ),
          );
          emit(MapReady(
            selectedIndex: currentState.selectedIndex,
            userLocation: currentLocation,
          ));
        } else {
          emit(MapReady(userLocation: currentLocation));
        }
      }

      // Démarrer le suivi de la position
      if (!emit.isDone) {
        add(StartLocationTracking());
      }
    } catch (e) {
      l.log('Erreur lors de l\'activation de la localisation: $e');
    }
  }

  Future<void> _onStartLocationTracking(
    StartLocationTracking event,
    Emitter<MapState> emit,
  ) async {
    await _positionStreamSubscription?.cancel();

    try {
      final locationStream = mapRepository.getLocationStream();
      _positionStreamSubscription = locationStream.listen(
        (userLocation) {
          if (!emit.isDone && state is MapReady) {
            final currentState = state as MapReady;
            add(UpdateUserLocation(
                currentState.userLocation! as UserLocationModel));
          }
        },
        onError: (error) {
          l.log('Erreur de suivi de position: $error');
        },
      );
    } catch (e) {
      l.log('Erreur lors du démarrage du suivi: $e');
    }
  }

  void _onUpdateUserLocation(
    UpdateUserLocation event,
    Emitter<MapState> emit,
  ) {
    if (state is MapReady) {
      final currentState = state as MapReady;
      emit(currentState.copyWith(userLocation: event.location));
    }
  }

  Future<void> _onDrawRoute(
    DrawRouteEvent event,
    Emitter<MapState> emit,
  ) async {
    try {
      await _driversSubscription?.cancel();
      emit(MapLoading());

      // 1. Obtenir les coordonnées de la route
      final routeCoordinates = await getRouteCoordinatesUseCase.execute(
        event.origin,
        event.destination,
      );

      // 2. Calculer les prix
      const cityName = "Paris";
      final vehiclePrices = await Future.wait([
        mapRepository.getVehiclePrices(cityName, 'berline'),
        mapRepository.getVehiclePrices(cityName, 'van'),
      ]);

      final priceCalculations = vehiclePrices.map((prices) {
        return RidePriceCalculator(
          distanceKm: routeCoordinates.distance / 1000,
          durationMinutes: (routeCoordinates.duration / 60).round(),
          prices: prices,
        ).calculate();
      }).toList();

      final Map<String, double> pricesMap = {
        'berline': priceCalculations[0],
        'van': priceCalculations[1],
      };

      // Créer un flag pour suivre si des chauffeurs sont trouvés
      bool driversFound = false;

      // Créer un timer pour vérifier si des chauffeurs sont trouvés
      Timer? noDriversTimer = Timer(const Duration(seconds: 8), () {
        if (!driversFound && !emit.isDone) {
          // Si aucun chauffeur n'est trouvé après 8 secondes, émettre l'état
          emit(MapNoDriversAvailable(
            route: routeCoordinates,
            origin: event.origin,
            destination: event.destination,
            prices: pricesMap,
            stringOrigin: event.originAddress!,
            stringDestination: event.destinationAddress!,
          ));
        }
      });

      // 3. Configurer le stream des chauffeurs
      await _driversSubscription?.cancel();
      _driversSubscription = mapRepository
          .getNearbyDriversStream(
            latitude: event.origin.coordinates.lat as double,
            longitude: event.origin.coordinates.lng as double,
            radius: 5.0,
            isOptionEnabled: event.isOptionEnable!,
            userGender: event.userGender!,
          )
          .debounce(
              (_) => TimerStream(true, const Duration(milliseconds: 2500)))
          .listen((drivers) {
        // Si des chauffeurs sont trouvés, mettre le flag à true
        if (drivers.isNotEmpty) {
          driversFound = true;
          noDriversTimer.cancel();
        }
        // Créer un nouvel événement pour gérer les mises à jour des drivers
        add(UpdateDriversEvent(drivers));
      });

      _routePolyline =
          await _polylineManager!.createPolyline(routeCoordinates.coordinates);

      // 6. Configurer la caméra
      final bounds = _calculateRouteBounds(routeCoordinates.coordinates);

      final cameraOptions = await mapController?.cameraForCoordinateBounds(
        bounds,
        _calculatePadding(),
        0.0, // bearing
        0.0, // pitch
        17.0, // maxZoom
        null, // offset
      );

      await mapController?.flyTo(
        cameraOptions!,
        MapAnimationOptions(
          duration: 1500, // 1.5 secondes
          startDelay: 0,
        ),
      );

      // Émettre l'état initial avec une liste vide de chauffeurs
      // Le timer vérifiera plus tard si des chauffeurs ont été trouvés
      emit(MapRouteDrawnWithPrices(
        route: routeCoordinates,
        origin: event.origin,
        destination: event.destination,
        nearbyDrivers: [],
        prices: pricesMap,
        selectedVehicleType: '',
        stringOrigin: event.originAddress!,
        stringDestination: event.destinationAddress!,
      ));
    } catch (e, stackTrace) {
      l.log('Erreur lors du dessin de la route: $e\n$stackTrace');
      emit(MapError('Impossible de tracer l\'itinéraire: ${e.toString()}'));
    }
  }

  Future<void> _updateDriverMarkers(List<Driver> drivers) async {
    await _removeExistingDriverMarkers();

    ByteData bytes = await rootBundle.load('assets/driver.png');
    Uint8List imageData = bytes.buffer.asUint8List();
    _driverMarkerImage = MbxImage(data: imageData, width: 28, height: 51);

    for (var driver in drivers) {
      final markerId = 'driver-${driver.driverId}';
      await _pointAnnotationManager?.create(
        PointAnnotationOptions(
          geometry: Point(
            coordinates: Position(driver.longitude, driver.latitude),
          ),
          image: _driverMarkerImage.data,
          // iconImage: "driver-marker",
          iconSize: 2.0,
        ),
      );
      _driverMarkerIds.add(markerId);
    }
  }

  Future<void> _onUpdateDrivers(
    UpdateDriversEvent event,
    Emitter<MapState> emit,
  ) async {
    if (state is MapRouteDrawnWithPrices) {
      final currentState = state as MapRouteDrawnWithPrices;
      l.log('Nombre de chauffeurs reçus: ${event.drivers.length}');

      // Vérification immédiate si aucun chauffeur n'est disponible
      if (event.drivers.isEmpty) {
        await _removeExistingDriverMarkers(); // Nettoyer la carte

        // Émettre l'état "aucun chauffeur disponible"
        emit(MapNoDriversAvailable(
          route: currentState.route,
          origin: currentState.origin,
          destination: currentState.destination,
          prices: currentState.prices,
          stringOrigin: currentState.stringOrigin,
          stringDestination: currentState.stringDestination,
        ));
        return; // Sortir de la méthode
      }

      // Si des chauffeurs sont disponibles, continuer avec le traitement normal

      // Structure pour stocker la distance à vol d'oiseau et le chauffeur
      final List<({Driver driver, double distance})> driversWithDistance = [];
      final originCoords = currentState.origin.coordinates;

      // Calculer la distance à vol d'oiseau pour chaque chauffeur
      for (var driver in event.drivers) {
        final distance = calculateHaversineDistance(
          originCoords.lat as double,
          originCoords.lng as double,
          driver.latitude,
          driver.longitude,
        );
        driversWithDistance.add((driver: driver, distance: distance));
      }

      // Trier les chauffeurs par distance
      driversWithDistance.sort((a, b) => a.distance.compareTo(b.distance));

      // Ne traiter que les 5 chauffeurs les plus proches
      const maxDriversToProcess = 5;
      final nearestDrivers = driversWithDistance.take(maxDriversToProcess);
      List<Driver> driversWithETA = [];

      // Traiter les chauffeurs les plus proches
      for (var driverWithDist in nearestDrivers) {
        final driver = driverWithDist.driver;
        final cacheKey = _generateCacheKey(driver.driverId, originCoords);

        try {
          int eta;
          // Vérifier le cache
          if (_etaCache.containsKey(cacheKey) &&
              _etaCache[cacheKey]!.isValid()) {
            eta = _etaCache[cacheKey]!.eta;
            l.log(
                'ETA trouvé dans le cache pour ${driver.driverId}: $eta minutes');
          } else {
            // Calculer nouvel ETA
            final driverPoint = Point(
              coordinates: Position(driver.longitude, driver.latitude),
            );
            final driverToClientRoute =
                await getRouteCoordinatesUseCase.execute(
              driverPoint,
              currentState.origin,
            );
            eta = (driverToClientRoute.duration / 60).round();

            // Mettre en cache
            _etaCache[cacheKey] = ETACacheEntry.now(eta: eta);
            l.log('Nouvel ETA calculé pour ${driver.driverId}: $eta minutes');
          }

          driversWithETA.add(driver.copyWith(
            estimatedTimeOfArrival: eta,
          ));
        } catch (e) {
          l.log(
              'Erreur lors du calcul ETA pour le chauffeur ${driver.driverId}: $e');
          continue;
        }
      }

      // Ajouter les chauffeurs restants sans ETA
      final remainingDrivers = driversWithDistance
          .skip(maxDriversToProcess)
          .map((d) => d.driver)
          .toList();

      // Combiner tous les chauffeurs et mettre à jour
      final allDrivers = [...driversWithETA, ...remainingDrivers];
      await _updateDriverMarkers(allDrivers);

      // Émettre l'état mis à jour avec des chauffeurs disponibles
      emit(currentState.copyWith(
        nearbyDrivers: allDrivers,
      ));

      l.log(
          'Mise à jour terminée: ${driversWithETA.length} chauffeurs avec ETA, '
          '${remainingDrivers.length} sans ETA');
    }
  }

  String _generateCacheKey(String driverId, Position origin) {
    final lat = (origin.lat as double).toStringAsFixed(3);
    final lng = (origin.lng as double).toStringAsFixed(3);
    return '${driverId}_${lat}_$lng';
  }

  double calculateHaversineDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double R = 6371.0; // Rayon de la Terre en kilomètres
    final double dLat = _toRadians(lat2 - lat1);
    final double dLon = _toRadians(lon2 - lon1);

    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }

  double _toRadians(double degree) {
    return degree * pi / 180;
  }

  Future<void> _onDriverFoundComing(
      DriverFoundComing event, Emitter<MapState> emit) async {
    try {
      l.log('Début de _onDriverFoundComing');
      await _cleanupExistingResources();

      // Émettre l'état initial avant de commencer le tracking
      // emit(MapDriverLocationUpdated(
      //   driverPosition: Position(event.driver.longitude, event.driver.latitude),
      //   acceptedDriver: event.driver,
      //   rideRequest: event.rideRequest,
      //   distance: 0, // Valeur initiale
      //   duration: 0, // Valeur initiale
      // ));

      // Démarrer le tracking
      await _setupRouteTracking(event, emit);
    } catch (e, stackTrace) {
      _handleError(e, stackTrace, emit);
    }
  }

  Future<void> _setupRouteTracking(
      DriverFoundComing event, Emitter<MapState> emit) async {
    final driverPosition = Point(
        coordinates: Position(event.driver.longitude, event.driver.latitude));
    final pickupPosition = Point(
        coordinates: Position(
            event.rideRequest.origin.lng, event.rideRequest.origin.lat));

    await for (final routeToPickup in streamRouteCoordinateUsescase.execute(
        driverPosition, pickupPosition)) {
      try {
        _handleRouteUpdate(routeToPickup, event.position).then((_) {
          emit(MapDriverLocationUpdated(
            driverPosition:
                Position(event.driver.longitude, event.driver.latitude),
            acceptedDriver: event.driver,
            rideRequest: event.rideRequest,
            distance: routeToPickup.distance,
            duration: routeToPickup.duration,
          ));
        });
      } catch (e) {
        l.log('Erreur dans le stream de route: $e');
      }
    }
  }

  Future<void> _cleanupExistingResources() async {
    await Future.wait([
      if (_positionStreamSubscription != null)
        _positionStreamSubscription!.cancel(),
      if (_driversSubscription != null) _driversSubscription!.cancel(),
      if (_routeStreamSubscription != null) _routeStreamSubscription!.cancel(),
      if (_polylineManager != null) _polylineManager!.removeAll(),
    ]);
  }

  Future<void> _handleRouteUpdate(
      RouteCoordinates route, Position driverPosition) async {
    if (_polylineManager == null || mapController == null) return;

    await Future.wait([
      _polylineManager!.createPolyline(route.coordinates),
      _updateDriverMarker(Position(driverPosition.lng, driverPosition.lat)),
      _updateMapCamera(driverPosition),
    ]);

    l.log(
        'Route mise à jour - Distance: ${route.distance / 1000}km, Durée: ${route.duration / 60}min');
  }

  Future<void> _onFullRideStartedInMap(
      FullRideStartedInMap event, Emitter<MapState> emit) async {
    try {
      await _cleanupExistingResources();

      final driverPosition = Point(
          coordinates: Position(event.driver.longitude, event.driver.latitude));
      final destinationPosition = Point(
          coordinates: Position(event.rideRequest.destination.lng,
              event.rideRequest.destination.lat));

      await emit.forEach(
        streamRouteCoordinateUsescase.execute(
            driverPosition, destinationPosition),
        onData: (routeToDestination) {
          final estimatedArrival = DateTime.now()
              .add(Duration(seconds: routeToDestination.duration.toInt()));

          return MapFullRideUpdated(
            driverPosition: driverPosition.coordinates,
            driver: event.driver,
            rideRequest: event.rideRequest,
            distance: routeToDestination.distance,
            duration: routeToDestination.duration,
            estimatedArrival: estimatedArrival,
          );
        },
      );
    } catch (e, stackTrace) {
      _handleError(e, stackTrace, emit);
    }
  }

  Future<void> _updateMapCamera(Position position) async {
    if (mapController == null) return;

    await mapController!.setCamera(
      CameraOptions(
        center: Point(coordinates: position),
        zoom: 17.5,
        bearing: 10,
        padding: _calculatePadding(),
      ),
    );
  }

  /// Gère les erreurs survenues pendant le processus
  void _handleError(
      Object error, StackTrace stackTrace, Emitter<MapState> emit) {
    l.log('ERREUR dans _onDriverFoundComing: $error');
    l.log('Stack trace: $stackTrace');
    emit(MapError(error.toString()));
  }

  Future<void> _updateDriverMarker(Position position) async {
    try {
      if (_driverMarker == null) {
        // Première création du marker
        ByteData bytes = await rootBundle.load('assets/driver.png');
        Uint8List imageData = bytes.buffer.asUint8List();

        _driverMarker = await _pointAnnotationManager?.create(
          PointAnnotationOptions(
            geometry: Point(
              coordinates: Position(position.lng, position.lat),
            ),
            iconImage: "driver-marker",
            image: imageData,
            iconSize: 2.5,
          ),
        );
      } else {
        // Mise à jour de la position
        _driverMarker!.geometry = Point(
          coordinates: Position(position.lng, position.lat),
        );
      }
    } catch (e) {
      l.log('Erreur lors de la mise à jour du marker: $e');
      rethrow;
    }
  }

  bool _arePositionsEqual(Position pos1, Position pos2) {
    const double threshold = 0.0001; // Environ 11 mètres à l'équateur
    return (pos1.lat - pos2.lng).abs() < threshold &&
        (pos1.lat - pos2.lng).abs() < threshold;
  }

  Future<void> _removeExistingDriverMarkers() async {
    try {
      await _pointAnnotationManager?.deleteAll();
    } catch (e) {
      l.log('Erreur lors de la suppression des marqueurs: $e');
    }
  }

  CoordinateBounds _calculateRouteBounds(List<Position> coordinates) {
    final lngs = coordinates.map((c) => c.lng);
    final lats = coordinates.map((c) => c.lat);

    return CoordinateBounds(
      southwest: Point(
        coordinates: Position(
          lngs.reduce(min),
          lats.reduce(min),
        ),
      ),
      northeast: Point(
        coordinates: Position(
          lngs.reduce(max),
          lats.reduce(max),
        ),
      ),
      infiniteBounds: false,
    );
  }

  MbxEdgeInsets _calculatePadding() {
    // Ajuster le padding pour tenir compte de la bottomSheet
    // bottomSheet prend 60% de l'écran en hauteur
    return MbxEdgeInsets(
      top: 50, // Petit padding en haut
      left: 50, // Padding standard sur les côtés
      right: 50, // Padding standard sur les côtés
      bottom: 300, // Plus grand padding en bas pour la bottomSheet
    );
  }

  @override
  Future<void> close() async {
    await _positionStreamSubscription?.cancel();
    await _driversSubscription?.cancel();

    mapController?.dispose();
    return super.close();
  }
}
