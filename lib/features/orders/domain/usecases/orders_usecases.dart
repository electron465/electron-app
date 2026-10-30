import 'package:dartz/dartz.dart' hide Order;
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/order.dart';
import '../repositories/orders_repository.dart';

class GetOrders implements UseCase<List<Order>, NoParams> {
  const GetOrders(this._repository);

  final OrdersRepository _repository;

  @override
  Future<Either<Failure, List<Order>>> call(NoParams params) =>
      _repository.getOrders();
}

class GetOrderById implements UseCase<Order, String> {
  const GetOrderById(this._repository);

  final OrdersRepository _repository;

  @override
  Future<Either<Failure, Order>> call(String id) =>
      _repository.getOrderById(id);
}
