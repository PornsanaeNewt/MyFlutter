import 'package:dio/dio.dart';
import 'package:flutter_app_test1/config/app_config.dart';
import 'package:flutter_app_test1/helpers/local_storage_service.dart';
import 'package:flutter_app_test1/helpers/network_api.dart';
import 'package:flutter_app_test1/model/user_profile.dart';
import 'package:flutter_app_test1/service/app_service.dart';
import 'package:flutter_app_test1/service/fmc/firebase_analytics.dart';
import 'package:flutter_app_test1/service/tokens/token_interceptor.dart';
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
              final makeToken = await LocalStorageService.getToken(Token.accessToken);
              // final makeToken = AppConfig.makeTokenAuthorization;

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
              String? refreshToken =
                  await LocalStorageService.getRefreshToken(
                    'refreshToken',
                  );
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

  Future<Response> register({
    required String email,
    required String password,
    required String name,
  }) async {
    final data = {'email': email, 'password': password, 'name': name};
    final response = await _dioDudee.post(NetworkAPI.register, data: data);
    if (response.statusCode == 201 && response.data['message'] == 'User registered successfully.') {
     final dataPayload = response.data['data'] as Map<String, dynamic>;
      print('Data Payload received: $dataPayload');
      final String accessToken = dataPayload['accessToken'] as String;
      final String refreshToken = dataPayload['refreshToken'] as String;
      await LocalStorageService.saveToken(accessToken);
      await LocalStorageService.saveRefreshToken(refreshToken);
    }else {
       throw DudeeServiceException(
        message: 'Register failed: Invalid response structure.',
      );
    }
    return response;
  }

  static Future<String?> login({
    required String email,
    required String password,
  }) async {
    final data = {'email': email, 'password': password};
    final response = await _dioDudee.post(NetworkAPI.login, data: data);
    print('response status : ${response.statusCode}');
    if (response.statusCode == 400 &&
        response.data['message'] == 'Something went wrong.') {
      throw DudeeServiceException(
        message: 'Login failed: Invalid response structure.',
      );
    } else if (response.statusCode == 200) {
      final dataPayload = response.data['data'] as Map<String, dynamic>;
      final String accessToken = dataPayload['accessToken'] as String;
      final String refreshToken = dataPayload['refreshToken'] as String;
      await LocalStorageService.saveToken(accessToken);
      await LocalStorageService.saveRefreshToken(refreshToken);
      return 'Successful';
    } else {
       if (response.data.containsKey('message')) {
        return response.data['message'];
      } else {
        return response.data['errors'];
      }
    }
  }

  Future<Response> refreshToken({required String refreshToken}) async {
    String? ref = await LocalStorageService.getRefreshToken(
      'refreshToken',
    );
    final data = {ref: refreshToken};
    return await _dioDudee.post('/auth/refresh', data: data);
  }

  // Get User Profile
  Future<UserProfile> getUserProfile() async {
    try {
      final response = await _dioDudee.get('${NetworkAPI.userProfile}');
      print('Get Profile Status ${response.statusCode}');
      if (response.statusCode == 200) {
        final userProfile = UserProfile.fromJson(response.data);
        return userProfile;
      } else {
        throw DudeeServiceException(
          message: 'Failed to load user profile',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<Response> logOut() async {
    final response = await _dioDudee.post('${NetworkAPI.logout}');
    print('logout response ${response.statusCode}');
    if(response.statusCode == 201 && response.data['status'] == 'success'){
      return response;
    }else{
      throw DudeeServiceException(message: 'Logged out successfully.');
    }
  }
}
