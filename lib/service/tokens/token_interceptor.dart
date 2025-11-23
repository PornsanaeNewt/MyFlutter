import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_app_test1/helpers/local_storage_service.dart';
import 'package:flutter_app_test1/helpers/network_api.dart';

class Token {
  static const String accessToken = 'accessToken';
  static const String refreshToken = 'refreshToken';
}

class TokenInterceptor extends Interceptor {
  bool _isRefreshing = false;
  final List<Function(RequestOptions)> _retryQueue = [];

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // ใส่ AccessToken ก่อนยิง request
    final accessToken = LocalStorageService.getToken;
    options.headers["Authorization"] = "Bearer ${accessToken}";
    return handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // ถ้า token หมดอายุ (401)
    if (err.response?.statusCode == 401) {
      final requestOptions = err.requestOptions;

      // ถ้ายังไม่มีการ refresh -> เริ่ม refresh
      if (!_isRefreshing) {
        _isRefreshing = true;

        try {
          final newTokens = await _refreshToken();
          final dio = Dio();

          // อัปเดท token
          await LocalStorageService.saveToken(newTokens['accessToken']);

          await LocalStorageService.saveRefreshToken(
            newTokens['refreshToken'],
          );

          // ปล่อย queue ที่รออยู่ให้ยิงใหม่
          // ignore: unused_local_variable
          for (var callback in _retryQueue) {
            _retryQueue.add((RequestOptions requestOptions) async {
              return dio.fetch(requestOptions);
            });
          }
          _retryQueue.clear();

          // ยิง request เดิมใหม่ด้วย token ใหม่
          final clonedRequest = await _retryRequest(requestOptions);
          _isRefreshing = false;

          return handler.resolve(clonedRequest);
        } catch (e) {
          _isRefreshing = false;
          return handler.reject(err);
        }
      } else {
        // ถ้ากำลัง refreshToken อยู่ → ให้รอ
        final response = await _waitAndRetry(requestOptions);
        return handler.resolve(response);
      }
    }

    return handler.next(err);
  }

  // --------------------
  // 🔄 Refresh Token API
  // --------------------
  Future<Map<String, dynamic>> _refreshToken() async {
    final dio = Dio();
    final refreshToken = LocalStorageService.getRefreshToken;
    final res = await dio.post(
      "${NetworkAPI.baseURLDudee}/auth/refresh",
      data: {"refreshToken": refreshToken},
    );

    return res.data['data']; // { accessToken, refreshToken }
  }

  // --------------------
  // 🔁 Retry Request
  // --------------------
  Future<Response> _retryRequest(RequestOptions requestOptions) async {
    final dio = Dio();
    final accessToken = LocalStorageService.getToken;
    requestOptions.headers["Authorization"] = "Bearer ${accessToken}";
    return await dio.fetch(requestOptions);
  }

  // --------------------
  // ⏳ Wait & Retry If Refresh In Progress
  // --------------------
  Future<Response> _waitAndRetry(RequestOptions requestOptions) async {
    final completer = Completer<Response>();

    _retryQueue.add((token) async {
      requestOptions.headers["Authorization"] = "Bearer $token";
      final dio = Dio();
      final result = await dio.fetch(requestOptions);
      completer.complete(result);
    });

    return completer.future;
  }
}
