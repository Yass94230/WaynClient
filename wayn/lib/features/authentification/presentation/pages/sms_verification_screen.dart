import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wayn/features/authentification/presentation/blocs/auth_bloc.dart';
import 'package:wayn/features/authentification/presentation/pages/login_password_screen.dart';
import 'package:wayn/features/authentification/presentation/pages/password_creation_screen.dart';
import 'package:wayn/features/authentification/presentation/widgets/auth_button.dart';
import 'package:wayn/features/home/presentation/widgets/platform_scaffold.dart';
import 'package:wayn/features/home/presentation/widgets/platform_snackbar.dart';
import 'package:wayn/features/home/presentation/widgets/platform_text_field.dart';

class SMSVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  final bool isNewUser;

  const SMSVerificationScreen({
    super.key,
    required this.phoneNumber,
    required this.isNewUser,
  });

  @override
  State<SMSVerificationScreen> createState() => _SMSVerificationScreenState();
}

class _SMSVerificationScreenState extends State<SMSVerificationScreen> {
  final List<TextEditingController> controllers = List.generate(
    6,
    (index) => TextEditingController(),
  );

  Timer? _timer;
  int _timeLeft = 35; // Temps initial en secondes
  bool _canResendCode = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    setState(() {
      _timeLeft = 35;
      _canResendCode = false;
    });

    _timer?.cancel(); // Annuler le timer existant si présent

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeLeft > 0) {
          _timeLeft--;
        } else {
          _canResendCode = true;
          timer.cancel();
        }
      });
    });
  }

  String get _formattedTime {
    final minutes = (_timeLeft / 60).floor();
    final seconds = _timeLeft % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  String getFullCode() {
    return controllers.map((controller) => controller.text).join();
  }

  Widget _buildCodeInput(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final inputWidth = (screenWidth - (40 + (5 * 10))) / 6;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(
        6,
        (index) => SizedBox(
          width: inputWidth,
          child: AspectRatio(
            aspectRatio: 1,
            child: PlatformTextField(
              read: false,
              controller: controllers[index],
              keyboardType: TextInputType.number,
              onChanged: (value) {
                if (value.length == 1 && index < 5) {
                  FocusScope.of(context).nextFocus();
                } else if (value.isEmpty && index > 0) {
                  FocusScope.of(context).previousFocus();
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is VerificationSuccess && state.isExistingUser) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LoginPasswordScreen(
                phoneNumber: widget.phoneNumber,
              ),
            ),
          );
        } else if (state is VerificationSuccess && !state.isExistingUser) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PasswordCreationScreen(
                phoneNumber: widget.phoneNumber,
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
        } else if (state is CodeSent) {
          _startTimer(); // Redémarrer le timer quand un nouveau code est envoyé
        }
      },
      builder: (context, state) {
        return PlatformScaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: screenHeight - MediaQuery.of(context).padding.top,
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.05,
                    vertical: screenHeight * 0.02,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(height: screenHeight * 0.04),
                      Text(
                        'Vérification',
                        style: TextStyle(
                          fontSize: screenWidth * 0.07,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: screenHeight * 0.04),
                      Text(
                        'Entrez le code que \nvous avez reçu par SMS',
                        style: TextStyle(
                          fontSize: screenWidth * 0.045,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.start,
                      ),
                      SizedBox(height: screenHeight * 0.02),
                      Text(
                        _formattedTime,
                        style: TextStyle(
                          fontSize: screenWidth * 0.045,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.start,
                      ),
                      SizedBox(height: screenHeight * 0.03),
                      _buildCodeInput(context),
                      SizedBox(height: screenHeight * 0.03),
                      TextButton(
                        onPressed: _canResendCode
                            ? () {
                                context.read<AuthBloc>().add(
                                      SendVerificationCode(widget.phoneNumber),
                                    );
                              }
                            : null,
                        child: Text(
                          'Renvoyer le code',
                          style: TextStyle(
                            color: _canResendCode ? Colors.blue : Colors.grey,
                            fontSize: screenWidth * 0.04,
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.2),
                      if (state is AuthLoading)
                        const Center(child: CircularProgressIndicator())
                      else
                        Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: screenHeight * 0.02,
                          ),
                          child: AuthButton(
                            text: 'Valider',
                            textColor: Colors.white,
                            color: Colors.blue,
                            onPressed: () {
                              final code = getFullCode();
                              if (code.length == 6) {
                                context.read<AuthBloc>().add(
                                      VerifyCode(code, widget.phoneNumber),
                                    );
                              }
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in controllers) {
      controller.dispose();
    }
    super.dispose();
  }
}
