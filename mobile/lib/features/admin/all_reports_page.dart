import 'package:flutter/material.dart';
import '../../data/api_service.dart';
import '../../providers/report_provider.dart';

class ReportData {
  final String id;
  final String title;
  final String category;
  final String requester;
  final String update;
  final String status;
  final String description;
  final String staffUpdate;

  const ReportData({
    required this.id,
    required this.title,
    required this.category,
    required this.requester,
    required this.update,
    required this.status,
    this.description = '',
    this.staffUpdate = '',
  });
}

class AllReportsPage extends StatefulWidget {
  const AllReportsPage({super.key});

  @override
  State<AllReportsPage> createState() => _AllReportsPageState();
}

class _AllReportsPageState extends State<AllReportsPage> {
  final List<ReportData> _databaseReports = [];
  String _selectedFilter = 'Semua';

  final List<String> _filterOptions = [
    'Semua',
    'Menunggu',
    'Diproses',
    'Selesai',
  ];

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    final result = await ApiService.getReports();
    if (!mounted || result['success'] != true) return;
    setState(() {
      _databaseReports
        ..clear()
        ..addAll(
          (result['data'] as List).map((item) {
            final report = Map<String, dynamic>.from(item as Map);
            final user = Map<String, dynamic>.from(
              report['user'] as Map? ?? {},
            );
            final taskUpdates = report['task']?['updates'] as List? ?? [];
            final latestUpdate = taskUpdates.isNotEmpty
                ? taskUpdates.last['notes']?.toString() ?? ''
                : '';
            return ReportData(
              id: report['ticket_number']?.toString() ?? '-',
              title: report['title']?.toString() ?? '-',
              category:
                  report['facility']?['name']?.toString() ??
                  report['category']?.toString() ??
                  '-',
              requester: user['name']?.toString() ?? '-',
              update: report['created_at']?.toString() ?? '-',
              status: Report.statusLabel(report['status']?.toString()),
              description: report['description']?.toString() ?? '',
              staffUpdate: latestUpdate,
            );
          }),
        );
    });
  }

  List<ReportData> get _filteredReports {
    if (_selectedFilter == 'Semua') return _databaseReports;
    return _databaseReports.where((r) => r.status == _selectedFilter).toList();
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'menunggu':
        return const Color(0xFFF97316);
      case 'diproses':
        return const Color(0xFFEAB308);
      case 'selesai':
        return const Color(0xFF16A34A);
      case 'ditolak':
        return Colors.red;
      default:
        return const Color(0xFF6B7280);
    }
  }

  IconData _statusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'menunggu':
        return Icons.pending_actions_outlined;
      case 'diproses':
        return Icons.sync_outlined;
      case 'selesai':
        return Icons.check_circle_outline;
      case 'ditolak':
        return Icons.cancel_outlined;
      default:
        return Icons.help_outline;
    }
  }

  void _showDetailDialog(ReportData report) {
    final red = Colors.red.shade800;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        contentPadding: EdgeInsets.zero,
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.red.shade900, Colors.red.shade700],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(18),
                    topRight: Radius.circular(18),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      report.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        report.status,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Body
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _DetailRow(
                      icon: Icons.tag,
                      label: 'ID Tiket',
                      value: report.id,
                    ),
                    _DetailRow(
                      icon: Icons.category_outlined,
                      label: 'Kategori',
                      value: report.category,
                    ),
                    _DetailRow(
                      icon: Icons.person_outline,
                      label: 'Pelapor',
                      value: report.requester,
                    ),
                    _DetailRow(
                      icon: Icons.access_time,
                      label: 'Tanggal',
                      value: report.update,
                    ),
                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 8),
                    const Text(
                      'Deskripsi Laporan:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      report.description.isNotEmpty
                          ? report.description
                          : 'Tidak ada deskripsi',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                      ),
                    ),
                    if (report.staffUpdate.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      const Divider(),
                      const SizedBox(height: 8),
                      const Text(
                        'Update Staff:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        report.staffUpdate,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Tutup', style: TextStyle(color: red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final red = Colors.red.shade800;
    final filtered = _filteredReports;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: red,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Semua Laporan',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadReports,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.red.shade900, Colors.red.shade700],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.list_alt, color: Colors.white, size: 28),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${filtered.length} Laporan Ditampilkan',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      'Total ${_databaseReports.length} laporan tersedia',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _filterOptions.map((filter) {
                  final isSelected = _selectedFilter == filter;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedFilter = filter),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? red : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? red : Colors.black26,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: red.withOpacity(0.3),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : [],
                      ),
                      child: Text(
                        filter,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : Colors.black54,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.inbox_outlined,
                          size: 64,
                          color: Colors.black26,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Tidak ada laporan "$_selectedFilter"',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black45,
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadReports,
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final r = filtered[index];
                        final statusColor = _statusColor(r.status);
                        final statusIcon = _statusIcon(r.status);

                        return GestureDetector(
                          onTap: () => _showDetailDialog(r),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 10),
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
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              leading: CircleAvatar(
                                backgroundColor: red.withOpacity(0.1),
                                child: Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: red,
                                  ),
                                ),
                              ),
                              title: Text(
                                r.title,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                    '#${r.id} • ${r.category}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  Text(
                                    'Pelapor: ${r.requester}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.black45,
                                    ),
                                  ),
                                  Text(
                                    'Update: ${r.update}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.black38,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      statusIcon,
                                      size: 14,
                                      color: statusColor,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      r.status,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: statusColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.black45),
          const SizedBox(width: 6),
          Text(
            '$label: ',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}
