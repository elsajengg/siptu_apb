import 'package:flutter/material.dart';
import '../home/home_shell.dart';

enum NotifType { laporanBaru, laporanSelesai }

class NotificationItem {
  final String id;
  final String reportId;
  final String reportTitle;
  final String category;
  final String location;
  final String? staffName; // hanya untuk notif selesai
  final DateTime time;
  final NotifType type;
  bool isRead;

  NotificationItem({
    required this.id,
    required this.reportId,
    required this.reportTitle,
    required this.category,
    required this.location,
    this.staffName,
    required this.time,
    required this.type,
    this.isRead = false,
  });
}

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final List<NotificationItem> _notifications = [
    // ── Laporan Baru (Pending) ────────────────────────────────
    NotificationItem(
      id: 'N-001',
      reportId: 'TIK-007',
      reportTitle: 'Lampu Parkiran Gedung C Mati',
      category: 'Penerangan',
      location: 'Parkiran Gedung C',
      time: DateTime.now().subtract(const Duration(minutes: 3)),
      type: NotifType.laporanBaru,
      isRead: false,
    ),
    NotificationItem(
      id: 'N-002',
      reportId: 'TIK-008',
      reportTitle: 'AC Ruang Kelas 204 Tidak Dingin',
      category: 'Kenyamanan Ruangan',
      location: 'Gedung A Lantai 2',
      time: DateTime.now().subtract(const Duration(minutes: 25)),
      type: NotifType.laporanBaru,
      isRead: false,
    ),

    // ── Laporan Selesai (Done) ────────────────────────────────
    NotificationItem(
      id: 'N-003',
      reportId: 'TIK-003',
      reportTitle: 'Keran Air Bocor di Toilet Lantai 1',
      category: 'Sanitasi',
      location: 'Gedung C Lantai 1',
      staffName: 'Citra Dewi',
      time: DateTime.now().subtract(const Duration(hours: 1)),
      type: NotifType.laporanSelesai,
      isRead: false,
    ),

    // ── Sudah dibaca ──────────────────────────────────────────
    NotificationItem(
      id: 'N-004',
      reportId: 'TIK-004',
      reportTitle: 'Kursi Rusak di Perpustakaan Utama',
      category: 'Furnitur',
      location: 'Perpustakaan Utama',
      staffName: 'Dendi Pratama',
      time: DateTime.now().subtract(const Duration(hours: 3)),
      type: NotifType.laporanSelesai,
      isRead: true,
    ),
    NotificationItem(
      id: 'N-005',
      reportId: 'TIK-006',
      reportTitle: 'Toilet Lantai 2 Tersumbat',
      category: 'Sanitasi',
      location: 'Gedung A Lantai 2',
      time: DateTime.now().subtract(const Duration(hours: 5)),
      type: NotifType.laporanBaru,
      isRead: true,
    ),
    NotificationItem(
      id: 'N-006',
      reportId: 'TIK-005',
      reportTitle: 'Proyektor Ruang 305 Rusak',
      category: 'Elektronik',
      location: 'Gedung B Lantai 3',
      time: DateTime.now().subtract(const Duration(days: 1)),
      type: NotifType.laporanBaru,
      isRead: true,
    ),
  ];

  int get _unreadCount => _notifications.where((n) => !n.isRead).length;

  void _markAllRead() {
    setState(() {
      for (final n in _notifications) {
        n.isRead = true;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Semua notifikasi telah ditandai dibaca'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _markRead(NotificationItem notif) {
    setState(() => notif.isRead = true);
  }

  void _deleteNotification(NotificationItem notif) {
    setState(() => _notifications.remove(notif));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Notifikasi dihapus'),
        backgroundColor: Colors.red,
      ),
    );
  }

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    return '${diff.inDays} hari lalu';
  }

  // ── Konfigurasi tampilan per tipe notifikasi ─────────────────
  IconData _notifIcon(NotifType type) {
    switch (type) {
      case NotifType.laporanBaru:
        return Icons.assignment_late_outlined;
      case NotifType.laporanSelesai:
        return Icons.check_circle_outline;
    }
  }

  Color _notifColor(NotifType type) {
    switch (type) {
      case NotifType.laporanBaru:
        return Colors.red.shade800;
      case NotifType.laporanSelesai:
        return Colors.green;
    }
  }

  String _notifTitle(NotifType type) {
    switch (type) {
      case NotifType.laporanBaru:
        return 'Laporan Baru Masuk';
      case NotifType.laporanSelesai:
        return 'Laporan Selesai Ditangani';
    }
  }

  String _notifSubtitle(NotificationItem notif) {
    switch (notif.type) {
      case NotifType.laporanBaru:
        return notif.reportTitle;
      case NotifType.laporanSelesai:
        return '${notif.staffName ?? "Staff"} telah menyelesaikan: ${notif.reportTitle}';
    }
  }

  // ── Detail bottom sheet ───────────────────────────────────────
  void _showDetail(NotificationItem notif) {
    _markRead(notif);
    final color = _notifColor(notif.type);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Icon + judul
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(_notifIcon(notif.type), color: color, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _notifTitle(notif.type),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _formatTime(notif.time),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black45,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Detail laporan
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notif.reportTitle,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _DetailRow(
                    icon: Icons.tag,
                    label: 'ID Laporan',
                    value: notif.reportId,
                  ),
                  const SizedBox(height: 6),
                  _DetailRow(
                    icon: Icons.category_outlined,
                    label: 'Kategori',
                    value: notif.category,
                  ),
                  const SizedBox(height: 6),
                  _DetailRow(
                    icon: Icons.location_on_outlined,
                    label: 'Lokasi',
                    value: notif.location,
                  ),
                  if (notif.staffName != null) ...[
                    const SizedBox(height: 6),
                    _DetailRow(
                      icon: Icons.assignment_ind_outlined,
                      label: 'Ditangani oleh',
                      value: notif.staffName!,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Info box sesuai tipe
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: color.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: color, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      notif.type == NotifType.laporanBaru
                          ? 'Laporan ini menunggu verifikasi. Buka halaman Pengaduan untuk menindaklanjuti.'
                          : 'Laporan telah selesai ditangani oleh staff. Periksa hasil perbaikan di halaman Pengaduan.',
                      style: TextStyle(fontSize: 12, color: color),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Tombol tutup
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: color,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Tutup',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final red = Colors.red.shade800;
    final unread = _notifications.where((n) => !n.isRead).toList();
    final read = _notifications.where((n) => n.isRead).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: red,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const HomeShell()),
            (route) => false,
          ),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        title: Row(
          children: [
            const Text(
              'Notifikasi',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (_unreadCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$_unreadCount baru',
                  style: TextStyle(
                    fontSize: 11,
                    color: red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (_unreadCount > 0)
            TextButton(
              onPressed: _markAllRead,
              child: const Text(
                'Tandai semua dibaca',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          const SizedBox(width: 4),
        ],
      ),
      body: _notifications.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_none,
                    size: 70,
                    color: Colors.black26,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Tidak ada notifikasi',
                    style: TextStyle(fontSize: 15, color: Colors.black45),
                  ),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // ── Belum Dibaca ──────────────────────────────
                if (unread.isNotEmpty) ...[
                  _SectionLabel(label: 'Belum Dibaca (${unread.length})'),
                  const SizedBox(height: 8),
                  ...unread.map(
                    (notif) => _NotifCard(
                      notif: notif,
                      notifIcon: _notifIcon(notif.type),
                      notifColor: _notifColor(notif.type),
                      notifTitle: _notifTitle(notif.type),
                      notifSubtitle: _notifSubtitle(notif),
                      timeLabel: _formatTime(notif.time),
                      onTap: () => _showDetail(notif),
                      onDelete: () => _deleteNotification(notif),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // ── Sudah Dibaca ──────────────────────────────
                if (read.isNotEmpty) ...[
                  _SectionLabel(label: 'Sudah Dibaca (${read.length})'),
                  const SizedBox(height: 8),
                  ...read.map(
                    (notif) => _NotifCard(
                      notif: notif,
                      notifIcon: _notifIcon(notif.type),
                      notifColor: _notifColor(notif.type),
                      notifTitle: _notifTitle(notif.type),
                      notifSubtitle: _notifSubtitle(notif),
                      timeLabel: _formatTime(notif.time),
                      onTap: () => _showDetail(notif),
                      onDelete: () => _deleteNotification(notif),
                    ),
                  ),
                ],
              ],
            ),
    );
  }
}

// ── Widget Helper ─────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.bold,
        color: Colors.black54,
      ),
    );
  }
}

