

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/supabase/supabase_service_provider.dart';
import 'category_notifier.dart';
import 'category_repository.dart';
import 'category_state.dart';


final categoryNotifierProvider =
AsyncNotifierProvider<CategoryNotifier, CategoryState>(CategoryNotifier.new);


final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  final supabaseClient = ref.watch(supabaseServiceProvider).client;
  return CategoryRepository(supabaseClient);
});