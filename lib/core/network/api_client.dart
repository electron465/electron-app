import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../error/exceptions.dart';
import '../storage/token_storage.dart';
import 'auth_interceptor.dart';

/// Envoltorio sobre Dio: centraliza configuración, interceptores y
/// el mapeo de errores HTTP a excepciones de la capa de datos.
class ApiClient {
  ApiClient({required String baseUrl, required TokenStorage tokenStorage})
    : _dio = Dio(
        BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 20),
          headers: {'Accept': 'application/json'},
        ),
      ) {
    _dio.interceptors.addAll([
      AuthInterceptor(tokenStorage),
      if (kDebugMode) LogInterceptor(requestBody: true, responseBody: true),
    ]);
  }

  final Dio _dio;

  static const _networkErrors = {
    DioExceptionType.connectionTimeout,
    DioExceptionType.sendTimeout,
    DioExceptionType.receiveTimeout,
    DioExceptionType.connectionError,
  };

  Future<dynamic> get(String path, {Map<String, dynamic>? query}) =>
      _request(() => _dio.get<dynamic>(path, queryParameters: query));

  Future<dynamic> post(String path, {Object? data}) =>
      _request(() => _dio.post<dynamic>(path, data: data));

  Future<dynamic> _request(Future<Response<dynamic>> Function() call) async {
    try {
      final response = await call();
      return response.data;
    } on DioException catch (e) {
      if (_networkErrors.contains(e.type)) throw const NetworkException();

      final statusCode = e.response?.statusCode;
      if (statusCode == 401) throw const UnauthorizedException();

      final data = e.response?.data;
      final message = data is Map && data['message'] is String
          ? data['message'] as String
          : 'Ocurrió un error en el servidor.';
      throw ServerException(message, statusCode: statusCode);
    }
  }
}
