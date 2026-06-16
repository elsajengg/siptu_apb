import 'package:flutter/material.dart';
import 'task_detail_page.dart';
import '../../data/api_service.dart';

class AssignedTasksPage extends StatefulWidget {
  const AssignedTasksPage({super.key});

  @override
  State<AssignedTasksPage> createState() => _AssignedTasksPageState();
}

class _AssignedTasksPageState extends State<AssignedTasksPage> {
  static const double _phi = 1.61803398875;

  String _searchQuery = '';
  String _selectedMonth = 'Semua';
  String _selectedStatus = 'Semua';

  final List<String> _months = [
    'Semua',
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  List<Map<String, dynamic>> _allTasks = [];
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
      _allTasks = result['success'] == true
          ? (result['data'] as List).map((item) {
              final task = Map<String, dynamic>.from(item as Map);
              final report = Map<String, dynamic>.from(
                task['report'] as Map? ?? {},
              );
              final createdAt = DateTime.tryParse(
                task['created_at']?.toString() ?? '',
              );
              return {
                'databaseId': task['id'],
                ...task,
                'id': task['task_number']?.toString() ?? '-',
                'title': report['title']?.toString() ?? '-',
                'location': report['location']?.toString() ?? '-',
                'room_detail': report['room_detail']?.toString() ?? '',
                'month': createdAt == null ? 'Semua' : _months[createdAt.month],
                'status': _statusLabel(task['status']?.toString()),
              };
            }).toList()
          : [];
    });
  }

  String _statusLabel(String? status) {
    return switch (status) {
      'assigned' => 'Baru',
      'resolved' => 'Selesai',
      'blocked' => 'Terkendala',
      'on_progress' => 'Progress',
      _ => status ?? 'Baru',
    };
  }

  IconData _statusIcon(String status) {
    return switch (status) {
      'Baru' => Icons.fiber_new_rounded,
      'Progress' => Icons.engineering_rounded,
      'Terkendala' => Icons.warning_amber_rounded,
      'Selesai' => Icons.task_alt_rounded,
      _ => Icons.all_inbox_rounded,
    };
  }

  List<Map<String, dynamic>> get _filteredTasks {
    return _allTasks.where((task) {
      final matchesSearch =
          task['title'].toString().toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          task['id'].toString().toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );
      final matchesMonth =
          _selectedMonth == 'Semua' || task['month'] == _selectedMonth;
      final matchesStatus =
          _selectedStatus == 'Semua' || task['status'] == _selectedStatus;
      return matchesSearch && matchesMonth && matchesStatus;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final red = Colors.red.shade800;
    final filteredTasks = _filteredTasks;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: red,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Tugas Saya',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Column(
        children: [
          // ── Header: Search & Filter ─────────────────────────────
          Container(
            color: Colors.white,
            padding: EdgeInsets.fromLTRB(
              16 * _phi,
              16 * _phi,
              16 * _phi,
              8 * _phi,
            ),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: InputDecoration(
                    hintText: 'Cari tugas atau ID tiket...',
                    hintStyle: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade400,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.grey.shade400,
                      size: 20 * _phi,
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    contentPadding: EdgeInsets.symmetric(vertical: 8 * _phi),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12 * _phi),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                SizedBox(height: 12 * _phi),
                SizedBox(
                  height: 24 * _phi,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: const [
                      'Semua',
                      'Baru',
                      'Progress',
                      'Terkendala',
                      'Selesai',
                    ].length,
                    separatorBuilder: (_, _) => SizedBox(width: 8 * _phi),
                    itemBuilder: (context, index) {
                      const statuses = [
                        'Semua',
                        'Baru',
                        'Progress',
                        'Terkendala',
                        'Selesai',
                      ];
                      final status = statuses[index];
                      final isSelected = _selectedStatus == status;
                      return FilterChip(
                        label: Text(status),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() => _selectedStatus = status);
                          }
                        },
                        selectedColor: red.withValues(alpha: 0.15),
                        backgroundColor: Colors.white,
                        showCheckmark: false,
                        avatar: Icon(
                          _statusIcon(status),
                          size: 16,
                          color: isSelected ? red : Colors.black38,
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 8 * _phi),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8 * _phi),
                          side: BorderSide(
                            color: isSelected ? red : Colors.grey.shade200,
                          ),
                        ),
                        labelStyle: TextStyle(
                          color: isSelected ? red : Colors.black54,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.w500,
                          fontSize: 12,
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 12 * _phi),
                // Month Filter
                SizedBox(
                  height: 24 * _phi,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _months.length,
                    separatorBuilder: (_, _) => SizedBox(width: 8 * _phi),
                    itemBuilder: (context, index) {
                      final month = _months[index];
                      final isSelected = _selectedMonth == month;
                      return ChoiceChip(
                        label: Text(month),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) setState(() => _selectedMonth = month);
                        },
                        selectedColor: red.withValues(alpha: 0.15),
                        backgroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 8 * _phi),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8 * _phi),
                          side: BorderSide(
                            color: isSelected ? red : Colors.grey.shade200,
                          ),
                        ),
                        labelStyle: TextStyle(
                          color: isSelected ? red : Colors.black54,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.w500,
                          fontSize: 12,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // ── Task List ──────────────────────────────────────────
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : filteredTasks.isEmpty
                ? Center(
                    child: Text(
                      'Tidak ada tugas ditemukan.',
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.all(16 * _phi),
                    itemCount: filteredTasks.length,
                    itemBuilder: (context, index) =>
                        _AssignedTaskCard(task: filteredTasks[index]),
                  ),
          ),
        ],
      ),
    );
  }
}

class _AssignedTaskCard extends StatelessWidget {
  final Map<String, dynamic> task;

  const _AssignedTaskCard({required this.task});

  static const double _phi = 1.61803398875;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 12 * _phi),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(16 * _phi),
        title: Text(
          '${task['id']} - ${task['title']}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 6 * _phi),
            Text(
              'Lokasi: ${task['location']}',
              style: const TextStyle(fontSize: 12, color: Colors.black87),
            ),
            if (task['room_detail'].toString().isNotEmpty) ...[
              SizedBox(height: 4 * _phi),
              Text(
                'Detail: ${task['room_detail']}',
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _statusColor(task['status']).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            task['status'],
            style: TextStyle(
              color: _statusColor(task['status']),
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TaskDetailPage(task: task)),
          );
        },
      ),
    );
  }

  Color _statusColor(Object? status) {
    return switch (status?.toString()) {
      'Baru' => const Color(0xFFF97316),
      'Progress' => const Color(0xFF2563EB),
      'Terkendala' => const Color(0xFFDC2626),
      'Selesai' => const Color(0xFF16A34A),
      _ => const Color(0xFF6B7280),
    };
  }
}
