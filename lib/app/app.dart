import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../core/di/injection.dart';
import '../core/router/app_router.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';

class App extends StatefulWidget {
  final bool hasSeenOnboarding; // Recibimos la variable desde main.dart

  const App({super.key, required this.hasSeenOnboarding});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  // 1. Instanciamos el AuthBloc global UNA SOLA VEZ
  late final AuthBloc _authBloc = sl<AuthBloc>()..add(const AuthCheckRequested());

  // 2. Creamos el Router UNA SOLA VEZ, pasándole el bloque y la variable del Onboarding
  late final GoRouter _router = createRouter(_authBloc, widget.hasSeenOnboarding);

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value( // Usamos .value porque el Bloc ya fue creado arriba
      value: _authBloc,
      child: MaterialApp.router(
        title: 'Grupo Electron',
        debugShowCheckedModeBanner: false,
        // Asumo que tienes tu AppTheme configurado, si no, usa ThemeData directamente
        // theme: AppTheme.light,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2196F3)),
          useMaterial3: true,
        ),
        routerConfig: _router, // Usamos el router que creamos en la línea 22
      ),
    );
  }
}