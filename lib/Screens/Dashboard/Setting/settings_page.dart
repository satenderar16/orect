import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context,ref) {
    return PopScope(
      canPop: false, // prevent automatic pop
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) {
          return;
        }

      },
      child: const Scaffold(
        body: Center(child: Text('Settings Page')),
      ),
    );
  }
}
