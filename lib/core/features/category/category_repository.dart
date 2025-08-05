import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:flutter/cupertino.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/model/category_modal.dart'; // Adjust path

class CategoryRepository {
  final SupabaseClient _client;

  CategoryRepository(this._client);

  /// Get all categories
  Future<List<CategoryModal>> fetchAll() async {
    final response = await _client
        .from('category')
        .select()
        .order('name', ascending: true);

    return (response as List)
        .map((json) => CategoryModal.fromJson(json))
        .toList();
  }

  /// as name suggests"
  Future<CategoryModal> insertAndReturn(CategoryModal category) async {
    final response =
        await _client
            .from('category')
            .insert(category.toJson())
            .select()
            .single(); // Only one row inserted

    return CategoryModal.fromJson(response);
  }

  /// for inserting more then one category
  Future<List<CategoryModal>> insertAllAndReturn(
    List<CategoryModal> categories,
  ) async {
    final payload = categories.map((e) => e.toJsonUpdate(name: true)).toList();

    final response =
        await _client
            .from('category')
            .insert(payload)
            .order('name')
            .select();

    return (response as List).map((e) => CategoryModal.fromJson(e)).toList();
  }

  /// Get one category by ID
  Future<CategoryModal?> getById(int id) async {
    final data =
        await _client.from('category').select().eq('id', id).maybeSingle();

    if (data == null) return null;
    return CategoryModal.fromJson(data);
  }

  /// Insert a new category
  Future<CategoryModal> insert(CategoryModal category) async {
    final result =
        await _client
            .from('category')
            .insert(category.toJson())
            .select()
            .single();

    return CategoryModal.fromJson(result);
  }

  /// Update an existing category
  Future<CategoryModal> update(Map<String,dynamic> json) async {
    try{
      final result = await  _client
          .from('category')
          .update(json)
          .eq('id', json['id']!)
          .select()
          .single();

      return CategoryModal.fromJson(result);
    }catch(e){
      debugPrint(e.toString());
      throw "category update failed";
    }
  }

  Future<List<CategoryModal>> updateAll(List<Map<String,dynamic>> payload) async {
    try {
      // Prepare the payload (only include fields to update)


      final response = await _client
          .from('category')
          .upsert(
        payload,
        onConflict: 'id',
      )
          .select();



      return response
          .map((json) => CategoryModal.fromJson(json ))
          .toList();
    } catch (e, st) {
      // Optional: Log or report the error
      debugPrint('updateAll failed: $e');
      debugPrintStack(stackTrace: st);

      // Re-throw or return empty list or custom exception
      throw 'Failed to update categories';
    }
  }

  /// Soft delete a category
  /// or simply we can use softDeleteAndReturn with single value:
  Future<void> softDelete(int id) async {
    await _client.from('category').update({'deleted': true}).eq('id', id);
  }

  Future<List<CategoryModal>> softDeleteAndReturn(Set<int> ids) async {
    if (ids.isEmpty) return [];

    try {
      final idList = ids.join(',');
      final filterString = '($idList)';

      final response =
          await _client
              .from('category')
              .update({'deleted': true})
              .filter('id', 'in', filterString)
              .select();

      return response.map((json) => CategoryModal.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to soft delete categories in Repository: $e');
    }
  }

  ///upload to category-image bucket:

  Future<String?> uploadCategoryImage(CategoryModal category) async {
    final path = category.imageUrl;

    if (path == null || !File(path).existsSync()) {
      debugPrint("No valid image path for category: ${category.name}");
      return null;
    }

    try {
      final file = File(path);
      final fileExt = p.extension(path);

      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        debugPrint("No user logged in");
        return null;
      }

      ///just reducing name so the url of image remains consistent
      final catName = category.name.trim().toLowerCase().replaceAll(
        RegExp(r'\s+'),
        '_',
      );
      //  File path: category/<user_id>/<category_id>/category_<id>.jpg
      final fileName = '${catName}_${category.id}$fileExt';
      final storagePath = 'category/$userId/${category.id}/$fileName';

      await _client.storage
          .from('orect-images')
          .upload(
            storagePath,
            file,
            fileOptions: const FileOptions(upsert: true),
          );

      final publicUrl = _client.storage
          .from('orect-images')
          .getPublicUrl(storagePath);

      return publicUrl;
    } catch (e, st) {
      debugPrint("Upload failed for repository: $e");
      throw "Upload failed for category '${category.name}";
    }
  }
}
