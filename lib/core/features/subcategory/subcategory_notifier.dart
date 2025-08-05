import 'package:amtnew/data/model/subcatergory_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'subcategory_state.dart';
import 'subcategory_repository.dart';

final subcategoryNotifierProvider =
    AsyncNotifierProvider<SubcategoryNotifier, SubcategoryState>(
      SubcategoryNotifier.new,
    );

class SubcategoryNotifier extends AsyncNotifier<SubcategoryState> {
  late final SubcategoryRepository _repository;

  @override
  Future<SubcategoryState> build() async {
    ref.keepAlive();
    _repository = SubcategoryRepository(Supabase.instance.client);
    return SubcategoryState.initial();
  }

  /// Load subcategories for a specific category (lazy, with loading/error handling)
  Future<void> loadForCategory(int categoryId) async {
    final current = state.valueOrNull ?? SubcategoryState.initial();

    // If already loading or loaded, skip
    final existing = current.categorySubMap[categoryId];
    if (existing is AsyncLoading || existing is AsyncData) return;
    debugPrint("subcategory calls remote");
    // Mark category as loading
    state = AsyncData(
      current.copyWith(
        categorySubMap: {
          ...current.categorySubMap,
          categoryId: const AsyncLoading(),
        },
      ),
    );

    try {
      final subcategories = await _repository.fetchByCategory(categoryId);
      state = AsyncData(
        state.value!.copyWith(
          categorySubMap: {
            ...state.value!.categorySubMap,
            categoryId: AsyncData(subcategories),
          },
        ),
      );
    } catch (e, st) {
      state = AsyncData(
        state.value!.copyWith(
          categorySubMap: {
            ...state.value!.categorySubMap,
            categoryId: AsyncError(e, st),
          },
        ),
      );
    }
  }

  /// Add new subcategory and insert into cached list
  Future<void> addSubcategory(
    Subcategory sub, {
    void Function(String)? onError,
  }) async {
    try {
      final inserted = await _repository.insertAndReturn(sub);
      final categoryId = inserted.categoryId!;
      final current = state.value ?? SubcategoryState.initial();
      final existing = current.categorySubMap[categoryId];

      final updatedList = switch (existing) {
        AsyncData(:final value) => [inserted, ...value],
        _ => [inserted],
      };

      state = AsyncData(
        current.copyWith(
          categorySubMap: {
            ...current.categorySubMap,
            categoryId: AsyncData(updatedList),
          },
        ),
      );
    } catch (e) {
      onError?.call('Failed to add subcategory: $e');
    }
  }

  /// Update subcategory and refresh category list
  Future<void> updateSubcategory(int id, Subcategory sub) async {
    try {
      await _repository.update(id, sub);
      await loadForCategory(sub.categoryId!); // Refresh affected category
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  /// Soft delete and refresh
  Future<void> deleteSubcategory(int id, int categoryId) async {
    try {
      await _repository.softDelete(id);
      await loadForCategory(categoryId); // Reload after delete
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  /// Get subcategories for category (safe fallback)
  AsyncValue<List<Subcategory>> getSubcategories(int categoryId) {
    return state.valueOrNull?.categorySubMap[categoryId] ??
        const AsyncLoading();
  }
}
