import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wayn/features/authentification/presentation/cubits/user_cubit.dart';
import 'package:wayn/features/home/presentation/widgets/platform_dialog.dart';
import 'package:wayn/features/home/presentation/widgets/platform_scaffold.dart';

class FavoriteAddressesScreen extends StatelessWidget {
  const FavoriteAddressesScreen({super.key});

  Future<void> _editAddress(
      BuildContext context, String type, String currentAddress) async {
    String title;
    switch (type) {
      case 'preferedDepart':
        title = 'Modifier l\'adresse de départ';
        break;
      case 'preferedArrival':
        title = 'Modifier l\'adresse d\'arrivée';
        break;
      default:
        title = 'Modifier l\'adresse';
    }

    final result = await PlatformDialogs.showEditDialog(
      context: context,
      title: title,
      initialValue: currentAddress,
      hintText: 'Entrez l\'adresse',
    );

    if (result != null && result.isNotEmpty && context.mounted) {
      context.read<UserCubit>().updateUserField(
            field: type,
            value: result,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      showNavigationBar: true,
      title: 'Adresses favorites',
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

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildAddressItem(
                  title: 'Domicile',
                  address: state.user!.preferedDepart ?? 'Non défini',
                  onEdit: () => _editAddress(
                    context,
                    'preferedDepart',
                    state.user!.preferedDepart ?? '',
                  ),
                ),
                const SizedBox(height: 8),
                _buildAddressItem(
                  title: 'Travail',
                  address: state.user!.preferedArrival ?? 'Non défini',
                  onEdit: () => _editAddress(
                    context,
                    'preferedArrival',
                    state.user!.preferedArrival ?? '',
                  ),
                ),
                const SizedBox(height: 16),
                // Bouton Ajouter une adresse
                InkWell(
                  onTap: () => _showAddAddressDialog(context),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add,
                          color: Colors.grey[800],
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Ajouter une adresse',
                          style: TextStyle(
                            color: Colors.grey[800],
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _showAddAddressDialog(BuildContext context) async {
    final result = await PlatformDialogs.showConfirmationDialog(
      context: context,
      title: 'Type d\'adresse',
      message: 'Quel type d\'adresse souhaitez-vous ajouter ?',
      confirmText: 'Arrivée',
      cancelText: 'Départ',
    );

    if (context.mounted) {
      if (result) {
        // Adresse d'arrivée
        _editAddress(context, 'preferedArrival', '');
      } else {
        // Adresse de départ
        _editAddress(context, 'preferedDepart', '');
      }
    }
  }

  Widget _buildAddressItem({
    required String title,
    required String address,
    required VoidCallback onEdit,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.bookmark_outline,
            color: Colors.black87,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  address,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.edit,
              size: 20,
              color: Colors.black87,
            ),
            onPressed: onEdit,
          ),
        ],
      ),
    );
  }
}
