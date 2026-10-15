import 'package:fpdart/fpdart.dart' hide Order;

import '../../../../core/error/failures.dart';
import '../entities/order.dart';

abstract interface class OrdersRepository {
  Future<Either<Failure, List<Order>>> getOrders();
  Future<Either<Failure, Order>> getOrderById(String id);
}
