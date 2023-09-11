import 'package:dio/dio.dart';
import 'package:dupfinder/config/http_config.dart';
import 'package:dupfinder/http/interceptor.dart';

class HttpRequest {
  HttpRequest._();

  static Dio? _instance;

  static get instance {
    if (_instance == null) {
      BaseOptions options = BaseOptions(
          baseUrl: HttpConfig.baseUrl,
          connectTimeout: const Duration(seconds: HttpConfig.connectTimeout));

      _instance = Dio(options);

      // 添加请求/返回拦截器

      _instance!.interceptors.add(HttpInterceptor());
    }
    return _instance;
  }
}

// 全局单例
Dio? httpInstance = HttpRequest.instance;