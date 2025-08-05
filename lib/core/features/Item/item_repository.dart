import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/model/item_model.dart';

class ItemRepository {
  final SupabaseClient _client;

  ItemRepository(this._client);

  Future<List<Item>> fetchBySubcategory(int subcategoryId) async {
    final data = await _client
        .from('item')
        .select()
        .eq('subcategory_id', subcategoryId)
        .eq('deleted', false)
        .order('created_at')
        .then((rows) => rows.map((e) => Item.fromJson(e)).toList());

    return data;
  }

  Future<Item> insertAndReturn(Item item) async {
    final inserted = await _client
        .from('item')
        .insert(item.toJson())
        .select()
        .single();

    return Item.fromJson(inserted);
  }

  Future<void> update(int id, Item item) async {
    await _client.from('item').update(item.toJson()).eq('id', id);
  }

  Future<void> softDelete(int id) async {
    await _client
        .from('item')
        .update({'deleted': true})
        .eq('id', id);
  }
}
