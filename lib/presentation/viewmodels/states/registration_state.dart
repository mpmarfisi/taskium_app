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
  final String? bornDate;

  const RegistrationState({
    this.screenState = RegistrationScreenState.idle,
    this.errorMessage,
    this.bornDate,
  });

  RegistrationState copyWith({
    RegistrationScreenState? screenState,
    String? errorMessage,
    String? bornDate,
  }) {
    return RegistrationState(
      screenState: screenState ?? this.screenState,
      errorMessage: errorMessage ?? this.errorMessage,
      bornDate: bornDate ?? this.bornDate,
    );
  }
}
