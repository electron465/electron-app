import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/auth_usecases.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/cubit/register_cubit.dart';
import '../../features/auth/presentation/cubit/login_cubit.dart';
import '../../features/credit/data/datasources/credit_remote_data_source.dart';
import '../../features/credit/data/repositories/credit_repository_impl.dart';
import '../../features/credit/domain/repositories/credit_repository.dart';
import '../../features/credit/domain/usecases/get_credit_line.dart';
import '../../features/credit/presentation/cubit/credit_cubit.dart';
import '../../features/orders/data/datasources/orders_remote_data_source.dart';
import '../../features/orders/data/repositories/orders_repository_impl.dart';
import '../../features/orders/domain/repositories/orders_repository.dart';
import '../../features/orders/domain/usecases/orders_usecases.dart';
import '../../features/orders/presentation/bloc/orders_bloc.dart';
import '../../features/orders/presentation/cubit/order_detail_cubit.dart';
import '../../features/payments/data/datasources/payments_remote_data_source.dart';
import '../../features/payments/data/repositories/payments_repository_impl.dart';
import '../../features/payments/domain/repositories/payments_repository.dart';
import '../../features/payments/domain/usecases/pay_installment.dart';
import '../../features/payments/presentation/cubit/payment_cubit.dart';
import '../../features/stores/data/datasources/stores_remote_data_source.dart';
import '../../features/stores/data/repositories/stores_repository_impl.dart';
import '../../features/stores/domain/repositories/stores_repository.dart';
import '../../features/stores/domain/usecases/get_stores.dart';
import '../../features/stores/presentation/bloc/stores_bloc.dart';
import '../config/env.dart';
import '../mock/mock_backend.dart';
import '../network/api_client.dart';
import '../storage/token_storage.dart';

/// Service locator. Convención:
/// - lazySingleton: infraestructura, datasources, repos, use cases y el
///   AuthBloc global.
/// - factory: Blocs/Cubits de pantalla (una instancia nueva por ruta).
final sl = GetIt.instance;

Future<void> configureDependencies() async {
  _core();
  _auth();
  _credit();
  _stores();
  _orders();
  _payments();
}

void _core() {
  sl
    ..registerLazySingleton(() => const FlutterSecureStorage())
    ..registerLazySingleton(() => TokenStorage(sl()))
    ..registerLazySingleton(
      () => ApiClient(baseUrl: Env.apiBaseUrl, tokenStorage: sl()),
    );
  if (Env.useMocks) sl.registerLazySingleton(MockBackend.new);
}

/// Elige la implementación real o la mock según [Env.useMocks].
T _source<T extends Object>(T Function() real, T Function() mock) =>
    Env.useMocks ? mock() : real();

void _auth() {
  sl
    ..registerLazySingleton<AuthRemoteDataSource>(
      () => _source<AuthRemoteDataSource>(
        () => AuthRemoteDataSourceImpl(sl()),
        () => AuthMockDataSource(sl()),
      ),
    )
    ..registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(sl(), sl()),
    )
    ..registerLazySingleton(() => RequestOtp(sl()))
    ..registerLazySingleton(() => VerifyOtp(sl()))
    ..registerLazySingleton(() => GetCurrentUser(sl()))
    ..registerLazySingleton(() => Logout(sl()))
    ..registerLazySingleton(() => CreatePassword(sl())) // <-- Agregado
    ..registerLazySingleton(() => AuthBloc(getCurrentUser: sl(), logout: sl()))
    ..registerFactory(() => LoginCubit(requestOtp: sl(), verifyOtp: sl()))

    // Registramos el RegisterCubit con los 3 casos de uso:
   ..registerFactory(() => RegisterCubit(
         requestOtp: sl(),
         verifyOtp: sl(),
         createPassword: sl(),
       ));
}

void _credit() {
  sl
    ..registerLazySingleton<CreditRemoteDataSource>(
      () => _source<CreditRemoteDataSource>(
        () => CreditRemoteDataSourceImpl(sl()),
        () => CreditMockDataSource(sl()),
      ),
    )
    ..registerLazySingleton<CreditRepository>(() => CreditRepositoryImpl(sl()))
    ..registerLazySingleton(() => GetCreditLine(sl()))
    ..registerFactory(() => CreditCubit(sl()));
}

void _stores() {
  sl
    ..registerLazySingleton<StoresRemoteDataSource>(
      () => _source<StoresRemoteDataSource>(
        () => StoresRemoteDataSourceImpl(sl()),
        () => StoresMockDataSource(sl()),
      ),
    )
    ..registerLazySingleton<StoresRepository>(() => StoresRepositoryImpl(sl()))
    ..registerLazySingleton(() => GetStores(sl()))
    ..registerFactory(() => StoresBloc(sl()));
}

void _orders() {
  sl
    ..registerLazySingleton<OrdersRemoteDataSource>(
      () => _source<OrdersRemoteDataSource>(
        () => OrdersRemoteDataSourceImpl(sl()),
        () => OrdersMockDataSource(sl()),
      ),
    )
    ..registerLazySingleton<OrdersRepository>(() => OrdersRepositoryImpl(sl()))
    ..registerLazySingleton(() => GetOrders(sl()))
    ..registerLazySingleton(() => GetOrderById(sl()))
    ..registerFactory(() => OrdersBloc(sl()))
    ..registerFactoryParam<OrderDetailCubit, String, void>(
      (orderId, _) => OrderDetailCubit(sl(), orderId: orderId),
    );
}

void _payments() {
  sl
    ..registerLazySingleton<PaymentsRemoteDataSource>(
      () => _source<PaymentsRemoteDataSource>(
        () => PaymentsRemoteDataSourceImpl(sl()),
        () => PaymentsMockDataSource(sl()),
      ),
    )
    ..registerLazySingleton<PaymentsRepository>(
      () => PaymentsRepositoryImpl(sl()),
    )
    ..registerLazySingleton(() => PayInstallment(sl()))
    ..registerFactoryParam<PaymentCubit, String, String>(
      (orderId, installmentId) =>
          PaymentCubit(sl(), orderId: orderId, installmentId: installmentId),
    );
}
