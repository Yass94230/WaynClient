import 'dart:developer';

import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:wayn/features/payment/domain/repositories/payment_repository.dart';

class SaveCard {
  final PaymentRepository repository;

  SaveCard(this.repository);

  Future<void> call({
    required String name,
    required String country,
    required CardFieldInputDetails cardDetails,
  }) async {
    try {
      log('🚀 SaveCard use case started');

      // Étape 1: Créer le SetupIntent
      log('📍 Creating SetupIntent...');
      final clientSecret = await repository.createSetupIntent();
      log('✅ SetupIntent created, clientSecret obtained');

      // Étape 2: Confirmer avec le formulaire de carte déjà rempli
      log('📍 Confirming setup...');

      // Utiliser le SDK directement sans passer cardDetails
      await Stripe.instance.confirmSetupIntent(
        paymentIntentClientSecret: clientSecret,
        params: const PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(),
        ),
      );

      log('✅ Setup confirmed successfully');
      return;
    } catch (e) {
      log('❌ Error in SaveCard: $e');
      throw Exception('Erreur lors de la sauvegarde de la carte: $e');
    }
  }
}
