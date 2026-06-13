import 'package:flutter/foundation.dart';

class Report {
  final String id;
  final String title;
  final String description;
  final String location;
  final String category;
  final String status;
  final String createdBy;
  final List<String> likedBy;
  final String staffName;
  final String staffFeedback;
  final bool needsReporterFeedback;
  final int? reporterRating;
  final String reporterFeedback;
  final DateTime createdAt;
  final List<String> photoPaths;
  final List<Uint8List>? photoBytesList; // Added for Web support

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
    this.photoBytesList,
  });

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
      photoBytesList: photoBytesList,
    );
  }

  int get likes => likedBy.length;
  String? get coverPhotoPath => photoPaths.isEmpty ? null : photoPaths.first;
  Uint8List? get coverPhotoBytes => (photoBytesList?.isEmpty ?? true) ? null : photoBytesList!.first;
}

class ReportProvider extends ChangeNotifier {
  List<Report> _reports = List.of(_dummyReports);

  List<Report> get reports => List.unmodifiable(_reports);

  void addReport(Report report) {
    _reports.insert(0, report);
    notifyListeners();
  }

  void toggleLike(String reportId, String userId) {
    final index = _reports.indexWhere((r) => r.id == reportId);
    if (index == -1) return;

    final r = _reports[index];
    final newLikedBy = List<String>.from(r.likedBy);

    if (newLikedBy.contains(userId)) {
      newLikedBy.remove(userId);
    } else {
      newLikedBy.add(userId);
    }

    _reports[index] = r.copyWith(likedBy: newLikedBy);
    notifyListeners();
  }

  void submitReporterFeedback({
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
    notifyListeners();
  }

  List<Report> getByUser(String userId) {
    return _reports.where((r) => r.createdBy == userId).toList();
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
