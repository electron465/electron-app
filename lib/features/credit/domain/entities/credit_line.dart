import 'package:equatable/equatable.dart';

/// Línea de crédito del cliente. El nivel determina el límite, el % de
/// inicial y el número de cuotas (sin intereses, cada N días).
class CreditLine extends Equatable {
  const CreditLine({
    required this.totalLimitCents,
    required this.availableCents,
    required this.level,
    required this.levelName,
    required this.initialPaymentPercent,
    required this.installmentsCount,
    required this.installmentFrequencyDays,
  });

  final int totalLimitCents;
  final int availableCents;
  final int level;
  final String levelName;
  final int initialPaymentPercent;
  final int installmentsCount;
  final int installmentFrequencyDays;

  int get usedCents => totalLimitCents - availableCents;

  double get usageRatio =>
      totalLimitCents == 0 ? 0 : usedCents / totalLimitCents;

  /// Calcula cómo se pagaría una compra de [priceCents].
  ///
  /// Regla: se paga una inicial (% según nivel) y el resto se divide en
  /// cuotas iguales. Si el monto financiado supera el cupo disponible,
  /// la diferencia se suma a la inicial.
  PurchasePlan simulate(int priceCents) {
    assert(priceCents > 0, 'priceCents must be positive');

    var initial = (priceCents * initialPaymentPercent / 100).ceil();
    var financed = priceCents - initial;
    if (financed > availableCents) {
      financed = availableCents;
      initial = priceCents - financed;
    }

    final base = financed ~/ installmentsCount;
    final remainder = financed % installmentsCount;
    final installments = List<int>.generate(
      installmentsCount,
      (i) => base + (i < remainder ? 1 : 0),
    );

    return PurchasePlan(
      priceCents: priceCents,
      initialCents: initial,
      installmentsCents: installments,
      frequencyDays: installmentFrequencyDays,
    );
  }

  @override
  List<Object?> get props => [
    totalLimitCents,
    availableCents,
    level,
    levelName,
    initialPaymentPercent,
    installmentsCount,
    installmentFrequencyDays,
  ];
}

class PurchasePlan extends Equatable {
  const PurchasePlan({
    required this.priceCents,
    required this.initialCents,
    required this.installmentsCents,
    required this.frequencyDays,
  });

  final int priceCents;
  final int initialCents;
  final List<int> installmentsCents;
  final int frequencyDays;

  int get financedCents => priceCents - initialCents;

  @override
  List<Object?> get props => [
    priceCents,
    initialCents,
    installmentsCents,
    frequencyDays,
  ];
}
