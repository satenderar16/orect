import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/features/subcategory/subcategory_notifier.dart';
import '../../../core/config/connectivity/internet_provider.dart';

class SubcategoryPage extends ConsumerStatefulWidget {
  final int categoryId;
  final String categoryName;

  const SubcategoryPage({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  ConsumerState<SubcategoryPage> createState() => _SubcategoryPageState();
}

class _SubcategoryPageState extends ConsumerState<SubcategoryPage> {
  @override
  void initState() {
    super.initState();
    // Trigger lazy load for this category
    Future.microtask(() {
      ref.read(subcategoryNotifierProvider.notifier).loadForCategory(widget.categoryId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final subcatValue = ref.watch(
      subcategoryNotifierProvider.select(
            (s) => s.value?.categorySubMap[widget.categoryId] ?? const AsyncLoading(),
      ),
    );
    final isOnline = ref.watch(internetProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName),
      ),
      body: subcatValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error loading subcategories: $err')),
        data: (subs) {
          if (subs.isEmpty) {
            return Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Add Sample Subcategories'),
                onPressed: () {
                  // Optionally add sample subcategories here
                },
              ),
            );
          }

          return ListView.builder(
            itemCount: subs.length,
            itemBuilder: (context, index) {
              final sub = subs[index];
              return ListTile(
                title: Text(sub.name),
                onTap: () {
                  if(!isOnline.hasInternet)return;

                  context.pushNamed(
                    'item',
                    pathParameters: {
                      'categoryName': GoRouterState.of(context).uri.pathSegments[1],
                      'subcategoryName': sub.name,
                    },
                    extra: {
                      'subcategoryId': sub.id,
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
