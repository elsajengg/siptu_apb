import 'package:flutter/material.dart';
import 'update_status.dart';
import 'task_detail_page.dart';

class AssignedTasksPage extends StatefulWidget {
  const AssignedTasksPage({super.key});

  @override
  State<AssignedTasksPage> createState() => _AssignedTasksPageState();
}

class _AssignedTasksPageState extends State<AssignedTasksPage> {
  static const double _phi = 1.61803398875;
  
  String _searchQuery = '';
  String _selectedMonth = 'Semua';

  final List<String> _months = [
    'Semua', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
  ];

  // Dummy tasks with months to demonstrate filtering
  final List<Map<String, dynamic>> _allTasks = List.generate(20, (index) {
    final monthIndex = (index % 12);
    final months = ['Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];
    return {
      'id': '#TGS-${101 + index}',
      'title': 'Perbaikan Fasilitas ${index % 3 == 0 ? 'AC' : 'Listrik'}',
      'location': 'Gedung Kuliah Utama, Lantai ${index % 4 + 1}',
      'deadline': '${(index * 2) % 28 + 1} ${months[monthIndex]} 2026',
      'month': months[monthIndex],
      'status': index % 5 == 0 ? 'Baru' : 'Diproses',
    };
  });

  @override
  Widget build(BuildContext context) {
    final red = Colors.red.shade800;

    // Filter logic
    final filteredTasks = _allTasks.where((task) {
      final matchesSearch = task['title'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) || 
                            task['id'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesMonth = _selectedMonth == 'Semua' || task['month'] == _selectedMonth;
      return matchesSearch && matchesMonth;
    }).toList();

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
            padding: EdgeInsets.fromLTRB(16 * _phi, 16 * _phi, 16 * _phi, 8 * _phi),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  onChanged: (value) => setState(() => _searchQuery = value),
                  decoration: InputDecoration(
                    hintText: 'Cari tugas atau ID tiket...',
                    hintStyle: TextStyle(fontSize: 14, color: Colors.grey.shade400),
                    prefixIcon: Icon(Icons.search, color: Colors.grey.shade400, size: 20 * _phi),
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
                // Month Filter
                SizedBox(
                  height: 24 * _phi,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _months.length,
                    separatorBuilder: (_, __) => SizedBox(width: 8 * _phi),
                    itemBuilder: (context, index) {
                      final month = _months[index];
                      final isSelected = _selectedMonth == month;
                      return ChoiceChip(
                        label: Text(month),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) setState(() => _selectedMonth = month);
                        },
                        selectedColor: red.withOpacity(0.15),
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
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
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
            child: filteredTasks.isEmpty 
              ? Center(
                  child: Text(
                    'Tidak ada tugas ditemukan.',
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(16 * _phi),
                  itemCount: filteredTasks.length,
                  itemBuilder: (context, index) {
                    final task = filteredTasks[index];
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
                            SizedBox(height: 4 * _phi),
                            Row(
                              children: [
                                  Icon(Icons.calendar_today, size: 12, color: Colors.black45),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Deadline: ${task['deadline']}', 
                                    style: const TextStyle(fontSize: 11, color: Colors.black54)
                                  ),
                              ],
                            ),
                          ],
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: task['status'] == 'Baru' ? Colors.orange.shade50 : Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            task['status'],
                            style: TextStyle(
                              color: task['status'] == 'Baru' ? Colors.orange.shade800 : Colors.blue.shade800, 
                              fontSize: 11, 
                              fontWeight: FontWeight.bold
                            ),
                          ),
                        ),
                        onTap: () {
                          if (task['status'] == 'Selesai') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => TaskDetailPage(task: task)),
                            );
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UpdateStatusPage(
                                  taskId: task['id'],
                                  taskTitle: task['title'],
                                  taskLocation: task['location'],
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    );
                  },
                ),
          ),
        ],
      ),
    );
  }
}
