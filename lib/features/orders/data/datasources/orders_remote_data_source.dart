import '../../../../core/error/exceptions.dart';
import '../../../../core/mock/mock_backend.dart';
import '../../../../core/network/api_client.dart';
import '../models/order_model.dart';

abstract interface class OrdersRemoteDataSource {
  Future<List<OrderModel>> getOrders();
  Future<OrderModel> getOrderById(String id);
}

class OrdersRemoteDataSourceImpl implements OrdersRemoteDataSource {
  const OrdersRemoteDataSourceImpl(this._api);

  final ApiClient _api;

  @override
  Future<List<OrderModel>> getOrders() async {
    final json = await _api.get('/orders');
    return (json as List)
        .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<OrderModel> getOrderById(String id) async {
    final json = await _api.get('/orders/$id');
    return OrderModel.fromJson(json as Map<String, dynamic>);
  }
}

class OrdersMockDataSource implements OrdersRemoteDataSource {
  const OrdersMockDataSource(this._backend);

  final MockBackend _backend;

  @override
  Future<List<OrderModel>> getOrders() async {
    await _backend.delay();
    return _backend.orders.map(OrderModel.fromJson).toList();
  }

  @override
  Future<OrderModel> getOrderById(String id) async {
    await _backend.delay();
    final json = _backend.orders.where((o) => o['id'] == id).firstOrNull;
    if (json == null) {
      throw const ServerException('Compra no encontrada', statusCode: 404);
    }
    return OrderModel.fromJson(json);
  }
}
