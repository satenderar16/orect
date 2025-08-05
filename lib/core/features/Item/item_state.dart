import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/model/item_model.dart'; // make sure this is your item model file

class ItemState {
  final Map<int, AsyncValue<List<Item>>> subcategoryItemMap;

  const ItemState({required this.subcategoryItemMap});

  factory ItemState.initial() => const ItemState(subcategoryItemMap: {});

  ItemState copyWith({
    Map<int, AsyncValue<List<Item>>>? subcategoryItemMap,
  }) {
    return ItemState(
      subcategoryItemMap: subcategoryItemMap ?? this.subcategoryItemMap,
    );
  }
}
