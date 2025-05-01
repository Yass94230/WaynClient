// lib/features/ride/domain/entities/ride_status.dart

enum RideStatus {
  created, // Course créée, pas encore en recherche de chauffeur
  searching, // En recherche de chauffeur
  accepted, // Un chauffeur a accepté la course
  started, // Le chauffeur a démarré la course (client dans le véhicule)
  completed,
  rejected, // Course terminée avec succès
  cancelled; // Course annulée (par le client ou le chauffeur)

  // Méthode pour convertir une string en RideStatus
  static RideStatus fromString(String status) {
    if (status.toLowerCase() == 'inride') {
      return RideStatus.started;
    }
    return RideStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == status.toLowerCase(),
      orElse: () => throw Exception('Invalid ride status: $status'),
    );
  }

  // Méthode pour obtenir une version lisible du statut
  String toDisplayString() {
    switch (this) {
      case RideStatus.created:
        return 'Créée';
      case RideStatus.searching:
        return 'Recherche en cours';
      case RideStatus.accepted:
        return 'Chauffeur trouvé';
      case RideStatus.started:
        return 'inRide';
      case RideStatus.completed:
        return 'Terminée';
      case RideStatus.rejected:
        return 'Rejetée';
      case RideStatus.cancelled:
        return 'Annulée';
    }
  }

  // Extensions pour faciliter les vérifications d'état
  bool get isActive =>
      this == RideStatus.accepted || this == RideStatus.started;
  bool get isTerminal =>
      this == RideStatus.completed || this == RideStatus.cancelled;
  bool get canCancel =>
      this == RideStatus.created ||
      this == RideStatus.searching ||
      this == RideStatus.accepted;

  // Méthode pour vérifier si une transition d'état est valide
  bool canTransitionTo(RideStatus newStatus) {
    switch (this) {
      case RideStatus.created:
        return newStatus == RideStatus.searching ||
            newStatus == RideStatus.cancelled;

      case RideStatus.searching:
        return newStatus == RideStatus.accepted ||
            newStatus == RideStatus.cancelled;

      case RideStatus.accepted:
        return newStatus == RideStatus.started ||
            newStatus == RideStatus.cancelled;

      case RideStatus.started:
        return newStatus == RideStatus.completed ||
            newStatus == RideStatus.cancelled;

      case RideStatus.completed:
      case RideStatus.rejected:
      case RideStatus.cancelled:
        return false; // États terminaux
    }
  }
}

// Extension pour faciliter la sérialisation
extension RideStatusX on RideStatus {
  String toJson() => name; // Utilise name au lieu de toString().split('.').last

  static RideStatus fromJson(dynamic json) {
    if (json is RideStatus) return json;
    if (json is String) return RideStatus.fromString(json);
    throw Exception('Invalid ride status format: $json');
  }
}
