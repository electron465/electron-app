import 'package:flutter_test/flutter_test.dart';
import 'package:app_client/features/registro/data/cedula_ocr_parser.dart';

void main() {
  test('extrae cédula con prefijo V- y separadores', () {
    final r = CedulaOcrParser.parse('REPUBLICA BOLIVARIANA DE VENEZUELA\nV-18.125.652');
    expect(r.cedula, '18125652');
  });

  test('extrae cédula sin prefijo', () {
    final r = CedulaOcrParser.parse('17239609');
    expect(r.cedula, '17239609');
  });

  test('no inventa cédula si no hay número válido', () {
    final r = CedulaOcrParser.parse('REPUBLICA BOLIVARIANA DE VENEZUELA');
    expect(r.tieneCedula, isFalse);
  });

  test('nombres y apellidos desde la línea siguiente a la etiqueta', () {
    const texto = '''
V-12.345.678
APELLIDOS
PEREZ GOMEZ
NOMBRES
MARIA JOSE
FECHA DE NACIMIENTO 10/05/1990
SEXO F
''';
    final r = CedulaOcrParser.parse(texto);
    expect(r.cedula, '12345678');
    expect(r.primerApellido, 'Perez');
    expect(r.segundoApellido, 'Gomez');
    expect(r.primerNombre, 'Maria');
    expect(r.segundoNombre, 'Jose');
    expect(r.fechaNacimiento, DateTime(1990, 5, 10));
    expect(r.sexo, 'F');
  });

  test('etiqueta y valor en la misma línea', () {
    final r = CedulaOcrParser.parse('NOMBRES: ANA\nAPELLIDOS: LOPEZ');
    expect(r.primerNombre, 'Ana');
    expect(r.primerApellido, 'Lopez');
  });

  test('fecha inválida no se acepta', () {
    final r = CedulaOcrParser.parse('31/02/1990');
    expect(r.fechaNacimiento, isNull);
  });
}
