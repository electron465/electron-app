import 'package:app_client/features/credit/domain/entities/credit_line.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  CreditLine line({int available = 18000}) => CreditLine(
    totalLimitCents: 30000,
    availableCents: available,
    level: 3,
    levelName: 'Nivel 3',
    initialPaymentPercent: 40,
    installmentsCount: 3,
    installmentFrequencyDays: 14,
  );

  group('CreditLine.simulate', () {
    test('divide la compra en inicial + cuotas iguales', () {
      final plan = line().simulate(10000);

      expect(plan.initialCents, 4000);
      expect(plan.installmentsCents, [2000, 2000, 2000]);
    });

    test('reparte el residuo de centavos en las primeras cuotas', () {
      final plan = line().simulate(1001);

      expect(
        plan.initialCents + plan.installmentsCents.reduce((a, b) => a + b),
        1001,
      );
      expect(
        plan.installmentsCents.first >= plan.installmentsCents.last,
        isTrue,
      );
    });

    test('si excede el cupo, la diferencia se suma a la inicial', () {
      final plan = line(available: 3000).simulate(10000);

      expect(plan.financedCents, 3000);
      expect(plan.initialCents, 7000);
      expect(plan.installmentsCents, [1000, 1000, 1000]);
    });
  });
}
