import 'package:taskium/domain/user.dart';

enum ProfileScreenState { loading, idle, error, updating, updated }

extension ProfileScreenStateX on ProfileScreenState {
  bool get isLoading => this == ProfileScreenState.loading;
  bool get isIdle => this == ProfileScreenState.idle;
  bool get isError => this == ProfileScreenState.error;
  bool get isUpdating => this == ProfileScreenState.updating;
  bool get isUpdated => this == ProfileScreenState.updated;

  R when<R>({
    required R Function() loading,
    required R Function() idle,
    required R Function() error,
    required R Function() updating,
    required R Function() updated,
  }) {
    final state = this;
    switch (state) {
      case ProfileScreenState.loading:
        return loading();
      case ProfileScreenState.idle:
        return idle();
      case ProfileScreenState.error:
        return error();
      case ProfileScreenState.updating:
        return updating();
      case ProfileScreenState.updated:
        return updated();
      default:
        throw AssertionError();
    }
  }
}

class ProfileState {
  final ProfileScreenState screenState;
  final User? user;
  final String? errorMessage;
  final bool hasChanges;
  final bool imageLoadError;

  const ProfileState({
    this.screenState = ProfileScreenState.idle,
    this.user,
    this.errorMessage,
    this.hasChanges = false,
    this.imageLoadError = false,
  });

  ProfileState copyWith({
    ProfileScreenState? screenState,
    User? user,
    String? errorMessage,
    bool? hasChanges,
    bool? imageLoadError,
  }) {
    return ProfileState(
      screenState: screenState ?? this.screenState,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
      hasChanges: hasChanges ?? this.hasChanges,
      imageLoadError: imageLoadError ?? this.imageLoadError,
    );
  }

  @override
  List<Object?> get props => [screenState, user, errorMessage, hasChanges, imageLoadError];
}
