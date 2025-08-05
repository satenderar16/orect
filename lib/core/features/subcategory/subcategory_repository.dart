import 'package:amtnew/data/model/subcatergory_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SubcategoryRepository {
  final SupabaseClient _client;

  SubcategoryRepository(this._client);

  Future<List<Subcategory>> fetchByCategory(int categoryId) async {
    final result = await _client
        .from('subcategory')
        .select()
        .eq('category_id', categoryId)
        .eq('deleted', false)
        .order('created_at', ascending: false);

    return (result as List).map((e) => Subcategory.fromJson(e)).toList();
  }

  Future<Subcategory> insertAndReturn(Subcategory subcategory) async {
    final result = await _client
        .from('subcategory')
        .insert(subcategory.toJson())
        .select()
        .single();

    return Subcategory.fromJson(result);
  }

  Future<void> update(int id, Subcategory subcategory) async {
    await _client
        .from('subcategory')
        .update(subcategory.toJson())
        .eq('id', id);
  }

  Future<void> softDelete(int id) async {
    await _client
        .from('subcategory')
        .update({'deleted': true})
        .eq('id', id);
  }
}
