import 'package:amtnew/core/config/connectivity/internet_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'internet_notifier.dart';

final internetProvider =
StateNotifierProvider<InternetNotifier, InternetState>((ref) {
  return InternetNotifier();
});