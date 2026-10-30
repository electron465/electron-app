import 'package:flutter_bloc/flutter_bloc.dart';
import 'login_event.dart';
import 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(LoginInitial()) {
    on<LoginSubmitted>((event, emit) async {
      emit(LoginLoading());

      // Simula la llamada al servidor
      await Future.delayed(const Duration(seconds: 1));

      if (event.identifier.isNotEmpty && event.password.isNotEmpty) {
        emit(LoginSuccess('¡Bienvenido!'));
      } else {
        emit(LoginFailure('Por favor, llena todos los campos.'));
      }
    });
  }
}