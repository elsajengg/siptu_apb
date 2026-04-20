import 'package:flutter/material.dart';
import 'assign_staff.dart';

class VerifyReportPage extends StatefulWidget {
  const VerifyReportPage({super.key});

  @override
  State<VerifyReportPage> createState() => _VerifyReportPageState();
}

// Model sederhana untuk pengaduan
class ReportItem {
  final String id;
  final String title;
  final String description;
  final String category;
  final String location;
  final String requester;
  final String time;
  final int upvotes;
  String status; // pending, acc, reject

  ReportItem({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.location,
    required this.requester,
    required this.time,
    required this.upvotes,
    this.status = 'pending',
  });
}

class _VerifyReportPageState extends State<VerifyReportPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<ReportItem> _reports = [
    ReportItem(
      id: 'TIK-001',
      title: 'Lampu Koridor Gedung B Lantai 3 Mati',
      description:
          'Lampu di koridor gedung B lantai 3 sudah mati selama 3 hari dan membuat area gelap saat malam.',
      category: 'Penerangan',
      location: 'Gedung B Lantai 3',
      requester: 'Bagus Faaza',
      time: '07 Apr 2026',
      upvotes: 24,
    ),
    ReportItem(
      id: 'TIK-002',
      title: 'AC Ruang Kelas 204 Tidak Dingin',
      description:
          'AC di ruang kelas 204 sudah tidak berfungsi dengan baik sejak seminggu lalu.',
      category: 'Kenyamanan Ruangan',
      location: 'Gedung A Lantai 2',
      requester: 'Elsa Ajeng',
      time: '06 Apr 2026',
      upvotes: 18,
    ),
    ReportItem(
      id: 'TIK-003',
      title: 'Keran Air Bocor di Toilet Lantai 1',
      description:
          'Keran air di toilet lantai 1 bocor dan menyebabkan lantai basah dan licin.',
      category: 'Sanitasi',
      location: 'Gedung C Lantai 1',
      requester: 'Iqbal Hilmi',
      time: '05 Apr 2026',
      upvotes: 12,
    ),
    ReportItem(
      id: 'TIK-004',
      title: 'Kursi Rusak di Perpustakaan Utama',
      description:
          'Beberapa kursi di perpustakaan utama sudah rusak dan tidak layak digunakan.',
      category: 'Furnitur',
      location: 'Perpustakaan Utama',
      requester: 'Mahasiswa_2023',
      time: '04 Apr 2026',
      upvotes: 9,
      status: 'acc',
    ),
    ReportItem(
      id: 'TIK-005',
      title: 'Proyektor Ruang 305 Rusak',
      description:
          'Proyektor di ruang 305 tidak bisa menyala sejak 2 hari lalu.',
      category: 'Elektronik',
      location: 'Gedung B Lantai 3',
      requester: 'Dosen_TI',
      time: '03 Apr 2026',
      upvotes: 7,
      status: 'reject',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<ReportItem> get _pending =>
      _reports.where((r) => r.status == 'pending').toList();
  List<ReportItem> get _acc =>
      _reports.where((r) => r.status == 'acc').toList();
  List<ReportItem> get _reject =>
      _reports.where((r) => r.status == 'reject').toList();

  void _showDetailDialog(ReportItem report) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          report.title,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _DetailRow(icon: Icons.tag, label: 'ID', value: report.id),
              _DetailRow(
                icon: Icons.category_outlined,
                label: 'Kategori',
                value: report.category,
              ),
              _DetailRow(
                icon: Icons.location_on_outlined,
                label: 'Lokasi',
                value: report.location,
              ),
              _DetailRow(
                icon: Icons.person_outline,
                label: 'Pelapor',
                value: report.requester,
              ),
              _DetailRow(
                icon: Icons.access_time,
                label: 'Waktu',
                value: report.time,
              ),
              _DetailRow(
                icon: Icons.thumb_up_outlined,
                label: 'Upvote',
                value: report.upvotes.toString(),
              ),
              const SizedBox(height: 8),
              const Text(
                'Deskripsi:',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              const SizedBox(height: 4),
              Text(
                report.description,
                style: const TextStyle(fontSize: 13, color: Colors.black87),
              ),
            ],
          ),
        ),
        actions: [
          if (report.status == 'pending') ...[
            TextButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _rejectReport(report);
              },
              icon: const Icon(Icons.close, color: Colors.red),
              label: const Text('Tolak', style: TextStyle(color: Colors.red)),
            ),
            FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () {
                Navigator.pop(context);
                _acceptReport(report);
              },
              icon: const Icon(Icons.check),
              label: const Text('Terima'),
            ),
          ] else
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tutup'),
            ),
        ],
      ),
    );
  }

  void _acceptReport(ReportItem report) {
    setState(() => report.status = 'acc');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Pengaduan "${report.title}" diterima!'),
        backgroundColor: Colors.green,
      ),
    );
    // Langsung buka halaman assign staff
    Future.delayed(const Duration(milliseconds: 500), () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => AssignStaffPage(report: report)),
      );
    });
  }

  void _rejectReport(ReportItem report) {
    final reasonCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Alasan Penolakan'),
        content: TextField(
          controller: reasonCtrl,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Masukkan alasan penolakan...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              setState(() => report.status = 'reject');
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Pengaduan "${report.title}" ditolak.'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text('Tolak'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red.shade800,
        elevation: 0,
        title: const Text(
          'Manajemen Pengaduan',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: [
            Tab(text: 'Pending (${_pending.length})'),
            Tab(text: 'Diterima (${_acc.length})'),
            Tab(text: 'Ditolak (${_reject.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildReportList(_pending),
          _buildReportList(_acc),
          _buildReportList(_reject),
        ],
      ),
    );
  }

  Widget _buildReportList(List<ReportItem> reports) {
    if (reports.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 60, color: Colors.black26),
            SizedBox(height: 12),
            Text(
              'Tidak ada pengaduan',
              style: TextStyle(color: Colors.black45),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: reports.length,
      itemBuilder: (context, index) {
        final report = reports[index];
        return _ReportCard(
          report: report,
          onTap: () => _showDetailDialog(report),
          onAccept: report.status == 'pending'
              ? () => _acceptReport(report)
              : null,
          onReject: report.status == 'pending'
              ? () => _rejectReport(report)
              : null,
        );
      },
    );
  }
}

