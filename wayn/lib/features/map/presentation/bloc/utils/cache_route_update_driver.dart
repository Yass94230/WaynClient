class ETACacheEntry {
  final int eta;
  final DateTime timestamp;

  const ETACacheEntry({
    required this.eta,
    required this.timestamp,
  });

  /// Vérifie si l'entrée du cache est encore valide
  bool isValid({int maxAgeSeconds = 30}) {
    return DateTime.now().difference(timestamp).inSeconds < maxAgeSeconds;
  }

  /// Crée une nouvelle entrée avec l'horodatage actuel
  factory ETACacheEntry.now({
    required int eta,
  }) {
    return ETACacheEntry(
      eta: eta,
      timestamp: DateTime.now(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ETACacheEntry &&
          runtimeType == other.runtimeType &&
          eta == other.eta &&
          timestamp == other.timestamp;

  @override
  int get hashCode => eta.hashCode ^ timestamp.hashCode;

  @override
  String toString() => 'ETACacheEntry(eta: $eta, timestamp: $timestamp)';

  /// Crée une copie de l'entrée avec des valeurs potentiellement modifiées
  ETACacheEntry copyWith({
    int? eta,
    DateTime? timestamp,
  }) {
    return ETACacheEntry(
      eta: eta ?? this.eta,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
