import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/model/item_model.dart';
import 'item_repository.dart';
import 'item_state.dart';

final itemRepositoryProvider = Provider<ItemRepository>((ref) {
  final client = Supabase.instance.client;
  return ItemRepository(client);
});

final itemNotifierProvider =
AsyncNotifierProvider<ItemNotifier, ItemState>(ItemNotifier.new);

class ItemNotifier extends AsyncNotifier<ItemState> {
  late final ItemRepository _repository;

  @override
  Future<ItemState> build() async {
    ref.keepAlive(); // Persist state
    _repository = ref.read(itemRepositoryProvider);
    return ItemState.initial();
  }

  Future<void> loadForSubcategory(int subcategoryId) async {
    final current = state.value ?? ItemState.initial();

    // Only fetch if not already present or previously failed
    if (current.subcategoryItemMap.containsKey(subcategoryId)) return;

    final updatedMap = Map<int, AsyncValue<List<Item>>>.from(current.subcategoryItemMap)
      ..[subcategoryId] = const AsyncLoading();
    debugPrint("item added calls remote db");
    state = AsyncData(current.copyWith(subcategoryItemMap: updatedMap));

    try {
      final items = await _repository.fetchBySubcategory(subcategoryId);

      final loadedMap = Map<int, AsyncValue<List<Item>>>.from(state.value!.subcategoryItemMap)
        ..[subcategoryId] = AsyncData(items);

      state = AsyncData(state.value!.copyWith(subcategoryItemMap: loadedMap));
    } catch (e, st) {
      final errorMap = Map<int, AsyncValue<List<Item>>>.from(state.value!.subcategoryItemMap)
        ..[subcategoryId] = AsyncError(e, st);

      state = AsyncData(state.value!.copyWith(subcategoryItemMap: errorMap));
    }
  }

  Future<void> addItem(Item item, {void Function(String message)? onError}) async {
    try {
      final inserted = await _repository.insertAndReturn(item);

      final current = state.value ?? ItemState.initial();
      final list = current.subcategoryItemMap[item.subcategoryId] ?? const AsyncData([]);
      final existing = list.valueOrNull ?? [];

      final updatedMap = Map<int, AsyncValue<List<Item>>>.from(current.subcategoryItemMap)
        ..[item.subcategoryId!] = AsyncData([inserted, ...existing]);

      state = AsyncData(current.copyWith(subcategoryItemMap: updatedMap));
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        onError?.call('Item "${item.name}" already exists.');
      } else {
        onError?.call('Supabase error: ${e.message}');
      }
    } catch (e) {
      onError?.call('Unexpected error: $e');
    }
  }

  Future<void> updateItem(int id, Item item) async {
    try {
      await _repository.update(id, item);
      await loadForSubcategory(item.subcategoryId!);
    } catch (e, st) {
      // optional error handling
    }
  }

  Future<void> deleteItem(int id, int subcategoryId) async {
    try {
      await _repository.softDelete(id);
      await loadForSubcategory(subcategoryId);
    } catch (e, st) {
      // optional error handling
    }
  }
}
