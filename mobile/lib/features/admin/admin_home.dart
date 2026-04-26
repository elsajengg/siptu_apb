import 'package:flutter/material.dart';
import 'verify_report.dart';
import 'manage_staff.dart';
import 'admin_profile.dart';
import 'notification_page.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  int _index = 0;

  final List<Widget> _pages = [
    const _AdminDashboard(),
    const VerifyReportPage(),
    const ManageStaffPage(),
    const AdminProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.red.shade800,
        unselectedItemColor: Colors.black45,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.verified_outlined),
            activeIcon: Icon(Icons.verified),
            label: 'Pengaduan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            activeIcon: Icon(Icons.people),
            label: 'Staff',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Akun',
          ),
        ],
      ),
    );
  }
}

class _AdminDashboard extends StatelessWidget {
  const _AdminDashboard();

  static const int _total = 12;
  static const int _menunggu = 5;
  static const int _diproses = 4;
  static const int _selesai = 3;

  static final List<Map<String, dynamic>> _recentReports = [
    {
      'id': 'TIK-202604-001',
      'title': 'Lampu Koridor Gedung B Lantai 3 Mati',
      'category': 'Penerangan',
      'requester': 'mahasiswa_2023',
      'update': '06 Apr 2026 19:30',
      'status': 'Diproses',
    },
    {
      'id': 'TIK-202604-002',
      'title': 'AC Ruang Kelas 204 Tidak Dingin',
      'category': 'Kenyamanan Ruangan',
      'requester': 'bima.putra',
      'update': '05 Apr 2026 09:15',
      'status': 'Menunggu',
    },
    {
      'id': 'TIK-202604-003',
      'title': 'Kursi Rusak di Perpustakaan Utama',
      'category': 'Furnitur',
      'requester': 'salsa_19',
      'update': '03 Apr 2026 14:45',
      'status': 'Selesai',
    },
    {
      'id': 'TIK-202604-004',
      'title': 'Keran Air Bocor di Toilet Lantai 1',
      'category': 'Sanitasi',
      'requester': 'agung.pratama',
      'update': '07 Apr 2026 08:10',
      'status': 'Diproses',
    },
  ];

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'menunggu':
        return const Color(0xFFF97316);
      case 'diproses':
        return const Color(0xFFEAB308);
      case 'selesai':
        return const Color(0xFF16A34A);
      default:
        return const Color(0xFF6B7280);
    }
  }

  @override
  Widget build(BuildContext context) {
    final red = Colors.red.shade800;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: red,
        elevation: 0,
        title: const Text(
          'Dashboard Admin',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotificationPage()),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Hero Card ──────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: LinearGradient(
                  colors: [Colors.red.shade900, Colors.red.shade700],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.admin_panel_settings, color: red),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _greeting(),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Super Admin',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Tanggal & Jam
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        color: Colors.white70,
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _formattedDate(),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Icon(
                        Icons.access_time,
                        color: Colors.white70,
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _formattedTime(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Summary Cards 2x2 ──────────────────────────────
            GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.7,
              children: const [
                _SummaryCard(
                  label: 'Total Tiket',
                  value: '$_total',
                  color: Color(0xFF2563EB),
                  icon: Icons.all_inbox_outlined,
                ),
                _SummaryCard(
                  label: 'Menunggu',
                  value: '$_menunggu',
                  color: Color(0xFFF97316),
                  icon: Icons.pending_actions_outlined,
                ),
                _SummaryCard(
                  label: 'Diproses',
                  value: '$_diproses',
                  color: Color(0xFFEAB308),
                  icon: Icons.sync_outlined,
                ),
                _SummaryCard(
                  label: 'Selesai',
                  value: '$_selesai',
                  color: Color(0xFF16A34A),
                  icon: Icons.check_circle_outline,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Daftar Laporan Terbaru ─────────────────────────
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Daftar Laporan Terbaru',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        Row(
                          children: [
                            Text(
                              '${_recentReports.length} tiket',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.black45,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Lihat semua',
                              style: TextStyle(
                                fontSize: 11,
                                color: red,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _recentReports.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final r = _recentReports[index];
                      final statusColor = _statusColor(r['status']!);
                      return ListTile(
                        dense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        title: Text(
                          r['title']!,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 2),
                            Text(
                              '#${r['id']} • ${r['category']}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.black54,
                              ),
                            ),
                            Text(
                              'Pelapor: ${r['requester']} • Update: ${r['update']}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.black45,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: statusColor.withOpacity(0.12),
                          ),
                          child: Text(
                            r['status']!,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: statusColor,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// ── Fungsi helper (di luar class) ────────────────────────────

String _greeting() {
  final hour = DateTime.now().hour;
  if (hour >= 5 && hour < 12) return 'Selamat Pagi 🌤️';
  if (hour >= 12 && hour < 15) return 'Selamat Siang ☀️';
  if (hour >= 15 && hour < 18) return 'Selamat Sore 🌇';
  return 'Selamat Malam 🌙';
}

String _formattedDate() {
  final now = DateTime.now();
  const days = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];
  return '${days[now.weekday - 1]}, ${now.day} ${months[now.month - 1]} ${now.year}';
}

String _formattedTime() {
  final now = DateTime.now();
  final h = now.hour.toString().padLeft(2, '0');
  final m = now.minute.toString().padLeft(2, '0');
  return '$h:$m WIB';
}

// ── Widget Helper ────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: color.withOpacity(0.12),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
              Icon(icon, size: 20, color: color),
            ],
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
