import 'package:flutter/material.dart';
import 'package:flutter_app_test1/controller/conversation_controller.dart';
import 'package:flutter_app_test1/controller/socket_controller.dart';
import 'package:flutter_app_test1/screen/chat/widgets/chat_widget.dart';
import 'package:get/get.dart';

class ChatPage extends StatelessWidget {
  final String conversationId;
  const ChatPage({super.key, required this.conversationId});

  Future<bool?> _showBackDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Are you sure?'),
          content: const Text('Are you sure you want to leave this page?'),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Nevermind'),
              onPressed: () {
                Navigator.pop(context, false);
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Leave'),
              onPressed: () {
                Navigator.pop(context, true);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, result) async {
        if (didPop) {
          return;
        }
        final bool shouldPop = await _showBackDialog(context) ?? false;
        if (context.mounted && shouldPop) {
          SocketController socketController = Get.find<SocketController>();
          socketController.socket?.emit("conversation:leave", {"conversationId": conversationId});
          Navigator.pop(context, result);
          ConversationController conversationController =
              Get.isRegistered<ConversationController>()
                  ? Get.find<ConversationController>()
                  : Get.put(ConversationController());
          await conversationController.fetchConversations();
        }
      },
      child: ChatWidget(conversationId: conversationId),
    );
  }
}
