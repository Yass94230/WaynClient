// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wayn/features/authentification/presentation/blocs/auth_bloc.dart';
import 'package:wayn/features/authentification/presentation/pages/registration_information_screen.dart';
import 'package:wayn/features/authentification/presentation/pages/sms_verification_screen.dart';
import 'package:wayn/features/authentification/presentation/widgets/auth_button.dart';
import 'package:wayn/features/authentification/presentation/widgets/country_code_picker.dart';
import 'package:wayn/features/home/presentation/widgets/platform_scaffold.dart';
import 'package:wayn/features/home/presentation/widgets/platform_snackbar.dart';
import 'package:wayn/features/home/presentation/widgets/platform_text_field.dart';

class ApplePhoneVerificationPage extends StatefulWidget {
  const ApplePhoneVerificationPage({super.key});

  @override
  _ApplePhoneVerificationPageState createState() =>
      _ApplePhoneVerificationPageState();
}

class _ApplePhoneVerificationPageState
    extends State<ApplePhoneVerificationPage> {
  final phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return PlatformScaffold(
      showNavigationBar: true,
      title: 'Entrez votre numéro de téléphone',
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is CodeSent) {
            // Navigation vers la page de vérification OTP
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
              backgroundColor: Colors.blue,
              textColor: Colors.white,
              fontSize: 18,
            );
          } else if (state is ManualVerificationRequired) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SMSVerificationScreen(
                  phoneNumber: phoneController.text,
                  isNewUser: true,
                ),
              ),
            );
          } else if (state is AutoVerificationSuccess) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const RegistrationInfoScreen()),
            );
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Pour finaliser votre inscription, veuillez ajouter un numéro de téléphone',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 20),
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
                          borderRadius:
                              BorderRadius.circular(screenWidth * 0.02),
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
                const SizedBox(height: 20),
                AuthButton(
                  color: Colors.blue,
                  text: 'Continuer',
                  textColor: Colors.white,
                  onPressed: () {
                    if (phoneController.text.isEmpty) {
                      PlatformSnackbar.show(
                        context: context,
                        message: 'Veuillez entrer votre numéro de téléphone',
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
              ],
            ),
          );
        },
      ),
    );
  }
}
