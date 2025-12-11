import 'package:flutter/material.dart';
import 'package:flutter_app_test1/model/chat_model.dart';
import 'package:flutter_app_test1/service/dudee_service.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:toastification/toastification.dart';

class ConversationController extends GetxController {
  RxList<Datum> conversations = <Datum>[].obs;
  Rx<Meta?> meta = Rx<Meta?>(null);
  RxBool isLoading = false.obs;

  Future<void> fetchConversations() async {
    try {
      isLoading.value = true;
      update();

      final fetchedConversations = await DudeeService().getConversations();

      // เช็ค null safety อย่างละเอียด
      if (fetchedConversations.data != null &&
          fetchedConversations.data!.data != null) {
        conversations.assignAll(fetchedConversations.data!.data!);
        meta.value = fetchedConversations.data!.meta;
        Toastification().show(
          title: Text("Conversation Loaded"),
          description: Text("✅ Fetched ${conversations.length} conversations"),
          type: ToastificationType.error,
        );
      } else {
        conversations.clear();
        meta.value = null;
        Toastification().show(
          title: Text("Conversation Cleared"),
          description: Text("⚠️ No conversations data received"),
          type: ToastificationType.error,
        );
      }
    } catch (e) {
      print("❌ Error fetching conversations: $e");
      Toastification().show(
        title: Text("Conversation Error"),
        description: Text("Failed to fetch conversations. $e"),
        type: ToastificationType.error,
      );
      // ไม่ clear conversations ถ้า error เพื่อให้แสดงข้อมูลเก่า
      // หรือถ้าต้องการ clear: conversations.clear();
    } finally {
      Toastification().show(
        title: Text("Conversation Loaded"),
        description: Text("..."),
        type: ToastificationType.error,
      );
      isLoading.value = false;
      update();
    }
  }

  Future<int?> createConversation(List<int> participantIds) async {
    try {
      isLoading.value = true;
      update();
      final response = await DudeeService().postConversations(
        participantIds: participantIds,
      );
      if (response.statusCode == 201 && response.data != null) {
        final conversationId = response.data['data']['conversationId'];
        await fetchConversations();
        print('Conversation created with ID: $conversationId');
        return conversationId;
      } else {
        print(
          'Failed to create conversation. Status code: ${response.statusCode}',
        );
        return null;
      }
    } catch (e) {
      print("Error creating conversation: $e");
      return null;
    } finally {
      isLoading.value = false;
      update();
    }
  }

  Future<void> clearConversations() async {
    conversations.clear();
    meta.value = null;
    update();
  }
}
