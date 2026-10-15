import '../../domain/entities/credit_line.dart';

class CreditLineModel extends CreditLine {
  const CreditLineModel({
    required super.totalLimitCents,
    required super.availableCents,
    required super.level,
    required super.levelName,
    required super.initialPaymentPercent,
    required super.installmentsCount,
    required super.installmentFrequencyDays,
  });

  factory CreditLineModel.fromJson(Map<String, dynamic> json) =>
      CreditLineModel(
        totalLimitCents: json['total_limit_cents'] as int,
        availableCents: json['available_cents'] as int,
        level: json['level'] as int,
        levelName: json['level_name'] as String,
        initialPaymentPercent: json['initial_payment_percent'] as int,
        installmentsCount: json['installments_count'] as int,
        installmentFrequencyDays: json['installment_frequency_days'] as int,
      );
}
