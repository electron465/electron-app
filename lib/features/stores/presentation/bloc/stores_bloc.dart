import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stream_transform/stream_transform.dart';

import '../../domain/entities/store.dart';
import '../../domain/usecases/get_stores.dart';

// ---------- Events ----------

sealed class StoresEvent extends Equatable {
  const StoresEvent();

  @override
  List<Object?> get props => [];
}

final class StoresRequested extends StoresEvent {
  const StoresRequested();
}

final class StoresQueryChanged extends StoresEvent {
  const StoresQueryChanged(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

// ---------- States ----------

sealed class StoresState extends Equatable {
  const StoresState();

  @override
  List<Object?> get props => [];
}

final class StoresLoading extends StoresState {
  const StoresLoading();
}

final class StoresLoaded extends StoresState {
  const StoresLoaded(this.stores);

  final List<Store> stores;

  @override
  List<Object?> get props => [stores];
}

final class StoresError extends StoresState {
  const StoresError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

// ---------- Bloc ----------

/// Se usa Bloc (no Cubit) porque la búsqueda necesita transformar el
/// stream de eventos: debounce + cancelar búsquedas anteriores.
class StoresBloc extends Bloc<StoresEvent, StoresState> {
  StoresBloc(this._getStores) : super(const StoresLoading()) {
    on<StoresRequested>((_, emit) => _fetch(null, emit));
    on<StoresQueryChanged>(
      (event, emit) => _fetch(event.query, emit),
      transformer: _debounceRestartable(const Duration(milliseconds: 350)),
    );
  }

  final GetStores _getStores;

  Future<void> _fetch(String? query, Emitter<StoresState> emit) async {
    final result = await _getStores(query);
    emit(result.fold((f) => StoresError(f.message), StoresLoaded.new));
  }

  static EventTransformer<E> _debounceRestartable<E>(Duration duration) =>
      (events, mapper) =>
          restartable<E>().call(events.debounce(duration), mapper);
}
