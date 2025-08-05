import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/model/profile_model.dart';
import '../profile/profile_notifier.dart';
import 'auth_state.dart';
import 'auth_repository.dart';

class AuthNotifier extends StateNotifier<AppAuthState> {
  final AuthRepository _repo;
  final ProfileNotifier _profileRepo;

  late final StreamSubscription<AuthState> _sub;

  AuthNotifier(this._repo, this._profileRepo) : super(AppAuthState.initial());

  Future<void> init() async {
    _listenToAuthChanges();
    _loadCurrentUser();
  }

  void _listenToAuthChanges() {
    _sub = _repo.authStateChanges().listen((data) {
      final event = data.event;
      final session = data.session;
      if (event == AuthChangeEvent.signedOut) {
        state = state.copyWith(isAuthenticated: false, user: null, error: null);
      } else if (session != null) {
        state = state.copyWith(user: session.user, error: null);
      }
    },
    onError: (error) {
      // Handle network/auth errors
      if (error is SocketException) {
        // state = state.copyWith(error: 'No internet connection');
        debugPrint('AuthSocketException: No network');
      } else if (error is AuthRetryableFetchException) {
        // state = state.copyWith(error: 'Check you Connection');
        debugPrint('AuthRetryableFetchException: ${error.message}');
      } else {
        // state = state.copyWith(error: 'Unexpected auth error');
        debugPrint('Unknown auth error: $error');
      }
    },
    cancelOnError: false,

    );
  }

  void _loadCurrentUser() {
    final user = _repo.currentUser;
    if (user != null) {
      state = state.copyWith(user: user, isAuthenticated: true);
    }
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final res = await _repo.loginWithPassword(email, password);
      final user = res.user;
      if (user == null) throw Exception("Invalid credentials");
      await _profileRepo.getProfile(user.id);
      state = state.copyWith(
        user: user,
        isAuthenticated: true,
        isLoading: false,
      );

      return true;
    } catch (e) {
      _handleError(e);
      debugPrint("${state.error}");
      return false;
    }
  }

  Future<bool> loginWithOtp(String email) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      await _repo.sendOtp(email);
      return true;
    } catch (e) {
      _handleError(e);
      return false;
    } finally {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<bool> signUpWithOtp(String email) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final exists = await _repo.checkUserExists(email);
      if (exists) {
        state = state.copyWith(error: "User already exists");
        return false;
      }
      await _repo.sendOtp(email, shouldCreateUser: true);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      _handleError(e);
      return false;
    }
  }

  Future<bool> verifyOtp(String email, String otp) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final user = await _repo.verifyOtp(email, otp);
      await _profileRepo.getProfile(user.id);
      state = state.copyWith(
        user: user,
        isAuthenticated: true,
        isLoading: false,
      );

      return true;
    } catch (e) {
      _handleError(e);
      return false;
    }
  }

  Future<bool> verifyOtpSignUp(
    String email,
    String otp,
    Profile profile,
  ) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      final user = await _repo.verifyOtp(email, otp);
      await _profileRepo.insertProfile(profile, user.id);
      state = state.copyWith(
        user: user,
        isAuthenticated: false,
        isLoading: false,
      );

      return true;
    } catch (e) {
      _handleError(e);
      return false;
    }
  }

  Future<bool> resetPassword(String password) async {
    try {
      state = state.copyWith(error: null, isLoading: true);
      await _repo.updatePassword(password);
      state = state.copyWith(
        error: null,
        isLoading: false,
        isAuthenticated: true,
      );
      return true;
    } catch (e) {
      _handleError(e);
      return false;
    }
  }

  Future<void> signOut() async {
    await _repo.signOut();
    await _profileRepo.clearProfile();
    state = AppAuthState.initial();
  }

  void _handleError(dynamic e) {
    String msg;
    if (e is SocketException) {
      msg = "No internet connection.";
    }
    else if (e is TimeoutException) {
      msg = "Slow Internet connection.";
    } else if (e is AuthException) {
      final lowerMsg = e.toString().toLowerCase();

      if (lowerMsg.contains('invalid login credentials')) {
        msg= "Invalid email or password.";
      } else if (lowerMsg.contains('email not confirmed')) {
        msg= "Please verify your email before signing in.";
      } else if (lowerMsg.contains('over_email_send_rate_limit')) {
        msg= "Too many requests. Please wait a few seconds and try again.";
      } else if (lowerMsg.contains('user not found')) {
        msg= "No account found with this email.";
      }else if (lowerMsg.contains('socketException') || lowerMsg.contains('failed host lookup')) {
        msg= "Please check your internet connection.";
      } else {
        msg= "Authentication failed: ${e.message.toString()}";
      }
    } else {
      msg = "Unexpected error";
    }
    debugPrint("this DebugPrint:");
    debugPrint(e.toString());

    state = state.copyWith(error: msg, isLoading: false);
  }

  void setIsAuthentication(bool value) {
    state = state.copyWith(isAuthenticated: true);
  }
   void clearError(){
    state = state.copyWith(error: null);
   }


  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
