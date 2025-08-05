
import 'dart:developer' as dev;

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'env_config.dart';

class AppInitializer {
  static Future<void> initialize() async {
    await EnvConfig.init();

    final supabaseUrl = EnvConfig.get('SUPABASE_URL');
    final supabaseAnonKey = EnvConfig.get('SUPABASE_ANON_KEY');

    if (supabaseUrl == null || supabaseAnonKey == null) {
      throw Exception('Supabase keys missing in .env');
    }

    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
   await initializeNotifications();

  }
}

final FlutterLocalNotificationsPlugin notificationsPlugin = FlutterLocalNotificationsPlugin();
Future<void> initializeNotifications() async {
  const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  const DarwinInitializationSettings iosSettings = DarwinInitializationSettings();

  const InitializationSettings settings = InitializationSettings(
    android: androidSettings,
    iOS: iosSettings,
  );

  await notificationsPlugin.initialize(settings);

  // iOS: Request permission
  await notificationsPlugin
      .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
      ?.requestPermissions(alert: true, badge: true, sound: true);

  // Android 13+: Request permission
  await requestNotificationPermission();

  // ✅ Also create a notification channel
  const androidChannel = AndroidNotificationChannel(
    'progress_channel',
    'Progress Notifications',
    description: 'Used for showing background upload progress',
    importance: Importance.high,
  );

  final androidImpl = notificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
  await androidImpl?.createNotificationChannel(androidChannel);
}
Future<void> requestNotificationPermission() async {
  final androidPlugin = notificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
  final isGranted = await androidPlugin?.requestNotificationsPermission();
  debugPrint("Android notification permission granted: $isGranted");
}