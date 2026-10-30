import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user.dart';

abstract interface class AuthRepository {
  /// Envía un código OTP por SMS al teléfono indicado.
  Future<Either<Failure, Unit>> requestOtp(String phone);

  Future<Either<Failure, User>> verifyOtp({
    required String phone,
    required String code,
  });

  Future<Either<Failure, void>> createPassword({
    required String identifier,
    required String password,
  });

  /// Devuelve el usuario de la sesión guardada o `null` si no hay sesión.
  Future<Either<Failure, User?>> getCurrentUser();

  Future<Either<Failure, Unit>> logout();
}
