import 'package:flutter/material.dart';
import 'report_feed_page.dart';
import 'report_detail_page.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final String _currentUser = 'mahasiswa_aktif';
  String _selectedStatus = 'Semua';

  List<Report> get _reports => ReportRepository.getByUser(_currentUser);

  List<Report> get _filteredReports {
    if (_selectedStatus == 'Semua') {
      return _reports;
    }
    return _reports
        .where((r) => r.status == _selectedStatus)
        .toList();
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'diproses':
        return const Color(0xFFF97316);
      case 'selesai':
        return const Color(0xFF16A34A);
      default:
        return const Color(0xFF6B7280);
    }
  }

  Future<void> _openFeedbackDialog(Report report) async {
    int selectedRating = 4;
    final feedbackCtrl = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: const Text('Feedback Pengaju'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Case ini sudah selesai. Berikan penilaian dan masukan untuk petugas.',
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: List.generate(5, (index) {
                      final star = index + 1;
                      return IconButton(
                        onPressed: () => setDialogState(() {
                          selectedRating = star;
                        }),
                        icon: Icon(
                          star <= selectedRating ? Icons.star : Icons.star_border,
                          color: const Color(0xFFF59E0B),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: feedbackCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Tulis feedback singkat...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Nanti'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade800,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Kirim'),
              ),
            ],
          ),
        );
      },
    );
    if (result != true) {
      feedbackCtrl.dispose();
      return;
    }
    ReportRepository.submitReporterFeedback(
      reportId: report.id,
      rating: selectedRating,
      feedback: feedbackCtrl.text,
    );
    feedbackCtrl.dispose();
    if (!mounted) return;
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Feedback berhasil dikirim. Terima kasih.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredReports;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red.shade800,
        title: const Text('Riwayat Laporan Saya'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Filter Status
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: Row(
              children: [
                _buildStatusFilter('Semua', _reports.length),
                const SizedBox(width: 8),
                _buildStatusFilter(
                  'Menunggu',
                  _reports
                      .where((r) => r.status == 'Menunggu')
                      .length,
                ),
                const SizedBox(width: 8),
                _buildStatusFilter(
                  'Diproses',
                  _reports
                      .where((r) => r.status == 'Diproses')
                      .length,
                ),
                const SizedBox(width: 8),
                _buildStatusFilter(
                  'Selesai',
                  _reports
                      .where((r) => r.status == 'Selesai')
                      .length,
                ),
              ],
            ),
          ),
          const Divider(height: 0),
          // List Laporan
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.folder_open_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Tidak ada laporan',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Mulai buat laporan baru',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      return _HistoryCard(
                        report: filtered[index],
                        statusColor: _statusColor(filtered[index].status),
                        onGiveFeedback: () => _openFeedbackDialog(filtered[index]),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusFilter(String status, int count) {
    final isSelected = _selectedStatus == status;
    return GestureDetector(
      onTap: () => setState(() => _selectedStatus = status),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.red.shade800 : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? null
              : Border.all(color: Colors.grey[300]!, width: 1),
        ),
        child: Row(
          children: [
            Text(
              status,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withAlpha((0.3 * 255).round())
                    : Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isSelected ? Colors.white : Colors.black54,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final Report report;
  final Color statusColor;
  final VoidCallback onGiveFeedback;

  const _HistoryCard({
    required this.report,
    required this.statusColor,
    required this.onGiveFeedback,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ReportDetailPage(report: report),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!, width: 1),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        report.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.place,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              report.location,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[700],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withAlpha((0.1 * 255).round()),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    report.status,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(
                    report.description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ID: ${report.id}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.black38,
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      Icons.thumb_up_alt_outlined,
                      size: 14,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${report.likes}',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (report.status == 'Selesai' && report.needsReporterFeedback) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.rate_review_outlined, size: 16, color: Color(0xFF92400E)),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Laporan selesai. Mohon feedback dari pengaju.',
                        style: TextStyle(fontSize: 12, color: Color(0xFF78350F)),
                      ),
                    ),
                    TextButton(
                      onPressed: onGiveFeedback,
                      child: const Text('Beri Feedback'),
                    ),
                  ],
                ),
              ),
            ],
            if (report.status == 'Selesai' && !report.needsReporterFeedback && report.reporterRating != null) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_outline, size: 16, color: Color(0xFF166534)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Feedback terkirim (${report.reporterRating}/5): ${report.reporterFeedback.isEmpty ? "Tanpa catatan" : report.reporterFeedback}',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF166534)),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
