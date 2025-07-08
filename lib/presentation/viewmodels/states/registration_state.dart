enum RegistrationScreenState { idle, registering, success, error }

extension RegistrationScreenStateX on RegistrationScreenState {
  bool get isIdle => this == RegistrationScreenState.idle;
  bool get isRegistering => this == RegistrationScreenState.registering;
  bool get isSuccess => this == RegistrationScreenState.success;
  bool get isError => this == RegistrationScreenState.error;
}

class RegistrationState {
  final RegistrationScreenState screenState;
  final String? errorMessage;

  const RegistrationState({
    this.screenState = RegistrationScreenState.idle,
    this.errorMessage,
  });

  RegistrationState copyWith({
    RegistrationScreenState? screenState,
    String? errorMessage,
  }) {
    return RegistrationState(
      screenState: screenState ?? this.screenState,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
