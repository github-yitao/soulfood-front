class ApiResult<T> {
  ApiResult({
    required this.code,
    required this.message,
    this.data,
  });

  final int code;
  final String message;
  final T? data;

  bool get isOk => code == 0;

  factory ApiResult.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) {
    return ApiResult<T>(
      code: json['code'] as int? ?? -1,
      message: json['message'] as String? ?? '',
      data: json['data'] == null ? null : fromJsonT(json['data']),
    );
  }
}
