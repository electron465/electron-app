import 'package:equatable/equatable.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/payment.dart';
import '../repositories/payments_repository.dart';

class PayInstallmentParams extends Equatable {
  const PayInstallmentParams({
    required this.orderId,
    required this.installmentId,
    required this.method,
  });

  final String orderId;
  final String installmentId;
  final PaymentMethod method;

  @override
  List<Object?> get props => [orderId, installmentId, method];
}

class PayInstallment implements UseCase<PaymentReceipt, PayInstallmentParams> {
  const PayInstallment(this._repository);

  final PaymentsRepository _repository;

  @override
  Future<Either<Failure, PaymentReceipt>> call(PayInstallmentParams params) =>
      _repository.payInstallment(
        orderId: params.orderId,
        installmentId: params.installmentId,
        method: params.method,
      );
}
