import 'package:fpdart/fpdart.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/credit_line.dart';
import '../repositories/credit_repository.dart';

class GetCreditLine implements UseCase<CreditLine, NoParams> {
  const GetCreditLine(this._repository);

  final CreditRepository _repository;

  @override
  Future<Either<Failure, CreditLine>> call(NoParams params) =>
      _repository.getCreditLine();
}
