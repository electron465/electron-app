/// Rutas centralizadas: nunca escribir paths "a mano" en las pantallas.
abstract final class Routes {
  static const splash = '/splash';
  static const login = '/login';
  static const home = '/home';
  static const stores = '/stores';
  static const orders = '/orders';
  static const profile = '/profile';

  static String orderDetail(String orderId) => '$orders/$orderId';

  static String payInstallment({
    required String orderId,
    required String installmentId,
    required int amountCents,
  }) => '/pay/$orderId/$installmentId?amount=$amountCents';
}
