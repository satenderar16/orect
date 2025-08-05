import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'env_config.dart';

final envProvider = Provider<EnvReader>((ref) => EnvReader());

class EnvReader {
  String? get(String key) {
    return EnvConfig.get(key);
  }
}
