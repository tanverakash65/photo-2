import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photon/common/widgets/colors.dart';
import 'package:photon/common/widgets/custom_buttons.dart';
import 'dart:io';
import 'package:photon/common/utils/utils.dart';
import 'package:photon/feature/auth/controller/auth_controller.dart';

class UserInformationScreen extends ConsumerStatefulWidget {
  static const String routeName = '/user-information';
  const UserInformationScreen({super.key});

  @override
  ConsumerState<UserInformationScreen> createState() => _UserInformationScreenState(); // Fixed: Added generic type
}

class _UserInformationScreenState extends ConsumerState<UserInformationScreen> { // Fixed: Added generic type
  final TextEditingController nameController = TextEditingController();
  File? image;

  @override
  void dispose() {
    super.dispose();
    nameController.dispose();
  }

  void selectImage() async {
    print('📷 Selecting image...');
    image = await pickImageFromGallery(context);
    if (image != null) {
      print('✅ Image selected: ${image!.path}');
    } else {
      print('❌ No image selected');
    }
    setState(() {});
  } // Fixed: Added missing closing brace

  void storeUserData() async {
    print('💾 Continue button pressed!');
    String name = nameController.text.trim();

    if (name.isNotEmpty) {
      print('📝 Name: $name, Image: ${image?.path ?? "No image"}');

      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text('Uploading...'),
            ],
          ),
        ),
      );

      // This calls Firebase, which will:
      // 1. Upload image to Cloudinary
      // 2. Save user data + image URL to Firebase Firestore
      ref.read(authControllerProvider).saveUserDataToFirebase(
        context,
        name,
        image,
      );
    } else {
      showSnackbar(context: context, content: 'Please enter your name');
    }
  } // Fixed: Added missing closing brace

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Information'),
        backgroundColor: backgroundColor,
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 20),
              Stack(
                children: [
                  image == null
                      ? const CircleAvatar(
                    backgroundImage: AssetImage('assets/user_icon.png'),
                    radius: 64,
                  )
                      : CircleAvatar(
                    backgroundImage: FileImage(image!),
                    radius: 64,
                  ),
                  Positioned(
                    bottom: -10,
                    left: 80,
                    child: IconButton(
                      onPressed: selectImage,
                      icon: const Icon(Icons.add_a_photo),
                    ),
                  ),
                ],
              ),

              Container(
                width: size.width * 0.85,
                padding: const EdgeInsets.all(20),
                child: TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    hintText: 'Enter your name',
                  ),
                ),
              ),

              const Spacer(),

              SizedBox(
                width: size.width * 0.85,
                child: CustomButton(
                  onPressed: storeUserData,
                  text: 'Continue',
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
