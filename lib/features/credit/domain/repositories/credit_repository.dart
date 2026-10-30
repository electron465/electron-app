import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/credit_line.dart';

abstract interface class CreditRepository {
  Future<Either<Failure, CreditLine>> getCreditLine();
}
