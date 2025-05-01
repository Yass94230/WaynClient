import 'package:wayn/features/authentification/domain/entities/user.dart';

class UserModel extends User {
  UserModel({
    required super.id,
    super.email,
    required super.phoneNumber,
    required super.firstName,
    required super.lastName,
    required super.sexe,
    required super.choices,
    super.createdAt,
    super.preferedDepart,
    super.preferedArrival,
    required super.firebaseToken,
    required super.stripeId,
    super.carPreferences,
    super.roles,
  });

  // Méthode modifiée pour récupérer toutes les infos personnelles depuis les données client
  factory UserModel.fromFirestoreWithClientMode(Map<String, dynamic> userData,
      Map<String, dynamic>? clientData, String id) {
    // Utiliser les données du profil client pour toutes les informations personnelles
    return UserModel(
      id: id,
      // Informations personnelles provenant uniquement du profil client
      email: clientData?['email'] ?? '',
      firstName: clientData?['firstName'] ?? '',
      lastName: clientData?['lastName'] ?? '',
      sexe: clientData?['gender'] ?? '',
      choices: List<String>.from(clientData?['choices'] ?? []),

      // Informations communes provenant du document principal
      phoneNumber: userData['phoneNumber'] ?? '',
      createdAt: userData['createdAt']?.toString(),
      firebaseToken: userData['firebaseToken'] ?? '',
      stripeId: userData['stripeId'] ?? '',

      // Données spécifiques au client
      preferedDepart: clientData?['preferedDepart'],
      preferedArrival: clientData?['preferedArrival'],
      carPreferences: List<String>.from(clientData?['carPreferences'] ?? []),

      // Détermine les rôles uniquement basés sur l'existence des données client
      roles: _determineRoles(clientData),
    );
  }

  // Méthode originale maintenue pour la compatibilité
  factory UserModel.fromFirestore(Map<String, dynamic> data, String id) {
    return UserModel(
      id: id,
      email: data['email'],
      phoneNumber: data['phoneNumber'] ?? '',
      firstName: data['firstName'] ?? '',
      lastName: data['lastName'] ?? '',
      sexe: data['sexe'] ?? '',
      choices: List<String>.from(data['choices'] ?? []),
      createdAt: data['createdAt']?.toString(),
      preferedDepart: data['preferedDepart'],
      preferedArrival: data['preferedArrival'],
      firebaseToken: data['firebaseToken'] ?? '',
      stripeId: data['stripeId'] ?? '',
      carPreferences: List<String>.from(data['carPreferences'] ?? []),
      roles: [],
    );
  }

  // Méthode simplifiée pour déterminer les rôles - basée uniquement sur les données client
  static List<String> _determineRoles(Map<String, dynamic>? clientData) {
    List<String> roles = [];

    // Si nous avons des données client, nous avons le rôle client
    if (clientData != null) {
      roles.add('client');
    }

    return roles;
  }

  // Ne map que les informations communes
  Map<String, dynamic> toMap() {
    return {
      'phoneNumber': phoneNumber,
      'createdAt': createdAt,
      'firebaseToken': firebaseToken,
      'stripeId': stripeId,
    };
  }

  // Génère les données pour le profil client avec toutes les informations personnelles
  Map<String, dynamic> toClientModeMap() {
    return {
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'gender': sexe,
      'choices': choices,
      'preferedDepart': preferedDepart,
      'preferedArrival': preferedArrival,
      'carPreferences': carPreferences,
      'isProfileCompleted': true,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? phoneNumber,
    String? firstName,
    String? lastName,
    String? sexe,
    List<String>? choices,
    String? createdAt,
    String? preferedDepart,
    String? preferedArrival,
    List<String>? recentTrips,
    double? rating,
    List<String>? carPreferences,
    List<String>? roles,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      sexe: sexe ?? this.sexe,
      choices: choices ?? this.choices,
      createdAt: createdAt ?? this.createdAt,
      preferedDepart: preferedDepart ?? this.preferedDepart,
      preferedArrival: preferedArrival ?? this.preferedArrival,
      firebaseToken: firebaseToken,
      stripeId: stripeId,
      carPreferences: this.carPreferences,
      roles: roles ?? this.roles,
    );
  }
}
