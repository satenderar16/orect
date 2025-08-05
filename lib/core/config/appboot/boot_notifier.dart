


import 'package:amtnew/core/config/connectivity/internet_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/auth_provider.dart';
import '../../features/profile/profile_provider.dart';
import 'boot_state.dart';

class AppBootNotifier extends StateNotifier<AppBootState> {
  final Ref ref;
  bool _isDisposed = false;

  AppBootNotifier(this.ref) : super(AppBootState.initial()){
    // This runs *after* init is done:
    /// provider is initializing values in it init state so when provider is done with it own init state,
    /// then call this function to initialized,required parameters:
    Future.microtask(() => _initializeApp());

  }

  Future<void> _initializeApp() async {
    if (state.isInitialized) return; //avoid splash screen building twice:

    if (!state.isLoading) {
      state = state.copyWith(isLoading: true, error: null);
    }

    try {
      /// take at least 1 second and max of async task required:
      await Future.wait([
        ref.read(authNotifierProvider.notifier).init(),
        ref.read(profileNotifierProvider.notifier).init(),
        ref.read(internetProvider.notifier).init(),
        Future.delayed(Duration(seconds: 2))
      ]);


      // Start both futures in parallel

    // ref.read(profileRepositoryProvider.notifier).debugPrintStoredProfile();
      if (!_isDisposed) {
        state = state.copyWith(isLoading: false, isInitialized: true);
      }
    } catch (e) {
      if (!_isDisposed) {
        state = state.copyWith(isLoading: false, isInitialized: false, error: e.toString());
      }
      debugPrint("app boot failed: $e}");
    }
  }

  void retry() => _initializeApp();

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}