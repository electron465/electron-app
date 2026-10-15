import 'package:equatable/equatable.dart';

enum OrderStatus { active, completed, cancelled }

enum InstallmentStatus { pending, paid, overdue }

class Installment extends Equatable {
  const Installment({
    required this.id,
    required this.number,
    required this.amountCents,
    required this.dueDate,
    required this.status,
  });

  final String id;
  final int number;
  final int amountCents;
  final DateTime dueDate;
  final InstallmentStatus status;

  bool get isPayable => status != InstallmentStatus.paid;

  @override
  List<Object?> get props => [id, number, amountCents, dueDate, status];
}

/// Compra financiada: inicial pagada + cuotas.
class Order extends Equatable {
  const Order({
    required this.id,
    required this.storeName,
    required this.description,
    required this.totalCents,
    required this.initialPaidCents,
    required this.createdAt,
    required this.status,
    required this.installments,
  });

  final String id;
  final String storeName;
  final String description;
  final int totalCents;
  final int initialPaidCents;
  final DateTime createdAt;
  final OrderStatus status;
  final List<Installment> installments;

  /// Próxima cuota a pagar (vencidas primero), o `null` si no hay.
  Installment? get nextInstallment {
    final payable = installments.where((i) => i.isPayable).toList()
      ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
    return payable.isEmpty ? null : payable.first;
  }

  int get pendingCents => installments
      .where((i) => i.isPayable)
      .fold(0, (sum, i) => sum + i.amountCents);

  bool get hasOverdue =>
      installments.any((i) => i.status == InstallmentStatus.overdue);

  @override
  List<Object?> get props => [
    id,
    storeName,
    description,
    totalCents,
    initialPaidCents,
    createdAt,
    status,
    installments,
  ];
}
