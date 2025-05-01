import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wayn/features/authentification/presentation/cubits/user_cubit.dart';
import 'package:wayn/features/home/presentation/widgets/platform_scaffold.dart';

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  void _updateCarPreference(String carType, UserState state) {
    context.read<UserCubit>().updateCarPreferences([carType]);
  }

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
        showNavigationBar: true,
        title: 'Préférences',
        backgroundColor: Colors.white,
        body: BlocBuilder<UserCubit, UserState>(
          builder: (context, userState) {
            log('userState: $userState');
            if (userState.status == UserStatus.loading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else if (userState.status == UserStatus.refreshing ||
                userState.status == UserStatus.refreshing) {
              return const Center(child: CircularProgressIndicator());
            } else if (userState.status == UserStatus.error) {
              return const Center(
                child: Text('Erreur lors du chargement des préférences'),
              );
            } else if (userState.status == UserStatus.loaded &&
                userState.user != null) {
              final carPreferences = userState.user!.carPreferences ?? [];
              final selectedCar =
                  carPreferences.isNotEmpty ? carPreferences.first : null;
              return SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      const Text(
                        'Options',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildOptionTile(
                        'assets/berline.png',
                        'Berline',
                        selectedCar == 'Berline',
                        () => _updateCarPreference('Berline', userState),
                      ),
                      const SizedBox(height: 8),
                      _buildOptionTile(
                        'assets/van.png',
                        'Van',
                        selectedCar == 'Van',
                        () => _updateCarPreference('Van', userState),
                      ),
                      const SizedBox(height: 32),
                      const Text(
                        'Adresses favoris',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildAddressTile(
                        'Domicile',
                        userState.user!.preferedDepart ?? 'Non défini',
                      ),
                      const SizedBox(height: 8),
                      _buildAddressTile(
                        'Travail',
                        userState.user!.preferedArrival ?? 'Non défini',
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () {},
                        child: const Text(
                          'Voir plus',
                          style: TextStyle(
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            return const Center(child: Text('Aucune donnée disponible'));
          },
        ));
  }

  Widget _buildOptionTile(
      String imagePath, String title, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 40,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(imagePath),
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            if (isSelected)
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue,
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 16,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressTile(String title, String address) {
    return Row(
      children: [
        const Icon(
          Icons.bookmark_border,
          color: Colors.black54,
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              address,
              style: const TextStyle(
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
