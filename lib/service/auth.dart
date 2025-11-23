import 'package:flutter/material.dart';
import 'package:flutter_app_test1/config/routes/app_route.dart';
import 'package:flutter_app_test1/controller/user_controller.dart';
import 'package:flutter_app_test1/service/dudee_service.dart';
import 'package:get/instance_manager.dart';
import 'package:get/state_manager.dart';
import 'package:go_router/go_router.dart';

class Auth {
  UserController userController = Get.put(UserController());

  Future<bool> login(
    BuildContext context, {
      required String email,
      required String password,
  }) async {
    dynamic result = await DudeeService.login(email: email, password: password);
    print(result);
    if (result == 'Successful') {
      userController.setIsLogIn(logIn: true);
      // userController.setUserData();
      GoRouter.of(context).goNamed(AppRoute.home);
      return true;
    }else{
      return false;
    }
  }
}