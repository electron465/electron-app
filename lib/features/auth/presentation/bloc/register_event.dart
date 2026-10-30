abstract class RegisterEvent {}

class SubmitIdentifier extends RegisterEvent {
  final String identifier;
  SubmitIdentifier(this.identifier);
}

class SubmitOtp extends RegisterEvent {
  final String otp;
  SubmitOtp(this.otp);
}

class SubmitPassword extends RegisterEvent {
  final String password;
  SubmitPassword(this.password);
}

// NUEVO EVENTO
class SelectUserType extends RegisterEvent {
  final bool isMilitar;
  SelectUserType(this.isMilitar);
}