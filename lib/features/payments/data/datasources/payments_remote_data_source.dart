import '../../../../core/mock/mock_backend.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/payment.dart';
import '../models/payment_receipt_model.dart';

abstract interface class PaymentsRemoteDataSource {
  Future<PaymentReceiptModel> payInstallment({
    required String orderId,
    required String installmentId,
    required PaymentMethod method,
  });
}

class PaymentsRemoteDataSourceImpl implements PaymentsRemoteDataSource {
  const PaymentsRemoteDataSourceImpl(this._api);

  final ApiClient _api;

  @override
  Future<PaymentReceiptModel> payInstallment({
    required String orderId,
    required String installmentId,
    required PaymentMethod method,
  }) async {
    final json = await _api.post(
      '/orders/$orderId/installments/$installmentId/payments',
      data: {'method': method.name},
    );
    return PaymentReceiptModel.fromJson(json as Map<String, dynamic>);
  }
}

class PaymentsMockDataSource implements PaymentsRemoteDataSource {
  const PaymentsMockDataSource(this._backend);

  final MockBackend _backend;

  @override
  Future<PaymentReceiptModel> payInstallment({
    required String orderId,
    required String installmentId,
    required PaymentMethod method,
  }) async {
    await _backend.delay();
    return PaymentReceiptModel.fromJson(
      _backend.payInstallment(
        orderId: orderId,
        installmentId: installmentId,
        method: method.name,
      ),
    );
  }
}
