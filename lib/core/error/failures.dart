import 'package:equatable/equatable.dart';

/// Errores de dominio que la capa de presentación sabe mostrar.
sealed class Failure extends Equatable {
  const Failure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

final class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Ocurrió un error en el servidor.']);
}

final class NetworkFailure extends Failure {
  const NetworkFailure([
    super.message = 'Sin conexión. Verifica tu internet e intenta de nuevo.',
  ]);
}

final class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([
    super.message = 'Tu sesión expiró. Inicia sesión nuevamente.',
  ]);
}

final class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Error leyendo datos locales.']);
}

final class UnexpectedFailure extends Failure {
  const UnexpectedFailure([super.message = 'Ocurrió un error inesperado.']);
}
