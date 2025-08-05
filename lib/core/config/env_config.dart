import 'package:flutter/cupertino.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
//Satender@1619 password for supabase db
class EnvConfig {
  static Future<void> init() async {
    try {
      await dotenv.load(fileName: '.env');
    } catch (e) {
      debugPrint("catch at EnvConfig file: not able to load .env file");
      rethrow;
    }
  }

  static String? get(String key) {
    return dotenv.env[key];
  }
}
