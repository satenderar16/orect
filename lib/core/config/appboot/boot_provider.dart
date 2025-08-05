import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'boot_notifier.dart';
import 'boot_state.dart';

final appBootProvider = StateNotifierProvider<AppBootNotifier, AppBootState>(
      (ref) => AppBootNotifier(ref),
);