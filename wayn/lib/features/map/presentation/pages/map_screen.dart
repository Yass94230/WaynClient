// ignore_for_file: library_private_types_in_public_api

import 'dart:developer';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wayn/features/authentification/domain/entities/user.dart';
import 'package:wayn/features/authentification/presentation/cubits/user_cubit.dart';
import 'package:wayn/features/core/config/size_config.dart';
import 'package:wayn/features/home/presentation/widgets/platform_bottom_sheet.dart';
import 'package:wayn/features/home/presentation/widgets/platform_scaffold.dart';
import 'package:wayn/features/map/presentation/bloc/map_bloc.dart';
import 'package:wayn/features/map/domain/entities/user_location.dart';
import 'package:wayn/features/notification/presentation/bloc/notification_bloc.dart';
import 'package:wayn/features/notification/presentation/bloc/notification_event.dart';
import 'package:wayn/features/notification/presentation/bloc/notification_state.dart';
import 'package:wayn/features/ride/presentation/blocs/ride_confirmation_bloc.dart';
import 'package:wayn/features/ride/presentation/blocs/ride_confirmation_state.dart';
import 'package:wayn/features/ride/presentation/pages/ride_full_course_screen.dart';
import 'package:wayn/features/ride/presentation/pages/ride_tracking_driver_screen.dart';
import 'package:wayn/features/search/presentation/pages/no_driver_available.dart';
import 'package:wayn/features/search/presentation/pages/promotion_banner.dart';
import 'package:wayn/features/search/presentation/pages/promotion_screen.dart';
import 'package:wayn/features/search/presentation/pages/ride_options_view.dart';
import 'package:wayn/features/search/presentation/pages/search_destination.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static const double _defaultZoom = 17.0;
  static final Position _defaultPosition = Position(2.3488, 48.8534); // Paris
  static const String _mapStyle =
      "mapbox://styles/mapbox/navigation-guidance-day-v2";

  MapboxMap? mapboxMap;

  User? user;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserCubit>().getUser();
    });
  }

  void _handleStateChanges(BuildContext context, MapState state) {
    if (state is LocationPermissionDenied) {
      _showPermissionDialog(
        title: "Permission refusée",
        message:
            "Vous devez autoriser la localisation pour utiliser cette fonctionnalité.",
        onRetry: () => context.read<MapBloc>().add(RequestLocationPermission()),
      );
    } else if (state is LocationPermissionPermanentlyDenied) {
      openAppSettings();
    } else if (state is LocationPermissionGranted) {
      context.read<MapBloc>().add(EnableUserLocation());
    } else if (state is MapReady && state.userLocation != null) {
      _updateCamera(state.userLocation!);
    } else if (state is MapRouteDrawnWithPrices &&
        state.nearbyDrivers.isNotEmpty) {
      // Marquer comme ouvert
      // Fermer le clavier
      PlatformBottomSheet.show(
        context: context,
        enableDrag: true,
        isDismissible: true,
        initialChildSize: 0.5,
        minChildSize: 0.5,
        maxChildSize: 0.5,
        child: RideOptionsView(
          selectedVehicleType: state.selectedVehicleType,
          prices: state.prices,
          route: state.route,
          nearbyDrivers: state.nearbyDrivers,
          originAddress: state.stringOrigin,
          destinationAddress: state.stringDestination,
          origin: state.origin.coordinates,
          destination: state.destination.coordinates,
          mapController: mapboxMap!,
        ),
      );
    } else if (state is MapDriverLocationUpdated) {
    } else if (state is MapNoDriversAvailable) {
      PlatformBottomSheet.show(
          context: context,
          enableDrag: true,
          isDismissible: true,
          initialChildSize: 0.7,
          minChildSize: 0.7,
          maxChildSize: 0.7,
          child: NoDriversAvailableScreen(
              route: state.route,
              origin: state.origin,
              destination: state.destination,
              originAddress: state.stringOrigin,
              destinationAddress: state.stringDestination));
    }
  }

  Widget _buildScreen(
    BuildContext context,
  ) {
    return BlocBuilder<UserCubit, UserState>(
      builder: (context, userState) {
        return Stack(
          children: [
            _buildMap(),
            Positioned(
                left: 0,
                right: 0,
                bottom: userState.status == UserStatus.loaded &&
                            userState.user!.preferedDepart != null ||
                        userState.status == UserStatus.loaded &&
                            userState.user!.preferedArrival != null
                    ? MobileAdaptive.screenHeight * 0.31
                    : MobileAdaptive.screenHeight * 0.23,
                child: Builder(
                  builder: (context) => PromotionBanner(
                    onTap: () {
                      log('PromotionBanner tapped');
                      if (Platform.isAndroid) {
                        showBottomSheet(
                          context: context,
                          builder: (context) {
                            return Container(
                              color: CupertinoColors.systemBackground
                                  .resolveFrom(context),
                              child: const PromotionScreen(),
                            );
                          },
                        );
                      } else if (Platform.isIOS) {
                        showCupertinoModalPopup(
                          context: context,
                          builder: (context) => Container(
                            color: CupertinoColors.systemBackground
                                .resolveFrom(context),
                            child: const PromotionScreen(),
                          ),
                        );
                      }
                    },
                  ),
                )),
            const SearchDestination(),
          ],
        );
      },
    );
  }

  Widget _buildMap() {
    return MapWidget(
      androidHostingMode: AndroidPlatformViewHostingMode.TLHC_HC,
      key: const ValueKey("mapBoxMap"),
      styleUri: _mapStyle,
      onMapCreated: _handleMapCreated,
      cameraOptions: _getCameraOptions(),
    );
  }

  void _handleMapCreated(MapboxMap controller) {
    log('MapScreen: Création de la carte');
    mapboxMap = controller;

    controller.scaleBar.updateSettings(ScaleBarSettings(enabled: false));

    controller.attribution.updateSettings(AttributionSettings(enabled: false));

    // Activer les gestes de la carte
    controller.gestures.updateSettings(GesturesSettings(
        rotateEnabled: true,
        scrollEnabled: true,
        doubleTapToZoomInEnabled: true,
        doubleTouchToZoomOutEnabled: true,
        pinchToZoomEnabled: true,
        zoomAnimationAmount: 1));

    log('MapScreen: Gestes activés');

    final bloc = context.read<MapBloc>();

    bloc
      ..add(InitializeMap(controller))
      ..add(RequestLocationPermission());
  }

  void _updateCamera(UserLocation location) {
    mapboxMap?.setCamera(
      CameraOptions(
        center: Point(
          coordinates: Position(
            location.longitude,
            location.latitude,
          ),
        ),
        zoom: _defaultZoom,
      ),
    );
  }

  CameraOptions _getCameraOptions([MapState? state]) {
    if (state is MapReady && state.userLocation != null) {
      return CameraOptions(
        center: Point(
          coordinates: Position(
            state.userLocation!.longitude,
            state.userLocation!.latitude,
          ),
        ),
        zoom: _defaultZoom,
      );
    }

    return CameraOptions(
      center: Point(
        coordinates: _defaultPosition,
      ),
      zoom: 27,
    );
  }

  void _showPermissionDialog({
    required String title,
    required String message,
    required VoidCallback onRetry,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              onRetry();
            },
            child: const Text("Réessayer"),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Annuler"),
          ),
        ],
      ),
    );
  }

  Widget _buildM(BuildContext context) {
    return MultiBlocListener(
        listeners: [
          BlocListener<NotificationBloc, NotificationState>(
            listener: (context, state) {
              if (state is NotificationReceived) {
                log('le state du notifation bloc est de type NotificationReceived');
              }
            },
          ),
          BlocListener<MapBloc, MapState>(
            listener: _handleStateChanges,
          ),
          BlocListener<UserCubit, UserState>(
            listener: (context, userState) {
              //log(' state de l"usercubit${userState.status}');
              switch (userState.status) {
                case UserStatus.loaded:
                  user = userState.user;
                  //log('Utilisateur chargé: ${user?.toString()}');
                  break;

                case UserStatus.error:
                  // Gérer les erreurs
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          userState.errorMessage ?? 'Erreur de chargement'),
                    ),
                  );
                  break;

                default:
                  break;
              }
            },
          ),
          BlocListener<RideConfirmationBloc, RideConfirmationState>(
            listener: (context, state) {
              if (state is TrackingStarted) {
                Navigator.of(context).pop();
                PlatformBottomSheet.show(
                    initialChildSize: 0.6,
                    maxChildSize: 0.6,
                    minChildSize: 0.4,
                    context: context,
                    child: RideTrackingDriverScreen(
                      driver: state.driver,
                      rideRequest: state.rideRequest,
                    ));
              }
              if (state is FullRideStarted) {
                // context.read<MapBloc>().add(
                //       FullRideStartedInMap(
                //         driver: state.driver,
                //         rideRequest: state.rideRequest,
                //       ),
                //     );
                // Navigator.of(context).pop();
                PlatformBottomSheet.show(
                    initialChildSize: 0.6,
                    maxChildSize: 0.6,
                    minChildSize: 0.4,
                    context: context,
                    child: RideFullCourseScreen(
                      ride: state.rideRequest,
                      driver: state.driver,
                    ));
              }
              if (state is NoDriversFound) {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => AlertDialog(
                    title: const Text('Aucun chauffeur disponible'),
                    content: Text(state.reason),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Ferme le dialog
                          Navigator.of(context)
                              .pop(); // Retourne à l'écran précédent
                        },
                        child: const Text('Retour'),
                      ),
                    ],
                  ),
                );
              }
            },
          )
        ],
        child: _buildScreen(
          context,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      showNavigationBar: false,
      body: _buildM(context),
    );
  }
}
