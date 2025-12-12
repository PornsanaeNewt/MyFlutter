import 'package:flutter/material.dart';
import 'package:flutter_app_test1/model/menubar_model.dart';
import 'package:flutter_app_test1/screen/home/widgets/home_widget.dart';
import 'package:flutter_app_test1/screen/profile/view/profile.dart';
import 'package:get/state_manager.dart';

class AppSetting {
  static const String isLogin = 'isLogin';
  static const String userId = 'userId';
  static const String email = 'email';
  static const String name = 'name';
  static const String password = 'password';
  static const String accessToken = 'accessToken';
  static const String refreshToken = 'refreshToken';
}

class AppSettingController extends GetxController{
  final RxInt selectedIndex = 0.obs;

  void setSelectedIndex(int index){
    selectedIndex.value = index;
    update();
  }

  List<MenubarModel> get menuBarItems => [
    MenubarModel(
      label: 'Home',
      icon: const Icon(Icons.home),
      screen: HomeScreen(),
    ),
    MenubarModel(
      label: 'Profile',
      icon: const Icon(Icons.person),
      screen: Profile(),
      ),
  ];

}