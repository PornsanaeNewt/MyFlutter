import 'package:flutter_app_test1/helpers/app_setting.dart';
import 'package:flutter_app_test1/service/tokens/token_interceptor.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(Token.accessToken, token);

  }

  static Future<String?> getToken(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);

  }

  static Future<void> deleteToken(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  static Future<void> saveRefreshToken(String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(Token.refreshToken, refreshToken);
  }

  static Future<String?> getRefreshToken(String refkey) async {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString(refkey);
      return refreshToken;
  }

  static Future<void> deleteRefreshToken(String refkey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(refkey);
  }
  
  Future<void> setUserInfo({int? userId , String? email, password, accessToken, refreshToken}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (userId != null) {
        prefs.setInt(AppSetting.userId, userId); 
    } else {
        prefs.remove(AppSetting.userId); 
    }
    prefs.setString(AppSetting.email, email ?? "");
    prefs.setString(AppSetting.password, password ?? "");
    prefs.setString(AppSetting.accessToken, accessToken ?? "");
    prefs.setString(AppSetting.refreshToken, refreshToken ?? "");
  }

  Future<Map<String, dynamic>> getUserInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // 1. ดึงข้อมูล userId (ประเภท int)
    // ใช้ .getInt(). ถ้าไม่มีค่าอยู่ จะคืนค่าเป็น null
    final int? userId = prefs.getInt(AppSetting.userId); 

    // 2. ดึงข้อมูล String อื่นๆ
    // ใช้ .getString(). ถ้าไม่มีค่าอยู่ จะคืนค่าเป็น null
    final String? email = prefs.getString(AppSetting.email);
    final String? password = prefs.getString(AppSetting.password);
    final String? accessToken = prefs.getString(AppSetting.accessToken);
    final String? refreshToken = prefs.getString(AppSetting.refreshToken);

    // 3. รวบรวมข้อมูลทั้งหมดในรูปแบบ Map เพื่อให้ง่ายต่อการนำไปใช้งาน
    return {
        'userId': userId,
        'email': email,
        'password': password,
        'accessToken': accessToken,
        'refreshToken': refreshToken,
    };
  }
}