/// Excepciones de la capa de datos. Nunca deben llegar a la UI:
/// los repositorios las convierten en [Failure] (ver `guard`).
class ServerException implements Exception {
  const ServerException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;
}

class NetworkException implements Exception {
  const NetworkException();
}

class UnauthorizedException implements Exception {
  const UnauthorizedException();
}

class CacheException implements Exception {
  const CacheException();
}
