import 'package:dio/dio.dart';

class DioHelper {
  static const _baseUrl = 'https://api.d-id.com';
  static const String _api_key = "d3g5NTM5OTkxMDlAZ21haWwuY29t:xpaDOP55y30JHnnI-aij2";
  static const Duration _defaultTimeoutDuration = Duration(seconds: 290);
  static final Dio _dio = Dio(BaseOptions(
    baseUrl: _baseUrl,
    connectTimeout: _defaultTimeoutDuration,
    sendTimeout: _defaultTimeoutDuration,
    receiveTimeout: _defaultTimeoutDuration,
  ));

  static Map<String, String> _getHeaders() {
    Map<String, String>? headers = {};
    headers.putIfAbsent("Authorization", () => 'Basic $_api_key');
    headers.putIfAbsent("Content-Type", () => 'application/json');
    return headers;
  }

  static Future<Response> post(String path, {dynamic data, dynamic queryParameters}) {
    return _dio.post(_baseUrl + (path.startsWith("/") ? '' : '/') + path,
        data: data,
        queryParameters: queryParameters,
        options: Options(
          contentType: Headers.jsonContentType,
          headers: _getHeaders(),
          sendTimeout: _defaultTimeoutDuration,
          receiveTimeout: _defaultTimeoutDuration,
          responseType: ResponseType.json,
        ));
  }

  static Future<Response> newChat(String agentId) {
    return _dio.post('$_baseUrl/agents/$agentId/chat',
        options: Options(
          contentType: Headers.jsonContentType,
          headers: _getHeaders(),
          sendTimeout: _defaultTimeoutDuration,
          receiveTimeout: _defaultTimeoutDuration,
          responseType: ResponseType.json,
        ));
  }

  static dynamic newSession() {}
}
