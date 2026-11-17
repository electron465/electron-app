import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/routes.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../data/cedula_ocr_parser.dart';
import '../cubit/cedula_registro_cubit.dart';

/// Muestra los datos leídos del OCR (o de Electron si la cédula existe),
/// pide correo, teléfono y clave, y crea la cuenta.
class RegistroDatosPage extends StatefulWidget {
  const RegistroDatosPage({super.key, required this.ocr});

  final CedulaOcrData ocr;

  @override
  State<RegistroDatosPage> createState() => _RegistroDatosPageState();
}

class _RegistroDatosPageState extends State<RegistroDatosPage> {
  final _form = GlobalKey<FormState>();
  final _cedula = TextEditingController();
  final _primerNombre = TextEditingController();
  final _segundoNombre = TextEditingController();
  final _primerApellido = TextEditingController();
  final _segundoApellido = TextEditingController();
  final _correo = TextEditingController();
  final _telefono = TextEditingController();
  final _clave = TextEditingController();
  final _confirmar = TextEditingController();
  bool _prellenado = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<CedulaRegistroCubit>().validar(widget.ocr);
    });
  }

  @override
  void dispose() {
    for (final c in [
      _cedula, _primerNombre, _segundoNombre, _primerApellido,
      _segundoApellido, _correo, _telefono, _clave, _confirmar,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _prellenar(CedulaRegistroState s) {
    if (_prellenado) return;
    _prellenado = true;
    String v(String k) => (s.datos[k] as String?) ?? '';
    _cedula.text = s.cedula;
    _primerNombre.text = v('primer_nombre');
    _segundoNombre.text = v('segundo_nombre');
    _primerApellido.text = v('primer_apellido');
    _segundoApellido.text = v('segundo_apellido');
  }

  void _enviar(CedulaRegistroCubit cubit) {
    if (!(_form.currentState?.validate() ?? false)) return;
    cubit.registrar(
      clave: _clave.text,
      correo: _correo.text.trim(),
      telefono: _telefono.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tus datos')),
      body: BlocConsumer<CedulaRegistroCubit, CedulaRegistroState>(
        listener: (context, s) {
          if (s.status == CedulaRegistroStatus.lista) _prellenar(s);
          if (s.status == CedulaRegistroStatus.exito) {
            context.read<AuthBloc>().add(AuthLoggedIn(User(
                  id: '${s.usuarioId}',
                  fullName: [
                    _primerNombre.text,
                    _segundoNombre.text,
                    _primerApellido.text,
                    _segundoApellido.text,
                  ].where((p) => p.trim().isNotEmpty).join(' '),
                  phone: _telefono.text.trim(),
                  documentId: 'V-${s.cedula}',
                  email: _correo.text.trim(),
                )));
            context.go(Routes.home);
          }
        },
        builder: (context, s) {
          final cubit = context.read<CedulaRegistroCubit>();
          if (s.status == CedulaRegistroStatus.validando) {
            return const Center(child: CircularProgressIndicator());
          }
          if (s.status == CedulaRegistroStatus.error && !_prellenado) {
            return _Error(
              mensaje: s.mensaje,
              cedulaYaRegistrada: s.cedulaYaRegistrada,
              onReintentar: () => cubit.validar(widget.ocr),
            );
          }

          final bloqueado = s.status == CedulaRegistroStatus.registrando;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _form,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (s.enElectron)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: Text(
                        'Encontramos su cédula en nuestros registros. Sus datos básicos no se pueden editar aquí.',
                      ),
                    ),
                  _campo(_cedula, 'Cédula', readOnly: true),
                  _campo(_primerNombre, 'Primer nombre',
                      readOnly: s.enElectron, requerido: true),
                  _campo(_segundoNombre, 'Segundo nombre', readOnly: s.enElectron),
                  _campo(_primerApellido, 'Primer apellido',
                      readOnly: s.enElectron, requerido: true),
                  _campo(_segundoApellido, 'Segundo apellido', readOnly: s.enElectron),
                  const Divider(height: 32),
                  _campo(_correo, 'Correo',
                      tipo: TextInputType.emailAddress, requerido: true,
                      validador: (v) => (v != null && v.contains('@') && v.contains('.'))
                          ? null
                          : 'Correo inválido'),
                  _campo(_telefono, 'Teléfono', tipo: TextInputType.phone, requerido: true,
                      validador: (v) => (v != null && v.replaceAll(RegExp(r'[^0-9]'), '').length >= 7)
                          ? null
                          : 'Teléfono inválido'),
                  _campo(_clave, 'Clave', oculto: true, requerido: true,
                      validador: (v) => (v != null && v.length >= 8)
                          ? null
                          : 'Mínimo 8 caracteres'),
                  _campo(_confirmar, 'Confirmar clave', oculto: true, requerido: true,
                      validador: (v) => v == _clave.text ? null : 'Las claves no coinciden'),
                  if (s.status == CedulaRegistroStatus.error) ...[
                    const SizedBox(height: 8),
                    Text(s.mensaje, style: const TextStyle(color: Colors.red)),
                  ],
                  const SizedBox(height: 24),
                  AppButton(
                    text: bloqueado ? 'Creando cuenta...' : 'Crear cuenta',
                    onPressed: bloqueado ? null : () => _enviar(cubit),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _campo(
    TextEditingController c,
    String etiqueta, {
    bool readOnly = false,
    bool requerido = false,
    bool oculto = false,
    TextInputType? tipo,
    String? Function(String?)? validador,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: c,
        readOnly: readOnly,
        obscureText: oculto,
        keyboardType: tipo,
        decoration: InputDecoration(labelText: etiqueta, border: const OutlineInputBorder()),
        validator: validador ??
            (requerido
                ? (v) => (v == null || v.trim().isEmpty) ? 'Campo obligatorio' : null
                : null),
      ),
    );
  }
}

class _Error extends StatelessWidget {
  const _Error({required this.mensaje, required this.cedulaYaRegistrada, required this.onReintentar});

  final String mensaje;
  final bool cedulaYaRegistrada;
  final VoidCallback onReintentar;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(mensaje, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            if (cedulaYaRegistrada)
              AppButton(text: 'Iniciar sesión', onPressed: () => context.go(Routes.login))
            else
              AppButton(text: 'Reintentar', onPressed: onReintentar),
          ],
        ),
      ),
    );
  }
}
