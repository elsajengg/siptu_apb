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
    required this.createdAt,
    this.photoPaths = const [],
  });

  // Helper method untuk copy dengan likedBy yang baru
  Report copyWith({List<String>? likedBy}) {
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

  void _like(int index) {
    final r = _reports[index];
    final newLikedBy = List<String>.from(r.likedBy);

    if (newLikedBy.contains(_currentUser)) {
      // User sudah like, hapus (unlike)
      newLikedBy.remove(_currentUser);
    } else {
      // User belum like, tambah
      newLikedBy.add(_currentUser);
    }

    setState(() {
      _reports[index] = r.copyWith(likedBy: newLikedBy);
    });
    ReportRepository.updateLikes(r.id, newLikedBy);
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
    final topReports = [..._reports]..sort((a, b) => b.likes.compareTo(a.likes));
    final top3 = topReports.take(3).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red.shade800,
        foregroundColor: Colors.white,
        title: const Text('Pengaduan (Timeline)'),
      ),
      body: Column(
        children: [
          _buildHeader(top3),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              itemCount: _reports.length,
              itemBuilder: (context, i) {
                return _ReportCard(report: _reports[i], onLike: () => _like(i));
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.red.shade800,
        onPressed: _openCreate,
        icon: const Icon(Icons.add),
        label: const Text('Buat Pengaduan'),
      ),
    );
  }

  Widget _buildHeader(List<Report> top3) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      color: const Color(0xFFF8FAFC),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Pantau semua pengaduan, beri dukungan, dan lihat progress terbaru secara real-time.',
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.local_fire_department,
                          size: 16, color: Color(0xFFB91C1C)),
                      SizedBox(width: 4),
                      Text(
                        'Trending',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFB91C1C),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 122,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: top3.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (_, i) {
                final item = top3[i];
                return _TopReportCard(report: item, rank: i + 1);
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
                // Cek apakah user sudah like
                StatefulBuilder(
                  builder: (context, setButtonState) {
                    final isLiked =
                        report.likedBy.contains('mahasiswa_aktif');
                    return Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            onLike();
                            setButtonState(() {});
                          },
                          icon: Icon(
                            isLiked
                                ? Icons.thumb_up_alt
                                : Icons.thumb_up_alt_outlined,
                            size: 18,
                            color: isLiked ? Colors.red.shade800 : null,
                          ),
                        ),
                        Text(
                          '${report.likes} dukungan',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    );
                  },
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

  const _TopReportCard({required this.report, required this.rank});

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
    createdAt: DateTime(2026, 4, 3, 14, 45),
    photoPaths: const [
      'https://images.unsplash.com/photo-1497366754035-f200968a6e72?auto=format&fit=crop&w=1200&q=80',
      'https://images.unsplash.com/photo-1524995997946-a1c2e315a42f?auto=format&fit=crop&w=1200&q=80',
    ],
  ),
];

String _formatTime(DateTime dt) {
  final hh = dt.hour.toString().padLeft(2, '0');
  final mm = dt.minute.toString().padLeft(2, '0');
  return '$hh:$mm';
}
