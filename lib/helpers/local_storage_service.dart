import 'package:flutter_app_test1/helpers/app_setting.dart';
import 'package:flutter_app_test1/service/tokens/token_interceptor.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(Token.accessToken, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(Token.accessToken);
  }

  static Future<void> deleteToken(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  static Future<void> saveRefreshToken(String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(Token.refreshToken, refreshToken);
  }

  static Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString(Token.refreshToken);
    return refreshToken;
  }

  static Future<void> deleteRefreshToken(String refkey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(refkey);
  }

  Future<void> setUserInfo({int? userId, String? email, name}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (userId != null) {
      prefs.setInt(AppSetting.userId, userId);
    } else {
      prefs.remove(AppSetting.userId);
    }
    prefs.setString(AppSetting.email, email ?? "");
    prefs.setString(AppSetting.name, name ?? "");
  }

  Future<Map<String, dynamic>> getUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final int? userId = prefs.getInt(AppSetting.userId);
    final String? email = prefs.getString(AppSetting.email);
    final String? name = prefs.getString(AppSetting.name);

    return {'userId': userId, 'email': email, 'name': name};
  }

  static Future<void> saveIsLogin(bool isLogin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppSetting.isLogin, isLogin);
  }

  static Future<bool> getIsLogin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(AppSetting.isLogin) ?? false;
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
