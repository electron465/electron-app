import '../../../../core/mock/mock_backend.dart';
import '../../../../core/network/api_client.dart';
import '../models/store_model.dart';

abstract interface class StoresRemoteDataSource {
  Future<List<StoreModel>> getStores({String? query});
}

class StoresRemoteDataSourceImpl implements StoresRemoteDataSource {
  const StoresRemoteDataSourceImpl(this._api);

  final ApiClient _api;

  @override
  Future<List<StoreModel>> getStores({String? query}) async {
    final json = await _api.get(
      '/stores',
      query: {if (query != null && query.isNotEmpty) 'q': query},
    );
    return (json as List)
        .map((e) => StoreModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

class StoresMockDataSource implements StoresRemoteDataSource {
  const StoresMockDataSource(this._backend);

  final MockBackend _backend;

  @override
  Future<List<StoreModel>> getStores({String? query}) async {
    await _backend.delay();
    final q = query?.trim().toLowerCase() ?? '';
    return _backend.stores
        .where(
          (s) =>
              q.isEmpty ||
              (s['name'] as String).toLowerCase().contains(q) ||
              (s['category'] as String).toLowerCase().contains(q),
        )
        .map(StoreModel.fromJson)
        .toList();
  }
}
