import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/order.dart';
import '../../domain/usecases/orders_usecases.dart';

// ---------- Events ----------

sealed class OrdersEvent extends Equatable {
  const OrdersEvent();

  @override
  List<Object?> get props => [];
}

final class OrdersRequested extends OrdersEvent {
  const OrdersRequested();
}

// ---------- States ----------

sealed class OrdersState extends Equatable {
  const OrdersState();

  @override
  List<Object?> get props => [];
}

final class OrdersLoading extends OrdersState {
  const OrdersLoading();
}

final class OrdersLoaded extends OrdersState {
  const OrdersLoaded(this.orders);

  final List<Order> orders;

  List<Order> get active =>
      orders.where((o) => o.status == OrderStatus.active).toList();

  List<Order> get history =>
      orders.where((o) => o.status != OrderStatus.active).toList();

  @override
  List<Object?> get props => [orders];
}

final class OrdersError extends OrdersState {
  const OrdersError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

// ---------- Bloc ----------

class OrdersBloc extends Bloc<OrdersEvent, OrdersState> {
  OrdersBloc(this._getOrders) : super(const OrdersLoading()) {
    // droppable: ignora "refresh" repetidos mientras hay uno en curso.
    on<OrdersRequested>(_onRequested, transformer: droppable());
  }

  final GetOrders _getOrders;

  Future<void> _onRequested(
    OrdersRequested event,
    Emitter<OrdersState> emit,
  ) async {
    final result = await _getOrders(const NoParams());
    emit(result.fold((f) => OrdersError(f.message), OrdersLoaded.new));
  }
}
