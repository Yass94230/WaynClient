import 'package:wayn/features/map/data/models/vehicule_prices.dart';

class RidePriceCalculator {
  final double distanceKm; // en km
  final int durationMinutes; // en minutes
  final VehiclePrices prices;

  RidePriceCalculator({
    required this.distanceKm,
    required this.durationMinutes,
    required this.prices,
  });

  double calculate() {
    // Calculer le coût de la distance
    final distanceCost = distanceKm * double.parse(prices.pricePerKm);

    // Calculer le coût du temps
    final timeCost = durationMinutes * double.parse(prices.pricePerMinute);

    // Prix total = prise en charge + coût distance + coût temps
    double totalPrice =
        double.parse(prices.pickupFee) + distanceCost + timeCost;

    // Vérifier si le prix est supérieur au minimum
    if (totalPrice < double.parse(prices.minimumPrice)) {
      totalPrice = double.parse(prices.minimumPrice);
    }

    // Arrondir à 2 décimales
    return double.parse(totalPrice.toStringAsFixed(2));
  }

  String formatPrice() {
    return '${calculate().toStringAsFixed(2)} €';
  }
}
