
import 'package:amtnew/core/features/subcategory/subcategory_notifier.dart';
import 'package:amtnew/core/features/subcategory/subcategory_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final subcategoryNotifierProvider =
AsyncNotifierProvider<SubcategoryNotifier, SubcategoryState>(
    SubcategoryNotifier.new);