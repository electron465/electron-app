import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Guarda credenciales en Keychain (iOS) / Keystore (Android).
class TokenStorage {
  const TokenStorage(this._storage);

  final FlutterSecureStorage _storage;

  static const _accessTokenKey = 'access_token';

  Future<String?> readAccessToken() => _storage.read(key: _accessTokenKey);

  Future<void> saveAccessToken(String token) =>
      _storage.write(key: _accessTokenKey, value: token);

  Future<void> clear() => _storage.delete(key: _accessTokenKey);
}
