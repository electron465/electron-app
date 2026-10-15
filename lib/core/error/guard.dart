import 'package:flutter/foundation.dart';
import 'package:fpdart/fpdart.dart';

import 'exceptions.dart';
import 'failures.dart';

/// Ejecuta [call] y traduce excepciones de datos a [Failure].
/// Todos los repositorios lo usan para no repetir try/catch.
Future<Either<Failure, T>> guard<T>(Future<T> Function() call) async {
  try {
    return Right(await call());
  } on UnauthorizedException {
    return const Left(UnauthorizedFailure());
  } on NetworkException {
    return const Left(NetworkFailure());
  } on ServerException catch (e) {
    return Left(ServerFailure(e.message));
  } on CacheException {
    return const Left(CacheFailure());
  } catch (e, st) {
    debugPrint('Unexpected error: $e\n$st');
    return const Left(UnexpectedFailure());
  }
}
