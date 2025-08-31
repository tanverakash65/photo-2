import 'package:flutter/material.dart';
import 'package:photon/common/widgets/custom_buttons.dart';
import 'package:photon/feature/auth/screens/login_screen.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  void navigateToLoginScreen(BuildContext context) {
    Navigator.pushNamed(context, LoginScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Welcome to Photon',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: size.height / 9),
              Image.asset("assets/logo_icon.png", height: 340, width: 340),
              SizedBox(height: size.height / 9),
              const Padding(
                padding: EdgeInsets.all(15.0),
                child: Text(
                  'Your gateway to seamless connectivity and innovation.',
                  style: TextStyle(fontSize: 18, color: Colors.white70),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 10),
              CustomButton(
                text: 'Agree & Continue',
                onPressed: () => navigateToLoginScreen(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
