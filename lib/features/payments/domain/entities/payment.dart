import 'package:equatable/equatable.dart';

enum PaymentMethod {
  pagoMovil('Pago Móvil'),
  transferencia('Transferencia bancaria'),
  tarjeta('Tarjeta internacional');

  const PaymentMethod(this.label);

  final String label;
}

class PaymentReceipt extends Equatable {
  const PaymentReceipt({
    required this.id,
    required this.orderId,
    required this.installmentId,
    required this.amountCents,
    required this.method,
    required this.reference,
    required this.paidAt,
  });

  final String id;
  final String orderId;
  final String installmentId;
  final int amountCents;
  final PaymentMethod method;
  final String reference;
  final DateTime paidAt;

  @override
  List<Object?> get props => [
    id,
    orderId,
    installmentId,
    amountCents,
    method,
    reference,
    paidAt,
  ];
}
