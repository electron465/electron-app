import 'package:equatable/equatable.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class RequestOtp implements UseCase<Unit, String> {
  const RequestOtp(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(String phone) =>
      _repository.requestOtp(phone);
}

class VerifyOtpParams extends Equatable {
  const VerifyOtpParams({required this.phone, required this.code});

  final String phone;
  final String code;

  @override
  List<Object?> get props => [phone, code];
}

class VerifyOtp implements UseCase<User, VerifyOtpParams> {
  const VerifyOtp(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, User>> call(VerifyOtpParams params) =>
      _repository.verifyOtp(phone: params.phone, code: params.code);
}

class CreatePassword implements UseCase<void, Map<String, String>> {
  final AuthRepository repository;
  CreatePassword(this.repository);

  @override
  Future<Either<Failure, void>> call(Map<String, String> params) {
    return repository.createPassword(
      identifier: params['identifier']!,
      password: params['password']!,
    );
  }
}


class GetCurrentUser implements UseCase<User?, NoParams> {
  const GetCurrentUser(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, User?>> call(NoParams params) =>
      _repository.getCurrentUser();
}

class Logout implements UseCase<Unit, NoParams> {
  const Logout(this._repository);

  final AuthRepository _repository;

  @override
  Future<Either<Failure, Unit>> call(NoParams params) => _repository.logout();
}
