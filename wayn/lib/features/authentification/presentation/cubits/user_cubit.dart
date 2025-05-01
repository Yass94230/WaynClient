// features/authentication/presentation/cubits/user_cubit.dart

import 'dart:developer';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wayn/features/authentification/data/datasources/firebase/firebase_auth_service.dart';
import 'package:wayn/features/authentification/data/datasources/local/user_local_storage.dart';
import 'package:wayn/features/authentification/domain/entities/user.dart';
import 'package:wayn/features/authentification/domain/usecases/get_user_usecase.dart';
import 'package:wayn/features/authentification/domain/usecases/refresh_user_usecase.dart';
import 'package:wayn/features/authentification/data/models/user_model.dart';

part 'user_state.dart';

class UserCubit extends Cubit<UserState> {
  final GetUserUseCase _getUserUseCase;
  final RefreshUserUseCase _refreshUserUseCase;
  final FirebaseAuthService _firebaseAuthService;
  final UserLocalStorage _localStorage;

  UserCubit(
    this._getUserUseCase,
    this._refreshUserUseCase,
    this._firebaseAuthService,
    this._localStorage,
  ) : super(const UserState()) {
    log('UserCubit initialisé');
  }

  Future<void> getUser() async {
    log('UserCubit: Début getUser()');
    emit(state.copyWith(status: UserStatus.loading));

    try {
      final user = await _getUserUseCase.execute();
      log('UserCubit: Données utilisateur reçues: ${user?.id}');

      if (user != null) {
        emit(state.copyWith(
          status: UserStatus.loaded,
          user: user,
        ));
        log('UserCubit: État mis à jour avec les données utilisateur');
      } else {
        emit(state.copyWith(
          status: UserStatus.error,
          errorMessage: 'User not found',
        ));
        log('UserCubit: Utilisateur non trouvé');
      }
    } catch (e) {
      log('UserCubit: Erreur lors de la récupération de l\'utilisateur: $e');
      emit(state.copyWith(
        status: UserStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> updateCarPreferences(List<String> carPreferences) async {
    log('UserCubit: Début updateCarPreferences()');

    if (state.user == null) {
      log('UserCubit: Pas d\'utilisateur à mettre à jour');
      return;
    }

    try {
      emit(state.copyWith(status: UserStatus.refreshing));

      // Créer un nouvel utilisateur avec les préférences mises à jour
      final currentUser = state.user!;
      final updatedUser = UserModel(
        id: currentUser.id,
        email: currentUser.email,
        phoneNumber: currentUser.phoneNumber,
        firstName: currentUser.firstName,
        lastName: currentUser.lastName,
        sexe: currentUser.sexe,
        choices: currentUser.choices,
        firebaseToken: currentUser.firebaseToken,
        stripeId: currentUser.stripeId,
        carPreferences: carPreferences, // Mise à jour des préférences
        roles: currentUser.roles,
        preferedDepart: currentUser.preferedDepart,
        preferedArrival: currentUser.preferedArrival,
        createdAt: currentUser.createdAt,
      );

      // Mettre à jour dans Firestore
      await _firebaseAuthService.updateClientModeData({
        'carPreferences': carPreferences,
      });

      // Mettre à jour le cache local
      await _localStorage.cacheUser(updatedUser);

      // Émettre le nouvel état
      emit(state.copyWith(
        status: UserStatus.loaded,
        user: updatedUser,
      ));

      log('UserCubit: Préférences de voiture mises à jour avec succès');
    } catch (e) {
      log('UserCubit: Erreur lors de la mise à jour des préférences: $e');
      emit(state.copyWith(
        status: UserStatus.error,
        errorMessage: 'Erreur lors de la mise à jour des préférences: $e',
      ));
    }
  }

  Future<void> updateUserField({
    required String field,
    required String value,
  }) async {
    if (state.user == null) return;

    try {
      emit(state.copyWith(status: UserStatus.refreshing));

      final currentUser = state.user!;

      // Créer un Map avec uniquement le champ à mettre à jour
      final Map<String, dynamic> updateData = {
        field: value,
      };

      // Mettre à jour dans Firestore uniquement ce champ
      await _firebaseAuthService.updateClientModeData(updateData);

      // Créer un nouveau UserModel en ne modifiant que le champ concerné
      final updatedUser = UserModel(
        id: currentUser.id,
        email: field == 'email' ? value : currentUser.email,
        phoneNumber: field == 'phoneNumber' ? value : currentUser.phoneNumber,
        firstName: field == 'firstName' ? value : currentUser.firstName,
        lastName: field == 'lastName' ? value : currentUser.lastName,
        sexe: field == 'sexe' ? value : currentUser.sexe,
        choices: currentUser.choices,
        firebaseToken: currentUser.firebaseToken,
        stripeId: currentUser.stripeId,
        carPreferences: currentUser.carPreferences,
        roles: currentUser.roles,
        preferedDepart:
            field == 'preferedDepart' ? value : currentUser.preferedDepart,
        preferedArrival:
            field == 'preferedArrival' ? value : currentUser.preferedArrival,
        createdAt:
            currentUser.createdAt, // Important pour la validation du cache
      );

      // Mettre à jour le cache local
      await _localStorage.cacheUser(updatedUser);

      // Émettre le nouvel état
      emit(state.copyWith(
        status: UserStatus.loaded,
        user: updatedUser,
      ));

      log('UserCubit: Champ $field mis à jour avec succès dans Firestore et le cache local');
    } catch (e) {
      log('UserCubit: Erreur lors de la mise à jour du champ $field: $e');
      emit(state.copyWith(
        status: UserStatus.error,
        errorMessage: 'Erreur lors de la mise à jour: $e',
      ));
    }
  }
}
