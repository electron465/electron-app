import 'package:fpdart/fpdart.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/guard.dart';
import '../../../../core/storage/token_storage.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._remote, this._tokenStorage);

  final AuthRemoteDataSource _remote;
  final TokenStorage _tokenStorage;

  @override
  Future<Either<Failure, Unit>> requestOtp(String phone) => guard(() async {
    await _remote.requestOtp(phone);
    return unit;
  });

  @override
  Future<Either<Failure, User>> verifyOtp({
    required String phone,
    required String code,
  }) => guard(() async {
    final session = await _remote.verifyOtp(phone: phone, code: code);
    await _tokenStorage.saveAccessToken(session.accessToken);
    return session.user;
  });

  @override
  Future<Either<Failure, User?>> getCurrentUser() => guard<User?>(() async {
    final token = await _tokenStorage.readAccessToken();
    if (token == null) return null;
    try {
      return await _remote.me();
    } on UnauthorizedException {
      await _tokenStorage.clear();
      return null;
    }
  });

  @override
  Future<Either<Failure, Unit>> logout() => guard(() async {
    await _tokenStorage.clear();
    return unit;
  });
}
