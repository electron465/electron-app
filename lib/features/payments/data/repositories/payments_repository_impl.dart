import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/error/guard.dart';
import '../../domain/entities/payment.dart';
import '../../domain/repositories/payments_repository.dart';
import '../datasources/payments_remote_data_source.dart';

class PaymentsRepositoryImpl implements PaymentsRepository {
  const PaymentsRepositoryImpl(this._remote);

  final PaymentsRemoteDataSource _remote;

  @override
  Future<Either<Failure, PaymentReceipt>> payInstallment({
    required String orderId,
    required String installmentId,
    required PaymentMethod method,
  }) => guard(
    () => _remote.payInstallment(
      orderId: orderId,
      installmentId: installmentId,
      method: method,
    ),
  );
}
