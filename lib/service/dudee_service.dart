import 'package:dio/dio.dart';
import 'package:flutter_app_test1/config/app_config.dart';
import 'package:flutter_app_test1/helpers/network_api.dart';
import 'package:flutter_app_test1/service/app_service.dart';
import 'package:flutter_app_test1/service/fmc/firebase_analytics.dart';
import 'package:flutter_app_test1/service/SharedPreferences/shared_preferences.dart';
//import 'package:logarte/logarte.dart';

/// Custom Exception สำหรับ DudeeService
class DudeeServiceException implements Exception {
  final String message;
  final int? statusCode;

  DudeeServiceException({required this.message, this.statusCode});

  @override
  String toString() => message;
}

/// Service สำหรับจัดการ API calls กับ Dudee backend
class DudeeService {
  // Singleton pattern
  DudeeService._internal();
  static final DudeeService _instance = DudeeService._internal();
  factory DudeeService() => _instance;

  /// Dio instance สำหรับ API calls หลัก
  static final Dio _dioDudee =
      Dio()
        //..interceptors.add(LogarteDioInterceptor(logarte))
        ..interceptors.add(
          InterceptorsWrapper(
            onRequest: (requestOptions, handler) async {
              requestOptions.connectTimeout = const Duration(seconds: 30);
              requestOptions.receiveTimeout = const Duration(seconds: 30);
              requestOptions.baseUrl = NetworkAPI.baseURLDudee;

              // Headers
              final makeToken = AppConfig.makeTokenAuthorization;
              final secretkey = AppConfig.secretKey;
              final cookie = AppConfig.cookie;

              requestOptions.headers['Authorization'] = 'Bearer $makeToken';
              requestOptions.headers['secretkey'] = secretkey;
              requestOptions.headers['Cookie'] = cookie;

              return handler.next(requestOptions);
            },
            onResponse: (response, handler) async {
              return handler.next(response);
            },
            onError: (dioError, handler) async {
              String? refreshToken = await SharedPreferencesProvider.getRefreshToken('refreshToken');
              if (refreshToken == null) {
                
                return handler.next(dioError);
                
              }
              // Log error
              AnalyticsService.logError(
                errorMessage: 'Dio Network Error',
                errorDetails:
                    'URL: ${dioError.requestOptions.uri}, '
                    'Status Code: ${dioError.response?.statusCode}, '
                    'Error: ${dioError.message}',
                stackTrace: dioError.stackTrace.toString(),
              );

              // Handle timeout errors
              if (dioError.type == DioExceptionType.connectionTimeout ||
                  dioError.type == DioExceptionType.receiveTimeout) {
                final errorText = await AppService().getErrorTextInfo();
                AnalyticsService.logError(
                  errorMessage: 'Dio 524 Error',
                  errorDetails:
                      'Connection timed out. ${dioError.requestOptions.uri} $errorText',
                );
              }

              // Handle 400 errors
              if (dioError.response != null &&
                  dioError.response!.statusCode == 400 &&
                  dioError.response!.data.containsKey('errors')) {
                final responseData = dioError.response!.data;
                await AppService().checkLicenseUser(
                  msgError: responseData['errors'],
                );

                AnalyticsService.logError(
                  errorMessage: 'Dio 400 Error',
                  errorDetails:
                      'Error Response Data: ${responseData['errors']}',
                );
              }

              // Handle non-response errors
              if (dioError.response == null) {
                AnalyticsService.logError(
                  errorMessage: 'Dio Non-Response Error',
                  errorDetails: 'Error: ${dioError.message}',
                );
              }

              return handler.next(dioError);
            },
          ),
        );

  static Dio get dioDudee => _dioDudee;

  Future<Response> get(String url) async {
    return await _dioDudee.get(url);
  }

  Future<Response> post(String url, {dynamic data}) async {
    return await _dioDudee.post(url, data: data);
  }

  Future<Response> Register({
    required String email,
    required String password,
    required String name,
  }) async {
    final data = {'email': email, 'password': password, 'name': name};
    final response = await _dioDudee.post('/auth/register', data: data);
    return response;
  }

  Future<Response> Login({
    required String email,
    required String password,
  }) async {
    final data = {'email': email, 'password': password};
    final response = await _dioDudee.post('/auth/login', data: data);

    if (response.data == null || response.data['data'] == null) {
      throw DudeeServiceException(message: 'Login failed: Invalid response structure.');
    }

    final dataPayload = response.data['data'] as Map<String, dynamic>; 
    print('Data Payload received: $dataPayload');

    final String accessToken = dataPayload['accessToken'] as String; 
    final String refreshToken = dataPayload['refreshToken'] as String; 

    await SharedPreferencesProvider.saveToken(accessToken);
    await SharedPreferencesProvider.saveRefreshToken(refreshToken); 

    return response;
  }

  Future<Response> refreshToken({required String refreshToken}) async {
    String? ref = await SharedPreferencesProvider.getRefreshToken('refreshToken');
    final data = {ref: refreshToken};
    return await _dioDudee.post('/auth/refresh', data: data);
  }

  Future<Response> getUserProfile() async {
    return await _dioDudee.get('/auth/me');
  }

  Future<Response> logout() async {
    return await _dioDudee.post('/auth/logout');
  }

}
