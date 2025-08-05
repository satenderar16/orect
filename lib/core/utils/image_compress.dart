import 'dart:io';
import 'package:amtnew/data/model/category_modal.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;



Future<List<CategoryModal>> compressImagesForInsertedCategories(List<CategoryModal> inserted) async {
  final List<CategoryModal> updatedCategories = [];

  for (final category in inserted) {
    final imagePath = category.imageUrl;

    if (imagePath != null && File(imagePath).existsSync()) {
      final compressedPath = await compressInIsolate(imagePath);
      if (compressedPath != null) {
        updatedCategories.add(category.copyWith(imageUrl: compressedPath));
      } else {
        updatedCategories.add(category); // fallback to original
      }
    } else {
      updatedCategories.add(category); // no image to compress
    }
  }

  return updatedCategories;
}


Future<String?> compressInIsolate(String path, {int quality = 75}) async {
  return await compute(
    compressImageInBackground,
    {'path': path, 'quality': quality},
  );
}

Future<String?> compressImageInBackground(Map<String, dynamic> args) async {
  final originalPath = args['path'] as String;
  final quality = args['quality'] as int? ?? 75;

  try {
    final dir = await getTemporaryDirectory();
    final targetPath = p.join(
      dir.path,
      'compressed_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );

    final result = await FlutterImageCompress.compressAndGetFile(
      originalPath,
      targetPath,
      quality: quality,
      minWidth: 800,
      minHeight: 800,
    );

    return result?.path;
  } catch (e) {
    debugPrint("Compression failed: $e");
    return null;
  }
}



Future<String?> compressImageSmartWebP(
    String originalPath, {
      int minWidth = 400,
      int minHeight = 400,
      int skipIfBelowKB = 100,
    }) async {
  try {
    final originalFile = File(originalPath);
    final originalSize = await originalFile.length();
    final originalSizeKB = originalSize / 1024;

    // ✅ Skip compression if already small
    if (originalSizeKB <= skipIfBelowKB) {
      debugPrint(" Skipping compression: ${originalSizeKB.toStringAsFixed(1)} KB");
      return originalPath;
    }

    // Define size-quality buckets
    final sizeQualityBuckets = [
      {'maxKB': 300.0, 'quality': 90},
      {'maxKB': 600.0, 'quality': 80},
      {'maxKB': 2000.0, 'quality': 75},
      {'maxKB': 6000.0, 'quality': 60},
      {'maxKB': double.infinity, 'quality': 40},
    ];

    // Find the first matching bucket
    final quality = sizeQualityBuckets
        .firstWhere((bucket) => originalSizeKB <= bucket['maxKB']!)['quality']!.toInt();

    final dir = await getTemporaryDirectory();
    final targetPath = p.join(
      dir.path,
      'compressed_${DateTime.now().millisecondsSinceEpoch}.webp',
    );

    final result = await FlutterImageCompress.compressAndGetFile(
      originalPath,
      targetPath,
      quality: quality,
      minWidth: minWidth,
      minHeight: minHeight,
      format: CompressFormat.webp,
    );

    if (result == null) return null;

    final finalSizeKB = await result.length() / 1024;
    print("Compressed ${originalSizeKB.toStringAsFixed(1)} KB → ${finalSizeKB.toStringAsFixed(1)} KB (quality $quality)");

    return result.path;
  } catch (e) {
    print("Compression failed: $e");
    return null;
  }
}
Future<String?> compressImage(String originalPath, {int quality = 75}) async {
  try {
    final dir = await getTemporaryDirectory();
    final targetPath = p.join(
      dir.path,
      'compressed_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );
    final originalFile = File(originalPath);
    final originalSize =await  originalFile.length();
    int estimatedQuality = ((100 * 1024) / originalSize * 100).clamp(10, 95).toInt();
    final result = await FlutterImageCompress.compressAndGetFile(
      originalPath,
      targetPath,
      quality: estimatedQuality,
      minWidth: 800,
      minHeight: 800,
    );

    return result?.path;
  } catch (e) {
    debugPrint("Compression failed: $e");
    return null;
  }
}

Future<void> deleteFileIfExists(String? filePath) async {
  if (filePath == null) return;

  final file = File(filePath);
  if (await file.exists()) {
    try {
      await file.delete();
      debugPrint("Deleted file: $filePath");
    } catch (e) {
      debugPrint("Failed to delete file: $filePath\nError: $e");
    }
  }
}
