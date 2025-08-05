import 'package:amtnew/core/features/auth/auth_provider.dart';
import 'package:amtnew/core/config/connectivity/internet_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'route_provider.dart';
import '../../../Screens/Authentication/forgot_otp.dart';
import '../../../Screens/Authentication/login_otp.dart';
import '../../../Screens/Authentication/login_page.dart';
import '../../../Screens/Authentication/registration/register_page.dart';
import '../../../Screens/Dashboard/Home/home_page.dart';
import '../../../Screens/Dashboard/MenuPage/items.dart';
import '../../../Screens/Dashboard/MenuPage/category/category_page.dart';
import '../../../Screens/Dashboard/MenuPage/options.dart';
import '../../../Screens/Dashboard/MenuPage/subcategory.dart';
import '../../../Screens/Dashboard/Order/order_page.dart';
import '../../../Screens/Dashboard/Setting/settings_page.dart';
import '../../../Screens/Dashboard/Statictis/statics_page.dart';
import '../../../Screens/Dashboard/dashboard_stf_shell.dart';
import '../../../main.dart';
import '../../../myapp.dart';

final passwordResetCompletedProvider = StateProvider<bool>((ref) => false);

final routerProvider = Provider<GoRouter>((ref) {
  final isAuthenticated = ref.watch(
    authNotifierProvider.select((state) => state.isAuthenticated),
  );
  final router = GoRouter(
    navigatorKey: rootNavigatorKey,
    // debugLogDiagnostics: true,
    initialLocation: '/',
    refreshListenable: ref.watch(routerRefreshProvider),

    routes: [
      GoRoute(
        path: '/auth',
        builder: (context, state) {
          final screen = state.uri.queryParameters['screen'];

          switch (screen) {
            case 'login':
              return const LoginPage();
            case 'otp':
              return const LoginOtp();
            case 'forgot':
              return ForgotOtp();
            case 'register':
              return const RegisterPage();
            default:
              return const LoginPage(); // fallback
          }
        },
      ),

      GoRoute(path: "/", redirect: (_, _) => "/home"),

      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {

          return DashboardStfShell(
            navigationShell: navigationShell,
            navigatorKeys: mainShellKeys,
          );
        },
        branches: [
          StatefulShellBranch(
            navigatorKey: homeNavKey,
            routes: [
              GoRoute(

                path: '/home',
                name: 'home',
                builder: (context, state) => const HomePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: ordersNavKey,
            routes: [
              GoRoute(
                path: '/orders',
                name: 'orders',
                builder: (context, state) => const OrdersPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: menuNavKey,

            routes: [
              GoRoute(

                //0--> menu, 1--> category, 2--> subcategory, 3--> items path segments:
                path: '/menu',
                name: 'menu',
                builder: (context, state) {
                  return  const MenuPage();
                },
                routes: [
                  GoRoute(
                    path: ':categoryName',
                    name: 'subcategory',
                    builder: (context, state) {
                      final categoryName = state.pathParameters['categoryName']!;
                      final extra = state.extra as Map<String, dynamic>;
                      return SubcategoryPage(
                        categoryId: extra['categoryId'] as int,
                        categoryName: categoryName,
                      );
                    },
                    routes: [
                      GoRoute(
                        path: ':subcategoryName',
                        name: 'item',
                        builder: (context, state) {
                          final subcategoryName = state.pathParameters['subcategoryName']!;
                          final extra = state.extra as Map<String, dynamic>;
                          return ItemPage(
                            subcategoryId: extra['subcategoryId'] as int,
                            subcategoryName: subcategoryName,

                          );
                        },
                        routes: [
                          GoRoute(
                            path: ':itemName',
                            name: 'option',
                            builder: (context, state) {
                              final itemName = state.pathParameters['itemName']!;
                              final extra = state.extra as Map<String, dynamic>;

                              return OptionPage(
                                itemId: extra['itemId'] as int,
                                itemName: itemName,
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          )
          ,

          StatefulShellBranch(
            navigatorKey: statsNavKey,
            routes: [
              GoRoute(
                path: '/statistics',
                name: 'statistics',
                builder: (context, state) => const StatisticsPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: settingNavKey,
            routes: [
              GoRoute(
                path: '/settings',
                name: 'settings',
                builder: (context, state) => const SettingsPage(),
              ),
            ],
          ),
        ],
      ),
    ],

    redirect: (context, state) {
      final isLoggedIn = isAuthenticated;
      final loggingIn = state.matchedLocation.startsWith('/auth');

      // If not logged in and trying to access a protected route
      if (!isLoggedIn && !loggingIn) return "/auth?screen=login";
      // If logged in and trying to go to auth screens, redirect to dashboard
      if (isLoggedIn && loggingIn) return "/home";

      return null; // No redirect
    },
  );

  return router;
});
