import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

import 'report_create_page.dart';
import 'report_detail_page.dart';

/// Model sederhana untuk laporan (feed/forum)
class Report {
  final String id;
  final String title;
  final String description;
  final String location;
  final String category;
  final String status; // Menunggu, Diproses, Selesai
  final String createdBy;
  final List<String> likedBy; // User IDs yang sudah support/like
  final String staffName;
  final String staffFeedback;
  final bool needsReporterFeedback;
  final int? reporterRating;
  final String reporterFeedback;
  final DateTime createdAt;
  final List<String> photoPaths;

  Report({
    required this.id,
    required this.title,
    required this.description,
    required this.location,
    required this.category,
    required this.status,
    required this.createdBy,
    required this.likedBy,
    required this.staffName,
    required this.staffFeedback,
    this.needsReporterFeedback = false,
    this.reporterRating,
    this.reporterFeedback = '',
    required this.createdAt,
    this.photoPaths = const [],
  });

  // Helper method untuk copy dengan likedBy yang baru
  Report copyWith({
    List<String>? likedBy,
    bool? needsReporterFeedback,
    int? reporterRating,
    String? reporterFeedback,
  }) {
    return Report(
      id: id,
      title: title,
      description: description,
      location: location,
      category: category,
      status: status,
      createdBy: createdBy,
      likedBy: likedBy ?? this.likedBy,
      staffName: staffName,
      staffFeedback: staffFeedback,
      needsReporterFeedback:
          needsReporterFeedback ?? this.needsReporterFeedback,
      reporterRating: reporterRating ?? this.reporterRating,
      reporterFeedback: reporterFeedback ?? this.reporterFeedback,
      createdAt: createdAt,
      photoPaths: photoPaths,
    );
  }

  int get likes => likedBy.length;
  String? get coverPhotoPath =>
      photoPaths.isEmpty ? null : photoPaths.first;
}

class ReportRepository {
  static final List<Report> _reports = List.of(_dummyReports);

  static List<Report> getAll() => List.unmodifiable(_reports);

  static void add(Report report) {
    _reports.insert(0, report);
  }

  static void updateLikes(String id, List<String> likedBy) {
    final index = _reports.indexWhere((r) => r.id == id);
    if (index == -1) return;
    _reports[index] = _reports[index].copyWith(likedBy: likedBy);
  }

  static void submitReporterFeedback({
    required String reportId,
    required int rating,
    required String feedback,
  }) {
    final index = _reports.indexWhere((r) => r.id == reportId);
    if (index == -1) return;
    _reports[index] = _reports[index].copyWith(
      needsReporterFeedback: false,
      reporterRating: rating,
      reporterFeedback: feedback.trim(),
    );
  }

  static List<Report> getByUser(String userId) {
    return _reports.where((r) => r.createdBy == userId).toList();
  }
}

class ReportFeedPage extends StatefulWidget {
  const ReportFeedPage({super.key});

  @override
  State<ReportFeedPage> createState() => _ReportFeedPageState();
}

class _ReportFeedPageState extends State<ReportFeedPage> {
  late List<Report> _reports;
  final String _currentUser = 'mahasiswa_aktif'; // Simulate current logged-in user

  @override
  void initState() {
    super.initState();
    _reports = ReportRepository.getAll();
  }

