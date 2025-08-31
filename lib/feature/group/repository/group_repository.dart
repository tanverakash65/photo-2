import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:photon/common/repositories/common_cloudinary_storage_repository.dart'; // ✅ CHANGED: Use Cloudinary instead
import 'package:photon/common/utils/utils.dart';
import 'package:photon/models/group.dart' as model;
import 'package:uuid/uuid.dart';

final groupRepositoryProvider = Provider(
      (ref) => GroupRepository(
    firestore: FirebaseFirestore.instance,
    auth: FirebaseAuth.instance,
    ref: ref,
  ),
);

class GroupRepository {
  final FirebaseFirestore firestore;
  final FirebaseAuth auth;
  final ProviderRef ref;

  GroupRepository({
    required this.firestore,
    required this.auth,
    required this.ref,
  });

  void createGroup(
      BuildContext context,
      String name,
      File profilePic,
      List<Contact> selectedContact, // ✅ Fixed: Added generic type
      ) async {
    try {
      List<String> uids = []; // ✅ Fixed: Added generic type

      for (int i = 0; i < selectedContact.length; i++) {
        var userCollection = await firestore
            .collection('users')
            .where(
          'phoneNumber',
          isEqualTo: selectedContact[i].phones[0].number.replaceAll(' ', ''),
        )
            .get();

        if (userCollection.docs.isNotEmpty && userCollection.docs[0].exists) {
          uids.add(userCollection.docs[0].data()['uid']); // ✅ Fixed: Access as Map
        }
      }

      var groupId = const Uuid().v1();

      // ✅ CHANGED: Upload to Cloudinary instead of Firebase Storage
      String profileUrl = await ref
          .read(commonCloudinaryStorageRepositoryProvider) // Changed provider
          .storeFileToFirebase( // Method name stays same for compatibility
        'group_$groupId', // Updated path format for Cloudinary
        profilePic,
      );

      model.Group group = model.Group(
        senderId: auth.currentUser!.uid,
        name: name,
        groupId: groupId,
        lastMessage: '',
        groupPic: profileUrl, // Now contains Cloudinary URL
        membersUid: [auth.currentUser!.uid, ...uids],
        timeSent: DateTime.now(),
      );

      await firestore.collection('groups').doc(groupId).set(group.toMap());
    } catch (e) {
      showSnackbar(context: context, content: e.toString());
    }
  }
}
