import 'package:taskium/domain/task.dart';

enum DetailScreenState { loading, idle, error, deleting, deleted }

extension DetailScreenStateX on DetailScreenState {
  bool get isLoading => this == DetailScreenState.loading;
  bool get isIdle => this == DetailScreenState.idle;
  bool get isError => this == DetailScreenState.error;
  bool get isDeleting => this == DetailScreenState.deleting;
  bool get isDeleted => this == DetailScreenState.deleted;

  R when<R>({
    required R Function() loading,
    required R Function() idle,
    required R Function() error,
    required R Function() deleting,
    required R Function() deleted,
  }) {
    final state = this;
    switch (state) {
      case DetailScreenState.loading:
        return loading();
      case DetailScreenState.idle:
        return idle();
      case DetailScreenState.error:
        return error();
      case DetailScreenState.deleting:
        return deleting();
      case DetailScreenState.deleted:
        return deleted();
      default:
        throw AssertionError();
    }
  }
}

class DetailState {
  final DetailScreenState screenState;
  final Task? task;
  final String? errorMessage;
  final bool hasChanges;
  final String? localFilePath;
  final bool shouldPreventNavigation;
  final bool isLoadingPdf;
  final int? galleryIndex;

  const DetailState({
    this.screenState = DetailScreenState.idle,
    this.task,
    this.errorMessage,
    this.hasChanges = false,
    this.localFilePath,
    this.shouldPreventNavigation = false,
    this.isLoadingPdf = false,
    this.galleryIndex,
  });

  DetailState copyWith({
    DetailScreenState? screenState,
    Task? task,
    String? errorMessage,
    bool? hasChanges,
    String? localFilePath,
    bool? shouldPreventNavigation,
    bool? isLoadingPdf,
    int? galleryIndex,
  }) {
    return DetailState(
      screenState: screenState ?? this.screenState,
      task: task ?? this.task,
      errorMessage: errorMessage ?? this.errorMessage,
      hasChanges: hasChanges ?? this.hasChanges,
      localFilePath: localFilePath ?? this.localFilePath,
      shouldPreventNavigation: shouldPreventNavigation ?? this.shouldPreventNavigation,
      isLoadingPdf: isLoadingPdf ?? this.isLoadingPdf,
      galleryIndex: galleryIndex ?? this.galleryIndex,
    );
  }

  @override
  List<Object?> get props => [
    screenState, task, errorMessage, hasChanges, localFilePath,
    shouldPreventNavigation, isLoadingPdf, galleryIndex
  ];
}
