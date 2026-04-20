import 'package:flutter/material.dart';

/// Model untuk notifikasi
class Notification {
  final String id;
  final String title;
  final String message;
  final String type; // 'status_update', 'new_feedback', 'reply', etc
  final DateTime createdAt;
  final bool isRead;
  final String? relatedReportId;

  Notification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.createdAt,
    required this.isRead,
    this.relatedReportId,
  });
}

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  late List<Notification> _notifications;

  @override
  void initState() {
    super.initState();
    _notifications = List.of(_dummyNotifications);
  }

  void _markAsRead(int index) {
    setState(() {
      final notif = _notifications[index];
      _notifications[index] = Notification(
        id: notif.id,
        title: notif.title,
        message: notif.message,
        type: notif.type,
        createdAt: notif.createdAt,
        isRead: true,
        relatedReportId: notif.relatedReportId,
      );
    });
  }

  void _deleteNotification(int index) {
    setState(() {
      _notifications.removeAt(index);
    });
  }

  String _getIcon(String type) {
    switch (type) {
      case 'status_update':
        return '📊';
      case 'new_feedback':
        return '💬';
      case 'reply':
        return '↩️';
      case 'reminder':
        return '⏰';
      default:
        return '📢';
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'status_update':
        return const Color(0xFF3B82F6);
      case 'new_feedback':
        return const Color(0xFF10B981);
      case 'reply':
        return const Color(0xFFF97316);
      case 'reminder':
        return const Color(0xFFA855F7);
      default:
        return const Color(0xFF6B7280);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red.shade800,
        title: const Text('Notifikasi'),
        elevation: 0,
        actions: [
          if (_notifications.isNotEmpty)
            TextButton(
              onPressed: () {
                setState(() {
                  for (var i = 0; i < _notifications.length; i++) {
                    final notif = _notifications[i];
                    _notifications[i] = Notification(
                      id: notif.id,
                      title: notif.title,
                      message: notif.message,
                      type: notif.type,
                      createdAt: notif.createdAt,
                      isRead: true,
                      relatedReportId: notif.relatedReportId,
                    );
                  }
                });
              },
              child: const Text(
                'Tandai semua dibaca',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
        ],
      ),
      body: _notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Tidak ada notifikasi',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Notifikasi akan muncul di sini',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                return _NotificationCard(
                  notification: _notifications[index],
                  onMarkAsRead: () => _markAsRead(index),
                  onDelete: () => _deleteNotification(index),
                  typeIcon: _getIcon(_notifications[index].type),
                  typeColor: _getTypeColor(_notifications[index].type),
                );
              },
            ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final Notification notification;
  final VoidCallback onMarkAsRead;
  final VoidCallback onDelete;
  final String typeIcon;
  final Color typeColor;

  const _NotificationCard({
    required this.notification,
    required this.onMarkAsRead,
    required this.onDelete,
    required this.typeIcon,
    required this.typeColor,
  });

  @override
  Widget build(BuildContext context) {
    final time = _formatTime(notification.createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: notification.isRead ? Colors.white : const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: notification.isRead
              ? Colors.grey[300]!
              : Colors.red.shade200,
          width: 1.5,
        ),
        boxShadow: !notification.isRead
            ? [
                BoxShadow(
                  color: Colors.red.shade100,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: typeColor.withAlpha((0.15 * 255).round()),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  typeIcon,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: Colors.red.shade800,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      time,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.black45,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            notification.message,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black54,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (!notification.isRead)
                TextButton(
                  onPressed: onMarkAsRead,
                  child: const Text(
                    'Tandai dibaca',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              TextButton(
                onPressed: onDelete,
                child: const Text(
                  'Hapus',
                  style: TextStyle(fontSize: 12, color: Colors.red),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

String _formatTime(DateTime dt) {
  final now = DateTime.now();
  final diff = now.difference(dt);

  if (diff.inMinutes < 1) {
    return 'Baru saja';
  } else if (diff.inMinutes < 60) {
    return '${diff.inMinutes}m yang lalu';
  } else if (diff.inHours < 24) {
    return '${diff.inHours}jam yang lalu';
  } else if (diff.inDays < 7) {
    return '${diff.inDays}hari yang lalu';
  } else {
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '${dt.day}/${dt.month} $hh:$mm';
  }
}

final List<Notification> _dummyNotifications = [
  Notification(
    id: 'NOTIF-001',
    title: 'Laporan Lampu Diproses',
    message:
        'Tim teknisi sudah menerima laporan Anda tentang lampu koridor Gedung B. Status akan diupdate segera.',
    type: 'status_update',
    createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
    isRead: false,
    relatedReportId: 'REP-20260406-193000',
  ),
  Notification(
    id: 'NOTIF-002',
    title: 'Feedback dari Pak Arif',
    message:
        'Pak Arif (Teknisi Listrik) memberikan update: Tim sudah cek awal. Pergantian dilakukan malam ini.',
    type: 'new_feedback',
    createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    isRead: false,
    relatedReportId: 'REP-20260406-193000',
  ),
  Notification(
    id: 'NOTIF-003',
    title: 'Laporan AC Sudah Ditindaklanjuti',
    message:
        'Laporan AC Ruang 204 Anda sudah dikonfirmasi dan sedang dalam antrian perbaikan.',
    type: 'status_update',
    createdAt: DateTime.now().subtract(const Duration(hours: 4)),
    isRead: true,
    relatedReportId: 'REP-20260405-091500',
  ),
  Notification(
    id: 'NOTIF-004',
    title: 'Kursi Perpustakaan Sudah Diganti',
    message:
        'Laporan Anda tentang kursi rusak di perpustakaan sudah selesai. 5 kursi baru telah dipasang.',
    type: 'status_update',
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
    isRead: true,
    relatedReportId: 'REP-20260403-144500',
  ),
  Notification(
    id: 'NOTIF-005',
    title: 'Pengingat: Update Laporan Pending',
    message:
        'Anda memiliki 2 laporan yang masih status "Menunggu" lebih dari 3 hari.',
    type: 'reminder',
    createdAt: DateTime.now().subtract(const Duration(days: 2)),
    isRead: true,
  ),
];
