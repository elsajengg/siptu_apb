import 'package:flutter/material.dart';
import 'assigned_tasks.dart';
import 'update_status.dart';
import 'task_detail_page.dart';
import 'staff_profile_page.dart';

class StaffHome extends StatefulWidget {
  const StaffHome({super.key});

  @override
  State<StaffHome> createState() => _StaffHomeState();
}

class _StaffHomeState extends State<StaffHome> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const _StaffDashboard(),
    const AssignedTasksPage(),
    const StaffProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.red.shade800,
        unselectedItemColor: Colors.black45,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            label: 'Tugas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Akun',
          ),
        ],
      ),
    );
  }
}

class _StaffDashboard extends StatelessWidget {
  const _StaffDashboard();


  static final List<Map<String, dynamic>> _myActiveTasks = [
    {
      'id': 'TGS-001',
      'title': 'Perbaikan AC Ruang 302',
      'priority': 'Urgent',
      'difficulty': 'Berat',
      'deadline': 'Hari ini, 16:00',
      'status': 'Diproses',
    },
    {
      'id': 'TGS-004',
      'title': 'Ganti Panel Lantai 2',
      'priority': 'Urgent',
      'difficulty': 'Sedang',
      'deadline': 'Hari ini, 18:00',
      'status': 'Diproses',
    },
    {
      'id': 'TGS-005',
      'title': 'Atur Temperatur Server',
      'priority': 'Urgent',
      'difficulty': 'Rendah',
      'deadline': 'Hari ini, 20:00',
      'status': 'Diproses',
    },
    {
      'id': 'TGS-002',
      'title': 'Ganti Lampu Selasar Barat',
      'priority': 'Sedang',
      'difficulty': 'Rendah',
      'deadline': 'Besok, 10:00',
      'status': 'Diproses',
    },
    {
      'id': 'TGS-003',
      'title': 'Pengecekan Panel Listrik Gedung C',
      'priority': 'Tinggi',
      'difficulty': 'Sedang',
      'deadline': '22 Apr 2026',
      'status': 'Menunggu',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final red = Colors.red.shade800;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: red,
        elevation: 0,
        title: const Text(
          'Dashboard Staff',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.white),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Hero Card ──────────────────────────────────────
            _buildHeroCard(context, red),
            const SizedBox(height: 16),



            // ── Daftar Tugas Aktif ─────────────────────────
            _buildTaskList(context, red),
            const SizedBox(height: 16),

          ],
        ),
      ),
    );
  }

  Widget _buildHeroCard(BuildContext context, Color red) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
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
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.engineering_outlined, color: red, size: 28),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Budi Santoso',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                    Text(
                      'Staff Teknisi • Listrik & AC',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Text(
            'Selamat bekerja! Selesaikan tugas dengan teliti dan utamakan keselamatan.',
            style: TextStyle(color: Colors.white, fontSize: 12, height: 1.4),
          ),
        ],
      ),
    );
  }



  Widget _buildTaskList(BuildContext context, Color red) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tugas Saya Saat Ini',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                ),
                Text(
                  'Lihat Semua',
                  style: TextStyle(
                    fontSize: 12,
                    color: red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Builder(
            builder: (context) {
              final sortedTasks = List<Map<String, dynamic>>.from(_myActiveTasks);
              sortedTasks.sort((a, b) {
                const priorityOrder = {'urgent': 0, 'tinggi': 1, 'sedang': 2};
                final pA = priorityOrder[a['priority'].toString().toLowerCase()] ?? 99;
                final pB = priorityOrder[b['priority'].toString().toLowerCase()] ?? 99;
                if (pA != pB) return pA.compareTo(pB);
                const diffOrder = {'berat': 0, 'sedang': 1, 'rendah': 2};
                final dA = diffOrder[a['difficulty']?.toString().toLowerCase()] ?? 99;
                final dB = diffOrder[b['difficulty']?.toString().toLowerCase()] ?? 99;
                return dA.compareTo(dB);
              });

              return ListView.separated(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: sortedTasks.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final task = sortedTasks[index];

                  return Container(
                    decoration: const BoxDecoration(),
                    child: TweenAnimationBuilder(
                      duration: Duration(milliseconds: 400 + (index * 100)),
                      tween: Tween<double>(begin: 0, end: 1),
                      curve: Curves.easeOutQuart,
                      builder: (context, double value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.translate(
                            offset: Offset(0, 20 * (1 - value)),
                            child: child,
                          ),
                        );
                      },
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        title: Hero(
                          tag: 'task_title_${task['id']}',
                          child: Material(
                            color: Colors.transparent,
                            child: Text(
                              task['title'],
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            children: [
                              const Icon(Icons.access_time, size: 12, color: Colors.black45),
                              const SizedBox(width: 4),
                              Text(
                                task['deadline'],
                                style: const TextStyle(fontSize: 11, color: Colors.black54),
                              ),
                            ],
                          ),
                        ),
                        trailing: const Icon(Icons.chevron_right, color: Colors.black26),
                        onTap: () {
                          if (task['status'] == 'Selesai') {
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                transitionDuration: const Duration(milliseconds: 500),
                                pageBuilder: (context, animation, secondaryAnimation) => TaskDetailPage(task: task),
                                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                  return FadeTransition(opacity: animation, child: child);
                                },
                              ),
                            );
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UpdateStatusPage(
                                  taskId: task['id'],
                                  taskTitle: task['title'],
                                  taskLocation: 'Lokasi Terlampir',
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}



