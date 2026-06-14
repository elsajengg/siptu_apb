import 'package:flutter/material.dart';
import '../../data/api_service.dart';
import '../../providers/report_provider.dart';

// ── Model data laporan ────────────────────────────────────────
class ReportData {
  final String id;
  final String title;
  final String category;
  final String requester;
  final String update;
  final String status;

  const ReportData({
    required this.id,
    required this.title,
    required this.category,
    required this.requester,
    required this.update,
    required this.status,
  });
}

class AllReportsPage extends StatefulWidget {
  const AllReportsPage({super.key});

  @override
  State<AllReportsPage> createState() => _AllReportsPageState();
}

class _AllReportsPageState extends State<AllReportsPage> {
  final List<ReportData> _databaseReports = [];

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
            return ReportData(
              id: report['ticket_number']?.toString() ?? '-',
              title: report['title']?.toString() ?? '-',
              category: report['category']?.toString() ?? '-',
              requester: user['name']?.toString() ?? '-',
              update: report['created_at']?.toString() ?? '-',
              status: Report.statusLabel(report['status']?.toString()),
            );
          }),
        );
    });
  }

  // Filter yang aktif
  String _selectedFilter = 'Semua';

  final List<String> _filterOptions = [
    'Semua',
    'Menunggu',
    'Diproses',
    'Selesai',
  ];

  // Data semua laporan (sesuaikan dengan data asli kamu nanti)
  final List<ReportData> _allReports = const [
    ReportData(
      id: 'TIK-202604-001',
      title: 'Lampu Koridor Gedung B Lantai 3 Mati',
      category: 'Penerangan',
      requester: 'mahasiswa_2023',
      update: '06 Apr 2026 19:30',
      status: 'Diproses',
    ),
    ReportData(
      id: 'TIK-202604-002',
      title: 'AC Ruang Kelas 204 Tidak Dingin',
      category: 'Kenyamanan Ruangan',
      requester: 'bima.putra',
      update: '05 Apr 2026 09:15',
      status: 'Menunggu',
    ),
    ReportData(
      id: 'TIK-202604-003',
      title: 'Kursi Rusak di Perpustakaan Utama',
      category: 'Furnitur',
      requester: 'salsa_19',
      update: '03 Apr 2026 14:45',
      status: 'Selesai',
    ),
    ReportData(
      id: 'TIK-202604-004',
      title: 'Keran Air Bocor di Toilet Lantai 1',
      category: 'Sanitasi',
      requester: 'agung.pratama',
      update: '07 Apr 2026 08:10',
      status: 'Diproses',
    ),
    ReportData(
      id: 'TIK-202604-005',
      title: 'Proyektor Ruang 305 Tidak Menyala',
      category: 'Elektronik',
      requester: 'dosen_ti',
      update: '07 Apr 2026 10:00',
      status: 'Menunggu',
    ),
    ReportData(
      id: 'TIK-202604-006',
      title: 'Toilet Lantai 2 Gedung A Tersumbat',
      category: 'Sanitasi',
      requester: 'budi_23',
      update: '06 Apr 2026 13:20',
      status: 'Menunggu',
    ),
    ReportData(
      id: 'TIK-202604-007',
      title: 'Lampu Parkiran Gedung C Mati',
      category: 'Penerangan',
      requester: 'siti.rahma',
      update: '05 Apr 2026 18:45',
      status: 'Selesai',
    ),
    ReportData(
      id: 'TIK-202604-008',
      title: 'Kaca Jendela Ruang 101 Retak',
      category: 'Infrastruktur',
      requester: 'andi.wijaya',
      update: '04 Apr 2026 11:30',
      status: 'Diproses',
    ),
    ReportData(
      id: 'TIK-202604-009',
      title: 'Stop Kontak Lab Komputer Rusak',
      category: 'Elektronik',
      requester: 'lab_komputer',
      update: '03 Apr 2026 09:00',
      status: 'Selesai',
    ),
    ReportData(
      id: 'TIK-202604-010',
      title: 'Pintu Kelas 203 Susah Dibuka',
      category: 'Infrastruktur',
      requester: 'rini.anggraini',
      update: '02 Apr 2026 14:00',
      status: 'Selesai',
    ),
    ReportData(
      id: 'TIK-202604-011',
      title: 'Wastafel Kantin Lantai 1 Mampet',
      category: 'Sanitasi',
      requester: 'kantin_01',
      update: '01 Apr 2026 08:30',
      status: 'Menunggu',
    ),
    ReportData(
      id: 'TIK-202604-012',
      title: 'Papan Tulis Ruang 305 Tidak Bisa Dihapus',
      category: 'Furnitur',
      requester: 'dosen_fisika',
      update: '01 Apr 2026 07:55',
      status: 'Diproses',
    ),
  ];

  // Getter — return laporan sesuai filter aktif
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
      default:
        return Icons.help_outline;
    }
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
      ),
      body: Column(
        children: [
          // ── Banner info jumlah ────────────────────────────
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

          // ── Filter chips ──────────────────────────────────
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

          // ── List laporan ──────────────────────────────────
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
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final r = filtered[index];
                      final statusColor = _statusColor(r.status);
                      final statusIcon = _statusIcon(r.status);

                      return Container(
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
                                Icon(statusIcon, size: 14, color: statusColor),
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
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
