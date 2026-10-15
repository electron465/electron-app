import '../../domain/entities/payment.dart';

class PaymentReceiptModel extends PaymentReceipt {
  const PaymentReceiptModel({
    required super.id,
    required super.orderId,
    required super.installmentId,
    required super.amountCents,
    required super.method,
    required super.reference,
    required super.paidAt,
  });

  factory PaymentReceiptModel.fromJson(Map<String, dynamic> json) =>
      PaymentReceiptModel(
        id: json['id'] as String,
        orderId: json['order_id'] as String,
        installmentId: json['installment_id'] as String,
        amountCents: json['amount_cents'] as int,
        method: PaymentMethod.values.byName(json['method'] as String),
        reference: json['reference'] as String,
        paidAt: DateTime.parse(json['paid_at'] as String),
      );
}
