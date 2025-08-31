import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photon/feature/group/repository/group_repository.dart';
import 'package:flutter_contacts/flutter_contacts.dart'; // ✅ Fixed: Use full import instead of contact.dart

final groupControllerProvider = Provider((ref) {
  final groupRepository = ref.read(groupRepositoryProvider);
  return GroupController(
    groupRepository: groupRepository,
    ref: ref,
  );
});

class GroupController {
  final GroupRepository groupRepository;
  final ProviderRef ref;

  GroupController({
    required this.groupRepository,
    required this.ref,
  });

  void createGroup(
      BuildContext context,
      String name,
      File profilePic,
      List<Contact> selectedContact, // ✅ Fixed: Added generic type
      ) {
    groupRepository.createGroup(context, name, profilePic, selectedContact);
  }
}
