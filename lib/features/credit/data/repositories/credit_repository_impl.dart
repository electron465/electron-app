import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/guard.dart';
import '../../domain/entities/credit_line.dart';
import '../../domain/repositories/credit_repository.dart';
import '../datasources/credit_remote_data_source.dart';

class CreditRepositoryImpl implements CreditRepository {
  const CreditRepositoryImpl(this._remote);

  final CreditRemoteDataSource _remote;

  @override
  Future<Either<Failure, CreditLine>> getCreditLine() =>
      guard(_remote.getCreditLine);
}
