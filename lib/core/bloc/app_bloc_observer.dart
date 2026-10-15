import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Log centralizado de transiciones y errores de todos los Blocs/Cubits.
/// Punto ideal para conectar Crashlytics/Sentry más adelante.
class AppBlocObserver extends BlocObserver {
  const AppBlocObserver();

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    if (kDebugMode) debugPrint('[${bloc.runtimeType}] $change');
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    debugPrint('[${bloc.runtimeType}] ERROR: $error\n$stackTrace');
    super.onError(bloc, error, stackTrace);
  }
}
