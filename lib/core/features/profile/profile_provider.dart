import 'package:amtnew/core/services/supabase/supabase_service_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'profile_state.dart';
import 'profile_notifier.dart';

final profileNotifierProvider = StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  final supabaseClient = ref.watch(supabaseServiceProvider).client;
  return ProfileNotifier(supabaseClient);
});