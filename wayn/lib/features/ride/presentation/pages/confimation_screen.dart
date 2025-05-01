import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wayn/features/authentification/domain/entities/user.dart';
import 'package:wayn/features/authentification/presentation/cubits/user_cubit.dart';
import 'package:wayn/features/core/config/size_config.dart';
import 'package:wayn/features/home/presentation/widgets/platform_scaffold.dart';
import 'package:wayn/features/home/presentation/widgets/platform_snackbar.dart';
import 'package:wayn/features/map/domain/entities/driver.dart';
import 'package:wayn/features/map/presentation/bloc/map_bloc.dart';
import 'package:wayn/features/ride/domain/entities/ride_request.dart';
import 'package:wayn/features/ride/presentation/blocs/ride_confirmation_bloc.dart';
import 'package:wayn/features/ride/presentation/blocs/ride_confirmation_event.dart';
import 'package:wayn/features/ride/presentation/blocs/ride_confirmation_state.dart';

class ConfirmationScreen extends StatelessWidget {
  final String vehicleType;
  final List<Driver> nearbyDrivers;
  final RideRequest rideRequest;

  const ConfirmationScreen({
    super.key,
    required this.vehicleType,
    required this.rideRequest,
    required this.nearbyDrivers,
  });

  @override
  Widget build(BuildContext context) {
    // Initialiser MobileAdaptive
    MobileAdaptive.init(context);

    return BlocBuilder<UserCubit, UserState>(
      builder: (context, userState) {
        log('UserState dans ConfirmationScreen: ${userState.status}');

        if (userState.user == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return _RideConfirmationContent(
          user: userState.user!,
          vehicleType: vehicleType,
          rideRequest: rideRequest,
          nearbyDrivers: nearbyDrivers,
        );
      },
    );
  }
}

class _RideConfirmationContent extends StatelessWidget {
  final User user;
  final String vehicleType;
  final List<Driver> nearbyDrivers;
  final RideRequest rideRequest;

  const _RideConfirmationContent({
    required this.user,
    required this.vehicleType,
    required this.rideRequest,
    required this.nearbyDrivers,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RideConfirmationBloc, RideConfirmationState>(
      bloc: BlocProvider.of<RideConfirmationBloc>(context)
        ..add(InitiateRideConfirmation(
          rideRequest: rideRequest,
          vehicleType: vehicleType,
          nearbyDrivers: nearbyDrivers,
          user: user,
        )),
      listener: _handleRideConfirmationState,
      builder: (context, state) {
        return _ConfirmationScreenLayout(
          state: state,
        );
      },
    );
  }

  void _handleRideConfirmationState(
      BuildContext context, RideConfirmationState state) {
    log('RideConfirmationBloc state: $state');

    if (state is NoDriversFound) {
      _showNoDriversDialog(context, state.reason);
      context.read<MapBloc>().add(BackToInitial());
    }
  }

  void _showNoDriversDialog(BuildContext context, String reason) {
    PlatformSnackbar.show(
      context: context,
      message: 'Aucun chauffeur disponible actuellement',
      duration: const Duration(seconds: 3),
    );
  }
}

class _ConfirmationScreenLayout extends StatelessWidget {
  final RideConfirmationState state;

  const _ConfirmationScreenLayout({
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    // Vérifier que MobileAdaptive est initialisé
    MobileAdaptive.init(context);

    // Détecter la plateforme
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    return PlatformScaffold(
      backgroundColor: Colors.white,
      // Ne pas utiliser SafeArea dans le body car PlatformScaffold gère déjà cela
      body: Padding(
        // Utiliser des valeurs adaptatives pour le padding
        padding: EdgeInsets.symmetric(horizontal: 24.0.w),
        child: LayoutBuilder(builder: (context, constraints) {
          // Ajuster la disposition en fonction de l'espace disponible
          final availableHeight = constraints.maxHeight;
          final headerSpace = availableHeight * 0.15;
          final vehicleSpace = availableHeight * 0.25;
          final statusSpace = availableHeight * 0.2;
          final bottomSpace = availableHeight * 0.1;

          return Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              // Espacement du haut adaptatif
              SizedBox(height: isIOS ? 20.h : 40.h),
              _buildHeader(),

              // Utiliser Expanded pour l'image du véhicule avec un ratio fixe
              Expanded(
                flex: 4,
                child: Center(child: _buildVehicleImage()),
              ),

              // Utiliser Expanded pour l'indicateur avec un ratio plus petit
              Expanded(
                flex: 2,
                child: Center(child: _buildStatusIndicator(state)),
              ),

              // Espace en bas fixe mais adaptatif
              SizedBox(height: MobileAdaptive.isSmallPhone ? 40.h : 60.h),
              _buildBottomIndicator(),
              SizedBox(height: 8.h),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildHeader() {
    return Center(
      child: Text(
        'Confirmation\nde la course',
        textAlign: TextAlign.center,
        style: TextStyle(
          // Utiliser des tailles de police adaptatives
          fontSize: 34.sp,
          fontWeight: FontWeight.bold,
          height: 1.2,
        ),
      ),
    );
  }

  Widget _buildVehicleImage() {
    // Utiliser FittedBox pour s'assurer que l'image s'adapte à l'espace disponible
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Image.asset(
        'assets/berline.png',
        // Tailles adaptatives mais contraintes pour l'image
        width: MobileAdaptive.isSmallPhone ? 250.w : 300.w,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildStatusIndicator(RideConfirmationState state) {
    if (state is SearchingDrivers) {
      return const _SearchingDriversIndicator();
    }
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildBottomIndicator() {
    return Center(
      child: Container(
        // Tailles adaptatives pour l'indicateur du bas
        width: 140.w,
        height: 5.h,
        decoration: BoxDecoration(
          color: Colors.black,
          // Rayon adaptatif
          borderRadius: BorderRadius.circular(2.5.r),
        ),
      ),
    );
  }
}

class _SearchingDriversIndicator extends StatelessWidget {
  const _SearchingDriversIndicator();

  @override
  Widget build(BuildContext context) {
    // S'assurer que MobileAdaptive est initialisé
    MobileAdaptive.init(context);

    return Container(
      // Ajouter des contraintes de largeur pour éviter les problèmes de layout
      constraints: BoxConstraints(maxWidth: MobileAdaptive.screenWidth * 0.8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Recherche en cours',
            style: TextStyle(
              // Taille de police adaptative
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          // Espacement adaptatif
          SizedBox(height: 16.h),
          // Conteneur avec largeur fixe pour l'indicateur
          Container(
            width: 200.w,
            child: SizedBox(
              // Hauteur adaptative
              height: 8.h,
              child: LinearProgressIndicator(
                backgroundColor: Colors.blue.withOpacity(0.2),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
