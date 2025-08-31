import 'package:flutter/material.dart';
import 'package:photon/models/message.dart';
import 'package:photon/common/enums/message_enum.dart';
import 'package:photon/feature/chat/widgets/my_message_card.dart';
import 'package:photon/feature/chat/widgets/sender_message_card.dart';
import 'package:photon/common/widgets/loader.dart';
import 'package:photon/feature/chat/controller/chat_controller.dart';
import 'package:photon/common/providers/message_reply_provider.dart'; // ✅ ADD THIS IMPORT
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class ChatList extends ConsumerStatefulWidget {
  final String recieverUserId;
  final bool isGroupChat;

  const ChatList({
    Key? key,
    required this.recieverUserId,
    required this.isGroupChat,
  }) : super(key: key);

  @override
  ConsumerState<ChatList> createState() => _ChatListState();
}

class _ChatListState extends ConsumerState<ChatList> {
  final ScrollController messageController = ScrollController();

  @override
  void dispose() {
    super.dispose();
    messageController.dispose();
  }

  void onMessageSwipe(String message, bool isMe, MessageEnum messageEnum) {
    ref.read(messageReplyProvider.notifier).update( // ✅ Fixed: Use notifier
          (state) => MessageReply(message, isMe, messageEnum), // ✅ Now defined
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Message>>(
      stream: widget.isGroupChat
          ? ref.read(chatControllerProvider).groupChatStream(widget.recieverUserId)
          : ref.read(chatControllerProvider).chatStream(widget.recieverUserId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Loader();
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) { // ✅ Added null check
          return const Center(child: Text('No messages yet'));
        }

        SchedulerBinding.instance.addPostFrameCallback((_) {
          messageController.jumpTo(messageController.position.maxScrollExtent);
        });

        return ListView.builder(
          controller: messageController,
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final messageData = snapshot.data![index];
            var timeSent = DateFormat.Hm().format(messageData.timeSent);

            if (!messageData.isSeen &&
                messageData.recieverid == FirebaseAuth.instance.currentUser!.uid) {
              ref.read(chatControllerProvider).setChatMessageSeen(
                context,
                widget.recieverUserId,
                messageData.messageId,
              );
            }

            if (messageData.senderId == FirebaseAuth.instance.currentUser!.uid) {
              return MyMessageCard(
                message: messageData.text,
                date: timeSent,
                type: messageData.type,
                repliedText: messageData.repliedMessage,
                username: messageData.repliedTo,
                repliedMessageType: messageData.repliedMessageType,
                onLeftSwipe: () => onMessageSwipe(messageData.text, true, messageData.type),
                isSeen: messageData.isSeen,
              );
            }

            return SenderMessageCard(
              message: messageData.text,
              date: timeSent,
              type: messageData.type,
              username: messageData.repliedTo,
              repliedMessageType: messageData.repliedMessageType,
              onRightSwipe: () => onMessageSwipe(messageData.text, false, messageData.type),
              repliedText: messageData.repliedMessage,
            );
          },
        );
      },
    );
  }
}
