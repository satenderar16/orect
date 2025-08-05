import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../Screens/Dashboard/MenuPage/category/category_creation.dart';
import '../../../data/model/category_modal.dart';
import '../../utils/image_compress.dart';
import 'category_provider.dart';
import 'category_repository.dart';
import 'category_state.dart';

class CategoryNotifier extends AsyncNotifier<CategoryState> {
  late final CategoryRepository _repository= ref.read(categoryRepositoryProvider);

  @override
  Future<CategoryState> build() async {
    ref.keepAlive();
    try {
      final data = await _repository.fetchAll();
      return CategoryState(categories: data);
    } on SocketException catch (_, st) {
      state = AsyncError('No internet Connection', st);
      // ✅ return a Future that never completes so Riverpod doesn't override the error
      return await Future.error('No internet Connection', st);
    } on TimeoutException catch (_, st) {
      state = AsyncError('Request timed out', st);
      return await Future.error('Request timed out', st);
    } catch (e, st) {
      state = AsyncError('Unknown error', st);
      return await Future.error("Something went wrong", st);
    }



  }
//refresh when data is present and user
  Future<void> refreshFetch() async {
    try {
      final categories = await _repository.fetchAll();
      // Only update on success
      state = AsyncData(
        state.value?.copyWith(categories: categories) ??
            CategoryState(categories: categories),
      );
    } on TimeoutException catch (e, stackTrace) {
      // Don't touch state, just log or handle externally
      debugPrint('Timeout during retry: $e');
    } on SocketException catch (e, stackTrace) {
      debugPrint('No internet during retry: $e');
    } catch (e, stackTrace) {
      debugPrint('Retry failed: $e');
    }
  }


  Future<void> retryFetch() async {
    // Set loading state
    state = const AsyncLoading();

    try {
      final categories = await _repository.fetchAll();

      // Set new data
      state = AsyncData(
        state.value?.copyWith(categories: categories) ??
            CategoryState(categories: categories),
      );
    } on TimeoutException catch (e, stackTrace) {
      state = AsyncError('Request timed out', stackTrace);
    } on SocketException catch (e, stackTrace) {
      state = AsyncError('No internet connection', stackTrace);
    } catch (e, stackTrace) {
      debugPrint(e.toString());
      debugPrint(stackTrace.toString());
      state = AsyncError('Something went wrong', stackTrace);
    }
  }

  Future<List<CategoryModal>> addCategories(
      List<CategoryModal> categories,) async {
    try {
      // Insert and get inserted categories with IDs
      final inserted = await _repository.insertAllAndReturn(categories);

      // Update state
      final current = state.valueOrNull?.categories ?? [];
      final updated = [...inserted, ...current];

      state = AsyncData(state.value!.copyWith(categories: updated));

      return inserted;
    } on PostgrestException catch (e) {
      final msg = e.code == '23505'
          ? 'One or more categories already exist.'
          : 'Supabase error: ${e.message}';
      throw msg;
    } catch (e) {

      debugPrint("unexpected error: $e");
      throw "something went wrong";
    }
    return [];

  }



  Future<void> updateCategory(CategoryModal category,CategoryMagicJson magicJson) async {
    state = AsyncData(state.value!.copyWith(isLoading: true));

    try {

      final updatedCategory = await _repository.update(category.toJsonUpdateWithFilter(magicJson));
      final int index = state.value!.categoryIndexMap[updatedCategory.id]!;

        final newList = List<CategoryModal>.from(state.value!.categories)
          ..[index] = updatedCategory;


      // Emit new state with updated category list
      state = AsyncData(state.value!.copyWith(
        categories: newList,
        isLoading: false,
      ));
    } catch (e, st) {
      debugPrint(st.toString());
      state = AsyncError("Something went Wrong", st);
    }
  }

//calls when the multiple insertion take place and need to upload imageUrl to db
  Future<void> updateCategories(List<CategoryModal> categoriesToUpdate,CategoryMagicJson magicJson) async {


    try {

      final payload  = categoriesToUpdate
          .map((c) => c.toJsonUpdateWithFilter(magicJson))
          .toList();
      final updated = await _repository.updateAll(payload);


      //  Merge updated into existing state
      final current = state.value!.categories;
      final updatedMap = {for (var cat in updated) cat.id: cat};

      final merged = current.map((cat) => updatedMap[cat.id] ?? cat).toList();

      state = AsyncData(state.value!.copyWith(
        categories: merged,
        isLoading: false,
      ));
    }  on TimeoutException catch (e, st) {
      state = AsyncError('Request timed out', st);
    } on SocketException catch (e, st) {
      state = AsyncError('No internet connection', st);
    } catch (e, st) {
      debugPrint(e.toString());
      debugPrint(st.toString());
      state = AsyncError('Something went wrong', st);
    }
  }





  Future<void> deleteCategory(int id) async {
    state = AsyncData(state.value!.copyWith(isLoading: true));
    try {
      await _repository.softDelete(id);
      final categories = await _repository.fetchAll();
      state = AsyncData(state.value!.copyWith(categories: categories, isLoading: false));
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }



  Future<void> deleteMultipleCategories(Set<int> ids) async {
    if (ids.isEmpty) return;

    state = AsyncData(state.value!.copyWith(isLoading: true));

    try {
      // Call repository to soft-delete and get updated rows
      final deletedCategories = await _repository.softDeleteAndReturn(ids);

      final current = state.value!.categories;

      // Replace each matching category with the updated (soft-deleted) version
      //todo
      /// we can replace this with only update values like in this case only the deleted_at and deleted bool, less work and network bandwidth is needed:
      /// upgrade we make the categories as null to use the null as error so don't need to rebuild the Notifier state:
      final updated = current.map((cat) {
        final updatedCat = deletedCategories.firstWhere(
              (deleted) => deleted.id == cat.id,
          orElse: () => cat,
        );
        return updatedCat;
      }).toList();

      state = AsyncData(state.value!.copyWith(
        categories: updated,
        isLoading: false,
      ));
    } catch (e, st) {

      state = AsyncError("Something went wrong", st);
      debugPrint(e.toString());
      throw e.toString();
    }
  }

  Future<String?> uploadImage(CategoryModal category)async{
    try{
     final String? path =  await compressImageSmartWebP(category.imageUrl!);
     if(path ==null) throw "image compression Failed";
      category.copyWith(imageUrl: path);
      final publicUrl = await _repository.uploadCategoryImage(category);
      if(publicUrl ==null){
       throw "public url fetching failed";
      }
      return publicUrl;
    }catch(e){
      debugPrint(e.toString());
      rethrow;
    }


  }

  ///uploading category Image
  Future<void> uploadImageAndUpdate(CategoryModal category,CategoryMagicJson magicJson) async {
    try {
      // Upload image and get public URL
      final publicUrl = await _repository.uploadCategoryImage(category);

      if (publicUrl != null) {
        final updated = category.copyWith(imageUrl: publicUrl);

        // Update in the DB
       final updatedRes =  await _repository.update(updated.toJsonUpdateWithFilter(magicJson));

        // Update local state with new category
        final current = state.value?.categories ?? [];
        final newList = current.map((cat) {
          return cat.id == updatedRes.id ? updatedRes : cat;
        }).toList();

        // Emit new state
        state = AsyncData(state.value!.copyWith(categories: newList));
      }
    } catch (e, st) {
      debugPrint(st.toString());
      state = AsyncError("Uploading Failed.", st);
    }
  }

}
