import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/exceptions.dart';
import '../../data/cedula_ocr_parser.dart';
import '../../data/registro_api.dart';

enum CedulaRegistroStatus { validando, lista, registrando, exito, error }

class CedulaRegistroState extends Equatable {
  const CedulaRegistroState({
    this.status = CedulaRegistroStatus.validando,
    this.cedula = '',
    this.enElectron = false,
    this.datos = const {},
    this.ocrToken = '',
    this.mensaje = '',
    this.cedulaYaRegistrada = false,
    this.usuarioId,
  });

  final CedulaRegistroStatus status;
  final String cedula;
  final bool enElectron;
  final Map<String, dynamic> datos;
  final String ocrToken;
  final String mensaje;
  final bool cedulaYaRegistrada;
  final int? usuarioId;

  CedulaRegistroState copyWith({
    CedulaRegistroStatus? status,
    String? cedula,
    bool? enElectron,
    Map<String, dynamic>? datos,
    String? ocrToken,
    String? mensaje,
    bool? cedulaYaRegistrada,
    int? usuarioId,
  }) =>
      CedulaRegistroState(
        status: status ?? this.status,
        cedula: cedula ?? this.cedula,
        enElectron: enElectron ?? this.enElectron,
        datos: datos ?? this.datos,
        ocrToken: ocrToken ?? this.ocrToken,
        mensaje: mensaje ?? this.mensaje,
        cedulaYaRegistrada: cedulaYaRegistrada ?? this.cedulaYaRegistrada,
        usuarioId: usuarioId ?? this.usuarioId,
      );

  @override
  List<Object?> get props =>
      [status, cedula, enElectron, datos, ocrToken, mensaje, cedulaYaRegistrada, usuarioId];
}

class CedulaRegistroCubit extends Cubit<CedulaRegistroState> {
  CedulaRegistroCubit(this._api) : super(const CedulaRegistroState());

  final RegistroApi _api;

  Future<void> validar(CedulaOcrData ocr) async {
    emit(state.copyWith(status: CedulaRegistroStatus.validando, mensaje: ''));
    try {
      final r = await _api.validarCedula(ocr);
      emit(state.copyWith(
        status: CedulaRegistroStatus.lista,
        cedula: r.cedula,
        enElectron: r.enElectron,
        datos: r.datos,
        ocrToken: r.ocrToken,
      ));
    } on ServerException catch (e) {
      emit(state.copyWith(
        status: CedulaRegistroStatus.error,
        mensaje: e.message,
        cedulaYaRegistrada: e.statusCode == 409,
      ));
    } on NetworkException {
      emit(state.copyWith(
        status: CedulaRegistroStatus.error,
        mensaje: 'Sin conexión con el servidor. Revise su red e intente de nuevo.',
      ));
    }
  }

  Future<void> registrar({
    required String clave,
    required String correo,
    required String telefono,
  }) async {
    emit(state.copyWith(status: CedulaRegistroStatus.registrando, mensaje: ''));
    try {
      final id = await _api.registrar(
        ocrToken: state.ocrToken,
        clave: clave,
        correo: correo,
        telefono: telefono,
      );
      emit(state.copyWith(status: CedulaRegistroStatus.exito, usuarioId: id));
    } on ServerException catch (e) {
      emit(state.copyWith(
        status: CedulaRegistroStatus.error,
        mensaje: e.message,
        cedulaYaRegistrada: e.statusCode == 409,
      ));
    } on NetworkException {
      emit(state.copyWith(
        status: CedulaRegistroStatus.error,
        mensaje: 'Sin conexión con el servidor. Revise su red e intente de nuevo.',
      ));
    }
  }
}
