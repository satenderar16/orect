import 'dart:async';

import 'package:amtnew/Screens/Dashboard/MenuPage/category/update_page.dart';
import 'package:amtnew/Screens/Dashboard/MenuPage/category/widgets/category_details_view.dart';
import 'package:amtnew/Screens/Dashboard/MenuPage/category/widgets/category_empty_widget.dart';
import 'package:amtnew/Screens/Dashboard/MenuPage/category/widgets/category_tile.dart';
import 'package:amtnew/core/config/connectivity/internet_provider.dart';
import 'package:amtnew/core/features/category/category_notifier.dart';
import 'package:amtnew/core/utils/base_color_list.dart';
import 'package:amtnew/data/model/category_modal.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/features/category/category_provider.dart';
import '../../../../main.dart';
import '../../back_handler.dart';
import 'category_creation.dart';

class MenuPage extends ConsumerStatefulWidget {
  const MenuPage({super.key});

  @override
  ConsumerState<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends ConsumerState<MenuPage>
    with TickerProviderStateMixin {
  int? expandedIndex;
  final Set<int> selectedIds = {};
  final nowTimeDate = DateTime.now();
  void _toggleExpanded(int index) {
    setState(() {
      expandedIndex = expandedIndex == index ? null : index;
    });
  }

  void _toggleSelection(int id) {
    setState(() {
      if (selectedIds.contains(id)) {
        selectedIds.remove(id);
      } else {
        selectedIds.add(id);
      }

      //  updating for the navigation when selection mode is on or not:
      final notifier = ref.read(menuNavProvider.notifier);
      notifier.setSelectionMode(selectedIds.isNotEmpty);
    });
  }

  void _clearSelection() {
      ref.read(menuNavProvider.notifier).setSelectionMode(false);
  }

  static const List<Color> baseColors = colorList;

  //when user delete any category or categories ui will get response will be a this error
  Future<bool> _deletionAlert({String? title, Set<int>? ids}) async {


   final delete = await _showDeleteSheet();
    if (delete != true) return false;

// make remote supabase db call:
     await ref
         .read(categoryNotifierProvider.notifier)
         .deleteMultipleCategories(ids ?? selectedIds);


    // Clear UI selection after deletion make mode to non selection mode
   ref.read(menuNavProvider.notifier).setSelectionMode(false);
    return true;
  }




  void _showCategoryDetails({required CategoryModal category,Color? color}) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    showModalBottomSheet(
      useRootNavigator: true,
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      builder: (context) {
        final height = MediaQuery.sizeOf(context).height * 0.80;
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: height),
            child: CategoryDetailsContent(
              color:color,
              category: category,
              isMobile: isMobile,
            ),
          ),
        );
      },
    );
  }
  Future<void>_onRefresh()async{
    await ref.read(categoryNotifierProvider.notifier).refreshFetch().timeout(
      const Duration(seconds: 5),
      onTimeout: () {
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    final categoryStateAsync = ref.watch(categoryNotifierProvider);
    final categoryNotifier = ref.watch(categoryNotifierProvider.notifier);
    final internet = ref.watch(internetProvider);

    final menuState = ref.watch(menuNavProvider);
    final isSelectionMode = menuState.selectionMode;
///help in make sync with navigator for selection and non selection
    if (isSelectionMode == false) {
      selectedIds.clear();
    }


    return PopScope(
      canPop: false,
      onPopInvokedWithResult: null,
      child: Scaffold(
        floatingActionButton: _buildFabMenuPage(isSelectionMode: isSelectionMode,hasInternet: internet.hasInternet) ,
        appBar: _buildAppBar(),
        body: categoryStateAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error:
              (error, _) => _buildErrorWidget(context, error, categoryNotifier),
          data: (state) {
            final categories =
                state.categories.where((cat) => !cat.deleted).toList();
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            final length = categories.length;

            if (categories.isEmpty) {
              return CategoryEmptyWidget();
            }

            return RefreshIndicator(
              onRefresh: _onRefresh,
              child: MasonryGridView.extent(
                maxCrossAxisExtent: 500, // Maximum width per tile
                mainAxisSpacing: 0.0,
                crossAxisSpacing: 0.0,
                padding: const EdgeInsets.all(0.0),
                itemCount: length + 1,
                itemBuilder: (context, index) {
                  final color = baseColors[index % baseColors.length];

                  if (index == length) {
                    return SizedBox(height: 140);
                  }

                  final category = categories[index];
                  final id = category.id!;

                  return CategoryTile(
                    key: ValueKey(category.id),
                    index: index,
                    category: category,
                    color: color,
                    timeNow: nowTimeDate,
                    isExpanded: expandedIndex == index,
                    isSelected: selectedIds.contains(category.id),
                    isSelectionMode: isSelectionMode,

                    onTap: () {
                      if (isSelectionMode) {
                        _toggleSelection(id);
                        return;
                      }
                        _toggleExpanded(index);

                    },
                    onLongPress: () =>
                      setState(() {
                        expandedIndex = null;
                        _toggleSelection(id);
                      }),
                    onEdit: () {

                     Navigator.push(context, MaterialPageRoute(builder: (context)=>UpdatePage(category: category)));
                    },
                    onDelete: () async =>
                      _deletionAlert(title: category.name, ids: {id}),
                    onInfo: () =>
                      _showCategoryDetails(category: category,color: color.withAlpha(130)),
                  );
                },
              ),
            );
          },
        ),

        bottomNavigationBar: _bottomConnectionIndicator(internet.hasInternet, context),
      ),
    );
  }
  AppBar _buildAppBar() {
    final isSelectionMode = ref.read(menuNavProvider).selectionMode;
    return AppBar(
      title:
      isSelectionMode
          ? Text('${selectedIds.length} selected')
          : const Text('Menu Page'),
      actions:
      isSelectionMode
          ? [
        IconButton(
          icon: const Icon(Icons.select_all),
          tooltip: 'Select All',
          onPressed: () {
            setState(() {
              final categories =
                  ref
                      .read(categoryNotifierProvider)
                      .value
                      ?.categories ??
                      [];
              selectedIds.addAll(
                categories
                    .where((cat) => cat.deleted != true)
                    .map((cat) => cat.id!),
              );
            });
          },
        ),
        IconButton(
          icon: const Icon(Icons.deselect),
          tooltip: 'Unselect All',
          onPressed: _clearSelection,
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline_outlined),
          tooltip: 'Delete Selected',
          onPressed: () async => await _deletionAlert()
          ,
        ),
      ]
          : null,
    );
  }

  Widget? _buildFabMenuPage({required bool hasInternet, required bool isSelectionMode}) {
    if(!hasInternet || isSelectionMode )return null;
    return FloatingActionButton.extended(
      heroTag: "fabToPage",
      onPressed: () {
        Route createRoute(BuildContext context) {
          return PageRouteBuilder(
            transitionDuration: Duration(milliseconds: 400),
            reverseTransitionDuration: Duration(milliseconds: 400),
            pageBuilder:
                (context, animation, secondaryAnimation) =>
                CategoryCreatePage(),
          );
        }

        Navigator.of(context).push(createRoute(context));
      },
      label: Text("Add New"),
    );
  }

  Center _buildErrorWidget(BuildContext context, Object error, CategoryNotifier categoryNotifier) {
    return Center(
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.8,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Asset Image
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Image.asset(
                        'assets/error_menu_refresh.png',
                        height: 200,
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Instructional Text (optional)
                    Text(
                      error.toString(),
                      style: TextTheme.of(context).titleLarge,
                    ),
                    const SizedBox(height: 16),

                    // Add Category Button
                    OutlinedButton(
                      child: const Text('retry'),
                      onPressed: () async {
                        await categoryNotifier.retryFetch();
                      },
                    ),
                  ],
                ),
              ),
            );
  }

  Widget _bottomConnectionIndicator(
      bool internet,
      BuildContext context,
      ) {
    final hasInternet = internet;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      transitionBuilder: (child, animation) {
        final offsetAnimation = Tween<Offset>(
          begin: const Offset(0, 1), // Slide from bottom
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut));

        return SlideTransition(position: offsetAnimation, child: child);
      },
      child:
      hasInternet
          ? const SizedBox.shrink() // completely removes it from the tree
          : Container(
        key: const ValueKey('no-internet-banner'),
        width: double.infinity,
        color: Theme.of(context).colorScheme.onSurface,
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 6,
        ),
        child: Text(
          'No internet connection',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: Theme.of(context).colorScheme.surfaceContainer,
          ),
        ),
      ),
    );
  }


  Future<bool?> _showDeleteSheet() {
    return showModalBottomSheet<bool>(
        context: rootNavigatorKey.currentState!.context,
        isScrollControlled: true,
        backgroundColor: Theme.of(context).colorScheme.onError,
        builder: (context){

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16,16,16,10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                spacing: 8,
                children: [
                  Text("Delete Categories",style: TextTheme.of(context).titleLarge,),
                  Text("Are you sure ?"),
                  Row(
                    spacing: 10,
                    mainAxisAlignment: MainAxisAlignment.end,children: [
                    TextButton(onPressed: (){context.pop(false);},style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.onSurface), child: const Text("cancel"),),
                    FilledButton(onPressed: (){context.pop(true);},style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error), child: const Text("Delete"),)
                  ],)
                ],
              ),
            ),
          );
        });
  }

  // if (!isOnline.hasInternet) return;
  // context.pushNamed(
  //   'subcategory',
  //   pathParameters: {
  //     'categoryName': category.name,
  //   },
  //   extra: {
  //     'categoryId': category.id,
  //   },
  // );
}

