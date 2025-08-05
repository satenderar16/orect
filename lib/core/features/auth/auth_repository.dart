import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  final SupabaseClient _client;

  AuthRepository(this._client);

  SupabaseClient get client => _client;

  Stream<AuthState> authStateChanges() => _client.auth.onAuthStateChange;

  User? get currentUser => _client.auth.currentUser;

  Future<AuthResponse> loginWithPassword(String email, String password) {
    return _client.auth.signInWithPassword(email: email, password: password);
  }

  Future<void> sendOtp(String email, {bool shouldCreateUser = false}) {
    return _client.auth.signInWithOtp(email: email, shouldCreateUser: shouldCreateUser);
  }

  Future<User> verifyOtp(String email, String otp) async {
    final result = await _client.auth.verifyOTP(
      type: OtpType.email,
      token: otp,
      email: email,
    );
    if (result.user == null) throw Exception("Verification failed");
    return result.user!;
  }

  Future<void> updatePassword(String password) {
    return _client.auth.updateUser(UserAttributes(password: password));
  }

  Future<void> signOut() => _client.auth.signOut();

  Future<bool> checkUserExists(String email) async {
    final result = await _client.rpc('user_exists_by_email', params: {'p_email': email});
    return result as bool;
  }
}
