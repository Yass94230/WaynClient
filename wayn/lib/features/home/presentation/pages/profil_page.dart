import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wayn/features/authentification/presentation/cubits/user_cubit.dart';
import 'package:wayn/features/home/presentation/pages/favorites_addresse_page.dart';
import 'package:wayn/features/home/presentation/pages/profil_info_page.dart';
import 'package:wayn/features/home/presentation/widgets/platform_list.dart';
import 'package:wayn/features/home/presentation/widgets/platform_scaffold.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      showNavigationBar: true,
      title: 'Profil',
      backgroundColor: Colors.white,
      body: BlocBuilder<UserCubit, UserState>(
        builder: (context, state) {
          if (state.isLoading || state.isRefreshing) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == UserStatus.error) {
            return Center(
              child: Text(state.errorMessage ?? 'Une erreur est survenue'),
            );
          }

          if (state.user == null) {
            return const Center(child: Text('Aucun utilisateur trouvé'));
          }

          return SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    // Photo de profil
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey[200],
                      ),
                      child: Icon(
                        Icons.person,
                        size: 50,
                        color: Colors.grey[400],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Nom complet de l'utilisateur
                    Text(
                      '${state.user!.firstName} ${state.user!.lastName}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // Email de l'utilisateur si disponible
                    if (state.user!.email != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        state.user!.email!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                    const SizedBox(height: 32),
                    // Liste des options
                    _buildOptionTile(
                      icon: Icons.person_outline,
                      title: 'Informations personnelles',
                      onPress: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProfileInfoScreen(),
                        ),
                      ),
                    ),
                    _buildOptionTile(
                      icon: Icons.location_on_outlined,
                      title: 'Adresses favoris',
                      onPress: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FavoriteAddressesScreen(),
                        ),
                      ),
                    ),
                    // _buildOptionTile(
                    //   icon: Icons.credit_card_outlined,
                    //   title: 'Moyens de paiement',
                    //   onPress: () {},
                    // ),
                    // _buildOptionTile(
                    //   icon: Icons.local_offer_outlined,
                    //   title: 'Codes promotionnels',
                    //   onPress: () {},
                    // ),
                    // _buildOptionTile(
                    //   icon: Icons.receipt_long_outlined,
                    //   title: 'Activité',
                    //   onPress: () {},
                    // ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required Function() onPress,
  }) {
    return PlatformListTile(
      onTap: onPress,
      title: title,
      leading: const Icon(
        Icons.chevron_right,
        color: Colors.black54,
      ),
    );
  }
}
