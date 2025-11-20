import 'package:flutter_app_test1/service/tokens/token.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesProvider {
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
}