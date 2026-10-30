abstract class LoginEvent {}

class LoginSubmitted extends LoginEvent {
  final String identifier;
  final String password;
  LoginSubmitted(this.identifier, this.password);
}