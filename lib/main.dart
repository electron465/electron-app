import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart'; // NUEVO: Para leer la memoria del teléfono

import 'app/app.dart';
import 'core/bloc/app_bloc_observer.dart';
import 'core/di/injection.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es');
  await configureDependencies();
  Bloc.observer = const AppBlocObserver();

  // NUEVO: Revisamos si el usuario ya vio el onboarding (tutorial)
  final prefs = await SharedPreferences.getInstance();
//   final bool hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;
    final bool hasSeenOnboarding = false; // Forzado para desarrollo


  // MODIFICADO: Le pasamos el resultado a la App
  runApp(App(hasSeenOnboarding: hasSeenOnboarding));
}