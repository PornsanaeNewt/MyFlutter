import 'package:flutter_app_test1/helpers/local_storage_service.dart';
import 'package:get/get.dart';

class UserController extends GetxController {
  RxBool isLogIn = false.obs;

  void setIsLogIn({required bool logIn}) {
    isLogIn.value = logIn;
    update();
  }

  void clearMemberInfo() {
    setIsLogIn(logIn: false);
  }

  Future setUserData({
    int? userId,
    String? email,password,accessToken, refreshToken
  }) async{
    await LocalStorageService().setUserInfo(
      userId: userId, 
      email: email, 
      password: password, 
      accessToken: accessToken, 
      refreshToken: refreshToken);
  }

  
  // Future<String?> getUserInfoController() async {
    
  // }
} 