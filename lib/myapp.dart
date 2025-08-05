import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/config/router/app_router.dart';
import 'core/config/appboot/boot_provider.dart';
import 'core/config/appboot/splash_screen.dart';
import 'core/theme/theme_provider.dart';
import 'main.dart';
import 'package:flutter/material.dart';

final List<GlobalKey<NavigatorState>> mainShellKeys = [homeNavKey,ordersNavKey,menuNavKey,statsNavKey,settingNavKey];
class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final appBoot = ref.watch(appBootProvider);
    final themeMode = ref.watch(themeModeProvider);
    final themeData = ref.watch(themeModeProvider.notifier);
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      scaffoldMessengerKey: scaffoldMessengerKey,
      routerConfig: router,
      theme: themeData.materialTheme.light(),
      darkTheme: themeData.materialTheme.dark(),
      themeMode: themeMode,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        if (appBoot.error != null) {
          return ErrorScreen(
            error: appBoot.error??"Something went wrong",
            onRetry: () => ref.read(appBootProvider.notifier).retry(),
          );
        }

        if (!appBoot.isInitialized) {
          return  SplashScreen();
        }

        return child!;
      },
    );
  }
}


final homeNavKey = GlobalKey<NavigatorState>();
final ordersNavKey = GlobalKey<NavigatorState>();
final menuNavKey = GlobalKey<NavigatorState>();
final statsNavKey = GlobalKey<NavigatorState>();
final settingNavKey = GlobalKey<NavigatorState>();

class ErrorScreen extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const ErrorScreen({
    super.key,
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(error, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: onRetry,
                child: const Text("Retry"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


