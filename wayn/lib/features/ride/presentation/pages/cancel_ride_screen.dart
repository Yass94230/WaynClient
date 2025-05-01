// ignore_for_file: library_private_types_in_public_api

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wayn/features/authentification/presentation/widgets/auth_button.dart';
import 'package:wayn/features/home/presentation/widgets/platform_radio_list_tile.dart';
import 'package:wayn/features/home/presentation/widgets/platform_scaffold.dart';
import 'package:wayn/features/ride/domain/entities/ride_request.dart';
import 'package:wayn/features/ride/presentation/blocs/ride_confirmation_bloc.dart';
import 'package:wayn/features/ride/presentation/blocs/ride_confirmation_event.dart';

class CancelRideScreen extends StatefulWidget {
  final RideRequest rideRequest;

  const CancelRideScreen({super.key, required this.rideRequest});

  @override
  _CancelRideScreenState createState() => _CancelRideScreenState();
}

class _CancelRideScreenState extends State<CancelRideScreen> {
  String? selectedReason;
  final TextEditingController _commentController = TextEditingController();

  final List<String> cancellationReasons = [
    'Attente trop longue',
    'Impossible de contacter le chauffeur',
    'Le chauffeur a refusé d\'aller à la destination',
    'Le chauffeur a refusé de venir au point de prise en charge',
    'L\'état du véhicule n\'est pas satisfaisant',
  ];

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      showNavigationBar: true,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pour quelle raison ?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Si vous annulez votre course, Wayn se réserve\nle droit de vous prélever 8€.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 20),
            ...cancellationReasons.map((reason) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: PlatformRadioListTile<String>(
                    title: reason,
                    value: reason,
                    groupValue: selectedReason.toString(),
                    onChanged: (value) {
                      setState(() {
                        selectedReason = value;
                      });
                    },
                    contentPadding: EdgeInsets.zero,
                    activeColor: Colors.blue,
                  ),
                )),
            const SizedBox(height: 16),
            const Text(
              'Autre raison / Commentaire :',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                controller: _commentController,
                maxLines: 3,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(12),
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: AuthButton(
                color: Colors.blue,
                text: 'Envoyer',
                textColor: Colors.white,
                onPressed: () {
                  context.read<RideConfirmationBloc>().add(
                        CancelRideConfirmation(
                          widget.rideRequest,
                          selectedReason!,
                          _commentController.text,
                        ),
                      );
                  // Handle submission
                  log('Reason: $selectedReason');
                  log('Comment: ${_commentController.text}');
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}
