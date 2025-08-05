import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/connectivity/internet_provider.dart';
import '../../../core/features/item/item_notifier.dart';

class ItemPage extends ConsumerStatefulWidget {
  final int subcategoryId;
  final String subcategoryName;

  const ItemPage({
    Key? key,
    required this.subcategoryId,
    required this.subcategoryName,
  }) : super(key: key);

  @override
  ConsumerState<ItemPage> createState() => _ItemPageState();
}

class _ItemPageState extends ConsumerState<ItemPage> {
  @override
  void initState() {
    super.initState();

    // Load items on first build
    Future.microtask(() {
      ref.read(itemNotifierProvider.notifier).loadForSubcategory(widget.subcategoryId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final itemState = ref.watch(itemNotifierProvider);
    final isOnline = ref.watch(internetProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Items of ${widget.subcategoryName}'),
      ),
      body: itemState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (state) {
          final asyncItems = state.subcategoryItemMap[widget.subcategoryId];

          if (asyncItems == null || asyncItems.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (asyncItems.hasError) {
            return Center(child: Text('Error: ${asyncItems.error}'));
          }

          final items = asyncItems.value ?? [];

          if (items.isEmpty) {
            return Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add Sample Items'),
                onPressed: () {
                  // TODO: Add sample items
                },
              ),
            );
          }

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return ListTile(
                title: Text(item.name),
                onTap: () {
                  if(!isOnline.hasInternet)return;

                  context.pushNamed(
                    'option',
                    pathParameters: {

                      'categoryName': GoRouterState.of(context).uri.pathSegments[1],
                      'subcategoryName': GoRouterState.of(context).uri.pathSegments[2],
                      'itemName': item.name,
                    },
                    extra: {
                      'itemId': item.id,
                    },
                  );

                },
              );
            },
          );
        },
      ),
    );
  }
}
