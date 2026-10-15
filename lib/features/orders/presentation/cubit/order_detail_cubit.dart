import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/order.dart';
import '../../domain/usecases/orders_usecases.dart';

sealed class OrderDetailState extends Equatable {
  const OrderDetailState();

  @override
  List<Object?> get props => [];
}

final class OrderDetailLoading extends OrderDetailState {
  const OrderDetailLoading();
}

final class OrderDetailLoaded extends OrderDetailState {
  const OrderDetailLoaded(this.order);

  final Order order;

  @override
  List<Object?> get props => [order];
}

final class OrderDetailError extends OrderDetailState {
  const OrderDetailError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class OrderDetailCubit extends Cubit<OrderDetailState> {
  OrderDetailCubit(this._getOrderById, {required this.orderId})
    : super(const OrderDetailLoading());

  final GetOrderById _getOrderById;
  final String orderId;

  Future<void> load() async {
    if (state is! OrderDetailLoaded) emit(const OrderDetailLoading());
    final result = await _getOrderById(orderId);
    emit(
      result.fold((f) => OrderDetailError(f.message), OrderDetailLoaded.new),
    );
  }
}
