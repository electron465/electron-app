import 'package:app_client/core/error/failures.dart';
import 'package:app_client/features/auth/domain/entities/user.dart';
import 'package:app_client/features/auth/domain/usecases/auth_usecases.dart';
import 'package:app_client/features/auth/presentation/cubit/login_cubit.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockRequestOtp extends Mock implements RequestOtp {}

class _MockVerifyOtp extends Mock implements VerifyOtp {}

void main() {
  late _MockRequestOtp requestOtp;
  late _MockVerifyOtp verifyOtp;

  const phone = '04121234567';
  const user = User(
    id: '1',
    fullName: 'Test User',
    phone: phone,
    documentId: 'V-1',
  );

  setUpAll(() {
    registerFallbackValue(const VerifyOtpParams(phone: '', code: ''));
  });

  setUp(() {
    requestOtp = _MockRequestOtp();
    verifyOtp = _MockVerifyOtp();
  });

  LoginCubit build() =>
      LoginCubit(requestOtp: requestOtp, verifyOtp: verifyOtp);

  blocTest<LoginCubit, LoginState>(
    'teléfono inválido emite failure sin llamar al use case',
    build: build,
    act: (c) => c.submitPhone('123'),
    expect: () => [
      isA<LoginState>().having((s) => s.status, 'status', LoginStatus.failure),
    ],
    verify: (_) => verifyNever(() => requestOtp(any())),
  );

  blocTest<LoginCubit, LoginState>(
    'teléfono válido avanza al paso OTP',
    setUp: () => when(
      () => requestOtp(phone),
    ).thenAnswer((_) async => const Right(unit)),
    build: build,
    act: (c) => c.submitPhone(phone),
    expect: () => const [
      LoginState(status: LoginStatus.loading, phone: phone),
      LoginState(step: LoginStep.otp, phone: phone),
    ],
  );

  blocTest<LoginCubit, LoginState>(
    'OTP correcto emite success con el usuario',
    setUp: () =>
        when(() => verifyOtp(any())).thenAnswer((_) async => const Right(user)),
    build: build,
    seed: () => const LoginState(step: LoginStep.otp, phone: phone),
    act: (c) => c.submitOtp('123456'),
    expect: () => const [
      LoginState(
        step: LoginStep.otp,
        status: LoginStatus.loading,
        phone: phone,
      ),
      LoginState(
        step: LoginStep.otp,
        status: LoginStatus.success,
        phone: phone,
        user: user,
      ),
    ],
  );

  blocTest<LoginCubit, LoginState>(
    'OTP incorrecto emite failure con el mensaje',
    setUp: () => when(
      () => verifyOtp(any()),
    ).thenAnswer((_) async => const Left(ServerFailure('Código inválido'))),
    build: build,
    seed: () => const LoginState(step: LoginStep.otp, phone: phone),
    act: (c) => c.submitOtp('000000'),
    skip: 1,
    expect: () => const [
      LoginState(
        step: LoginStep.otp,
        status: LoginStatus.failure,
        phone: phone,
        errorMessage: 'Código inválido',
      ),
    ],
  );
}
