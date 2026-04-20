import '../models/report.dart';

/// Data contoh untuk feed (butuh internet agar foto URL tampil).
final List<Report> kReportDummyList = [
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
    images: [
      'https://picsum.photos/seed/siptu-lamp/900/520',
      'https://picsum.photos/seed/siptu-lamp2/900/520',
    ],
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
    images: [
      'https://picsum.photos/seed/siptu-ac/900/520',
    ],
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
    images: [
      'https://picsum.photos/seed/siptu-chair/900/520',
      'https://picsum.photos/seed/siptu-chair2/900/520',
      'https://picsum.photos/seed/siptu-chair3/900/520',
    ],
  ),
];
