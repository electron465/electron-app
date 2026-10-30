import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/usecases/auth_usecases.dart';
import '../../domain/repositories/auth_repository.dart';

enum RegisterStatus { initial, loading, success, error }

class RegisterState extends Equatable {
  final RegisterStatus status;
  final int currentStep;
  final String identifier;
  final String errorMessage;

  const RegisterState({
    this.status = RegisterStatus.initial,
    this.currentStep = 1,
    this.identifier = '',
    this.errorMessage = '',
  });

  RegisterState copyWith({
    RegisterStatus? status,
    int? currentStep,
    String? identifier,
    String? errorMessage,
  }) {
    return RegisterState(
      status: status ?? this.status,
      currentStep: currentStep ?? this.currentStep,
      identifier: identifier ?? this.identifier,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, currentStep, identifier, errorMessage];
}

class RegisterCubit extends Cubit<RegisterState> {
  final RequestOtp _requestOtp;
  final VerifyOtp _verifyOtp;
  final CreatePassword _createPassword;

  RegisterCubit({
    required RequestOtp requestOtp,
    required VerifyOtp verifyOtp,
    required CreatePassword createPassword,
  })  : _requestOtp = requestOtp,
        _verifyOtp = verifyOtp,
        _createPassword = createPassword,
        super(const RegisterState());

  Future<void> submitIdentifier(String identifier) async {
    emit(state.copyWith(status: RegisterStatus.loading, errorMessage: ''));

    // 1. Enviamos el OTP
    final result = await _requestOtp(identifier);

    result.fold(
      (failure) => emit(state.copyWith(status: RegisterStatus.error, errorMessage: failure.message)),
      (_) => emit(state.copyWith(status: RegisterStatus.success, currentStep: 2, identifier: identifier)),
    );
  }

  Future<void> submitOtp(String otp) async {
    emit(state.copyWith(status: RegisterStatus.loading, errorMessage: ''));

    // 2. Verificamos el OTP usando tu clase VerifyOtpParams
    final result = await _verifyOtp(
      VerifyOtpParams(phone: state.identifier, code: otp),
    );

    result.fold(
      (failure) => emit(state.copyWith(status: RegisterStatus.error, errorMessage: failure.message)),
      (_) => emit(state.copyWith(status: RegisterStatus.success, currentStep: 3)),
    );
  }

  Future<void> submitPassword(String password) async {
    emit(state.copyWith(status: RegisterStatus.loading, errorMessage: ''));

    // 3. Creamos la contraseña (Asegúrate de que tu CreatePassword reciba un Map, como vimos en tu código)
    final result = await _createPassword({
      'identifier': state.identifier,
      'password': password,
    });

    result.fold(
      (failure) => emit(state.copyWith(status: RegisterStatus.error, errorMessage: failure.message)),
      (_) => emit(state.copyWith(status: RegisterStatus.success, currentStep: 4)),
    );
  }
}