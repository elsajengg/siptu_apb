import 'package:flutter/material.dart';

/// Model sederhana untuk laporan (feed/forum)
class Report {
  final String title;
  final String description;
  final String location;
  final String category;
  final String status; // Menunggu, Diproses, Selesai
  final String createdBy;
  final int likes;
  final String staffName;
  final String staffFeedback;
  final DateTime createdAt;

  Report({
    required this.title,
    required this.description,
    required this.location,
    required this.category,
    required this.status,
    required this.createdBy,
    required this.likes,
    required this.staffName,
    required this.staffFeedback,
    required this.createdAt,
  });
}

class ReportFeedPage extends StatefulWidget {
  const ReportFeedPage({super.key});

  @override
  State<ReportFeedPage> createState() => _ReportFeedPageState();
}

class _ReportFeedPageState extends State<ReportFeedPage> {
  late List<Report> _reports;

  @override
  void initState() {
    super.initState();
    _reports = List.of(_dummyReports);
  }

  void _like(int index) {
    final r = _reports[index];
    setState(() {
      _reports[index] = Report(
        title: r.title,
        description: r.description,
        location: r.location,
        category: r.category,
        status: r.status,
        createdBy: r.createdBy,
        likes: r.likes + 1,
        staffName: r.staffName,
        staffFeedback: r.staffFeedback,
        createdAt: r.createdAt,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red.shade800,
        title: const Text('Forum Laporan'),
      ),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              itemCount: _reports.length,
              itemBuilder: (context, i) {
                return _ReportCard(
                  report: _reports[i],
                  onLike: () => _like(i),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.red.shade800,
        onPressed: () => _comingSoon(context),
        icon: const Icon(Icons.add),
        label: const Text('Buat Laporan'),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      color: Colors.white,
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'Konsep forum: laporan bisa dilihat pengguna lain dan mendapat dukungan (upvote).',
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFEE2E2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: const [
                Icon(Icons.trending_up, size: 16, color: Color(0xFFB91C1C)),
                SizedBox(width: 4),
                Text(
                  'Trending',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFB91C1C),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _comingSoon(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Buat Laporan'),
        content: const Text('Form pelaporan (placeholder).'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final Report report;
  final VoidCallback onLike;

  const _ReportCard({required this.report, required this.onLike});

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

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showDetail(context),
      borderRadius: BorderRadius.circular(16),
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
            )
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
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: _statusColor(report.status).withOpacity(0.12),
                  ),
                  child: Text(
                    report.status,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _statusColor(report.status),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              report.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, color: Color(0xFF4B5563)),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.place, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    report.location,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: const Color(0xFFF3F4F6),
                  ),
                  child: Text(
                    report.category,
                    style: const TextStyle(fontSize: 11),
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: onLike,
                  icon: const Icon(Icons.thumb_up_alt_outlined, size: 18),
                ),
                Text(
                  '${report.likes} dukungan',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
            const Divider(height: 18),
            if (report.staffFeedback.isNotEmpty)
              Text(
                'Feedback staff: ${report.staffName}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF166534),
                ),
              )
            else
              const Text(
                'Belum ada feedback dari staff.',
                style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
              ),
          ],
        ),
      ),
    );
  }

  void _showDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                Text(
                  report.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(report.description),
                const SizedBox(height: 12),
                Text('Lokasi: ${report.location}'),
                const SizedBox(height: 6),
                Text('Kategori: ${report.category}'),
                const SizedBox(height: 6),
                Text('Status: ${report.status}'),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                const Text(
                  'Feedback Staff',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                if (report.staffFeedback.isNotEmpty)
                  Text('${report.staffName}\n${report.staffFeedback}')
                else
                  const Text('Belum ada feedback dari staff.'),
              ],
            ),
          ),
        );
      },
    );
  }
}

final List<Report> _dummyReports = [
  Report(
    title: 'Lampu Koridor Gedung B Lantai 3 Mati',
    description:
        'Sejak dua hari terakhir, lampu di koridor lantai 3 Gedung B mati total. Koridor jadi gelap dan berisiko.',
    location: 'Gedung B, Lantai 3, Koridor Timur',
    category: 'Penerangan',
    status: 'Diproses',
    createdBy: 'mahasiswa_2023',
    likes: 32,
    staffName: 'Pak Arif (Teknisi Listrik)',
    staffFeedback:
        'Tim sudah cek awal. Pergantian komponen dilakukan malam ini di luar jam kuliah.',
    createdAt: DateTime(2026, 4, 6, 19, 30),
  ),
  Report(
    title: 'AC Ruang Kelas 204 Tidak Dingin',
    description:
        'AC di ruang 204 hanya mengeluarkan angin tanpa dingin, mengganggu kenyamanan belajar.',
    location: 'Gedung A, Ruang 204',
    category: 'Kenyamanan Ruangan',
    status: 'Menunggu',
    createdBy: 'bima.putra',
    likes: 18,
    staffName: '',
    staffFeedback: '',
    createdAt: DateTime(2026, 4, 5, 9, 15),
  ),
  Report(
    title: 'Kursi Rusak di Perpustakaan Utama',
    description:
        'Beberapa kursi di area baca lantai 2 perpustakaan tidak layak pakai (kaki patah).',
    location: 'Perpustakaan Utama, Lantai 2',
    category: 'Furnitur',
    status: 'Selesai',
    createdBy: 'salsa_19',
    likes: 25,
    staffName: 'Bu Rina (Koordinator Perpus)',
    staffFeedback:
        'Sudah diganti 5 kursi. Mohon info lagi bila ada kursi lain yang rusak.',
    createdAt: DateTime(2026, 4, 3, 14, 45),
  ),
];

