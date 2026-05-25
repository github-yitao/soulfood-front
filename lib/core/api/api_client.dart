import 'package:dio/dio.dart';
import 'package:soulfood_front/core/api/api_result.dart';
import 'package:soulfood_front/core/config/app_config.dart';
import 'package:soulfood_front/core/session/session_store.dart';

class ApiException implements Exception {
  ApiException(this.message, {this.code = -1});

  final String message;
  final int code;

  @override
  String toString() => message;
}

class ApiClient {
  ApiClient(this._session) {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 90),
        headers: {'Content-Type': 'application/json'},
      ),
    );
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = _session.accessToken;
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          } else {
            final userId = _session.userId;
            if (userId != null) {
              options.headers['X-User-Id'] = '$userId';
            }
          }
          handler.next(options);
        },
      ),
    );
  }

  final SessionStore _session;
  late final Dio _dio;

  Future<T> getData<T>(
    String path, {
    Map<String, dynamic>? query,
    required T Function(Object? json) parser,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(path, queryParameters: query);
    return _parse(response.data, parser);
  }

  Future<T> postData<T>(
    String path, {
    Object? data,
    required T Function(Object? json) parser,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(path, data: data);
    return _parse(response.data, parser);
  }

  Future<void> postVoid(String path, {Object? data}) async {
    final response = await _dio.post<Map<String, dynamic>>(path, data: data);
    _ensureOk(response.data);
  }

  Future<T> putData<T>(
    String path, {
    Object? data,
    required T Function(Object? json) parser,
  }) async {
    final response = await _dio.put<Map<String, dynamic>>(path, data: data);
    return _parse(response.data, parser);
  }

  Future<void> deleteVoid(String path) async {
    final response = await _dio.delete<Map<String, dynamic>>(path);
    _ensureOk(response.data);
  }

  T _parse<T>(Map<String, dynamic>? json, T Function(Object? json) parser) {
    final result = _parseResult(json, parser);
    if (result.data == null) {
      throw ApiException('无数据');
    }
    return result.data as T;
  }

  ApiResult<T> _parseResult<T>(Map<String, dynamic>? json, T Function(Object? json) parser) {
    if (json == null) {
      throw ApiException('空响应');
    }
    final result = ApiResult<T>.fromJson(json, parser);
    if (!result.isOk) {
      throw ApiException(result.message, code: result.code);
    }
    return result;
  }

  void _ensureOk(Map<String, dynamic>? json) {
    if (json == null) {
      throw ApiException('空响应');
    }
    final code = json['code'] as int? ?? -1;
    if (code != 0) {
      throw ApiException(json['message'] as String? ?? '请求失败', code: code);
    }
  }
}
