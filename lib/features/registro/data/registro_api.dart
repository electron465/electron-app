import '../../../core/error/exceptions.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/token_storage.dart';
import 'cedula_ocr_parser.dart';

class ValidacionCedula {
  const ValidacionCedula({
    required this.cedula,
    required this.enElectron,
    required this.datos,
    required this.ocrToken,
  });

  final String cedula;
  final bool enElectron;
  final Map<String, dynamic> datos;
  final String ocrToken;
}

/// Llamadas al backend-app para el registro por OCR y el login.
class RegistroApi {
  const RegistroApi(this._api, this._tokens);

  final ApiClient _api;
  final TokenStorage _tokens;

  Future<ValidacionCedula> validarCedula(CedulaOcrData ocr) async {
    final json = await _api.post(
      '/registro/validar-cedula',
      data: {
        'cedula': ocr.cedula,
        'primer_nombre': ocr.primerNombre,
        'segundo_nombre': ocr.segundoNombre,
        'primer_apellido': ocr.primerApellido,
        'segundo_apellido': ocr.segundoApellido,
        'fecha_nacimiento': ocr.toJson()['fecha_nacimiento'],
        'sexo': ocr.sexo,
      },
    ) as Map<String, dynamic>;

    return ValidacionCedula(
      cedula: json['cedula'] as String,
      enElectron: json['en_electron'] as bool,
      datos: Map<String, dynamic>.from(json['datos'] as Map),
      ocrToken: json['ocr_token'] as String,
    );
  }

  Future<int> registrar({
    required String ocrToken,
    required String clave,
    required String correo,
    required String telefono,
  }) async {
    final json = await _api.post(
      '/registro',
      data: {
        'ocr_token': ocrToken,
        'clave': clave,
        'correo': correo,
        'telefono': telefono,
      },
    ) as Map<String, dynamic>;
    await _guardarSesion(json);
    return json['usuario_id'] as int;
  }

  Future<void> login({required String cedula, required String clave}) async {
    final json = await _api.post(
      '/login',
      data: {'cedula': cedula, 'clave': clave},
    ) as Map<String, dynamic>;
    await _guardarSesion(json);
  }

  Future<void> _guardarSesion(Map<String, dynamic> json) async {
    final access = json['access_token'] as String?;
    if (access == null) throw const ServerException('Respuesta inválida del servidor.');
    await _tokens.saveAccessToken(access);
    await _tokens.saveRefreshToken(json['refresh_token'] as String);
  }
}
