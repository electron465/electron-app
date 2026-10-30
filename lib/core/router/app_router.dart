import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/login_bloc.dart';
import '../../features/auth/presentation/bloc/register_bloc.dart';
import '../../features/auth/presentation/pages/docs_capture_page.dart';
import '../../features/auth/presentation/pages/face_capture_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/onboarding_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/credit/presentation/cubit/credit_cubit.dart';
import '../../features/credit/presentation/pages/home_page.dart';
import '../../features/orders/presentation/bloc/orders_bloc.dart';
import '../../features/orders/presentation/cubit/order_detail_cubit.dart';
import '../../features/orders/presentation/pages/order_detail_page.dart';
import '../../features/orders/presentation/pages/orders_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/stores/presentation/bloc/stores_bloc.dart';
import '../../features/stores/presentation/pages/stores_page.dart';
import '../di/injection.dart';
import 'main_shell.dart';
import 'routes.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

GoRouter createRouter(AuthBloc authBloc, bool hasSeenOnboarding) => GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: hasSeenOnboarding ? Routes.login : Routes.onboarding,
      refreshListenable: _StreamListenable(authBloc.stream),
      redirect: (context, state) {
        final location = state.matchedLocation;
        final onSplash = location == Routes.splash;
        final onLogin = location == Routes.login;
        final onRegister = location == Routes.register;

        // Permitimos que estas rutas fluyan sin pedir autenticación
        final onOnboarding = location == Routes.onboarding;
        final onDocs = location == '/docs-capture';
        final onFace = location == '/face-capture';

        // AQUÍ ESTÁ LA VARIABLE MOVIDA A SU LUGAR CORRECTO:
        final onHome = location == Routes.home;

        return switch (authBloc.state.status) {
          AuthStatus.unknown => onSplash ? null : Routes.splash,

          // Usamos onHome aquí:
          AuthStatus.unauthenticated => (onLogin || onRegister || onOnboarding || onDocs || onFace || onHome)
              ? null
              : Routes.login,

          AuthStatus.authenticated => (onSplash || onLogin || onRegister || onOnboarding)
              ? Routes.home
              : null,
        };
      },
      routes: [
        GoRoute(
          path: Routes.onboarding,
          builder: (_, _) => const OnboardingPage(),
        ),
        GoRoute(
          path: Routes.login,
          builder: (_, _) => BlocProvider(
            create: (_) => LoginBloc(),
            child: const LoginPage(),
          ),
        ),
        GoRoute(
          path: Routes.register,
          builder: (_, _) => BlocProvider(
            create: (_) => RegisterBloc(),
            child: const RegisterPage(),
          ),
        ),
        GoRoute(
          path: '/docs-capture',
          builder: (context, state) {
            final isMilitar = state.uri.queryParameters['isMilitar'] == 'true';
            return DocsCapturePage(isMilitar: isMilitar);
          },
        ),
        GoRoute(
          path: '/face-capture',
          builder: (_, _) => const FaceCapturePage(),
        ),
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
      ],
    );

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