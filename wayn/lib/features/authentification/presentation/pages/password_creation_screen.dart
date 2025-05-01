import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wayn/features/authentification/presentation/blocs/auth_bloc.dart';
import 'package:wayn/features/authentification/presentation/pages/registration_information_screen.dart';
import 'package:wayn/features/authentification/presentation/widgets/auth_button.dart';
import 'package:wayn/features/home/presentation/widgets/platform_scaffold.dart';
import 'package:wayn/features/home/presentation/widgets/platform_snackbar.dart';
import 'package:wayn/features/home/presentation/widgets/platform_text_field.dart';

class PasswordCreationScreen extends StatelessWidget {
  final String phoneNumber;

  PasswordCreationScreen({
    super.key,
    required this.phoneNumber,
  });

  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool _validatePasswords() {
    if (passwordController.text.length < 6) {
      return false;
    }
    return passwordController.text == confirmPasswordController.text;
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;
    final safePaddingBottom = MediaQuery.of(context).padding.bottom;

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AccountCreated) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const RegistrationInfoScreen(),
            ),
            (route) => false,
          );
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        return PlatformScaffold(
          showNavigationBar: true,
          title: 'Inscription',
          body: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.05,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          SizedBox(height: screenHeight * 0.05),
                          Text(
                            'Créez votre mot de passe',
                            style: TextStyle(
                              fontSize: screenWidth * 0.04,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.035),

                          // Premier champ de mot de passe
                          Container(
                            padding: EdgeInsets.symmetric(
                              vertical: screenHeight * 0.015,
                              horizontal: screenWidth * 0.04,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius:
                                  BorderRadius.circular(screenWidth * 0.01),
                            ),
                            child: PlatformTextField(
                              read: false,
                              controller: passwordController,
                              obscureText: true,
                            ),
                          ),

                          SizedBox(height: screenHeight * 0.02),

                          // Deuxième champ de mot de passe
                          Container(
                            padding: EdgeInsets.symmetric(
                              vertical: screenHeight * 0.015,
                              horizontal: screenWidth * 0.04,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius:
                                  BorderRadius.circular(screenWidth * 0.01),
                            ),
                            child: PlatformTextField(
                              read: false,
                              controller: confirmPasswordController,
                              obscureText: true,
                            ),
                          ),

                          // Espace flexible qui s'adapte au clavier
                          SizedBox(
                            height: isKeyboardOpen
                                ? screenHeight * 0.02
                                : screenHeight * 0.25,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Bouton de validation en bas
                Padding(
                  padding: EdgeInsets.only(
                    left: screenWidth * 0.05,
                    right: screenWidth * 0.05,
                    bottom: safePaddingBottom + screenHeight * 0.02,
                  ),
                  child: state is AuthLoading
                      ? const Center(child: CircularProgressIndicator())
                      : AuthButton(
                          text: 'Valider',
                          color: Colors.blue,
                          textColor: Colors.white,
                          onPressed: () {
                            if (_validatePasswords()) {
                              context.read<AuthBloc>().add(
                                    CreateAccount(
                                      phoneNumber: phoneNumber,
                                      password: passwordController.text,
                                    ),
                                  );
                            } else {
                              PlatformSnackbar.show(
                                context: context,
                                message:
                                    'Les mots de passe ne correspondent pas ou sont trop courts',
                              );
                            }
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