class _ReportCard extends StatelessWidget {
  final ReportItem report;
  final VoidCallback onTap;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;

  const _ReportCard({
    required this.report,
    required this.onTap,
    this.onAccept,
    this.onReject,
  });

  Color get _statusColor {
    switch (report.status) {
      case 'acc':
        return const Color(0xFF16A34A);
      case 'reject':
        return Colors.red;
      default:
        return const Color(0xFFF97316);
    }
  }

  String get _statusLabel {
    switch (report.status) {
      case 'acc':
        return 'Diterima';
      case 'reject':
        return 'Ditolak';
      default:
        return 'Pending';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    report.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: _statusColor.withOpacity(0.12),
                  ),
                  child: Text(
                    _statusLabel,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.category_outlined,
                  size: 14,
                  color: Colors.black45,
                ),
                const SizedBox(width: 4),
                Text(
                  report.category,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
                const SizedBox(width: 12),
                const Icon(
                  Icons.location_on_outlined,
                  size: 14,
                  color: Colors.black45,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    report.location,
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  Icons.thumb_up_outlined,
                  size: 14,
                  color: Colors.black45,
                ),
                const SizedBox(width: 4),
                Text(
                  '${report.upvotes} upvote',
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.access_time, size: 14, color: Colors.black45),
                const SizedBox(width: 4),
                Text(
                  report.time,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
            if (onAccept != null && onReject != null) ...[
              const SizedBox(height: 10),
              const Divider(height: 1),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onReject,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: const Icon(Icons.close, size: 16),
                      label: const Text(
                        'Tolak',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: onAccept,
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: const Icon(Icons.check, size: 16),
                      label: const Text(
                        'Terima',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
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
