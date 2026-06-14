import 'package:flutter/material.dart';
import 'assigned_tasks.dart';
import 'update_status.dart';
import 'staff_profile_page.dart';
import '../../data/api_service.dart';

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

class _StaffDashboard extends StatefulWidget {
  const _StaffDashboard();

  @override
  State<_StaffDashboard> createState() => _StaffDashboardState();
}

class _StaffDashboardState extends State<_StaffDashboard> {
  List<Map<String, dynamic>> _myActiveTasks = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final result = await ApiService.getTasks();
    if (!mounted || result['success'] != true) return;
    setState(() {
      _myActiveTasks = (result['data'] as List)
          .map((item) {
            final task = Map<String, dynamic>.from(item as Map);
            final report = Map<String, dynamic>.from(
              task['report'] as Map? ?? {},
            );
            return {
              'databaseId': task['id'],
              'id': task['task_number']?.toString() ?? '-',
              'title': report['title']?.toString() ?? '-',
              'location': report['location']?.toString() ?? '-',
              'deadline': task['deadline_at']?.toString() ?? '-',
              'status': task['status'] == 'assigned' ? 'Menunggu' : 'Diproses',
            };
          })
          .where((task) => task['status'] != 'Selesai')
          .toList();
    });
  }

  List<Map<String, dynamic>> get _sortedTasks {
    final sorted = List<Map<String, dynamic>>.from(_myActiveTasks);
    sorted.sort((a, b) {
      return a['deadline'].toString().compareTo(b['deadline'].toString());
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ApiService.currentUser?['name']?.toString() ??
                              'Staff',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 19,
                          ),
                        ),
                        Text(
                          'Staff Teknisi • ${ApiService.currentUser?['nip'] ?? '-'}',
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
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  color: Color(0xFF1F2937),
                ),
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
          itemBuilder: (context, index) =>
              _ActiveTaskTile(task: _sortedTasks[index], index: index),
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
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UpdateStatusPage(
                    taskDatabaseId: task['databaseId'] as int,
                    taskId: task['id'],
                    taskTitle: task['title'],
                    taskLocation: task['location'],
                  ),
                ),
              );
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
                    child: Icon(
                      Icons.build_circle_outlined,
                      color: Colors.red.shade700,
                      size: 26,
                    ),
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
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF111827),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(
                              Icons.access_time_rounded,
                              size: 14,
                              color: Colors.black45,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              task['deadline'],
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.black38,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
