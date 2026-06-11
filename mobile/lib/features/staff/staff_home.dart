import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/notification_provider.dart';
import 'notification_center_screen.dart';
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

  List<Map<String, dynamic>> get _sortedTasks {
    final sorted = List<Map<String, dynamic>>.from(_myActiveTasks);
    sorted.sort((a, b) {
      const priorityOrder = {'urgent': 0, 'tinggi': 1, 'sedang': 2};
      final pA = priorityOrder[a['priority'].toString().toLowerCase()] ?? 99;
      final pB = priorityOrder[b['priority'].toString().toLowerCase()] ?? 99;
      if (pA != pB) return pA.compareTo(pB);
      
      const diffOrder = {'berat': 0, 'sedang': 1, 'rendah': 2};
      final dA = diffOrder[a['difficulty']?.toString().toLowerCase()] ?? 99;
      final dB = diffOrder[b['difficulty']?.toString().toLowerCase()] ?? 99;
      return dA.compareTo(dB);
    });
    return sorted;
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
          'Dashboard Staff',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          Consumer<NotificationProvider>(
            builder: (context, notificationProvider, child) {
              return IconButton(
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.notifications_none, color: Colors.white),
                    if (notificationProvider.hasNotificationToday)
                      Positioned(
                        right: 2,
                        top: 2,
                        child: Container(
                          padding: const EdgeInsets.all(1),
                          decoration: BoxDecoration(
                            color: Colors.yellow.shade600,
                            shape: BoxShape.circle,
                            border: Border.all(color: red, width: 1.5),
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 10,
                            minHeight: 10,
                          ),
                        ),
                      ),
                  ],
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationCenterScreen(),
                    ),
                  );
                },
              );
            },
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
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: [Colors.red.shade900, Colors.red.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.red.shade900.withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Icon(
              Icons.handyman_outlined,
              size: 100,
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(Icons.engineering, color: red, size: 30),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Budi Santoso',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 19,
                          ),
                        ),
                        Text(
                          'Staff Teknisi • Listrik & AC',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }



  Widget _buildTaskList(BuildContext context, Color red) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tugas Saya Saat Ini',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: Color(0xFF1F2937)),
              ),
              Text(
                'Lihat Semua',
                style: TextStyle(
                  fontSize: 13,
                  color: red,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        ListView.separated(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _sortedTasks.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, index) => _ActiveTaskTile(
            task: _sortedTasks[index],
            index: index,
          ),
        ),
      ],
    );
  }
}

class _ActiveTaskTile extends StatelessWidget {
  final Map<String, dynamic> task;
  final int index;

  const _ActiveTaskTile({required this.task, required this.index});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
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
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: const Color(0xFFF3F4F6)),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
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
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.build_circle_outlined, color: Colors.red.shade700, size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Hero(
                          tag: 'task_title_${task['id']}',
                          child: Material(
                            color: Colors.transparent,
                            child: Text(
                              task['title'],
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF111827)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.access_time_rounded, size: 14, color: Colors.black45),
                            const SizedBox(width: 4),
                            Text(
                              task['deadline'],
                              style: const TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: Colors.black38),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}



