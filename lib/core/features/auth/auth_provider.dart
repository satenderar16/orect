import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../profile/profile_provider.dart';
import '../../services/supabase/supabase_service_provider.dart';
import 'auth_repository.dart';
import 'auth_notifier.dart';
import 'auth_state.dart';



final authRepositoryProvider = Provider<AuthRepository>((ref) {

  //we can even pass client directly with supabaseClient.client

  final supabaseClient = ref.watch(supabaseServiceProvider).client;
  return AuthRepository(supabaseClient);
});


final authNotifierProvider = StateNotifierProvider<AuthNotifier, AppAuthState>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  final profileRepo = ref.watch(profileNotifierProvider.notifier);
  return AuthNotifier(repo, profileRepo);
});
