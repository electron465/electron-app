import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../bloc/register_bloc.dart';
import '../bloc/register_event.dart';
import '../bloc/register_state.dart';
import 'package:go_router/go_router.dart'; // <-- Agrega esta línea


class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit(int step) {
    if (_formKey.currentState?.validate() ?? false) {
      final text = _controller.text.trim();
      final bloc = context.read<RegisterBloc>();

      if (step == 1) bloc.add(SubmitIdentifier(text));
      else if (step == 2) bloc.add(SubmitOtp(text));
      else if (step == 3) bloc.add(SubmitPassword(text));

      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<RegisterBloc, RegisterState>(
      listener: (context, state) {
        if (state is RegisterError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
           if (state is RegisterCompleted) {
                  // IMPORTANTE: Necesitamos saber si el usuario eligió Militar o Civil.
                  // Para no complicar el estado, podemos hacer una pequeña validación:
                  // Si el paso anterior fue el 4, asumimos que ya eligió.

                  // Navegamos a la nueva pantalla (pasando un valor por defecto por ahora)
                  context.push('/docs-capture?isMilitar=false'); // Lo ajustaremos cuando guardemos la elección
                }
      },
      builder: (context, state) {
        final isLoading = state is RegisterLoading;

        return Scaffold(
          backgroundColor: const Color(0xFFF5F7FA),
          appBar: AppBar(
            title: const Text('Crear Cuenta', style: TextStyle(color: Colors.white)),
            backgroundColor: const Color(0xFF0A192F),
            elevation: 0,
          ),
          body: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  LinearProgressIndicator(
                    value: state.currentStep / 4, // Ahora son 4 pasos
                    backgroundColor: Colors.grey[300],
                    color: const Color(0xFF2196F3),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    _getTitle(state.currentStep),
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0A192F)),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _getSubtitle(state.currentStep),
                    style: const TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                  const SizedBox(height: 30),

                  // Si estamos en el paso 4, mostramos los botones de Militar/Civil
                  if (state.currentStep == 4)
                    Column(
                      children: [
                        AppButton(
                          text: 'Soy Civil / Empleado Público',
                          isLoading: isLoading,
                          onPressed: () => context.read<RegisterBloc>().add(SelectUserType(false)),
                        ),
                        const SizedBox(height: 16),
                        AppButton(
                          text: 'Soy Militar',
                          isLoading: isLoading,
                          onPressed: () => context.read<RegisterBloc>().add(SelectUserType(true)),
                        ),
                      ],
                    )
                  else ...[
                    // Si estamos en los pasos 1, 2 o 3, mostramos el input normal
                    AppTextField(
                      label: _getLabel(state.currentStep),
                      icon: _getIcon(state.currentStep),
                      obscureText: state.currentStep == 3,
                      controller: _controller,
                      keyboardType: state.currentStep == 1 ? TextInputType.emailAddress : TextInputType.number,
                      validator: (val) {
                        if (val == null || val.isEmpty) return 'Campo requerido';
                        if (state.currentStep == 3 && val.length < 6) return 'Mínimo 6 dígitos';
                        return null;
                      },
                    ),
                    const SizedBox(height: 30),
                    AppButton(
                      text: _getButtonText(state.currentStep),
                      isLoading: isLoading,
                      onPressed: () => _submit(state.currentStep),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _getTitle(int step) {
    switch (step) {
      case 1: return 'Tus Datos';
      case 2: return 'Verificación';
      case 3: return 'Seguridad';
      case 4: return 'Tipo de Solicitante';
      default: return '';
    }
  }

  String _getSubtitle(int step) {
    switch (step) {
      case 1: return 'Ingresa tu Cédula, Correo o Celular.';
      case 2: return 'Ingresa el código (Prueba: 123456).';
      case 3: return 'Crea un PIN de 6 dígitos.';
      case 4: return 'Selecciona tu tipo de empleo para continuar.';
      default: return '';
    }
  }

  String _getLabel(int step) {
    switch (step) {
      case 1: return 'Cédula / Correo / Celular';
      case 2: return 'Código OTP';
      case 3: return 'PIN';
      default: return '';
    }
  }

  IconData _getIcon(int step) {
    switch (step) {
      case 1: return Icons.person_outline;
      case 2: return Icons.security;
      case 3: return Icons.lock_outline;
      default: return Icons.error;
    }
  }

  String _getButtonText(int step) {
    switch (step) {
      case 1: return 'Enviar Código';
      case 2: return 'Verificar';
      case 3: return 'Finalizar';
      default: return 'Continuar';
    }
  }
}