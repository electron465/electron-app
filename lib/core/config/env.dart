/// Configuración por entorno inyectada en compilación con `--dart-define`.
///
/// Ejemplo:
/// ```
/// flutter run --dart-define=FLAVOR=prod \
///   --dart-define=API_BASE_URL=https://api.miapp.com/v1 \
///   --dart-define=USE_MOCKS=false
/// ```
abstract final class Env {
  static const flavor = String.fromEnvironment('FLAVOR', defaultValue: 'dev');

  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.dev.example.com/v1',
  );

  /// Mientras no exista backend, la app funciona con datos simulados.
  static const useMocks = bool.fromEnvironment('USE_MOCKS', defaultValue: true);

  static bool get isProd => flavor == 'prod';
}
