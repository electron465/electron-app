import 'package:intl/intl.dart';

/// Los montos se manejan SIEMPRE en centavos (int) para evitar errores
/// de redondeo con double. Solo se convierten al mostrarlos.
abstract final class Formatters {
  static final _usd = NumberFormat.currency(locale: 'es', symbol: r'$');
  static final _shortDate = DateFormat('d MMM yyyy', 'es');

  static String money(int cents) => _usd.format(cents / 100);

  static String date(DateTime date) => _shortDate.format(date);
}
