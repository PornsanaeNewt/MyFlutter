import 'package:flutter_app_test1/config/routes/app_route.dart';
import 'package:flutter_app_test1/controller/conversation_controller.dart';
import 'package:flutter_app_test1/controller/socket_controller.dart';
import 'package:flutter_app_test1/controller/user_controller.dart';
import 'package:flutter_app_test1/model/message_model.dart';
import 'package:flutter_app_test1/model/chat_model.dart' as chat_model;
import 'package:flutter_app_test1/service/dudee_service.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class ChatController extends GetxController {
  final dudee = DudeeService();
  final SocketController skController = Get.find<SocketController>();
  final UserController userController = Get.find<UserController>();

  final RxList<Item> messages = <Item>[].obs;
  final TextEditingController messageController = TextEditingController();
  ScrollController? scrollController;
  String? currentConversationId;

  // ข้อมูลของคู่สนทนา
  final Rx<chat_model.Participant?> otherParticipant =
      Rx<chat_model.Participant?>(null);

  @override
  void onInit() {
    super.onInit();
  }

  void navigateToChat(int? conversationId) {
    if (conversationId == null) {
      print('Conversation ID is null');
      Get.snackbar(
        'Error',
        'Cannot open chat, conversation ID is missing.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    Get.toNamed(
      AppRoute.chat,
      parameters: {'conversationId': conversationId.toString()},
    );
  }

  // --- Logic สำหรับหน้า Chat ---

  void handleIncomingMessage(dynamic data) {
    print('📬 [ChatController] Handling incoming message: $data');
    if (data is Map<String, dynamic>) {
      if (data['conversationId'].toString() == currentConversationId) {
        final messageItem = Item.fromJson(data);
        messages.add(messageItem);
        scrollToBottom(); // เลื่อนลง
      } else {
        print(
          'Ignoring message for different conversation: ${data['conversationId']}',
        );
      }
    }
  }

  Future<void> fetchDataForChat(String conversationIdStr) async {
    currentConversationId = conversationIdStr;
    final conversationId = int.tryParse(conversationIdStr);
    if (conversationId == null) return;
    try {
      await dudee.chatRead(conversationId);
      final messageResponse = await dudee.getMessages(conversationId);
      //print('Fetched messages: ${jsonEncode(messageResponse)}');

      if (messageResponse.data != null && messageResponse.data!.items != null) {
        final items = messageResponse.data!.items!;
        items.sort((a, b) {
          return (a.createdAt ?? DateTime(0)).compareTo(
            b.createdAt ?? DateTime(0),
          );
        });
        // อัปเดตข้อความทั้งหมด
        messages.assignAll(items);
        scrollToBottom();
      }
      _findOtherParticipant(conversationId);
    } catch (e) {
      print('Failed to fetch messages: $e');
    }
  }

  /// ค้นหาข้อมูลของอีกฝ่ายในห้องแชท
  void _findOtherParticipant(int conversationId) {
    final ConversationController conversationController = Get.find();
    final currentUserId = userController.userProfile.value?.data?.userId;

    final conversation = conversationController.conversations.firstWhereOrNull(
      (c) => c.id == conversationId,
    );

    if (conversation != null && conversation.participants != null) {
      otherParticipant.value = conversation.participants!.firstWhereOrNull(
        (p) => p.id != currentUserId,
      );
    }
  }

  Future<void> sendMessage(String conversationId) async {
    if (messageController.text.trim().isEmpty) return;
    final content = messageController.text.trim();
    await dudee.sendMessage(int.parse(conversationId), content);

    // final messageData = {
    //   'conversationId': int.parse(conversationId),
    //   'content': content,
    // };
    // ส่งข้อความผ่าน Socket
    //skController.socket?.emit('message:send', messageData);

    // Optimistic UI update: เพิ่มข้อความใหม่ทันที
    final currentUser = userController.userProfile.value?.data;
    final optimisticMessage = Item(
      content: content,
      sender: Sender(
        id: currentUser?.userId,
        name: currentUser?.name,
        profileUrl: currentUser?.profileUrl,
      ),
      createdAt: DateTime.now(),
      isReadByMe: false, // ตั้งเป็น false ในตอนแรก
    );

    // อัปเดตข้อความผ่าน messages.add()
    messages.add(optimisticMessage);
    messageController.clear();
    scrollToBottom();
  }

  void scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController != null && scrollController!.hasClients) {
        try {
          scrollController!.animateTo(
            scrollController!.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        } catch (e) {
          // Handle case where controller might be detached
          print('Error scrolling to bottom: $e');
        }
      }
    });
  }

  void setScrollController(ScrollController controller) {
    scrollController = controller;
  }

  @override
  void onClose() {
    messageController.dispose();
    scrollController = null;
    super.onClose();
  }
}
