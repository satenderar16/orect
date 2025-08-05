import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/model/option_model.dart';

class OptionRepository {
  final SupabaseClient _client = Supabase.instance.client;

  Future<List<Option>> fetchForItem(int itemId) async {
    final response = await _client
        .from('option')
        .select()
        .eq('item_id', itemId)
        .eq('deleted', false)
        .order('created_at');

    return (response as List).map((json) => Option.fromJson(json)).toList();
  }

  Future<Option> insertAndReturn(Option option) async {
    final response = await _client
        .from('option')
        .insert(option.toJson())
        .select()
        .single();

    return Option.fromJson(response);
  }

  Future<void> update(int id, Option option) async {
    await _client
        .from('option')
        .update(option.toJson())
        .eq('id', id);
  }

  Future<void> softDelete(int id) async {
    await _client
        .from('option')
        .update({
      'deleted': true,
      'deleted_at': DateTime.now().toIso8601String(),
    })
        .eq('id', id);
  }
}
