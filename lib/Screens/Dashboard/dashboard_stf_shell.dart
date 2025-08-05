import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../widgets/AlertDialog/exit_alert.dart';
import 'back_handler.dart';

class DashboardStfShell extends ConsumerStatefulWidget {
  final StatefulNavigationShell navigationShell;
  final List<GlobalKey<NavigatorState>> navigatorKeys;

  const DashboardStfShell({
    super.key,
    required this.navigationShell,
    required this.navigatorKeys,
  });

  @override
  ConsumerState<DashboardStfShell> createState() => _DashboardStfShellState();
}

class _DashboardStfShellState extends ConsumerState<DashboardStfShell> {
  bool isRailExpanded = false;

  void toggleRailExpansion(double width) {
    if (width >= 600 && width < 1200) {
      setState(() {
        isRailExpanded = !isRailExpanded;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final currentIndex = widget.navigationShell.currentIndex;

    return PopScope(
      canPop: false,
        onPopInvokedWithResult: (didPop, _) async {
        await handleBackPress(ref: ref, navigationShell: widget.navigationShell, navigatorKeys: widget.navigatorKeys, context: context);
        },
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;

          // Determine layout based on screen width
          if (width < 600) {
            //  Small screen: Bottom navigation
            return Scaffold(
              body: widget.navigationShell,
              bottomNavigationBar: BottomNavigationBar(
                currentIndex: currentIndex,
                onTap: (index) => widget.navigationShell.goBranch(index),
                backgroundColor: colorScheme.surface,
                selectedItemColor: colorScheme.primary,
                unselectedItemColor:
                colorScheme.onSurface.withAlpha(130),
                type: BottomNavigationBarType.fixed,
                items: const [
                  BottomNavigationBarItem(
                      icon: Icon(Icons.home), label: 'Home'),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.list), label: 'Orders'),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.menu_book), label: 'Menu'),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.bar_chart), label: 'Stats'),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.settings), label: 'Settings'),
                ],
              ),
            );
          }
          final bool railAlwaysExpanded = width >= 1200;
          final bool isExpanded = railAlwaysExpanded || isRailExpanded;

          return Scaffold(

            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: currentIndex,
                  onDestinationSelected: (index) {
                    widget.navigationShell.goBranch(index);
                    toggleRailExpansion(width);
                  },
                  extended: isExpanded,
                  labelType: railAlwaysExpanded
                      ? NavigationRailLabelType.none
                      : isExpanded
                      ? NavigationRailLabelType.none
                      : NavigationRailLabelType.selected,
                  backgroundColor: colorScheme.surface,
                  selectedIconTheme:
                  IconThemeData(color: colorScheme.primary),
                  unselectedIconTheme: IconThemeData(
                    color: colorScheme.onSurface.withAlpha(130),
                  ),
                  destinations: const [
                    NavigationRailDestination(
                        icon: Icon(Icons.home), label: Text('Home')),
                    NavigationRailDestination(
                        icon: Icon(Icons.list), label: Text('Orders')),
                    NavigationRailDestination(
                        icon: Icon(Icons.menu_book), label: Text('Menu')),
                    NavigationRailDestination(
                        icon: Icon(Icons.bar_chart), label: Text('Stats')),
                    NavigationRailDestination(
                        icon: Icon(Icons.settings), label: Text('Settings')),
                  ],
                ),VerticalDivider(thickness: 0,width: 0,),
                Expanded(child: widget.navigationShell),
              ],
            ),
          );
        },
      ),
    );
  }
}
