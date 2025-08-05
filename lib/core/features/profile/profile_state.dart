import '../../../data/model/profile_model.dart';  // assuming your Profile model is here

class ProfileState {
  final Profile? profile;
  final bool isLoading;
  final String? error;

  ProfileState({
    this.profile,
    this.isLoading = false,
    this.error,
  });

  ProfileState copyWith({
    Profile? profile,
    bool? isLoading,
    String? error,
  }) {
    return ProfileState(
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  factory ProfileState.initial() {
    return ProfileState(
      profile: null,
      isLoading: false,
      error: null,
    );
  }
}