class _NotifCard extends StatelessWidget {
  final NotificationItem notif;
  final IconData notifIcon;
  final Color notifColor;
  final String notifTitle;
  final String notifSubtitle;
  final String timeLabel;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _NotifCard({
    required this.notif,
    required this.notifIcon,
    required this.notifColor,
    required this.notifTitle,
    required this.notifSubtitle,
    required this.timeLabel,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(notif.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 24),
      ),
      onDismissed: (_) => onDelete(),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: notif.isRead ? Colors.white : notifColor.withOpacity(0.04),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: notif.isRead
                  ? Colors.transparent
                  : notifColor.withOpacity(0.2),
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon dengan dot belum dibaca
              Stack(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: notif.isRead
                          ? Colors.grey.withOpacity(0.1)
                          : notifColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      notifIcon,
                      color: notif.isRead ? Colors.grey : notifColor,
                      size: 22,
                    ),
                  ),
                  if (!notif.isRead)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: notifColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),

              // Konten
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Badge tipe notifikasi
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: notifColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            notifTitle,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: notifColor,
                            ),
                          ),
                        ),
                        Text(
                          timeLabel,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.black38,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      notifSubtitle,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: notif.isRead
                            ? FontWeight.normal
                            : FontWeight.w600,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.category_outlined,
                          size: 12,
                          color: Colors.black38,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          notif.category,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.black45,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Icon(
                          Icons.location_on_outlined,
                          size: 12,
                          color: Colors.black38,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            notif.location,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.black45,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            notif.reportId,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.orange,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.black45),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.black54,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 12, color: Colors.black87),
          ),
        ),
      ],
    );
  }
}
