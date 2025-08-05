import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/model/option_model.dart';

class OptionState {
  final Map<int, AsyncValue<List<Option>>> itemOptionsMap;

  const OptionState({required this.itemOptionsMap});

  factory OptionState.initial() => const OptionState(itemOptionsMap: {});

  OptionState copyWith({
    Map<int, AsyncValue<List<Option>>>? itemOptionsMap,
  }) {
    return OptionState(
      itemOptionsMap: itemOptionsMap ?? this.itemOptionsMap,
    );
  }
}
