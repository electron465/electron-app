import 'package:flutter_bloc/flutter_bloc.dart';
import 'register_event.dart';
import 'register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  String _savedIdentifier = '';

  RegisterBloc() : super(const RegisterInitial()) {
    // PASO 1: Enviar OTP
    on<SubmitIdentifier>((event, emit) async {
      emit(const RegisterLoading(currentStep: 1));
      await Future.delayed(const Duration(milliseconds: 800));

      if (event.identifier.isEmpty) {
        emit(const RegisterError(currentStep: 1, message: 'El campo no puede estar vacío'));
      } else {
        _savedIdentifier = event.identifier;
        emit(RegisterStepSuccess(currentStep: 2, identifier: _savedIdentifier));
      }
    });

    // PASO 2: Validar OTP
    on<SubmitOtp>((event, emit) async {
      emit(const RegisterLoading(currentStep: 2));
      await Future.delayed(const Duration(milliseconds: 800));

      if (event.otp == '123456') {
        emit(RegisterStepSuccess(currentStep: 3, identifier: _savedIdentifier));
      } else {
        emit(const RegisterError(currentStep: 2, message: 'Código OTP incorrecto. Usa 123456'));
      }
    });

    // PASO 3: Crear PIN
    on<SubmitPassword>((event, emit) async {
      emit(const RegisterLoading(currentStep: 3));
      await Future.delayed(const Duration(milliseconds: 800));

      if (event.password.length < 6) {
        emit(const RegisterError(currentStep: 3, message: 'El PIN debe tener al menos 6 dígitos'));
      } else {
        // Al crear el PIN, pasamos al Paso 4: Tipo de Solicitante
        emit(const RegisterStepSuccess(currentStep: 4, identifier: ''));
      }
    });

    // PASO 4: Seleccionar Tipo de Solicitante
    on<SelectUserType>((event, emit) async {
      emit(RegisterLoading(currentStep: 4));
      await Future.delayed(const Duration(milliseconds: 500));

      if (event.isMilitar) {
        // Aquí en el futuro navegaremos a la pantalla de subida de Carnet Militar
        emit(const RegisterCompleted());
      } else {
        // Aquí en el futuro navegaremos a la pantalla de subida de Cédula/Constancia
        emit(const RegisterCompleted());
      }
    });
  }
}