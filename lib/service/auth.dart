import 'package:flutter/material.dart';
import 'package:flutter_app_test1/config/routes/app_route.dart';
import 'package:flutter_app_test1/controller/conversation_controller.dart';
import 'package:flutter_app_test1/controller/friend_controller.dart';
import 'package:flutter_app_test1/controller/socket_controller.dart';
import 'package:flutter_app_test1/controller/user_controller.dart';
import 'package:flutter_app_test1/service/dudee_service.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/instance_manager.dart';
import 'package:get/state_manager.dart';
import 'package:go_router/go_router.dart';

class Auth {
  UserController userController = Get.put(UserController());
  SocketController skController = Get.put(SocketController());
  FriendController friendController = Get.put(FriendController());
  ConversationController conversationController = Get.put(
    ConversationController(),
  );

  Future<bool> login(
    BuildContext context, {
    required String email,
    required String password,
  }) async {
    dynamic result = await DudeeService.login(email: email, password: password);
    print(result);
    if (result == 'Successful') {
      userController.setIsLogIn(logIn: true);
      GoRouter.of(context).goNamed(AppRoute.home);
      return true;
    } else {
      return false;
    }
  }

  Future<bool> register(
    BuildContext context, {
    required String email,
    required String password,
    required String name,
  }) async {
    dynamic result = await DudeeService().register(
      email: email,
      password: password,
      name: name,
    );
    print(result.statusCode);
    if (result.statusCode == 201) {
      userController.setIsLogIn(logIn: true);
      GoRouter.of(context).goNamed(AppRoute.home);
      return true;
    } else {
      return false;
    }
  }

  Future<void> logout(BuildContext context) async {
    final logout = await DudeeService().logOut();
    if (logout) {
      await userController.clearMemberInfo();
      await conversationController.clearConversations();
      await friendController.clearFriends();
      GoRouter.of(context).goNamed(AppRoute.login);
    } else {
      Fluttertoast.showToast(
        msg: "Logout failed",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }
}
