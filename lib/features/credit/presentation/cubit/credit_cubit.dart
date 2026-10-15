import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/credit_line.dart';
import '../../domain/usecases/get_credit_line.dart';

sealed class CreditState extends Equatable {
  const CreditState();

  @override
  List<Object?> get props => [];
}

final class CreditLoading extends CreditState {
  const CreditLoading();
}

final class CreditLoaded extends CreditState {
  const CreditLoaded(this.creditLine);

  final CreditLine creditLine;

  @override
  List<Object?> get props => [creditLine];
}

final class CreditError extends CreditState {
  const CreditError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class CreditCubit extends Cubit<CreditState> {
  CreditCubit(this._getCreditLine) : super(const CreditLoading());

  final GetCreditLine _getCreditLine;

  Future<void> load() async {
    if (state is! CreditLoaded) emit(const CreditLoading());
    final result = await _getCreditLine(const NoParams());
    emit(result.fold((f) => CreditError(f.message), CreditLoaded.new));
  }
}
