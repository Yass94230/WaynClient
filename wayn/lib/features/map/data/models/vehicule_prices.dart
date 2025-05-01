class VehiclePrices {
  final String pricePerKm; // PrixAuKM
  final String pickupFee; // PriseEnCharge
  final String minimumPrice; // PrixMinimum
  final String pricePerMinute; // PrixParMinute
  final String vehicleType; // "berline" ou "van"

  VehiclePrices({
    required this.pricePerKm,
    required this.pickupFee,
    required this.minimumPrice,
    required this.pricePerMinute,
    required this.vehicleType,
  });

  // Convertir les prix en double pour les calculs
  double get pricePerKmValue => double.parse(pricePerKm);
  double get pickupFeeValue => double.parse(pickupFee);
  double get minimumPriceValue => double.parse(minimumPrice);
  double get pricePerMinuteValue => double.parse(pricePerMinute);

  factory VehiclePrices.fromFirestore(Map<String, dynamic> data, String type) {
    return VehiclePrices(
      pricePerKm: data['PrixAuKM'] as String,
      pickupFee: data['PriseEnCharge'] as String,
      minimumPrice: data['PrixMinimum'] as String,
      pricePerMinute: data['PrixParMinute'] as String,
      vehicleType: type,
    );
  }
}
