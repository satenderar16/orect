import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/model/option_model.dart';
import 'option_state.dart';
import 'option_repository.dart';

final optionNotifierProvider =
AsyncNotifierProvider<OptionNotifier, OptionState>(OptionNotifier.new);

class OptionNotifier extends AsyncNotifier<OptionState> {
  late final OptionRepository _repository;

  @override
  Future<OptionState> build() async {
    _repository = OptionRepository();
    return OptionState.initial();
  }

  Future<void> loadOptionsForItem(int itemId) async {
    final currentMap = state.value?.itemOptionsMap ?? {};/// although  we know when state is initialize map is {} so it can't be null
    final existing = currentMap[itemId];

    // Avoid refetching if data already exists and is not loading or errored
    if (existing is AsyncData<List<Option>>) {
      final options = existing.value;
      if ( options.isNotEmpty) {
        return;
      }
    }
    debugPrint("option calls remote db:");
    // Set loading state for this itemId
    state = AsyncData(
      OptionState(itemOptionsMap: {
        ...currentMap,
        itemId: const AsyncLoading(),
      }),
    );

    try {
      final options = await _repository.fetchForItem(itemId);
      state = AsyncData(
        OptionState(itemOptionsMap: {
          ...currentMap,
          itemId: AsyncData(options),
        }),
      );
    } catch (e, st) {
      state = AsyncData(
        OptionState(itemOptionsMap: {
          ...currentMap,
          itemId: AsyncError(e, st),
        }),
      );
    }
  }

  Future<void> addOption(int itemId, Option option, {void Function(String msg)? onError}) async {
    try {
      final inserted = await _repository.insertAndReturn(option);
      final existing = state.value?.itemOptionsMap[itemId];

      final updatedList = [
        inserted,
        ...?existing?.value,
      ];

      state = AsyncData(
        state.value!.copyWith(
          itemOptionsMap: {
            ...state.value!.itemOptionsMap,
            itemId: AsyncData(updatedList),
          },
        ),
      );
    } catch (e) {
      state = AsyncData(
        state.value!.copyWith(
          itemOptionsMap: {
            ...state.value!.itemOptionsMap,
            itemId: AsyncError(e, StackTrace.current),
          },
        ),
      );
      onError?.call('Failed to add option: $e');
    }
  }

  Future<void> updateOption(int itemId, int optionId, Option option, {void Function(String msg)? onError}) async {
    try {
      await _repository.update(optionId, option);
      final options = await _repository.fetchForItem(itemId);

      state = AsyncData(
        state.value!.copyWith(
          itemOptionsMap: {
            ...state.value!.itemOptionsMap,
            itemId: AsyncData(options),
          },
        ),
      );
    } catch (e) {
      state = AsyncData(
        state.value!.copyWith(
          itemOptionsMap: {
            ...state.value!.itemOptionsMap,
            itemId: AsyncError(e, StackTrace.current),
          },
        ),
      );
      onError?.call('Failed to update option: $e');
    }
  }

  Future<void> deleteOption(int itemId, int optionId, {void Function(String msg)? onError}) async {
    try {
      await _repository.softDelete(optionId);
      final current = state.value?.itemOptionsMap[itemId]?.value ?? [];
      final updated = current.where((o) => o.id != optionId).toList();

      state = AsyncData(
        state.value!.copyWith(
          itemOptionsMap: {
            ...state.value!.itemOptionsMap,
            itemId: AsyncData(updated),
          },
        ),
      );
    } catch (e) {
      state = AsyncData(
        state.value!.copyWith(
          itemOptionsMap: {
            ...state.value!.itemOptionsMap,
            itemId: AsyncError(e, StackTrace.current),
          },
        ),
      );
      onError?.call('Failed to delete option: $e');
    }
  }
}
