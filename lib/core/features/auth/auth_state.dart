
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/model/profile_model.dart';

class AppAuthState {
  final bool isAuthenticated;
  final User? user;
  final bool isLoading;
  final String? error;



  AppAuthState({
    required this.isAuthenticated,
    this.user,
    this.isLoading = false,
    this.error,

  });

  factory AppAuthState.initial() => AppAuthState(
    isAuthenticated: false,
  );

  AppAuthState copyWith({
    bool? isAuthenticated,
    User? user,
    bool? isLoading,
    String? error,

  }) {
    return AppAuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,

    );
  }
}
