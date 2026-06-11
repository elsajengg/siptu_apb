import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/notification_provider.dart';

class NotificationCenterScreen extends StatelessWidget {
  const NotificationCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text(
          'Pusat Notifikasi',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.red.shade800,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, child) {
          if (!provider.hasNotificationToday) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off_outlined,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Tidak ada jadwal perbaikan hari ini',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: 1, // Berdasarkan mock data ada 1 notifikasi hari ini
            itemBuilder: (context, index) {
              return Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.build_circle_outlined, color: Colors.red.shade700, size: 28),
                  ),
                  title: const Text(
                    'Jadwal Perbaikan Hari Ini',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: const Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Text(
                      'Sistem mendeteksi ada jadwal perbaikan fasilitas kampus yang harus Anda kerjakan hari ini. Segera cek daftar tugas Anda.',
                      style: TextStyle(height: 1.4, fontSize: 14),
                    ),
                  ),
                  onTap: () {
                    // Tandai sudah dibaca dan hapus badge notifikasi
                    provider.markAsRead();
                    // Optional: Bisa tambahkan snackbar
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Notifikasi telah dibaca')),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
