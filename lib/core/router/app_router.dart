import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/credit/presentation/cubit/credit_cubit.dart';
import '../../features/credit/presentation/pages/home_page.dart';
import '../../features/orders/presentation/bloc/orders_bloc.dart';
import '../../features/orders/presentation/cubit/order_detail_cubit.dart';
import '../../features/orders/presentation/pages/order_detail_page.dart';
import '../../features/orders/presentation/pages/orders_page.dart';
import '../../features/payments/presentation/cubit/payment_cubit.dart';
import '../../features/payments/presentation/pages/payment_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/stores/presentation/bloc/stores_bloc.dart';
import '../../features/stores/presentation/pages/stores_page.dart';
import '../di/injection.dart';
import 'main_shell.dart';
import 'routes.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

/// Cada ruta crea (vía DI) los Blocs que su pantalla necesita, así su
/// ciclo de vida queda atado al de la ruta.
GoRouter createRouter(AuthBloc authBloc) => GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: Routes.splash,
  refreshListenable: _StreamListenable(authBloc.stream),
  redirect: (context, state) {
    final location = state.matchedLocation;
    final onSplash = location == Routes.splash;
    final onLogin = location == Routes.login;

    return switch (authBloc.state.status) {
      AuthStatus.unknown => onSplash ? null : Routes.splash,
      AuthStatus.unauthenticated => onLogin ? null : Routes.login,
      AuthStatus.authenticated => onSplash || onLogin ? Routes.home : null,
    };
  },
  routes: [
    GoRoute(path: Routes.splash, builder: (_, _) => const SplashPage()),
    GoRoute(path: Routes.login, builder: (_, _) => const LoginPage()),
    StatefulShellRoute.indexedStack(
      builder: (_, _, shell) => MainShell(navigationShell: shell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.home,
              builder: (_, _) => BlocProvider(
                create: (_) => sl<CreditCubit>()..load(),
                child: const HomePage(),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.stores,
              builder: (_, _) => BlocProvider(
                create: (_) => sl<StoresBloc>()..add(const StoresRequested()),
                child: const StoresPage(),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.orders,
              builder: (_, _) => BlocProvider(
                create: (_) => sl<OrdersBloc>()..add(const OrdersRequested()),
                child: const OrdersPage(),
              ),
              routes: [
                GoRoute(
                  path: ':orderId',
                  builder: (_, state) => BlocProvider(
                    create: (_) => sl<OrderDetailCubit>(
                      param1: state.pathParameters['orderId'],
                    )..load(),
                    child: const OrderDetailPage(),
                  ),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: Routes.profile,
              builder: (_, _) => const ProfilePage(),
            ),
          ],
        ),
      ],
    ),
    // Fuera del shell: pantalla completa sin bottom bar.
    GoRoute(
      path: '/pay/:orderId/:installmentId',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (_, state) => BlocProvider(
        create: (_) => sl<PaymentCubit>(
          param1: state.pathParameters['orderId'],
          param2: state.pathParameters['installmentId'],
        ),
        child: PaymentPage(
          amountCents:
              int.tryParse(state.uri.queryParameters['amount'] ?? '') ?? 0,
        ),
      ),
    ),
  ],
);

/// Adapta un Stream (el del AuthBloc) a Listenable para go_router.
class _StreamListenable extends ChangeNotifier {
  _StreamListenable(Stream<dynamic> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
