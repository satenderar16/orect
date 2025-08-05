import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/features/option/option_notifier.dart';

class OptionPage extends ConsumerStatefulWidget {
  final int itemId;
  final String itemName;

  const OptionPage({
    Key? key,
    required this.itemId,
    required this.itemName,
  }) : super(key: key);

  @override
  ConsumerState<OptionPage> createState() => _OptionPageState();
}

class _OptionPageState extends ConsumerState<OptionPage> {
  @override
  void initState() {
    super.initState();

    // Load options for this item
    Future.microtask(() {
      ref.read(optionNotifierProvider.notifier).loadOptionsForItem(widget.itemId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final optionState = ref.watch(optionNotifierProvider);

    final asyncOptions = optionState.maybeWhen(
      data: (state) => state.itemOptionsMap[widget.itemId],
      orElse: () => null,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.itemName),
      ),
      body: Builder(
        builder: (_) {
          if (asyncOptions == null || asyncOptions.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (asyncOptions.hasError) {
            return Center(child: Text('Error: ${asyncOptions.error}'));
          }

          final options = asyncOptions.value ?? [];

          if (options.isEmpty) {
            return const Center(child: Text('No options available.'));
          }

          return ListView.builder(
            itemCount: options.length,
            itemBuilder: (context, index) {
              final opt = options[index];
              return ListTile(
                title: Text(opt.name),
                subtitle: Text('${opt.unitTag} • ₹${opt.baseUnitPrice} • ${opt.type ?? '-'}'),
              );
            },
          );
        },
      ),
    );
  }
}
