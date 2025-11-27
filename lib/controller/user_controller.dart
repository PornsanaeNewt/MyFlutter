import 'package:flutter_app_test1/helpers/local_storage_service.dart';
import 'package:flutter_app_test1/model/user_profile.dart';
import 'package:flutter_app_test1/service/dudee_service.dart';
import 'package:get/get.dart';

class UserController extends GetxController {
  RxBool isLogIn = false.obs;

  Rx<UserProfile?> userProfile = Rx<UserProfile?>(null);

  void setIsLogIn({required bool logIn}) async {
    await LocalStorageService.saveIsLogin(logIn);
    final isLogin = await LocalStorageService.getIsLogin();
    isLogIn.value = isLogin;
    update();
  }

  Future<void> fetchUserProfile() async {
    try {
      final response = await DudeeService().getUserProfile();
      userProfile.value = response;
      update();
    } catch (e) {
      print("Error fetching user profile: $e");
    }
  }

  void clearMemberInfo() {
    setIsLogIn(logIn: false);
  }
}
