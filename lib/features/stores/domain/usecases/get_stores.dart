import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/store.dart';
import '../repositories/stores_repository.dart';

class GetStores implements UseCase<List<Store>, String?> {
  const GetStores(this._repository);

  final StoresRepository _repository;

  /// [query] filtra por nombre o categoría; `null` devuelve todos.
  @override
  Future<Either<Failure, List<Store>>> call(String? query) =>
      _repository.getStores(query: query);
}
