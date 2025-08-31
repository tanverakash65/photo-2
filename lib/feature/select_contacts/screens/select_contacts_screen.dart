import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_contacts/flutter_contacts.dart'; // ✅ ADD THIS IMPORT
import 'package:photon/common/widgets/error.dart';
import 'package:photon/common/widgets/loader.dart';
import 'package:photon/common/widgets/colors.dart';
import 'package:photon/feature/select_contacts/controller/select_contact_controller.dart';

class SelectContactsScreen extends ConsumerWidget {
  static const String routeName = '/select-contacts';
  const SelectContactsScreen({super.key});

  void selectContact(WidgetRef ref, Contact selectedContact, BuildContext context) {
    ref.read(selectContactControllerProvider).selectContact(selectedContact, context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Contacts'),
        backgroundColor: appBarColor, // ✅ Fixed: Use lowercase appBarcolor
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Implement search functionality
            },
            icon: const Icon(Icons.search),
          ),
          IconButton(
            onPressed: () {
              // TODO: Implement more options
            },
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      body: ref.watch(getContactsProvider).when(
        data: (contactList) => ListView.builder(
          itemCount: contactList.length,
          itemBuilder: (context, index) {
            final contact = contactList[index];
            return InkWell(
              onTap: () => selectContact(ref, contact, context),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: ListTile(
                  title: Text(
                    contact.displayName,
                    style: const TextStyle(
                      fontSize: 18,
                    ),
                  ),
                  subtitle: contact.phones.isNotEmpty
                      ? Text(
                    contact.phones[0].number,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  )
                      : null,
                  leading: CircleAvatar(
                    backgroundImage: contact.photo != null && contact.photo!.isNotEmpty // ✅ Fixed: Use 'photo' instead of 'avatar'
                        ? MemoryImage(contact.photo!) // ✅ Fixed: Use 'photo' instead of 'avatar'
                        : null,
                    backgroundColor: Colors.grey,
                    radius: 30,
                    child: contact.photo == null // ✅ Fixed: Use 'photo' instead of 'avatar'
                        ? const Icon(
                      Icons.person,
                      size: 30,
                      color: Colors.white,
                    )
                        : null,
                  ),
                  trailing: const Icon(
                    Icons.chat,
                    color: tabColor,
                  ),
                ),
              ),
            );
          },
        ),
        error: (err, trace) => ErrorScreen(error: err.toString()),
        loading: () => const Loader(),
      ),
    );
  }
}
