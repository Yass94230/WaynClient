import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wayn/features/authentification/domain/entities/user_choice_option.dart';
import 'package:wayn/features/authentification/presentation/blocs/auth_bloc.dart';
import 'package:wayn/features/authentification/presentation/widgets/auth_button.dart';
import 'package:wayn/features/home/presentation/widgets/platform_check_list_tile.dart';
import 'package:wayn/features/home/presentation/widgets/platform_radio_list_tile.dart';
import 'package:wayn/features/home/presentation/widgets/platform_scaffold.dart';
import 'package:wayn/features/home/presentation/widgets/platform_snackbar.dart';
import 'package:wayn/features/home/presentation/widgets/platform_text_field.dart';
import 'package:wayn/features/map/presentation/pages/map_screen.dart';

class RegistrationInfoScreen extends StatefulWidget {
  const RegistrationInfoScreen({super.key});

  @override
  State<RegistrationInfoScreen> createState() => _RegistrationInfoScreenState();
}

class _RegistrationInfoScreenState extends State<RegistrationInfoScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  String _selectedGender = '';
  List<UserChoiceOption> _userChoiceOption = [];

  void _updateSubscriptionOptions() {
    if (_selectedGender == 'femme') {
      _userChoiceOption = SubscriptionOptionsManager.getFemaleOptions();
    } else if (_selectedGender == 'homme') {
      _userChoiceOption = SubscriptionOptionsManager.getMaleOptions();
    } else {
      _userChoiceOption = [];
    }
    setState(() {});
  }

  Widget _buildSubscriptionOptions(double screenWidth, double screenHeight) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choisissez vos options  :',
          style: TextStyle(
            fontSize: screenWidth * 0.035,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: screenHeight * 0.012),
        ..._userChoiceOption.map((option) => Container(
              margin: EdgeInsets.only(bottom: screenHeight * 0.012),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(screenWidth * 0.02),
                border: option.isSelected
                    ? Border.all(color: Colors.black, width: 2)
                    : null,
              ),
              child: PlatformCheckboxListTile(
                title: option.title,
                value: option.isSelected,
                onChanged: (bool? value) {
                  if (value == true) {
                    if (!SubscriptionOptionsManager.canSelect(
                        option, _userChoiceOption)) {
                      PlatformSnackbar.show(
                        context: context,
                        message:
                            'Cette option n\'est pas compatible avec vos autres sélections',
                      );

                      return;
                    }
                    if (_userChoiceOption.where((o) => o.isSelected).length >=
                        2) {
                      PlatformSnackbar.show(
                        context: context,
                        message:
                            'Vous ne pouvez sélectionner que 2 options maximum',
                      );
                      ;
                      return;
                    }
                  }
                  setState(() {
                    option.isSelected = value ?? false;
                  });
                },
              ),
            )),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required String label,
    TextInputType? keyboardType,
    required double screenWidth,
    required double screenHeight,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: screenWidth * 0.035,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: screenHeight * 0.01),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.04,
            vertical: screenHeight * 0.025,
          ),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(screenWidth * 0.01),
          ),
          child: PlatformTextField(
            read: false,
            controller: controller,
            keyboardType: keyboardType,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
    final safePaddingBottom = MediaQuery.of(context).padding.bottom;

    return PlatformScaffold(
      showNavigationBar: true,
      title: 'Inscription',
      body: SafeArea(
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is ProfileCompleted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const MapScreen()),
              );
            } else if (state is AuthError) {
              PlatformSnackbar.show(
                context: context,
                message: state.message,
              );
            }
          },
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // SizedBox(height: screenHeight * 0.05),

                        SizedBox(height: screenHeight * 0.05),
                        Text(
                          'Entrez vos informations',
                          style: TextStyle(
                            fontSize: screenWidth * 0.045,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.040),
                        Text(
                          'Je suis :',
                          style: TextStyle(
                            fontSize: screenWidth * 0.040,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.012),

                        // Options de genre
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius:
                                      BorderRadius.circular(screenWidth * 0.01),
                                ),
                                child: PlatformRadioListTile<String>(
                                  value: 'femme',
                                  groupValue: _selectedGender,
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedGender = value.toString();
                                    });
                                    _updateSubscriptionOptions(); // Ajoutez cet appel ici
                                  },
                                  title: 'une femme',
                                ),
                              ),
                            ),
                            SizedBox(width: screenWidth * 0.025),
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius:
                                      BorderRadius.circular(screenWidth * 0.01),
                                ),
                                child: PlatformRadioListTile<String>(
                                  value: 'homme',
                                  groupValue: _selectedGender,
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedGender = value.toString();
                                    });
                                    _updateSubscriptionOptions(); // Ajoutez cet appel ici
                                  },
                                  title: 'un homme',
                                ),
                              ),
                            ),
                          ],
                        ),

                        if (_selectedGender.isNotEmpty) ...[
                          SizedBox(height: screenHeight * 0.025),
                          _buildSubscriptionOptions(screenWidth, screenHeight),
                        ],

                        SizedBox(height: screenHeight * 0.025),

                        // Champs de texte
                        _buildTextField(
                          controller: _firstNameController,
                          hintText: 'Entrez votre prénom',
                          label: 'Prénom',
                          screenWidth: screenWidth,
                          screenHeight: screenHeight,
                        ),
                        SizedBox(height: screenHeight * 0.025),
                        _buildTextField(
                          controller: _lastNameController,
                          hintText: 'Entrez votre nom',
                          label: 'Nom',
                          screenWidth: screenWidth,
                          screenHeight: screenHeight,
                        ),
                        SizedBox(height: screenHeight * 0.025),
                        _buildTextField(
                          controller: _emailController,
                          hintText: 'Entrez votre e-mail',
                          label: 'E-mail',
                          keyboardType: TextInputType.emailAddress,
                          screenWidth: screenWidth,
                          screenHeight: screenHeight,
                        ),

                        SizedBox(
                            height: isKeyboardOpen
                                ? screenHeight * 0.03
                                : screenHeight * 0.05),
                      ],
                    ),
                  ),
                ),
              ),

              // Bouton Continuer
              Padding(
                padding: EdgeInsets.only(
                  left: screenWidth * 0.05,
                  right: screenWidth * 0.05,
                  bottom: safePaddingBottom + screenHeight * 0.02,
                  top: screenHeight * 0.02,
                ),
                child: AuthButton(
                  text: 'Continuer',
                  color: Colors.blue,
                  textColor: Colors.white,
                  onPressed: () {
                    if (_validateInputs()) {
                      context.read<AuthBloc>().add(
                            CompleteUserProfile(
                              uid: FirebaseAuth.instance.currentUser!.uid,
                              firstName: _firstNameController.text,
                              lastName: _lastNameController.text,
                              email: _emailController.text,
                              gender: _selectedGender,
                              choices: _userChoiceOption
                                  .where((option) => option.isSelected)
                                  .map((option) => option.title)
                                  .toList(),
                            ),
                          );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _validateInputs() {
    if (_firstNameController.text.isEmpty ||
        _lastNameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _selectedGender.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs')),
      );
      return false;
    }

    final selectedOptionsCount =
        _userChoiceOption.where((option) => option.isSelected).length;
    if (selectedOptionsCount == 0) {
      PlatformSnackbar.show(
        context: context,
        message: 'Veuillez sélectionner au moins un abonnement',
      );

      return false;
    }

    if (!_emailController.text.contains('@')) {
      PlatformSnackbar.show(
        context: context,
        message: 'Email invalide',
      );

      return false;
    }
    return true;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}
