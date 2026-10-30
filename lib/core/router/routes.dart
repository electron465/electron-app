abstract final class Routes {
  static const splash = '/';
  static const onboarding = '/onboarding'; // NUEVA RUTA
  static const login = '/login';
  static const register = '/register';
  static const home = '/home';
  static const stores = '/stores';
  static const orders = '/orders';
  static const profile = '/profile';
  
  // Rutas con parámetros (por si las necesitas luego)
  static String orderDetail(String id) => '/orders/$id';
}