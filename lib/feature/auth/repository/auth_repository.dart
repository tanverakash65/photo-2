import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:photon/common/utils/utils.dart';
import 'package:photon/feature/auth/screens/otp_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photon/feature/auth/screens/user_information_screen.dart';
import 'dart:io';
import 'package:photon/models/user_model.dart';
import 'package:photon/common/services/cloudinary_service.dart';

final authRepositoryProvider = Provider(
      (ref) => AuthRepository(
    auth: FirebaseAuth.instance,
    firestore: FirebaseFirestore.instance,
  ),
);

class AuthRepository {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;

  AuthRepository({required this.auth, required this.firestore});

  // ✅ Fixed: Added return type
  Future<UserModel?> getCurrentUserData() async {
    if (auth.currentUser != null) {
      var userData = await firestore
          .collection('users')
          .doc(auth.currentUser!.uid)
          .get();

      if (userData.data() != null) {
        return UserModel.fromMap(userData.data()!);
      }
    }
    return null;
  }

  // ✅ Fixed: Complete implementation
  void signInWithPhone(BuildContext context, String phoneNumber) async {
    print('🔥 Starting phone verification for: $phoneNumber');
    try {
      await auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          print('🔥 Auto-verification completed');
          await auth.signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          print('🔥 Verification failed: ${e.code} - ${e.message}');
          throw Exception(e.message);
        },
        codeSent: (String verificationId, int? resendToken) async {
          print('🔥 Code sent! Verification ID: $verificationId');
          Navigator.pushNamed(
            context,
            OTPScreen.routeName,
            arguments: verificationId,
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          print('🔥 Code auto-retrieval timeout');
        },
      );
    } on FirebaseAuthException catch (e) {
      print('🔥 Firebase exception: $e');
      showSnackbar(context: context, content: e.toString());
    }
  }

  // ✅ Fixed: Complete implementation
  void verifyOTP({
    required BuildContext context,
    required String verificationId,
    required String userOTP,
  }) async {
    print('🔥 Verifying OTP: $userOTP for verification ID: $verificationId');
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: userOTP,
      );
      await auth.signInWithCredential(credential);
      print('🔥 OTP verification successful!');
      Navigator.pushNamedAndRemoveUntil(
        context,
        UserInformationScreen.routeName,
            (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      print('🔥 OTP verification failed: ${e.message}');
      showSnackbar(context: context, content: e.message!);
    }
  }

  // ✅ Fixed: Complete implementation with Cloudinary
  void saveUserDataToFirebase({
    required String name,
    required File? profilePic,
    required ProviderRef ref,
    required BuildContext context,
  }) async {
    try {
      String uid = auth.currentUser!.uid;
      String photoUrl = 'https://res.cloudinary.com/demo/image/upload/avatar.png'; // Default avatar

      // Upload to Cloudinary instead of Firebase Storage
      if (profilePic != null) {
        String? cloudinaryUrl = await CloudinaryService.uploadProfileImage(profilePic, uid);
        if (cloudinaryUrl != null) {
          photoUrl = cloudinaryUrl;
        } else {
          // If upload fails, show error but continue with default image
          showSnackbar(
            context: context,
            content: 'Failed to upload image, using default avatar',
          );
        }
      }

      var user = UserModel(
        uid: uid,
        name: name,
        profilePic: photoUrl, // Now using Cloudinary URL
        isOnline: true,
        phoneNumber: auth.currentUser!.phoneNumber!,
        groupId: [],
      );

      await firestore.collection('users').doc(uid).set(user.toMap());
      print('🔥 User data saved for UID: $uid with photo: $photoUrl');

      // Navigate to landing screen since you don't have a home route yet
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/', // This will go to your landing screen
            (route) => false,
      );

    } catch (e) {
      print('❌ Error saving user data: $e');
      showSnackbar(context: context, content: e.toString());
    }
  }

  // ✅ Fixed: Added return type
  Stream<UserModel> userData(String userId) {
    return firestore.collection('users').doc(userId).snapshots().map(
          (event) => UserModel.fromMap(event.data()!),
    );
  }

  // ✅ Added: Missing setUserState method
  void setUserState(bool isOnline) async {
    if (auth.currentUser != null) {
      await firestore.collection('users').doc(auth.currentUser!.uid).update({
        'isOnline': isOnline,
      });
    }
  }
}
