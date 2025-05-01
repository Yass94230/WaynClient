import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wayn/features/authentification/presentation/blocs/auth_bloc.dart';
import 'package:wayn/features/authentification/presentation/pages/apple_phone.dart';
import 'package:wayn/features/authentification/presentation/pages/registration_information_screen.dart';
import 'package:wayn/features/authentification/presentation/pages/sms_verification_screen.dart';
import 'package:wayn/features/authentification/presentation/widgets/auth_button.dart';
import 'package:wayn/features/authentification/presentation/widgets/social_auth_button.dart';
import 'package:wayn/features/home/presentation/widgets/platform_scaffold.dart';
import 'package:wayn/features/home/presentation/widgets/platform_snackbar.dart';
import 'package:wayn/features/home/presentation/widgets/platform_text_field.dart';
import '../widgets/country_code_picker.dart';

class RegistrationScreen extends StatelessWidget {
  final phoneController = TextEditingController();
  RegistrationScreen({super.key});

  void _handleAuthState(BuildContext context, AuthState state) {
    log('Current auth state: $state');

    if (state is ManualVerificationRequired) {
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
    } else if (state is AppleSignInComplete) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ApplePhoneVerificationPage(),
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
  }

  void _handlePhoneSubmission(BuildContext context) {
    if (phoneController.text.isEmpty) {
      PlatformSnackbar.show(
        context: context,
        message: 'Veuillez entrer votre numéro de téléphone',
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 18,
      );

      return;
    }

    final phoneNumber = '+33${phoneController.text.trim()}';
    context.read<AuthBloc>().add(SendVerificationCode(phoneNumber));
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return BlocConsumer<AuthBloc, AuthState>(
      listener: _handleAuthState,
      builder: (context, state) {
        return PlatformScaffold(
          showNavigationBar: true,
          title: 'Inscription',
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
                      child: state is AuthLoading
                          ? const Center(child: CircularProgressIndicator())
                          : Column(
                              children: [
                                SizedBox(height: screenHeight * 0.04),
                                _buildPhoneInput(screenWidth, screenHeight),
                                SizedBox(height: screenHeight * 0.02),
                                _buildContinueButton(context, screenHeight),
                                if (Platform.isIOS) ...[
                                  SizedBox(height: screenHeight * 0.03),
                                  _buildDivider(screenWidth),
                                  SizedBox(height: screenHeight * 0.03),
                                  _buildAppleButton(context),
                                ],
                              ],
                            ),
                    ),
                  ),
                ),
                if (!isKeyboardOpen) _buildFooter(screenWidth, screenHeight),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPhoneInput(double screenWidth, double screenHeight) {
    return Row(
      children: [
        CountryCode(onCountryChanged: (String) {}),
        SizedBox(width: screenWidth * 0.03),
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.04,
              vertical: screenHeight * 0.015,
            ),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(screenWidth * 0.02),
            ),
            child: PlatformTextField(
              read: false,
              controller: phoneController,
              keyboardType: TextInputType.phone,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContinueButton(BuildContext context, double screenHeight) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
      child: AuthButton(
        text: 'Continuer',
        textColor: Colors.white,
        color: Colors.blue,
        onPressed: () => _handlePhoneSubmission(context),
      ),
    );
  }

  Widget _buildDivider(double screenWidth) {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
          child: Text(
            'ou',
            style: TextStyle(fontSize: screenWidth * 0.035),
          ),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }

  Widget _buildAppleButton(BuildContext context) {
    return SocialAuthButton(
      text: 'Continuer avec Apple',
      onPressed: () {
        context.read<AuthBloc>().add(SignInWithApple());
      },
    );
  }

  Widget _buildFooter(double screenWidth, double screenHeight) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.05,
            vertical: screenHeight * 0.02,
          ),
          child: Text(
            'En vous inscrivant, vous acceptez nos conditions générales d\'utilisation. '
            'Vous acceptez également de recevoir des appels et des messages.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: screenWidth * 0.03,
              color: Colors.black54,
            ),
          ),
        ),
        Container(
          width: screenWidth * 0.15,
          height: screenHeight * 0.005,
          margin: EdgeInsets.only(
            bottom: screenHeight * 0.02,
            top: screenHeight * 0.01,
          ),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(screenWidth * 0.005),
          ),
        ),
      ],
    );
  }
}