  void _like(String reportId) {
    final index = _reports.indexWhere((r) => r.id == reportId);
    if (index == -1) return;
    final r = _reports[index];
    final newLikedBy = List<String>.from(r.likedBy);

    if (newLikedBy.contains(_currentUser)) {
      // User sudah like, hapus (unlike)
      newLikedBy.remove(_currentUser);
    } else {
      // User belum like, tambah
      newLikedBy.add(_currentUser);
    }

    final wasLiked = r.likedBy.contains(_currentUser);
    setState(() {
      ReportRepository.updateLikes(r.id, newLikedBy);
      _reports = ReportRepository.getAll();
    });
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(milliseconds: 900),
        content: Text(
          wasLiked ? 'Dukungan dibatalkan.' : 'Terima kasih sudah mendukung laporan ini.',
        ),
      ),
    );
  }

  Future<void> _openCreate() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const ReportCreatePage(currentUser: 'mahasiswa_aktif'),
      ),
    );
    if (!mounted) return;
    setState(() => _reports = ReportRepository.getAll());
  }

  @override
  Widget build(BuildContext context) {
    final topReports = [..._reports]
      ..sort((a, b) {
        final byLikes = b.likes.compareTo(a.likes);
        if (byLikes != 0) return byLikes;
        return b.createdAt.compareTo(a.createdAt);
      });
    final top3 = topReports.take(3).toList();
    final totalDukungan = _reports.fold<int>(0, (sum, r) => sum + r.likes);
    final totalSelesai =
        _reports.where((r) => r.status.toLowerCase() == 'selesai').length;
    final totalDiproses =
        _reports.where((r) => r.status.toLowerCase() == 'diproses').length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.red.shade900, Colors.red.shade700],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        leading: BackButton(color: Colors.white),
        title: const Text('Pengaduan (Timeline)'),
      ),
      body: Column(
        children: [
          _buildHeader(
            top3: top3,
            totalDukungan: totalDukungan,
            totalDiproses: totalDiproses,
            totalSelesai: totalSelesai,
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 90),
              itemCount: _reports.length,
              itemBuilder: (context, i) {
                return _ReportCard(
                  key: ValueKey(_reports[i].id),
                  report: _reports[i],
                  currentUser: _currentUser,
                  onLike: () => _like(_reports[i].id),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.red.shade800,
        onPressed: _openCreate,
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: const Icon(Icons.add),
        label: const Text('Buat Pengaduan'),
      ),
    );
  }

  Widget _buildHeader({
    required List<Report> top3,
    required int totalDukungan,
    required int totalDiproses,
    required int totalSelesai,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: LinearGradient(
                colors: [Colors.red.shade900, Colors.red.shade700],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.shade200.withAlpha((0.6 * 255).round()),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Pantau laporan kampus, beri dukungan, dan bantu percepat tindak lanjut.',
                    style: TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha((0.15 * 255).round()),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.local_fire_department,
                          size: 16, color: Colors.amber.shade300),
                      const SizedBox(width: 4),
                      Text(
                        'Trending',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _StatsChip(
                  icon: Icons.thumb_up_alt_outlined,
                  label: 'Total Dukungan',
                  value: '$totalDukungan',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatsChip(
                  icon: Icons.settings_suggest_outlined,
                  label: 'Diproses',
                  value: '$totalDiproses',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatsChip(
                  icon: Icons.task_alt_outlined,
                  label: 'Selesai',
                  value: '$totalSelesai',
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (top3.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: const Center(
                child: Text(
                  'Belum ada pelaporan yang bisa dirangking.',
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ),
            )
          else
            SizedBox(
              height: 126,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: top3.length,
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (_, i) {
                  final item = top3[i];
                  return _TopReportCard(
                    key: ValueKey('${item.id}-${item.likes}'),
                    report: item,
                    rank: i + 1,
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final Report report;
  final String currentUser;
  final VoidCallback onLike;

  const _ReportCard({
    super.key,
    required this.report,
    required this.currentUser,
    required this.onLike,
  });

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
    final time = _formatTime(report.createdAt);
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => ReportDetailPage(report: report)),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE5E7EB)),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((0.05 * 255).round()),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: const Color(0xFFFEE2E2),
                  foregroundColor: const Color(0xFF991B1B),
                  child: Text(
                    report.createdBy.trim().isEmpty
                        ? '?'
                        : report.createdBy.trim()[0].toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
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
                                fontWeight: FontWeight.w800,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            time,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.black45,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '@${report.createdBy} • ${report.category}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              report.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, color: Color(0xFF4B5563)),
            ),
            if ((report.coverPhotoPath ?? '').trim().isNotEmpty) ...[
              const SizedBox(height: 10),
              _ReportPhoto(photoPath: report.coverPhotoPath!.trim()),
            ],
            const SizedBox(height: 10),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: const Color(0xFFF3F4F6),
                  ),
                  child: Text(
                    report.category,
                    style: const TextStyle(fontSize: 11),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: _statusColor(
                      report.status,
                    ).withAlpha((0.10 * 255).round()),
                  ),
                  child: Text(
                    report.status,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: _statusColor(report.status),
                    ),
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    IconButton(
                      onPressed: onLike,
                      icon: Icon(
                        report.likedBy.contains(currentUser)
                            ? Icons.thumb_up_alt
                            : Icons.thumb_up_alt_outlined,
                        size: 18,
                        color: report.likedBy.contains(currentUser)
                            ? Colors.red.shade800
                            : null,
                      ),
                    ),
                    Text(
                      '${report.likes} dukungan',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
            if (report.staffFeedback.isNotEmpty) ...[
              const Divider(height: 18),
              Text(
                'Update staff: ${report.staffName}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF166534),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                report.staffFeedback,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatsChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatsChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF991B1B)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827),
                  ),
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.black54,
                    fontWeight: FontWeight.w600,
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

class _ReportPhoto extends StatelessWidget {
  final String photoPath;

  const _ReportPhoto({required this.photoPath});

  @override
  Widget build(BuildContext context) {
    final isUrl = photoPath.startsWith('http://') || photoPath.startsWith('https://');
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: isUrl
            ? Image.network(
                photoPath,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _imageFallback(),
              )
            : (!kIsWeb
                  ? Image.file(
                      File(photoPath),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _imageFallback(),
                    )
                  : _imageFallback()),
      ),
    );
  }

  Widget _imageFallback() {
    return Container(
      color: const Color(0xFFF3F4F6),
      alignment: Alignment.center,
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.broken_image_outlined, color: Colors.black38, size: 28),
          SizedBox(height: 6),
          Text(
            'Foto tidak tersedia',
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

class _TopReportCard extends StatelessWidget {
  final Report report;
  final int rank;

  const _TopReportCard({
    super.key,
    required this.report,
    required this.rank,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 235,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          colors: [Colors.red.shade800, Colors.red.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha((0.2 * 255).round()),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Top $rank',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              const Icon(Icons.thumb_up_alt_rounded,
                  size: 16, color: Colors.white),
              const SizedBox(width: 4),
              Text(
                '${report.likes}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            report.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
          const Spacer(),
          Text(
            '@${report.createdBy}',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

final List<Report> _dummyReports = [
  Report(
    id: 'REP-20260406-193000',
    title: 'Lampu Koridor Gedung B Lantai 3 Mati',
    description:
        'Sejak dua hari terakhir, lampu di koridor lantai 3 Gedung B mati total. Koridor jadi gelap dan berisiko.',
    location: 'Gedung B, Lantai 3, Koridor Timur',
    category: 'Penerangan',
    status: 'Diproses',
    createdBy: 'mahasiswa_2023',
    likedBy: ['mahasiswa_2024', 'dosen_01', 'mahasiswa_2025'],
    staffName: 'Pak Arif (Teknisi Listrik)',
    staffFeedback:
        'Tim sudah cek awal. Pergantian komponen dilakukan malam ini di luar jam kuliah.',
    needsReporterFeedback: false,
    createdAt: DateTime(2026, 4, 6, 19, 30),
    photoPaths: const [
      'https://images.unsplash.com/photo-1524230572899-a752b3835840?auto=format&fit=crop&w=1200&q=80',
      'https://images.unsplash.com/photo-1497366754035-f200968a6e72?auto=format&fit=crop&w=1200&q=80',
    ],
  ),
  Report(
    id: 'REP-20260405-091500',
    title: 'AC Ruang Kelas 204 Tidak Dingin',
    description:
        'AC di ruang 204 hanya mengeluarkan angin tanpa dingin, mengganggu kenyamanan belajar.',
    location: 'Gedung A, Ruang 204',
    category: 'Kenyamanan Ruangan',
    status: 'Menunggu',
    createdBy: 'bima.putra',
    likedBy: ['mahasiswa_2024', 'mahasiswa_aktif'],
    staffName: '',
    staffFeedback: '',
    needsReporterFeedback: false,
    createdAt: DateTime(2026, 4, 5, 9, 15),
    photoPaths: const [
      'https://images.unsplash.com/photo-1517022812141-23620dba5c23?auto=format&fit=crop&w=1200&q=80',
    ],
  ),
  Report(
    id: 'REP-20260403-144500',
    title: 'Kursi Rusak di Perpustakaan Utama',
    description:
        'Beberapa kursi di area baca lantai 2 perpustakaan tidak layak pakai (kaki patah).',
    location: 'Perpustakaan Utama, Lantai 2',
    category: 'Furnitur',
    status: 'Selesai',
    createdBy: 'salsa_19',
    likedBy: ['mahasiswa_2023', 'mahasiswa_2024', 'mahasiswa_2025', 'dosen_01'],
    staffName: 'Bu Rina (Koordinator Perpus)',
    staffFeedback:
        'Sudah diganti 5 kursi. Mohon info lagi bila ada kursi lain yang rusak.',
    needsReporterFeedback: false,
    createdAt: DateTime(2026, 4, 3, 14, 45),
    photoPaths: const [
      'https://images.unsplash.com/photo-1497366754035-f200968a6e72?auto=format&fit=crop&w=1200&q=80',
      'https://images.unsplash.com/photo-1524995997946-a1c2e315a42f?auto=format&fit=crop&w=1200&q=80',
    ],
  ),
  Report(
    id: 'REP-20260408-101000',
    title: 'Kabel LAN Lab Komputer Terputus',
    description:
        'Koneksi internet di 10 PC baris tengah sering putus karena kabel LAN longgar/terputus.',
    location: 'Lab Komputer 2, Gedung D',
    category: 'Internet & Jaringan',
    status: 'Menunggu',
    createdBy: 'mahasiswa_aktif',
    likedBy: ['mahasiswa_2024'],
    staffName: '',
    staffFeedback: '',
    needsReporterFeedback: false,
    createdAt: DateTime(2026, 4, 8, 10, 10),
  ),
  Report(
    id: 'REP-20260407-083000',
    title: 'Pintu Toilet Pria Lantai 1 Sulit Ditutup',
    description:
        'Engsel pintu sudah turun sehingga pintu seret dan tidak bisa tertutup rapat.',
    location: 'Gedung C, Toilet Pria Lantai 1',
    category: 'Sanitasi',
    status: 'Diproses',
    createdBy: 'mahasiswa_aktif',
    likedBy: ['mahasiswa_2023', 'dosen_02'],
    staffName: 'Pak Dimas (Teknisi Umum)',
    staffFeedback: 'Engsel sedang dipesan, estimasi pemasangan besok pagi.',
    needsReporterFeedback: false,
    createdAt: DateTime(2026, 4, 7, 8, 30),
  ),
  Report(
    id: 'REP-20260401-160500',
    title: 'Proyektor Ruang Sidang Buram',
    description:
        'Output proyektor kurang fokus dan warna pudar, mengganggu presentasi kelas.',
    location: 'Ruang Sidang Fakultas Teknik',
    category: 'Fasilitas Belajar',
    status: 'Selesai',
    createdBy: 'mahasiswa_aktif',
    likedBy: ['mahasiswa_2023', 'mahasiswa_2024', 'dosen_01'],
    staffName: 'Bu Sinta (Tim Multimedia)',
    staffFeedback:
        'Lensa sudah dibersihkan dan lampu proyektor diganti. Mohon konfirmasi hasilnya.',
    needsReporterFeedback: true,
    createdAt: DateTime(2026, 4, 1, 16, 5),
  ),
];

String _formatTime(DateTime dt) {
  final hh = dt.hour.toString().padLeft(2, '0');
  final mm = dt.minute.toString().padLeft(2, '0');
  return '$hh:$mm';
}
