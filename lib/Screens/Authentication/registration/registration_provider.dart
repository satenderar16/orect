import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'registration_state_model.dart';
import 'registration_repo.dart';

final registrationProvider = StateNotifierProvider.autoDispose<RegistrationNotifier, RegistrationState>(
      (ref) => RegistrationNotifier(),
);
