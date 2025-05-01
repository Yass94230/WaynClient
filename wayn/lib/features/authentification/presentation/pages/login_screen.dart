import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wayn/features/authentification/presentation/blocs/auth_bloc.dart';
import 'package:wayn/features/authentification/presentation/pages/sms_verification_screen.dart';
import 'package:wayn/features/authentification/presentation/widgets/auth_button.dart';
import 'package:wayn/features/authentification/presentation/widgets/country_code_picker.dart';
import 'package:wayn/features/authentification/presentation/widgets/social_auth_button.dart';
import 'package:wayn/features/home/presentation/widgets/platform_scaffold.dart';
import 'package:wayn/features/home/presentation/widgets/platform_snackbar.dart';
import 'package:wayn/features/home/presentation/widgets/platform_text_field.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});

  final phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is CodeSent) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SMSVerificationScreen(
                phoneNumber: phoneController.text,
                isNewUser: false,
              ),
            ),
          );
        } else if (state is ManualVerificationRequired) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SMSVerificationScreen(
                phoneNumber: phoneController.text,
                isNewUser: false,
              ),
            ),
          );
        } else if (state is AuthError) {
          PlatformSnackbar.show(
            context: context,
            message: state.message,
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 18,
          );
        }
      },
      builder: (context, state) {
        return PlatformScaffold(
          showNavigationBar: true,
          title: 'Connexion',
          backgroundColor: Colors.white,
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
                        children: [
                          // SizedBox(height: screenHeight * 0.05),
                          // // Titre centré

                          SizedBox(height: screenHeight * 0.04),

                          // Champ de numéro de téléphone
                          Row(
                            children: [
                              CountryCode(
                                onCountryChanged: (String) {},
                              ),
                              SizedBox(width: screenWidth * 0.03),
                              Expanded(
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: screenWidth * 0.04,
                                    vertical: screenHeight * 0.015,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[50],
                                    borderRadius: BorderRadius.circular(
                                        screenWidth * 0.02),
                                  ),
                                  child: PlatformTextField(
                                    read: false,

                                    controller: phoneController,
                                    // decoration: const InputDecoration(
                                    //   hintText: 'Numéro de téléphone',
                                    //   border: InputBorder.none,
                                    // ),
                                    keyboardType: TextInputType.phone,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: screenHeight * 0.03),

                          // Bouton Continuer
                          if (state is AuthLoading)
                            Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: screenHeight * 0.02),
                                child: const CircularProgressIndicator(),
                              ),
                            )
                          else
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: screenHeight * 0.01),
                              child: AuthButton(
                                color: Colors.blue,
                                text: 'Continuer',
                                textColor: Colors.white,
                                onPressed: () {
                                  if (phoneController.text.isEmpty) {
                                    PlatformSnackbar.show(
                                      context: context,
                                      message:
                                          'Veuillez entrer votre numéro de téléphone',
                                      duration: const Duration(seconds: 3),
                                      backgroundColor: Colors.blue,
                                      textColor: Colors.white,
                                      fontSize: 18,
                                    );

                                    return;
                                  }

                                  context.read<AuthBloc>().add(
                                        SendVerificationCode(
                                          '+33${phoneController.text}',
                                        ),
                                      );
                                },
                              ),
                            ),

                          if (Platform.isIOS) ...[
                            SizedBox(height: screenHeight * 0.03),
                            Row(
                              children: [
                                const Expanded(child: Divider()),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: screenWidth * 0.04,
                                  ),
                                  child: Text(
                                    'ou',
                                    style: TextStyle(
                                      fontSize: screenWidth * 0.035,
                                    ),
                                  ),
                                ),
                                const Expanded(child: Divider()),
                              ],
                            ),
                            SizedBox(height: screenHeight * 0.03),
                            SocialAuthButton(
                              text: 'Se connecter avec Apple',
                              onPressed: () {},
                            ),
                          ],

                          // Espace qui s'adapte quand le clavier est ouvert
                          SizedBox(
                            height: isKeyboardOpen
                                ? screenHeight * 0.02
                                : screenHeight * 0.15,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Indicateur du bas
                if (!isKeyboardOpen)
                  Padding(
                    padding: EdgeInsets.only(bottom: screenHeight * 0.02),
                    child: Center(
                      child: Container(
                        width: screenWidth * 0.15,
                        height: screenHeight * 0.004,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius:
                              BorderRadius.circular(screenWidth * 0.005),
                        ),
                      ),
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
