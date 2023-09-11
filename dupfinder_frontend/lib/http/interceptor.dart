import 'package:dio/dio.dart';

class HttpInterceptor extends InterceptorsWrapper {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (response.statusCode == 200) {
      handler.next(response);
    } else {
      handler.reject(DioException.badResponse(
          statusCode: response.statusCode!,
          requestOptions: response.requestOptions,
          response: response));
    }
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // TODO: implement onError

    super.onError(err, handler);
  }
}
