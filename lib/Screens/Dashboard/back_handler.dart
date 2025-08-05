import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// -----------------------------------------
/// Navigation States & Notifiers
/// -----------------------------------------

class MenuNavState {
  final bool selectionMode;
  MenuNavState({this.selectionMode = false});
}

class MenuNavNotifier extends StateNotifier<MenuNavState> {
  MenuNavNotifier() : super(MenuNavState());

  void setSelectionMode(bool value) {
    state = MenuNavState(selectionMode: value);
  }
}

final menuNavProvider =
StateNotifierProvider<MenuNavNotifier, MenuNavState>((ref) => MenuNavNotifier());

class OrdersNavState {
  final bool selectionMode;
  OrdersNavState({this.selectionMode = false});
}

class OrdersNavNotifier extends StateNotifier<OrdersNavState> {
  OrdersNavNotifier() : super(OrdersNavState());

  void setSelectionMode(bool value) {
    state = OrdersNavState(selectionMode: value);
  }
}

final ordersNavProvider =
StateNotifierProvider<OrdersNavNotifier, OrdersNavState>((ref) => OrdersNavNotifier());

/// -----------------------------------------
/// Complete Back Handler Function
/// -----------------------------------------

Future<void> handleBackPress({
  required WidgetRef ref,
  required StatefulNavigationShell navigationShell,
  required List<GlobalKey<NavigatorState>> navigatorKeys,
  required BuildContext context,
}) async {
  final currentIndex = navigationShell.currentIndex;

  final bool didHandle = await handleBranchBack(ref, currentIndex);
  if (didHandle) return;

  final currentNavigator = navigatorKeys[currentIndex].currentState;
  if (currentNavigator?.canPop() ?? false) {
    currentNavigator?.pop();
    return;
  }

  if (currentIndex != 0) {
    navigationShell.goBranch(0);
    return;
  }

  final shouldExit = await showExitDialog(context);
  if (shouldExit) {
    SystemNavigator.pop();
  }
}

/// -----------------------------------------
/// Per-Branch Back Handler
/// -----------------------------------------

Future<bool> handleBranchBack(WidgetRef ref, int index) async {
  switch (index) {
    case 0:
      return false;

    case 1:
      final ordersState = ref.read(ordersNavProvider);
      if (ordersState.selectionMode) {
        ref.read(ordersNavProvider.notifier).setSelectionMode(false);
        return true;
      }
      return false;

    case 2:
      final menuState = ref.read(menuNavProvider);
      if (menuState.selectionMode) {
        ref.read(menuNavProvider.notifier).setSelectionMode(false);
        return true;
      }
      return false;

    case 3:
    case 4:
    default:
      return false;
  }
}

/// -----------------------------------------
/// Exit Dialog (Reusable)
/// -----------------------------------------

Future<bool> showExitDialog(BuildContext context) async {
  return await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Exit App'),
      content: const Text('Do you want to exit the app?'),
      actions: [
        TextButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.of(ctx).pop(false),
        ),
        TextButton(
          child: const Text('Exit'),
          onPressed: () => Navigator.of(ctx).pop(true),
        ),
      ],
    ),
  ) ??
      false;
}
