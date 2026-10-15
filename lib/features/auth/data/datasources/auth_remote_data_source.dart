import '../../../../core/error/exceptions.dart';
import '../../../../core/mock/mock_backend.dart';
import '../../../../core/network/api_client.dart';
import '../models/user_model.dart';

abstract interface class AuthRemoteDataSource {
  Future<void> requestOtp(String phone);
  Future<AuthSessionModel> verifyOtp({
    required String phone,
    required String code,
  });
  Future<UserModel> me();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  const AuthRemoteDataSourceImpl(this._api);

  final ApiClient _api;

  @override
  Future<void> requestOtp(String phone) =>
      _api.post('/auth/otp', data: {'phone': phone});

  @override
  Future<AuthSessionModel> verifyOtp({
    required String phone,
    required String code,
  }) async {
    final json = await _api.post(
      '/auth/otp/verify',
      data: {'phone': phone, 'code': code},
    );
    return AuthSessionModel.fromJson(json as Map<String, dynamic>);
  }

  @override
  Future<UserModel> me() async {
    final json = await _api.get('/me');
    return UserModel.fromJson(json as Map<String, dynamic>);
  }
}

class AuthMockDataSource implements AuthRemoteDataSource {
  const AuthMockDataSource(this._backend);

  final MockBackend _backend;

  @override
  Future<void> requestOtp(String phone) => _backend.delay();

  @override
  Future<AuthSessionModel> verifyOtp({
    required String phone,
    required String code,
  }) async {
    await _backend.delay();
    if (code != MockBackend.validOtp) {
      throw const ServerException('Código inválido. Usa 123456 en modo demo.');
    }
    return AuthSessionModel.fromJson({
      'access_token': 'mock-token',
      'user': {..._backend.user, 'phone': phone},
    });
  }

  @override
  Future<UserModel> me() async {
    await _backend.delay();
    return UserModel.fromJson(_backend.user);
  }
}
