import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/error/guard.dart';
import '../../domain/entities/store.dart';
import '../../domain/repositories/stores_repository.dart';
import '../datasources/stores_remote_data_source.dart';

class StoresRepositoryImpl implements StoresRepository {
  const StoresRepositoryImpl(this._remote);

  final StoresRemoteDataSource _remote;

  @override
  Future<Either<Failure, List<Store>>> getStores({String? query}) =>
      guard(() => _remote.getStores(query: query));
}
