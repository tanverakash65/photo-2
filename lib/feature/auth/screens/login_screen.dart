import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:photon/common/utils/utils.dart';
import 'package:photon/common/widgets/colors.dart';
import 'package:photon/common/widgets/custom_buttons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photon/feature/auth/controller/auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  static const String routeName = '/login-screen';
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState(); // Fixed: Added generic type and method name
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  // Fixed: Added generic type
  final phoneController = TextEditingController();
  Country? country;

  @override
  void dispose() {
    super.dispose();
    phoneController.dispose();
  } // Fixed: Added missing closing brace

  void pickCountry() {
    showCountryPicker(
      context: context,
      onSelect: (Country selectedCountry) {
        setState(() {
          country = selectedCountry;
        });
      },
    );
  } // Fixed: Added missing closing brace

  void sendPhoneNumber() {
    String phoneNumber = phoneController.text.trim();
    if (country != null && phoneNumber.isNotEmpty) {
      String fullPhoneNumber = '+${country!.phoneCode}$phoneNumber';
      ref
          .read(authControllerProvider)
          .signInWithPhone(context, fullPhoneNumber);
    } else {
      showSnackbar(context: context, content: 'Fill out all the fields');
    }
  } // Fixed: Added missing closing brace and proper logic

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Enter your phone number'),
        elevation: 0,
        backgroundColor: backgroundColor,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'We will send you a verification code to your phone number',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),

              TextButton(
                onPressed: pickCountry,
                child: Text(
                  country != null
                      ? 'Country: ${country!.name}'
                      : 'Pick Country',
                ),
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(4),
                        bottomLeft: Radius.circular(4),
                      ),
                    ),
                    child: Text(
                      country != null ? '+${country!.phoneCode}' : '+880',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),

                  Expanded(
                    child: TextField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        hintText: 'Enter your phone number',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(4),
                            bottomRight: Radius.circular(4),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(4),
                            bottomRight: Radius.circular(4),
                          ),
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: CustomButton(onPressed: sendPhoneNumber, text: 'Next'),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
