import '../../domain/entities/order.dart';

class InstallmentModel extends Installment {
  const InstallmentModel({
    required super.id,
    required super.number,
    required super.amountCents,
    required super.dueDate,
    required super.status,
  });

  factory InstallmentModel.fromJson(Map<String, dynamic> json) =>
      InstallmentModel(
        id: json['id'] as String,
        number: json['number'] as int,
        amountCents: json['amount_cents'] as int,
        dueDate: DateTime.parse(json['due_date'] as String),
        status: InstallmentStatus.values.byName(json['status'] as String),
      );
}

class OrderModel extends Order {
  const OrderModel({
    required super.id,
    required super.storeName,
    required super.description,
    required super.totalCents,
    required super.initialPaidCents,
    required super.createdAt,
    required super.status,
    required super.installments,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(
    id: json['id'] as String,
    storeName: json['store_name'] as String,
    description: json['description'] as String,
    totalCents: json['total_cents'] as int,
    initialPaidCents: json['initial_paid_cents'] as int,
    createdAt: DateTime.parse(json['created_at'] as String),
    status: OrderStatus.values.byName(json['status'] as String),
    installments: (json['installments'] as List)
        .map((e) => InstallmentModel.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}
