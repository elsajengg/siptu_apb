import 'package:flutter/material.dart';
import 'task_detail_page.dart';
import '../../data/task_service.dart';
class CompletedTasksPage extends StatelessWidget {
  const CompletedTasksPage({super.key});

  static const double _phi = 1.61803398875;

  List<Map<String, dynamic>> get _allTasks {
    final realTasks = TaskService().completedTasks.map((t) => {
      'id': t.id,
      'title': t.title,
      'location': t.location,
      'date': t.date,
      'status': t.status,
      'note': t.note,
      'localImages': t.images,
    }).toList();

    final mockTasks = [
      {'id': 'TGS-010', 'title': 'Perbaikan AC Ruang 302', 'location': 'Gedung Kuliah Utama, Lt 3', 'date': '21 Apr 2026', 'status': 'Selesai'},
      {'id': 'TGS-008', 'title': 'Ganti Lampu Selasar Barat', 'location': 'Gedung B, Selasar', 'date': '19 Apr 2026', 'status': 'Selesai'},
      {'id': 'TGS-005', 'title': 'Perbaikan Kran Air Toilet', 'location': 'Gedung C, Lantai 1', 'date': '15 Apr 2026', 'status': 'Selesai'},
    ];

    return [...realTasks, ...mockTasks];
  }

  @override
  Widget build(BuildContext context) {
    final red = Colors.red.shade800;
    final tasks = _allTasks;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: red,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: const Text(
          'Riwayat Perbaikan Selesai',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16 * _phi),
        itemCount: tasks.length,
        itemBuilder: (context, index) => _CompletedTaskTile(task: tasks[index], red: red),
      ),
    );
  }
}

class _CompletedTaskTile extends StatelessWidget {
  final Map<String, dynamic> task;
  final Color red;

  const _CompletedTaskTile({required this.task, required this.red});

  static const double _phi = 1.61803398875;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12 * _phi),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(12 * _phi),
        title: Text(
          '${task['id']} - ${task['title']}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            _buildIconText(Icons.location_on_outlined, task['location']),
            const SizedBox(height: 4),
            _buildIconText(Icons.calendar_today_outlined, 'Diselesaikan pada: ${task['date']}'),
          ],
        ),
        trailing: Icon(Icons.chevron_right_rounded, color: red.withValues(alpha: 0.4)),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TaskDetailPage(
                task: task,
                localImages: task['localImages'],
                customNote: task['note'],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildIconText(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.black38),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 12, color: Colors.black54),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
