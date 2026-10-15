import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../entities/payment.dart';

abstract interface class PaymentsRepository {
  Future<Either<Failure, PaymentReceipt>> payInstallment({
    required String orderId,
    required String installmentId,
    required PaymentMethod method,
  });
}
