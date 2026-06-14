import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../data/api_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static const _channel = AndroidNotificationChannel(
    'siptu_task_updates',
    'Update Tugas SIPTU',
    description: 'Notifikasi perubahan status laporan dan tugas SIPTU',
    importance: Importance.max,
  );

  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  bool get _supportsMessaging =>
      kIsWeb ||
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;

  Future<void> init() async {
    if (_initialized || !_supportsMessaging) return;

    if (!kIsWeb) {
      const settings = InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      );
      await _localNotifications.initialize(settings: settings);

      await _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(_channel);
    }

    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
          alert: true,
          badge: true,
          sound: true,
        );

    FirebaseMessaging.onMessage.listen(_showFirebaseMessage);
    FirebaseMessaging.instance.onTokenRefresh.listen(_registerToken);
    _initialized = true;
  }

  Future<void> syncDeviceToken() async {
    await init();
    if (!_supportsMessaging) return;

    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        await _registerToken(token);
        debugPrint('FCM device token berhasil didaftarkan.');
      }
    } catch (error) {
      debugPrint('Gagal mengambil FCM token: $error');
    }
  }

  Future<void> _registerToken(String token) async {
    final result = await ApiService.registerDevice(
      token: token,
      platform: _platform,
    );

    if (result['success'] != true) {
      debugPrint('Gagal menyimpan FCM token: ${result['message']}');
    }
  }

  Future<void> _showFirebaseMessage(RemoteMessage message) async {
    if (kIsWeb || defaultTargetPlatform == TargetPlatform.iOS) return;

    final notification = message.notification;
    final title = notification?.title ?? message.data['title']?.toString();
    final body = notification?.body ?? message.data['body']?.toString();

    if (title == null && body == null) return;

    await showNotification(
      title: title ?? 'SIPTU',
      body: body ?? 'Ada pembaruan baru.',
      payload: message.data['type']?.toString(),
    );
  }

  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    if (kIsWeb) return;

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'siptu_task_updates',
        'Update Tugas SIPTU',
        channelDescription:
            'Notifikasi perubahan status laporan dan tugas SIPTU',
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );

    await _localNotifications.show(
      id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title: title,
      body: body,
      notificationDetails: details,
      payload: payload,
    );
  }

  String get _platform {
    if (kIsWeb) return 'web';

    return switch (defaultTargetPlatform) {
      TargetPlatform.android => 'android',
      TargetPlatform.iOS => 'ios',
      TargetPlatform.windows => 'windows',
      _ => 'web',
    };
  }
}
