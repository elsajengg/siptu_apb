import 'package:flutter/material.dart';

class NotificationProvider extends ChangeNotifier {
  bool _hasNotificationToday = false;
  bool get hasNotificationToday => _hasNotificationToday;

  bool _notificationsEnabled = true;
  bool get notificationsEnabled => _notificationsEnabled;

  void toggleNotifications(bool value) {
    _notificationsEnabled = value;
    notifyListeners();
  }

  // Mock list jadwal perbaikan (repair schedules)
  final List<DateTime> _schedules = [
    DateTime.now(), // Memaksa ada jadwal hari ini untuk keperluan testing
    DateTime.now().add(const Duration(days: 2)),
  ];

  NotificationProvider() {
    _checkSchedules();
  }

  void _checkSchedules() {
    final now = DateTime.now();
    bool foundToday = false;

    for (var date in _schedules) {
      if (date.year == now.year && date.month == now.month && date.day == now.day) {
        foundToday = true;
        break;
      }
    }

    if (foundToday) {
      _hasNotificationToday = true;
      notifyListeners();
      _triggerInAppNotification();
    } else {
      _hasNotificationToday = false;
      notifyListeners();
    }
  }

  void _triggerInAppNotification() {
    // Fungsi mock-up untuk men-trigger in-app notification
    debugPrint('🔔 System Alert: Ada jadwal perbaikan hari ini!');
  }

  /// Tandai notifikasi sudah dibaca — hapus badge dari AppBar
  void markAsRead() {
    if (_hasNotificationToday) {
      _hasNotificationToday = false;
      notifyListeners();
    }
  }
}
