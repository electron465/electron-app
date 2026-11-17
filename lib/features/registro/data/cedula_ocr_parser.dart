/// Datos interpretados del texto que devuelve ML Kit sobre la cédula.
class CedulaOcrData {
  const CedulaOcrData({
    this.cedula,
    this.primerNombre,
    this.segundoNombre,
    this.primerApellido,
    this.segundoApellido,
    this.fechaNacimiento,
    this.sexo,
  });

  final String? cedula;
  final String? primerNombre;
  final String? segundoNombre;
  final String? primerApellido;
  final String? segundoApellido;
  final DateTime? fechaNacimiento;
  final String? sexo;

  bool get tieneCedula => cedula != null && cedula!.isNotEmpty;

  Map<String, dynamic> toJson() => {
        'cedula': cedula,
        'primer_nombre': primerNombre,
        'segundo_nombre': segundoNombre,
        'primer_apellido': primerApellido,
        'segundo_apellido': segundoApellido,
        'fecha_nacimiento': fechaNacimiento == null
            ? null
            : '${fechaNacimiento!.year.toString().padLeft(4, '0')}-'
                '${fechaNacimiento!.month.toString().padLeft(2, '0')}-'
                '${fechaNacimiento!.day.toString().padLeft(2, '0')}',
        'sexo': sexo,
      };
}

/// Interpreta el texto crudo de la cédula venezolana.
///
/// Heurística: la cédula se busca como número con prefijo V/E o con separadores
/// (18.125.652). Los nombres y apellidos se toman de la línea siguiente a su etiqueta.
/// Es una lectura aproximada: el usuario siempre puede corregir los campos.
abstract final class CedulaOcrParser {
  static final _cedulaPrefijo = RegExp(r'\b[VE]\s*[-.:]?\s*(\d[\d.\s]{5,12}\d)');
  static final _cedulaSuelta = RegExp(r'\b(\d{1,2}[.\s]?\d{3}[.\s]?\d{3}|\d{7,9})\b');
  static final _fecha = RegExp(r'(\d{2})[/\-.](\d{2})[/\-.](\d{4})');
  static final _sexo = RegExp(r'\bSEXO\W{0,3}([MF])\b');
  static final _etiquetasConocidas = RegExp(
    r'FECHA|SEXO|CEDULA|CÉDULA|REPUBLICA|REPÚBLICA|VENEZUELA|NACIMIENTO|ESTADO|VENCIMIENTO',
  );

  static CedulaOcrData parse(String texto) {
    final upper = texto.toUpperCase();
    final lineas = texto
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    final cedula = _extraerCedula(upper);
    final apellidos = _palabrasTrasEtiqueta(lineas, 'APELLIDO');
    final nombres = _palabrasTrasEtiqueta(lineas, 'NOMBRE');

    DateTime? fecha;
    final mFecha = _fecha.firstMatch(texto);
    if (mFecha != null) {
      final d = int.parse(mFecha.group(1)!);
      final m = int.parse(mFecha.group(2)!);
      final y = int.parse(mFecha.group(3)!);
      final candidata = DateTime(y, m, d);
      if (candidata.day == d && candidata.month == m) fecha = candidata;
    }

    final mSexo = _sexo.firstMatch(upper);

    return CedulaOcrData(
      cedula: cedula,
      primerNombre: _primera(nombres),
      segundoNombre: _resto(nombres),
      primerApellido: _primera(apellidos),
      segundoApellido: _resto(apellidos),
      fechaNacimiento: fecha,
      sexo: mSexo?.group(1),
    );
  }

  static String? _extraerCedula(String upper) {
    String? candidato = _cedulaPrefijo.firstMatch(upper)?.group(1);
    candidato ??= _cedulaSuelta.firstMatch(upper)?.group(1);
    if (candidato == null) return null;
    final digitos = candidato.replaceAll(RegExp(r'\D'), '');
    return (digitos.length >= 6 && digitos.length <= 9) ? digitos : null;
  }

  static List<String> _palabrasTrasEtiqueta(List<String> lineas, String etiqueta) {
    for (var i = 0; i < lineas.length; i++) {
      final up = lineas[i].toUpperCase();
      if (!up.contains(etiqueta)) continue;

      // Caso "APELLIDOS: PEREZ GOMEZ" en la misma línea.
      final tras = up.split(etiqueta).last.replaceFirst(RegExp(r'^[A-ZÑ]*\s*[:.\-]?\s*'), '');
      if (tras.trim().isNotEmpty && !_etiquetasConocidas.hasMatch(tras)) {
        return _soloLetras(tras);
      }

      // Caso habitual: el valor está en la línea siguiente.
      if (i + 1 < lineas.length) {
        final siguiente = lineas[i + 1];
        if (!_etiquetasConocidas.hasMatch(siguiente.toUpperCase())) {
          return _soloLetras(siguiente);
        }
      }
    }
    return const [];
  }

  static List<String> _soloLetras(String texto) => texto
      .replaceAll(RegExp(r'[^A-Za-zÁÉÍÓÚÑáéíóúñ\s]'), ' ')
      .split(RegExp(r'\s+'))
      .where((p) => p.isNotEmpty)
      .toList();

  static String? _primera(List<String> palabras) =>
      palabras.isEmpty ? null : _capitalizar(palabras.first);

  static String? _resto(List<String> palabras) => palabras.length < 2
      ? null
      : palabras.skip(1).map(_capitalizar).join(' ');

  static String _capitalizar(String p) =>
      p.isEmpty ? p : p[0].toUpperCase() + p.substring(1).toLowerCase();
}
