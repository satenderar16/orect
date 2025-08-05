

class AppBootState {
  final bool isLoading;
  final bool isInitialized;
  final String? error;

  const AppBootState({
    required this.isLoading,
    required this.isInitialized,
    this.error,
  });

  factory AppBootState.initial() => const AppBootState(
    isLoading: true,
    isInitialized: false,
    error: null,
  );

  AppBootState copyWith({
    bool? isLoading,
    bool? isInitialized,
    String? error,
  }) {
    return AppBootState(
      isLoading: isLoading ?? this.isLoading,
      isInitialized: isInitialized ?? this.isInitialized,
      error: error,
    );
  }
}
