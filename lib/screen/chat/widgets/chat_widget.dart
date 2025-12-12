import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_app_test1/controller/chat_controller.dart';
import 'package:flutter_app_test1/controller/friend_controller.dart';
import 'package:flutter_app_test1/controller/socket_controller.dart';
import 'package:flutter_app_test1/controller/user_controller.dart';
import 'package:flutter_app_test1/helpers/local_storage_service.dart';
import 'package:flutter_app_test1/model/message_model.dart';
import 'package:flutter_app_test1/screen/widgets/profile_circle.dart';
import 'package:get/get.dart';

class ChatWidget extends StatefulWidget {
  final String conversationId;
  const ChatWidget({super.key, required this.conversationId});

  @override
  State<ChatWidget> createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  late final ChatController chatController;
  late final UserController userController;
  late final FriendController friendController;
  late final ScrollController _scrollController;
  SocketController socketController = Get.find<SocketController>();
  Map<String, dynamic> _currentUserInfo = {};
  Timer? _timer;
  void startTimer() {
    _timer = Timer.periodic(Duration(seconds: 10), (Timer t) {
      chatController.fetchDataForChat(widget.conversationId);
    });
  }

  void stopTimer() {
    _timer?.cancel();
  }

  @override
  void initState() {
    super.initState();
    chatController = Get.put(ChatController());
    userController = Get.find<UserController>();
    friendController = Get.find<FriendController>();
    _scrollController = ScrollController();

    socketController.socket?.emit("conversation:join", {widget.conversationId});

    chatController.setScrollController(_scrollController);
    //startTimer();

    _loadCurrentUserInfo().then((_) {
      chatController.fetchDataForChat(widget.conversationId);
    });
  }

  Future<void> _loadCurrentUserInfo() async {
    final userInfo = await LocalStorageService().getUserInfo();
    setState(() {
      _currentUserInfo = userInfo;
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    //stopTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        scrolledUnderElevation: 1,
        title: Obx(() {
          final participant = chatController.otherParticipant.value;
          if (participant == null) {
            return const Text('Chat');
          }
          final isOnline =
              friendController.onlineStatus[participant.id] ?? false;

          return Row(
            children: [
              ProfileCircle(imageUrl: participant.profileUrl, size: 40),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    participant.name ?? 'User',
                    style: const TextStyle(fontSize: 16),
                  ),
                  if (isOnline)
                    const Text(
                      'Online',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ],
          );
        }),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Obx(() => _buildMessageList(chatController.messages)),
            ),
            _buildUserInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageList(List<Item> messages) {
    if (messages.isEmpty) {
      return const Center(child: Text("No messages yet."));
    }
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(8.0),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final messageItem = messages[index];
        final bool isMe = messageItem.sender?.id == _currentUserInfo['userId'];
        return _buildMessageBubble(messageItem, isMe);
      },
    );
  }

  Widget _buildMessageBubble(Item message, bool isMe) {
    final participant = message.sender;

    // final readed = message.readBy?.firstWhere(
    //   (reader) => reader.userId == _currentUserInfo['userId'] ,
    // );
    final bool readedStatus = (message.readBy?.length ?? 0) > 1;

    if (participant == null) {
      return const SizedBox.shrink();
    }

    final messageBubble = Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
      decoration: BoxDecoration(
        color: isMe ? Colors.blue[200] : Colors.grey[300],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isMe)
            Text(
              participant.name ?? 'Unknown',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          if (!isMe) const SizedBox(height: 4),
          Text(message.content ?? ''),
          if (isMe && readedStatus)
            const Text(
              '✓ อ่านแล้ว',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
        ],
      ),
    );

    // ตรวจสอบเพื่อดึง profileUrl ของตัวเอง
    final myProfileUrl = userController.userProfile.value?.data?.profileUrl;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe)
            ProfileCircle(imageUrl: message.sender?.profileUrl, size: 30),
          if (!isMe) const SizedBox(width: 8),
          Flexible(child: messageBubble),
          if (isMe) const SizedBox(width: 8),
          if (isMe) ProfileCircle(imageUrl: myProfileUrl, size: 30),
        ],
      ),
    );
  }

  Widget _buildUserInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              // ใช้ Controller จาก ChatController
              controller: chatController.messageController,
              decoration: InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              maxLines: 5,
              minLines: 1,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            // เรียกใช้ sendMessage จาก Controller
            onPressed: () => chatController.sendMessage(widget.conversationId),
          ),
        ],
      ),
    );
  }
}
