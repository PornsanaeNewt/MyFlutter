import 'package:dio/dio.dart';
import 'package:flutter_app_test1/helpers/local_storage_service.dart';
import 'package:flutter_app_test1/service/dudee_service.dart';

class AuthInterceptor extends QueuedInterceptor {
  final DudeeService _dudeeService = DudeeService();

  @override
  void onError(DioError err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      try {
        String? refreshToken = await LocalStorageService.getRefreshToken();
        if (refreshToken != null) {
          final response = await _dudeeService.refreshToken(
            refreshToken: refreshToken,
          );
          if (response.statusCode == 200) {
            String newAccessToken = response.data['data']['accessToken'];
            await LocalStorageService.saveToken(newAccessToken);

            final opts = err.requestOptions;
            opts.headers['Authorization'] = 'Bearer $newAccessToken';

            final cloneReq = await DudeeService.dioDudee.fetch(opts);
            return handler.resolve(cloneReq);
          }
        }
      } catch (e) {
        return handler.reject(err);
      }
    }
    return handler.reject(err);
  }
}
