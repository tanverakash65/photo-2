import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photon/common/widgets/colors.dart';
import 'package:photon/common/utils/utils.dart';
import 'package:photon/feature/auth/controller/auth_controller.dart';
import 'package:photon/feature/select_contacts/screens/select_contacts_screen.dart';
import 'package:photon/feature/chat/widgets/contact_list.dart';
import 'package:photon/feature/group/screens/create_group_screen.dart';
import 'package:photon/feature/status/screens/status_contacts_screen.dart';
import 'package:photon/feature/status/screens/confirm_status_screen.dart';

class MobileLayoutScreen extends ConsumerStatefulWidget {
  const MobileLayoutScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<MobileLayoutScreen> createState() => _MobileLayoutScreenState();
}

class _MobileLayoutScreenState extends ConsumerState<MobileLayoutScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  late TabController tabBarController;

  @override
  void initState() {
    super.initState();
    tabBarController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
    tabBarController.dispose(); // ✅ Added: Dispose tab controller
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        ref.read(authControllerProvider).setUserState(true);
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
      case AppLifecycleState.paused:
        ref.read(authControllerProvider).setUserState(false);
        break;
      case AppLifecycleState.hidden: // ✅ ADDED: Missing case
        ref.read(authControllerProvider).setUserState(false);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: appBarColor,
          centerTitle: false,
          title: const Text(
            'Photon',
            style: TextStyle(
              fontSize: 20,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.search, color: Colors.grey),
              onPressed: () {
                // TODO: Implement search functionality
              },
            ),
            PopupMenuButton(
              icon: const Icon(Icons.more_vert, color: Colors.grey),
              itemBuilder: (context) => [
                PopupMenuItem(
                  child: const Text('Create Group'),
                  onTap: () => Future(
                        () => Navigator.pushNamed(
                      context,
                      CreateGroupScreen.routeName, // ✅ Now properly imported
                    ),
                  ),
                ),
                PopupMenuItem(
                  child: const Text('Settings'),
                  onTap: () {
                    // TODO: Navigate to settings
                  },
                ),
                PopupMenuItem(
                  child: const Text('Logout'),
                  onTap: () {
                    // TODO: Implement logout
                  },
                ),
              ],
            ),
          ],
          bottom: TabBar(
            controller: tabBarController,
            indicatorColor: tabColor,
            indicatorWeight: 4,
            labelColor: tabColor,
            unselectedLabelColor: Colors.grey,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            tabs: const [
              Tab(text: 'CHATS'),
              Tab(text: 'STATUS'),
              Tab(text: 'CALLS'),
            ],
          ),
        ),
        body: TabBarView(
          controller: tabBarController,
          children: [
            const ContactsList(),
            StatusContactsScreen(),
            const CallsPlaceholder(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            if (tabBarController.index == 0) {
              // Navigate to select contacts for chat
              Navigator.pushNamed(context, SelectContactsScreen.routeName);
            } else if (tabBarController.index == 1) {
              // Navigate to add status
              File? pickedImage = await pickImageFromGallery(context);
              if (pickedImage != null) {
                Navigator.pushNamed(
                  context,
                  ConfirmStatusScreen.routeName, // ✅ Now properly imported
                  arguments: pickedImage,
                );
              }
            } else {
              // Calls tab - show coming soon message
              showSnackbar(context: context, content: 'Calls feature coming soon!');
            }
          },
          backgroundColor: tabColor,
          child: const Icon(Icons.comment, color: Colors.white),
        ),
      ),
    );
  }
}

// ✅ ADD: Placeholder widget for calls tab
class CallsPlaceholder extends StatelessWidget {
  const CallsPlaceholder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.call, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Calls feature coming soon!',
            style: TextStyle(color: Colors.grey, fontSize: 18),
          ),
        ],
      ),
    );
  }
}
