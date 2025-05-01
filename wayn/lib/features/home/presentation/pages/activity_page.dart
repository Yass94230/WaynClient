import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wayn/features/authentification/presentation/cubits/user_cubit.dart';
import 'package:wayn/features/home/presentation/widgets/platform_scaffold.dart';

class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      showNavigationBar: true,
      title: 'Activité',
      backgroundColor: Colors.white,
      body: BlocBuilder<UserCubit, UserState>(
        builder: (context, userState) {
          if (userState.status == UserStatus.loaded && userState.user != null) {
            // Remplacer uniquement le contenu intérieur par un widget scrollable
            // sans utiliser Expanded
            return SafeArea(
              // Utiliser un SingleChildScrollView pour un défilement simple
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    // Column avec une taille minimale pour éviter les problèmes de layout
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 24),
                      _buildToggleButtons(),
                      const SizedBox(height: 24),
                      // Ajouter directement les RideCards ici
                      const RideCard(
                        date: "22/12/2024, 14h20",
                        startAddress:
                            "50, avenue de la Liberté, 34000 Montp...",
                        endAddress: "10, rue de la République, 34000 Montp...",
                        distance: 6.4,
                        price: 15.84,
                      ),
                      const SizedBox(height: 16),
                      const RideCard(
                        date: "22/12/2024, 14h20",
                        startAddress:
                            "50, avenue de la Liberté, 34000 Montp...",
                        endAddress: "10, rue de la République, 34000 Montp...",
                        distance: 6.4,
                        price: 15.84,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
          return const Center(child: Text('Aucune donnée disponible'));
        },
      ),
    );
  }

  Widget _buildToggleButtons() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: const Text(
                'Passées',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: const Text(
                'À venir',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RideCard extends StatelessWidget {
  final String date;
  final String startAddress;
  final String endAddress;
  final double distance;
  final double price;

  const RideCard({
    super.key,
    required this.date,
    required this.startAddress,
    required this.endAddress,
    required this.distance,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  date,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: Colors.black54,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                Column(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blue,
                      ),
                    ),
                    Container(
                      width: 2,
                      height: 30,
                      color: Colors.grey[300],
                    ),
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        startAddress,
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        endAddress,
                        style: TextStyle(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.grey[300]!),
              ),
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Course de ${distance.toStringAsFixed(1)} km',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '${price.toStringAsFixed(2)}€',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
