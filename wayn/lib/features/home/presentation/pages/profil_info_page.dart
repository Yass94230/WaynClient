import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wayn/features/authentification/presentation/cubits/user_cubit.dart';
import 'package:wayn/features/home/presentation/widgets/platform_dialog.dart';
import 'package:wayn/features/home/presentation/widgets/platform_scaffold.dart';

class ProfileInfoScreen extends StatelessWidget {
  const ProfileInfoScreen({super.key});

  Future<void> _editField(
      BuildContext context, String field, String currentValue) async {
    String title;
    String? hintText;
    TextInputType keyboardType = TextInputType.text;
    bool obscureText = false;

    switch (field) {
      case 'firstName':
        title = 'Modifier le prénom';
        hintText = 'Entrez votre prénom';
        break;
      case 'lastName':
        title = 'Modifier le nom';
        hintText = 'Entrez votre nom';
        break;
      case 'email':
        title = 'Modifier l\'email';
        hintText = 'Entrez votre email';
        keyboardType = TextInputType.emailAddress;
        break;
      case 'phoneNumber':
        title = 'Modifier le numéro';
        hintText = 'Entrez votre numéro';
        keyboardType = TextInputType.phone;
        break;
      case 'password':
        title = 'Modifier le mot de passe';
        hintText = 'Entrez votre nouveau mot de passe';
        obscureText = true;
        break;
      default:
        return;
    }

    final result = await PlatformDialogs.showEditDialog(
      context: context,
      title: title,
      initialValue: field == 'password' ? '' : currentValue,
      hintText: hintText,
      keyboardType: keyboardType,
      obscureText: obscureText,
    );

    if (result != null && result.isNotEmpty && context.mounted) {
      if (field != 'password') {
        context.read<UserCubit>().updateUserField(
              field: field,
              value: result,
            );
      } else {
        // TODO: Implémenter la mise à jour du mot de passe
      }
    }
  }

  Future<void> _showDeleteConfirmation(BuildContext context) async {
    final willDelete = await PlatformDialogs.showConfirmationDialog(
      context: context,
      title: 'Supprimer le compte',
      message:
          'Êtes-vous sûr de vouloir supprimer votre compte ? Cette action est irréversible.',
      confirmText: 'Supprimer',
      cancelText: 'Annuler',
      isDangerous: true,
    );

    if (willDelete && context.mounted) {
      // TODO: Implémenter la suppression du compte
    }
  }

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      showNavigationBar: true,
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

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Center(
                    child: Stack(
                      children: [
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
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.blue,
                            ),
                            child: const Icon(
                              Icons.add,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildInfoField(
                    label: 'Prénom',
                    value: state.user!.firstName,
                    onEdit: () =>
                        _editField(context, 'firstName', state.user!.firstName),
                  ),
                  _buildInfoField(
                    label: 'Nom',
                    value: state.user!.lastName,
                    onEdit: () =>
                        _editField(context, 'lastName', state.user!.lastName),
                  ),
                  if (state.user!.email != null)
                    _buildInfoField(
                      label: 'E-mail',
                      value: state.user!.email!,
                      onEdit: () =>
                          _editField(context, 'email', state.user!.email!),
                    ),
                  _buildInfoField(
                    label: 'Téléphone',
                    value: state.user!.phoneNumber,
                    onEdit: () => _editField(
                        context, 'phoneNumber', state.user!.phoneNumber),
                  ),
                  _buildInfoField(
                    label: 'Mot de passe',
                    value: '••••••••',
                    onEdit: () => _editField(context, 'password', ''),
                  ),
                  const SizedBox(height: 48),
                  TextButton.icon(
                    onPressed: () => _showDeleteConfirmation(context),
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.red,
                    ),
                    label: const Text(
                      'Supprimer mon compte',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoField({
    required String label,
    required String value,
    required VoidCallback onEdit,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
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
          Container(
            height: 1,
            color: Colors.grey[300],
          ),
        ],
      ),
    );
  }
}
