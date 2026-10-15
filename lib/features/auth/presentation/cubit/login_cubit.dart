import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/user.dart';
import '../../domain/usecases/auth_usecases.dart';

enum LoginStep { phone, otp }

enum LoginStatus { idle, loading, success, failure }

final class LoginState extends Equatable {
  const LoginState({
    this.step = LoginStep.phone,
    this.status = LoginStatus.idle,
    this.phone = '',
    this.user,
    this.errorMessage,
  });

  final LoginStep step;
  final LoginStatus status;
  final String phone;
  final User? user;
  final String? errorMessage;

  bool get isLoading => status == LoginStatus.loading;

  LoginState copyWith({
    LoginStep? step,
    LoginStatus? status,
    String? phone,
    User? user,
    String? errorMessage,
  }) => LoginState(
    step: step ?? this.step,
    status: status ?? this.status,
    phone: phone ?? this.phone,
    user: user ?? this.user,
    errorMessage: errorMessage,
  );

  @override
  List<Object?> get props => [step, status, phone, user, errorMessage];
}

/// Flujo de login por teléfono + OTP (local a la pantalla).
/// Al tener éxito, la UI notifica al [AuthBloc] global.
class LoginCubit extends Cubit<LoginState> {
  LoginCubit({required RequestOtp requestOtp, required VerifyOtp verifyOtp})
    : _requestOtp = requestOtp,
      _verifyOtp = verifyOtp,
      super(const LoginState());

  final RequestOtp _requestOtp;
  final VerifyOtp _verifyOtp;

  static final _vePhone = RegExp(r'^04(12|14|16|24|26|22)\d{7}$');

  Future<void> submitPhone(String rawPhone) async {
    final phone = rawPhone.replaceAll(RegExp(r'\D'), '');
    if (!_vePhone.hasMatch(phone)) {
      emit(
        state.copyWith(
          status: LoginStatus.failure,
          errorMessage: 'Ingresa un número válido (ej. 04121234567).',
        ),
      );
      return;
    }

    emit(state.copyWith(status: LoginStatus.loading, phone: phone));
    final result = await _requestOtp(phone);
    emit(
      result.fold(
        (failure) => state.copyWith(
          status: LoginStatus.failure,
          errorMessage: failure.message,
        ),
        (_) => state.copyWith(step: LoginStep.otp, status: LoginStatus.idle),
      ),
    );
  }

  Future<void> submitOtp(String code) async {
    if (code.length != 6) {
      emit(
        state.copyWith(
          status: LoginStatus.failure,
          errorMessage: 'El código tiene 6 dígitos.',
        ),
      );
      return;
    }

    emit(state.copyWith(status: LoginStatus.loading));
    final result = await _verifyOtp(
      VerifyOtpParams(phone: state.phone, code: code),
    );
    emit(
      result.fold(
        (failure) => state.copyWith(
          status: LoginStatus.failure,
          errorMessage: failure.message,
        ),
        (user) => state.copyWith(status: LoginStatus.success, user: user),
      ),
    );
  }

  void backToPhone() => emit(const LoginState());
}
