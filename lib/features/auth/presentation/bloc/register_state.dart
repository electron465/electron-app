abstract class RegisterState {
  final int currentStep;
  const RegisterState({this.currentStep = 1});
}

class RegisterInitial extends RegisterState {
  const RegisterInitial({super.currentStep});
}

class RegisterLoading extends RegisterState {
  const RegisterLoading({required super.currentStep});
}

class RegisterStepSuccess extends RegisterState {
  final String identifier;
  const RegisterStepSuccess({required super.currentStep, this.identifier = ''});
}

class RegisterCompleted extends RegisterState {
  const RegisterCompleted() : super(currentStep: 4);
}

class RegisterError extends RegisterState {
  final String message;
  const RegisterError({required super.currentStep, required this.message});
}