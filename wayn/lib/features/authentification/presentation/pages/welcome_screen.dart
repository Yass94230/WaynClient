import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wayn/features/authentification/presentation/blocs/auth_bloc.dart';
import 'package:wayn/features/authentification/presentation/pages/login_screen.dart';
import 'package:wayn/features/authentification/presentation/pages/registration_information_screen.dart';
import 'package:wayn/features/authentification/presentation/pages/registration_screen.dart';
import 'package:wayn/features/authentification/presentation/widgets/auth_button.dart';
import 'package:wayn/features/authentification/presentation/widgets/welcome_header.dart';
import 'package:wayn/features/home/presentation/widgets/platform_scaffold.dart';
import 'package:wayn/features/map/presentation/pages/map_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  void initState() {
    super.initState();
    // Vérifier le statut d'authentification après le premier rendu
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AuthBloc>().add(CheckAuthStatus());
      }
    });
  }

  void _handleNavigation(BuildContext context, AuthState state) {
    if (state is Authenticated) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const MapScreen()),
      );
    } else if (state is ProfileIncomplete) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const RegistrationInfoScreen()),
      );
    }
  }

  void _navigateToLogin(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
    );
  }

  void _navigateToRegistration(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => RegistrationScreen()),
    );
  }

  Widget _buildBackgroundImage(double screenWidth, double screenHeight) {
    return Container(
      width: screenWidth,
      height: screenHeight * 0.6,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/backgroundWelcomeScreen.jpeg'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildBottomIndicator(
      double screenWidth, double screenHeight, double safePaddingBottom) {
    return Container(
      width: screenWidth * 0.15,
      height: screenHeight * 0.004,
      margin: EdgeInsets.only(
        bottom: screenHeight * 0.01 + safePaddingBottom,
      ),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(screenWidth * 0.005),
      ),
    );
  }

  Widget _buildAuthButtons(double screenHeight) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
          child: AuthButton(
            color: Colors.blue,
            text: 'Se connecter',
            textColor: Colors.white,
            onPressed: () => _navigateToLogin(context),
          ),
        ),
        SizedBox(height: screenHeight * 0.015),
        Padding(
          padding: EdgeInsets.symmetric(vertical: screenHeight * 0.01),
          child: AuthButton(
            color: Colors.grey[200]!,
            text: 'Créer un compte',
            textColor: Colors.black,
            onPressed: () => _navigateToRegistration(context),
          ),
        ),
      ],
    );
  }

  Widget _buildContent(
      double screenWidth, double screenHeight, double safePaddingBottom) {
    return Container(
      width: screenWidth,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(screenWidth * 0.032),
          topRight: Radius.circular(screenWidth * 0.032),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.05,
          vertical: screenHeight * 0.02,
        ),
        child: Column(
          children: [
            const WelcomeHeader(),
            SizedBox(height: screenHeight * 0.04),
            _buildAuthButtons(screenHeight),
            const Spacer(),
            Center(
                child: _buildBottomIndicator(
                    screenWidth, screenHeight, safePaddingBottom)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final safePaddingBottom = MediaQuery.of(context).padding.bottom;

    return BlocConsumer<AuthBloc, AuthState>(
      listenWhen: (previous, current) {
        return current is Authenticated || current is ProfileIncomplete;
      },
      listener: (context, state) => _handleNavigation(context, state),
      builder: (context, state) {
        if (state is AuthLoading) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return PlatformScaffold(
          backgroundColor: Colors.white,
          body: Stack(
            children: [
              _buildBackgroundImage(screenWidth, screenHeight),
              SafeArea(
                child: Column(
                  children: [
                    const Expanded(flex: 5, child: SizedBox()),
                    Expanded(
                      flex: 6,
                      child: _buildContent(
                          screenWidth, screenHeight, safePaddingBottom),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
