import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/login_bloc.dart';
import '../bloc/login_event.dart';
import '../bloc/login_state.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // Variable para saber si el botón debe estar activo o gris
  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    // Escuchamos los cambios en los inputs para habilitar el botón
    _identifierController.addListener(_validateForm);
    _passwordController.addListener(_validateForm);
  }

  void _validateForm() {
    setState(() {
      _isFormValid = _identifierController.text.isNotEmpty && _passwordController.text.isNotEmpty;
    });
  }

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<LoginBloc>().add(
            LoginSubmitted(
              _identifierController.text.trim(),
              _passwordController.text.trim(),
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Definimos los colores basados en tu imagen de referencia
    const Color bgColor = Color(0xFFFDFCF3); // Fondo crema muy claro
    const Color textColor = Color(0xFF1A1A1A); // Texto casi negro
    const Color buttonColor = Color(0xFF1E1E1E); // Botón oscuro
    const Color disabledButtonColor = Color(0xFFD9D9D9); // Gris claro

    return Scaffold(
      backgroundColor: bgColor,
      body: BlocConsumer<LoginBloc, LoginState>(
        listener: (context, state) {
          if (state is LoginSuccess) {
            context.go('/home');
          } else if (state is LoginFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error), backgroundColor: Colors.red),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is LoginLoading;

          return SafeArea(
            child: Stack(
              children: [
                // BOTÓN DE AYUDA (Arriba a la derecha)
                Positioned(
                  top: 16,
                  right: 16,
                  child: IconButton(
                    icon: const Icon(Icons.help_outline, color: Colors.black, size: 28),
                    onPressed: () {
                      // TODO: Acción de ayuda
                    },
                  ),
                ),

                // CONTENIDO PRINCIPAL
                Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 40),

                          // TU LOGO (Ya conectado a la ruta de assets)
                          Center(
                            child: Image.asset(
                              'assets/logo.png',
                              width: 120,
                              height: 120,
                              fit: BoxFit.contain,
                            ),
                          ),

                          const SizedBox(height: 30),

                          // Título
                          const Text(
                            '¡Todo listo para ingresar!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w900, // Letra bien gruesa
                              color: textColor,
                              letterSpacing: -0.5,
                            ),
                          ),

                          const SizedBox(height: 40),

                          // CAJA EXTERNA (El detalle del borde)
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white, // Fondo blanco
                              borderRadius: BorderRadius.circular(20), // Bordes bien redondos
                              border: Border.all(color: Colors.grey.shade300, width: 1.5), // Borde sutil
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Ingresa tu correo :',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: textColor,
                                  ),
                                ),
                                const SizedBox(height: 12),

                                // CAJA INTERNA (El Input gris)
                                TextFormField(
                                  controller: _identifierController,
                                  style: const TextStyle(fontSize: 16, color: textColor),
                                  decoration: InputDecoration(
                                    hintText: 'email@email.com o 0412...',
                                    hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 15),
                                    filled: true,
                                    fillColor: const Color(0xFFF5F5F5), // Gris muy clarito
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12), // Bordes redondos internos
                                      borderSide: BorderSide.none,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: BorderSide.none,
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      borderSide: const BorderSide(color: Colors.black26, width: 1),
                                    ),
                                  ),
                                  validator: (val) => val == null || val.isEmpty ? 'Requerido' : null,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Olvidé mi correo
                          TextButton(
                            onPressed: () {},
                            child: const Text(
                              '¿No recuerdas tu correo?',
                              style: TextStyle(
                                color: textColor,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),

                          const SizedBox(height: 40),

                          // BOTÓN INFERIOR
                          SizedBox(
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _isFormValid && !isLoading ? _submit : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: buttonColor,
                                disabledBackgroundColor: disabledButtonColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30), // Bordes de píldora
                                ),
                                elevation: 0,
                              ),
                              child: isLoading
                                  ? const SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                    )
                                  : Text(
                                      'Continuar',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: _isFormValid ? Colors.white : Colors.grey.shade600,
                                      ),
                                    ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Texto para crear cuenta
                          TextButton(
                            onPressed: () => context.push('/register'),
                            child: const Text('Crear una cuenta nueva', style: TextStyle(color: Colors.black54)),
                          ),

                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}