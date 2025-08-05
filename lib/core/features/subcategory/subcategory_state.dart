import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/model/subcatergory_model.dart';

class SubcategoryState {
  final Map<int, AsyncValue<List<Subcategory>>> categorySubMap;

  const SubcategoryState({
    required this.categorySubMap,
  });

  factory SubcategoryState.initial() => const SubcategoryState(categorySubMap: {});

  SubcategoryState copyWith({
    Map<int, AsyncValue<List<Subcategory>>>? categorySubMap,
  }) {
    return SubcategoryState(
      categorySubMap: categorySubMap ?? this.categorySubMap,
    );
  }
}
