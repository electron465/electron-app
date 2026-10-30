import 'package:equatable/equatable.dart';
import 'package:dartz/dartz.dart';
import '../error/failures.dart';

/// Contrato de un caso de uso: una sola acción de negocio.
abstract interface class UseCase<T, Params> {
  Future<Either<Failure, T>> call(Params params);
}

final class NoParams extends Equatable {
  const NoParams();

  @override
  List<Object?> get props => [];
}
