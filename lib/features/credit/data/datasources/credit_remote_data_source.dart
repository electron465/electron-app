import '../../../../core/mock/mock_backend.dart';
import '../../../../core/network/api_client.dart';
import '../models/credit_line_model.dart';

abstract interface class CreditRemoteDataSource {
  Future<CreditLineModel> getCreditLine();
}

class CreditRemoteDataSourceImpl implements CreditRemoteDataSource {
  const CreditRemoteDataSourceImpl(this._api);

  final ApiClient _api;

  @override
  Future<CreditLineModel> getCreditLine() async {
    final json = await _api.get('/credit-line');
    return CreditLineModel.fromJson(json as Map<String, dynamic>);
  }
}

class CreditMockDataSource implements CreditRemoteDataSource {
  const CreditMockDataSource(this._backend);

  final MockBackend _backend;

  @override
  Future<CreditLineModel> getCreditLine() async {
    await _backend.delay();
    return CreditLineModel.fromJson(_backend.creditLine);
  }
}
