import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/app_button.dart';
import '../bloc/auth_bloc.dart';
import '../cubit/login_cubit.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<LoginCubit>(),
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatelessWidget {
  const _LoginView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginCubit, LoginState>(
      listener: (context, state) {
        if (state.status == LoginStatus.failure && state.errorMessage != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        }
        if (state.status == LoginStatus.success && state.user != null) {
          // El router redirige solo al detectar la sesión.
          context.read<AuthBloc>().add(AuthLoggedIn(state.user!));
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: BlocBuilder<LoginCubit, LoginState>(
              buildWhen: (prev, curr) => prev.step != curr.step,
              builder: (context, state) => AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: switch (state.step) {
                  LoginStep.phone => const _PhoneStep(key: ValueKey('phone')),
                  LoginStep.otp => const _OtpStep(key: ValueKey('otp')),
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PhoneStep extends StatefulWidget {
  const _PhoneStep({super.key});

  @override
  State<_PhoneStep> createState() => _PhoneStepState();
}

class _PhoneStepState extends State<_PhoneStep> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final isLoading = context.select((LoginCubit c) => c.state.isLoading);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Spacer(),
        Text('Compra ahora,\npaga en cuotas', style: text.headlineMedium),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Ingresa tu número de teléfono para continuar.',
          style: text.bodyLarge,
        ),
        const SizedBox(height: AppSpacing.lg),
        TextField(
          controller: _controller,
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(11),
          ],
          decoration: const InputDecoration(
            labelText: 'Teléfono',
            hintText: '04121234567',
            prefixIcon: Icon(Icons.phone_iphone),
          ),
        ),
        const Spacer(),
        AppButton(
          label: 'Enviar código',
          isLoading: isLoading,
          onPressed: () =>
              context.read<LoginCubit>().submitPhone(_controller.text),
        ),
      ],
    );
  }
}

class _OtpStep extends StatefulWidget {
  const _OtpStep({super.key});

  @override
  State<_OtpStep> createState() => _OtpStepState();
}

class _OtpStepState extends State<_OtpStep> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final cubit = context.read<LoginCubit>();
    final isLoading = context.select((LoginCubit c) => c.state.isLoading);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: cubit.backToPhone,
          ),
        ),
        const Spacer(),
        Text('Verifica tu número', style: text.headlineMedium),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'Enviamos un código de 6 dígitos al ${cubit.state.phone}.',
          style: text.bodyLarge,
        ),
        const SizedBox(height: AppSpacing.lg),
        TextField(
          controller: _controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          style: text.headlineSmall?.copyWith(letterSpacing: 12),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(6),
          ],
          decoration: const InputDecoration(hintText: '······'),
        ),
        const Spacer(),
        AppButton(
          label: 'Verificar',
          isLoading: isLoading,
          onPressed: () => cubit.submitOtp(_controller.text),
        ),
      ],
    );
  }
}
