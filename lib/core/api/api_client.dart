import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:soulfood_front/core/api/api_result.dart';
import 'package:soulfood_front/core/auth/auth_session_guard.dart';
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
    _dio.interceptors.addAll([
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
        onResponse: (response, handler) {
          if (response.requestOptions.extra['skip_auth_recovery'] != true) {
            _maybeHandleUnauthorized(
              response.requestOptions.path,
              response.data,
            );
          }
          handler.next(response);
        },
        onError: (error, handler) async {
          final path = error.requestOptions.path;
          final status = error.response?.statusCode;
          final skipRecovery =
              error.requestOptions.extra['skip_auth_recovery'] == true;
          final alreadyRetried =
              error.requestOptions.extra['_auth_refresh_tried'] == true;

          if (!skipRecovery && status == 401 && !alreadyRetried) {
            final refreshed = await _tryRefreshToken();
            if (refreshed) {
              error.requestOptions.extra['_auth_refresh_tried'] = true;
              try {
                final response = await _dio.fetch(error.requestOptions);
                return handler.resolve(response);
              } on DioException catch (retryError) {
                return handler.next(retryError);
              }
            }
            final data = error.response?.data;
            final message = data is Map ? data['message'] as String? : null;
            _maybeHandleUnauthorized(path, data, force: true, message: message);
          }
          handler.next(error);
        },
      ),
      _RetryInterceptor(_dio),
    ]);
  }

  final SessionStore _session;
  late final Dio _dio;
  bool _refreshing = false;

  Future<T> getData<T>(
    String path, {
    Map<String, dynamic>? query,
    required T Function(Object? json) parser,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        path,
        queryParameters: query,
      );
      return _parse(response.data, parser);
    } on DioException catch (e) {
      throw _toApiException(e);
    }
  }

  Future<T> postData<T>(
    String path, {
    Object? data,
    required T Function(Object? json) parser,
    bool skipAuthRecovery = false,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        path,
        data: data,
        options: Options(
          extra: {if (skipAuthRecovery) 'skip_auth_recovery': true},
        ),
      );
      return _parse(response.data, parser);
    } on DioException catch (e) {
      throw _toApiException(e);
    }
  }

  Future<void> postVoid(
    String path, {
    Object? data,
    bool skipAuthRecovery = false,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        path,
        data: data,
        options: Options(
          extra: {if (skipAuthRecovery) 'skip_auth_recovery': true},
        ),
      );
      _ensureOk(response.data);
    } on DioException catch (e) {
      throw _toApiException(e);
    }
  }

  Future<T> postMultipart<T>(
    String path, {
    required String filePath,
    required String fieldName,
    required T Function(Object? json) parser,
  }) async {
    try {
      final formData = FormData.fromMap({
        fieldName: await MultipartFile.fromFile(filePath),
      });
      final response = await _dio.post<Map<String, dynamic>>(
        path,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
      );
      return _parse(response.data, parser);
    } on DioException catch (e) {
      throw _toApiException(e);
    }
  }

  Future<T> putData<T>(
    String path, {
    Object? data,
    required T Function(Object? json) parser,
  }) async {
    try {
      final response = await _dio.put<Map<String, dynamic>>(path, data: data);
      return _parse(response.data, parser);
    } on DioException catch (e) {
      throw _toApiException(e);
    }
  }

  Future<void> deleteVoid(String path) async {
    try {
      final response = await _dio.delete<Map<String, dynamic>>(path);
      _ensureOk(response.data);
    } on DioException catch (e) {
      throw _toApiException(e);
    }
  }

  Future<void> patchVoid(String path, {Object? data}) async {
    try {
      final response = await _dio.patch<Map<String, dynamic>>(path, data: data);
      _ensureOk(response.data);
    } on DioException catch (e) {
      throw _toApiException(e);
    }
  }

  Future<T> patchData<T>(
    String path, {
    Object? data,
    required T Function(Object? json) parser,
  }) async {
    try {
      final response = await _dio.patch<Map<String, dynamic>>(path, data: data);
      return _parse(response.data, parser);
    } on DioException catch (e) {
      throw _toApiException(e);
    }
  }

  /// NDJSON 流式 POST，每行一个 JSON 对象
  Stream<Map<String, dynamic>> postNdjsonStream(
    String path, {
    Object? data,
  }) async* {
    try {
      final response = await _dio.post<ResponseBody>(
        path,
        data: data,
        options: Options(
          responseType: ResponseType.stream,
          receiveTimeout: const Duration(seconds: 120),
          headers: const {'Accept': 'application/x-ndjson'},
        ),
      );
      final body = response.data;
      if (body == null) return;

      var pending = '';
      await for (final chunk in utf8.decoder.bind(body.stream)) {
        pending += chunk;
        final extracted = _extractJsonObjects(pending);
        pending = extracted.rest;
        for (final objectText in extracted.objects) {
          final decoded = jsonDecode(objectText);
          if (decoded is Map<String, dynamic>) {
            yield decoded;
          }
        }
      }
      final tail = pending.trim();
      if (tail.isNotEmpty) {
        final decoded = jsonDecode(tail);
        if (decoded is Map<String, dynamic>) {
          yield decoded;
        }
      }
    } on DioException catch (e) {
      throw _toApiException(e);
    }
  }

  _JsonObjectBatch _extractJsonObjects(String input) {
    final objects = <String>[];
    var depth = 0;
    var inString = false;
    var escaping = false;
    var start = -1;
    var lastConsumed = 0;

    for (var i = 0; i < input.length; i++) {
      final ch = input[i];
      if (escaping) {
        escaping = false;
        continue;
      }
      if (ch == '\\') {
        escaping = true;
        continue;
      }
      if (ch == '"') {
        inString = !inString;
        continue;
      }
      if (inString) continue;

      if (ch == '{') {
        if (depth == 0) start = i;
        depth++;
      } else if (ch == '}') {
        if (depth > 0) depth--;
        if (depth == 0 && start >= 0) {
          objects.add(input.substring(start, i + 1));
          lastConsumed = i + 1;
          start = -1;
        }
      }
    }

    final rest = input.substring(lastConsumed).trimLeft();
    return _JsonObjectBatch(objects: objects, rest: rest);
  }

  T _parse<T>(Map<String, dynamic>? json, T Function(Object? json) parser) {
    final result = _parseResult(json, parser);
    if (result.data == null) {
      throw ApiException('无数据');
    }
    return result.data as T;
  }

  ApiResult<T> _parseResult<T>(
    Map<String, dynamic>? json,
    T Function(Object? json) parser,
  ) {
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

  void _maybeHandleUnauthorized(
    String path,
    Object? data, {
    bool force = false,
    String? message,
  }) {
    if (AuthSessionGuard.shouldIgnorePath(path)) return;

    var code = force ? 401 : null;
    String? msg = message;
    if (data is Map<String, dynamic>) {
      code ??= data['code'] as int?;
      msg ??= data['message'] as String?;
    }
    if (code == 401) {
      unawaited(
        AuthSessionGuard.handleUnauthorized(message: msg ?? '登录已过期，请重新登录'),
      );
    }
  }

  Future<bool> _tryRefreshToken() async {
    if (_refreshing) return false;
    final refresh = _session.refreshToken;
    if (refresh == null || refresh.isEmpty) return false;

    _refreshing = true;
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/v1/auth/refresh',
        data: {'refreshToken': refresh},
        options: Options(extra: {'skip_auth_recovery': true}),
      );
      final json = response.data;
      if (json == null || (json['code'] as int? ?? -1) != 0) return false;
      final data = json['data'] as Map<String, dynamic>?;
      if (data == null) return false;
      final access = data['token'] as String? ?? '';
      final nextRefresh = data['refreshToken'] as String? ?? '';
      if (access.isEmpty || nextRefresh.isEmpty) return false;
      await _session.updateTokens(
        accessToken: access,
        refreshToken: nextRefresh,
      );
      return true;
    } catch (_) {
      return false;
    } finally {
      _refreshing = false;
    }
  }

  ApiException _toApiException(DioException e) {
    final status = e.response?.statusCode;
    if (status == 530 || status == 502 || status == 503 || status == 504) {
      return ApiException(
        '后端暂时不可用（$status），请确认本机后端已启动后重试。',
        code: status ?? -1,
      );
    }
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException('请求超时，请检查网络后重试', code: -1);
      case DioExceptionType.connectionError:
        return ApiException('无法连接服务器，请确认后端已在 8080 端口运行', code: -1);
      default:
        final msg = e.response?.data is Map
            ? (e.response!.data as Map)['message'] as String?
            : null;
        return ApiException(msg ?? e.message ?? '网络请求失败', code: status ?? -1);
    }
  }
}

class _JsonObjectBatch {
  const _JsonObjectBatch({required this.objects, required this.rest});

  final List<String> objects;
  final String rest;
}

/// 瞬时网络/网关错误自动重试，避免用户手动刷新。
class _RetryInterceptor extends Interceptor {
  _RetryInterceptor(this._dio);

  final Dio _dio;
  static const _maxAttempts = 3;

  static const _retryKey = '_api_retry_count';

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final attempt = (err.requestOptions.extra[_retryKey] as int?) ?? 0;
    if (attempt >= _maxAttempts - 1 || !_isTransient(err)) {
      return handler.next(err);
    }

    err.requestOptions.extra[_retryKey] = attempt + 1;
    await Future<void>.delayed(Duration(milliseconds: 400 * (attempt + 1)));

    try {
      final response = await _dio.fetch(err.requestOptions);
      return handler.resolve(response);
    } on DioException catch (e) {
      return handler.next(e);
    }
  }

  bool _isTransient(DioException err) {
    final status = err.response?.statusCode;
    if (status == 502 || status == 503 || status == 504 || status == 530) {
      return true;
    }
    return err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.connectionTimeout;
  }
}
