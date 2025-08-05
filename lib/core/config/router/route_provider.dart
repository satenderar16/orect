

import 'package:amtnew/core/features/auth/auth_provider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/auth_state.dart';
final routerRefreshProvider = Provider<GoRouterRefreshStream>((ref) {
  final notifier = GoRouterRefreshStream(ref);
  ref.onDispose(() => notifier.dispose());
  return notifier;
});


class GoRouterRefreshStream extends ChangeNotifier {
  late final ProviderSubscription<AppAuthState> _subscription;

  GoRouterRefreshStream(Ref ref) {
    _subscription = ref.listen<AppAuthState>(
      authNotifierProvider,
          (previous, next) {
        final prevUser = previous?.user;
        final nextUser = next.user;


        // Only notify when user changes (null <-> non-null or different user)
        if (prevUser?.id != nextUser?.id) {

          notifyListeners();
        }
      },
    );
  }

  @override
  void dispose() {
    _subscription.close();
    super.dispose();
  }
}

