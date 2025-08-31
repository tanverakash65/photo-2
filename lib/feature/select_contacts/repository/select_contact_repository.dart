import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart'; // ✅ ADD THIS IMPORT
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photon/models/user_model.dart';
import 'package:photon/feature/chat/screens/mobile_chat_screen.dart';
import 'package:photon/common/utils/utils.dart'; // ✅ ADD THIS IMPORT

final selectContactRepositoryProvider = Provider( // ✅ Fixed: lowercase 's'
      (ref) => SelectContactRepository(
    firestore: FirebaseFirestore.instance,
  ),
);

class SelectContactRepository {
  final FirebaseFirestore firestore;

  SelectContactRepository({required this.firestore});

  Future<List<Contact>> getContacts() async { // ✅ Fixed: Added return type
    List<Contact> contacts = [];
    try {
      if (await FlutterContacts.requestPermission()) {
        contacts = await FlutterContacts.getContacts(withProperties: true); // ✅ Fixed: Assign result to contacts
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return contacts;
  } // ✅ Added missing closing brace

  void selectContact(Contact selectedContact, BuildContext context) async {
    try {
      var userCollection = await firestore.collection('users').get();
      bool isFound = false;

      for (var document in userCollection.docs) {
        var userData = UserModel.fromMap(document.data());
        String selectedPhoneNumber = selectedContact.phones[0].number.replaceAll(' ', '');

        // ✅ Fixed: Use userData.phoneNumber instead of userData['phoneNumber']
        if (selectedPhoneNumber == userData.phoneNumber) {
          isFound = true;
          Navigator.pushNamed(
            context,
            MobileChatScreen.routeName, // ✅ Fixed: Use routeName instead of routename
            arguments: {
              'name': userData.name, // ✅ Fixed: Use userData.name instead of userData['name']
              'uid': userData.uid, // ✅ Fixed: Use userData.uid instead of userData['uid']
              'isGroupChat': false,
              'profilePic': userData.profilePic,
            },
          );
          break;
        }
      }

      if (!isFound) {
        showSnackbar(context: context, content: 'This number does not exist on this app');
      }
    } catch (e) {
      showSnackbar(context: context, content: e.toString());
    }
  }
}
