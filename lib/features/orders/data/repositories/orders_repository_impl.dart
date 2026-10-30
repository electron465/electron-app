import 'package:dartz/dartz.dart' hide Order;
import '../../../../core/error/failures.dart';
import '../../../../core/error/guard.dart';
import '../../domain/entities/order.dart';
import '../../domain/repositories/orders_repository.dart';
import '../datasources/orders_remote_data_source.dart';

class OrdersRepositoryImpl implements OrdersRepository {
  const OrdersRepositoryImpl(this._remote);

  final OrdersRemoteDataSource _remote;

  @override
  Future<Either<Failure, List<Order>>> getOrders() => guard(_remote.getOrders);

  @override
  Future<Either<Failure, Order>> getOrderById(String id) =>
      guard(() => _remote.getOrderById(id));
}
