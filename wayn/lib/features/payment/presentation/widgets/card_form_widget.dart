import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get_it/get_it.dart';
import 'package:wayn/features/home/presentation/widgets/platform_button.dart';
import 'package:wayn/features/home/presentation/widgets/platform_scaffold.dart';
import 'package:wayn/features/home/presentation/widgets/platform_snackbar.dart';
import 'package:wayn/features/home/presentation/widgets/platform_text_field.dart';
import 'package:wayn/features/payment/presentation/blocs/payment_bloc.dart';

class CardForm extends StatefulWidget {
  final bool isCupertino;
  final double amount;

  const CardForm({
    super.key,
    this.isCupertino = false,
    required this.amount,
  });

  @override
  CardFormState createState() => CardFormState();
}

class CardFormState extends State<CardForm> {
  final _nameController = TextEditingController();
  final String _selectedCountry = 'France';
  bool _isComplete = false;
  bool _isLoading = false;
  late final CardFormEditController controller;
  CardFieldInputDetails? _cardFieldInputDetails;
  late final PaymentBloc _paymentBloc;

  @override
  void initState() {
    super.initState();
    controller = CardFormEditController();
    _paymentBloc = GetIt.I<PaymentBloc>();
  }

  // Dans CardFormState
  Future<void> _handleSaveCard() async {
    if (!_isComplete || _cardFieldInputDetails == null) {
      PlatformSnackbar.show(
        context: context,
        message: 'Veuillez remplir tous les champs correctement',
        backgroundColor: Colors.red,
      );
      return;
    }

    // Important: assurez-vous que le formulaire est valide
    if (!controller.details.complete) {
      PlatformSnackbar.show(
        context: context,
        message: 'Formulaire incomplet. Veuillez vérifier vos informations.',
        backgroundColor: Colors.red,
      );
      return;
    }

    try {
      setState(() => _isLoading = true);

      _paymentBloc.add(
        SaveCardEvent(
          name: _nameController.text,
          country: _selectedCountry,
          cardDetails: _cardFieldInputDetails!,
        ),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      PlatformSnackbar.show(
        context: context,
        message: 'Erreur: $e',
        backgroundColor: Colors.red,
      );
    }
  }

  Widget _buildCardFormField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Numéro de carte',
          style: TextStyle(
            fontSize: 14,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        CardFormField(
            enablePostalCode: false,
            controller: controller,
            style: CardFormStyle(
              textColor: Colors.black,
              textErrorColor: Colors.red,
              placeholderColor: Colors.grey[400],
              backgroundColor: const Color(0xFFF3F4F6),
              borderRadius: 8,
              borderColor: Colors.transparent,
              borderWidth: 0,
              fontSize: 16,
            ),
            onCardChanged: (details) {
              setState(() {
                log('Card changed: ${details?.complete}');
                _cardFieldInputDetails = details;
                _isComplete = details?.complete ?? false;
              });
            }),
      ],
    );
  }

  Widget _buildNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Nom sur la carte',
          style: TextStyle(
            fontSize: 14,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(8),
          ),
          child: PlatformTextField(
            read: false,
            controller: _nameController,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      backgroundColor: Colors.white,
      showNavigationBar: true,
      title: 'Ajouter une carte',
      body: BlocListener<PaymentBloc, PaymentState>(
        listener: (context, state) {
          if (state is PaymentLoading) {
            setState(() => _isLoading = true);
          } else if (state is CardSaved) {
            // Nouvel état pour la carte sauvegardée
            setState(() => _isLoading = false);
            PlatformSnackbar.show(
              context: context,
              message: 'Carte enregistrée avec succès !',
              backgroundColor: Colors.green,
            );

            Navigator.of(context).pop(true);
          } else if (state is PaymentError) {
            setState(() => _isLoading = false);
            PlatformSnackbar.show(
              context: context,
              message: 'Erreur: ${state.message}',
              backgroundColor: Colors.red,
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCardFormField(),
              const SizedBox(height: 24),
              _buildNameField(),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: PlatformButton(
                  onPressed: _isLoading || !_isComplete
                      ? null
                      : () {
                          _handleSaveCard();
                        },
                  text: 'Enregistrer la carte',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }
}
