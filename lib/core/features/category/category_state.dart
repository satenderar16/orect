import '../../../data/model/category_modal.dart';

class CategoryState {
  final List<CategoryModal> categories;
  final bool isLoading;
  final String? errorMessage;

  const CategoryState({
    required this.categories,
    this.isLoading = false,
    this.errorMessage,
  });

  factory CategoryState.initial() => const CategoryState(categories: []);

  CategoryState copyWith({
    List<CategoryModal>? categories,
    bool? isLoading,
    String? errorMessage,
  }) {
    return CategoryState(
      categories: categories ?? this.categories,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  Map<int, CategoryModal> get categoryMap {
    return {
      for (final category in categories) category.id!: category,
    };
  }
//fast lookup with id to index
  Map<int, int> get categoryIndexMap {
    final map = <int, int>{};
    for (int i = 0; i < categories.length; i++) {
      final id = categories[i].id;
      if (id != null) map[id] = i;
    }
    return map;
  }
}
