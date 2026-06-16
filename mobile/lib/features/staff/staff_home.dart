import 'package:flutter/material.dart';
import 'assigned_tasks.dart';
import 'task_detail_page.dart';
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
  List<Map<String, dynamic>> _myTasks = [];
  String _selectedStatus = 'Baru';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final result = await ApiService.getTasks();
    if (!mounted) return;
    setState(() {
      _loading = false;
      _myTasks = result['success'] == true
          ? (result['data'] as List).map((item) {
              final task = Map<String, dynamic>.from(item as Map);
              final report = Map<String, dynamic>.from(
                task['report'] as Map? ?? {},
              );
              return {
                'databaseId': task['id'],
                ...task,
                'id': task['task_number']?.toString() ?? '-',
                'title': report['title']?.toString() ?? '-',
                'location': report['location']?.toString() ?? '-',
                'room_detail': report['room_detail']?.toString() ?? '',
                'status': task['status'] == 'assigned'
                    ? 'Baru'
                    : task['status'] == 'resolved'
                    ? 'Selesai'
                    : 'Progress',
              };
            }).toList()
          : [];
    });
  }

  List<Map<String, dynamic>> get _sortedTasks {
    final sorted = _myTasks
        .where((task) => task['status'] == _selectedStatus)
        .map((task) => Map<String, dynamic>.from(task))
        .toList();
    sorted.sort((a, b) {
      return b['created_at'].toString().compareTo(a['created_at'].toString());
    });
    return sorted;
  }

  int get _activeCount => _myTasks
      .where((task) => task['status'] == 'Baru' || task['status'] == 'Progress')
      .length;

  int get _completedCount =>
      _myTasks.where((task) => task['status'] == 'Selesai').length;

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
            _buildStats(),
            const SizedBox(height: 16),

            // ── Daftar Tugas Aktif ─────────────────────────
            _buildTaskList(context, red),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildStats() {
    return Row(
      children: [
        Expanded(
          child: _StatBox(
            icon: Icons.pending_actions_rounded,
            label: 'Sedang dikerjakan',
            value: _loading ? '-' : _activeCount.toString(),
            color: const Color(0xFF2563EB),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatBox(
            icon: Icons.task_alt_rounded,
            label: 'Selesai',
            value: _loading ? '-' : _completedCount.toString(),
            color: const Color(0xFF16A34A),
          ),
        ),
      ],
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
            color: Colors.red.shade900.withValues(alpha: 0.4),
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
              color: Colors.white.withValues(alpha: 0.1),
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
                          color: Colors.black.withValues(alpha: 0.1),
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
    final tasks = _sortedTasks;
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
                '$_activeCount aktif',
                style: TextStyle(
                  fontSize: 13,
                  color: red,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        Row(
          children: ['Baru', 'Progress'].map((status) {
            final selected = _selectedStatus == status;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ChoiceChip(
                  label: Center(child: Text(status)),
                  selected: selected,
                  onSelected: (_) => setState(() => _selectedStatus = status),
                  selectedColor: red.withValues(alpha: 0.12),
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: selected ? red : const Color(0xFFE5E7EB),
                    ),
                  ),
                  labelStyle: TextStyle(
                    color: selected ? red : Colors.black54,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        if (_loading)
          const Padding(
            padding: EdgeInsets.only(top: 24),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (tasks.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Text(
              'Tidak ada tugas $_selectedStatus.',
              style: const TextStyle(fontSize: 13, color: Colors.black45),
            ),
          )
        else
          ListView.separated(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: tasks.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) =>
                _ActiveTaskTile(task: tasks[index], index: index),
          ),
      ],
    );
  }
}

class _StatBox extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatBox({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF6B7280),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
              color: Colors.black.withValues(alpha: 0.04),
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
                  builder: (context) => TaskDetailPage(task: task),
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
                        Text(
                          task['room_detail'].toString().isEmpty
                              ? task['location'].toString()
                              : '${task['location']} - ${task['room_detail']}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                            fontWeight: FontWeight.w500,
                          ),
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
