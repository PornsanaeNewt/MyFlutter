import 'package:flutter/material.dart';
import 'package:flutter_app_test1/controller/conversation_controller.dart';
import 'package:flutter_app_test1/controller/friend_controller.dart';
import 'package:flutter_app_test1/controller/socket_controller.dart';
import 'package:flutter_app_test1/controller/user_controller.dart';
import 'package:flutter_app_test1/helpers/app_setting.dart';
import 'package:flutter_app_test1/screen/home/widgets/bottom_bar.dart';
import 'package:get/get.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ConversationController conversationController = Get.put(
    ConversationController(),
  );
  final FriendController friendController = Get.put(FriendController());
  SocketController skController = Get.put(SocketController());
  AppSettingController appSettingController = Get.put(AppSettingController());

  final UserController userController = Get.put(UserController());
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _connectSocket());
  }

  //เชื่อมต่อ Socket (async)
  Future<void> _connectSocket() async {
    try {
      await skController.connectSocket();
    } catch (e) {
      print('❌ [Home] Failed to connect socket: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Obx(
          () => IndexedStack(
            index: appSettingController.selectedIndex.value,
            children: List.generate(
              appSettingController.menuBarItems.length,
              (index) =>
                  appSettingController.menuBarItems[index].screen ??
                  Container(),
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomBar(),
    );
  }
}
