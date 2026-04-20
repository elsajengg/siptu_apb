/// Tiket laporan masuk (dipakai admin & staff).
class IncomingTicket {
  final String id;
  final String title;
  final String category;
  final String status; // Menunggu, Diproses, Selesai
  final String requester;
  final String lastUpdate;
  /// Login staff yang ditugaskan; null jika belum ditugaskan.
  final String? assignedTo;

  IncomingTicket({
    required this.id,
    required this.title,
    required this.category,
    required this.status,
    required this.requester,
    required this.lastUpdate,
    this.assignedTo,
  });
}

/// Data contoh. Untuk demo tugas staff, login dengan username `staff` (peran Staff).
final List<IncomingTicket> kIncomingTickets = [
  IncomingTicket(
    id: 'TIK-202604-001',
    title: 'Lampu Koridor Gedung B Lantai 3 Mati',
    category: 'Penerangan',
    status: 'Diproses',
    requester: 'mahasiswa_2023',
    lastUpdate: '06 Apr 2026 19:30',
    assignedTo: 'staff',
  ),
  IncomingTicket(
    id: 'TIK-202604-002',
    title: 'AC Ruang Kelas 204 Tidak Dingin',
    category: 'Kenyamanan Ruangan',
    status: 'Menunggu',
    requester: 'bima.putra',
    lastUpdate: '05 Apr 2026 09:15',
    assignedTo: null,
  ),
  IncomingTicket(
    id: 'TIK-202604-003',
    title: 'Kursi Rusak di Perpustakaan Utama',
    category: 'Furnitur',
    status: 'Selesai',
    requester: 'salsa_19',
    lastUpdate: '03 Apr 2026 14:45',
    assignedTo: 'staff2',
  ),
  IncomingTicket(
    id: 'TIK-202604-004',
    title: 'Keran Air Bocor di Toilet Lantai 1',
    category: 'Sanitasi',
    status: 'Diproses',
    requester: 'agung.pratama',
    lastUpdate: '07 Apr 2026 08:10',
    assignedTo: 'staff',
  ),
];
