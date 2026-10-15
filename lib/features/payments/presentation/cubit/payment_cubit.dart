import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/payment.dart';
import '../../domain/usecases/pay_installment.dart';

enum PaymentStatus { editing, submitting, success, failure }

final class PaymentState extends Equatable {
  const PaymentState({
    this.status = PaymentStatus.editing,
    this.method = PaymentMethod.pagoMovil,
    this.receipt,
    this.errorMessage,
  });

  final PaymentStatus status;
  final PaymentMethod method;
  final PaymentReceipt? receipt;
  final String? errorMessage;

  PaymentState copyWith({
    PaymentStatus? status,
    PaymentMethod? method,
    PaymentReceipt? receipt,
    String? errorMessage,
  }) => PaymentState(
    status: status ?? this.status,
    method: method ?? this.method,
    receipt: receipt ?? this.receipt,
    errorMessage: errorMessage,
  );

  @override
  List<Object?> get props => [status, method, receipt, errorMessage];
}

class PaymentCubit extends Cubit<PaymentState> {
  PaymentCubit(
    this._payInstallment, {
    required this.orderId,
    required this.installmentId,
  }) : super(const PaymentState());

  final PayInstallment _payInstallment;
  final String orderId;
  final String installmentId;

  void selectMethod(PaymentMethod method) =>
      emit(state.copyWith(method: method, status: PaymentStatus.editing));

  Future<void> submit() async {
    if (state.status == PaymentStatus.submitting) return;
    emit(state.copyWith(status: PaymentStatus.submitting));

    final result = await _payInstallment(
      PayInstallmentParams(
        orderId: orderId,
        installmentId: installmentId,
        method: state.method,
      ),
    );
    emit(
      result.fold(
        (f) => state.copyWith(
          status: PaymentStatus.failure,
          errorMessage: f.message,
        ),
        (receipt) =>
            state.copyWith(status: PaymentStatus.success, receipt: receipt),
      ),
    );
  }
}
