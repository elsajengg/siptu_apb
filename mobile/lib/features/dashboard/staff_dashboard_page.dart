import 'package:flutter/material.dart';

import 'ticket_models.dart';

/// Dashboard staff: tugas yang ditugaskan ke [staffUsername] + semua laporan masuk.
class StaffDashboardPage extends StatelessWidget {
  const StaffDashboardPage({super.key, required this.staffUsername});

  final String staffUsername;

  String get _key => staffUsername.trim().toLowerCase();

  List<IncomingTicket> get _myTasks {
    final k = _key;
    if (k.isEmpty) return [];
    return kIncomingTickets
        .where((t) =>
            t.assignedTo != null && t.assignedTo!.trim().toLowerCase() == k)
        .toList();
  }

  List<IncomingTicket> get _allSorted {
    final copy = List<IncomingTicket>.from(kIncomingTickets);
    copy.sort((a, b) => b.lastUpdate.compareTo(a.lastUpdate));
    return copy;
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

  Widget _statusPill(String status) {
    final c = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: c.withOpacity(0.12),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: c,
        ),
      ),
    );
  }

  Widget _ticketCard(IncomingTicket t, {required bool compactAssignee}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  t.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _statusPill(t.status),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '#${t.id} • ${t.category}',
            style: const TextStyle(fontSize: 11, color: Colors.black54),
          ),
          const SizedBox(height: 4),
          Text(
            'Pelapor: ${t.requester} • ${t.lastUpdate}',
            style: const TextStyle(fontSize: 11, color: Colors.black45),
          ),
          if (compactAssignee && t.assignedTo != null) ...[
            const SizedBox(height: 6),
            Text(
              'Penugasan: ${t.assignedTo}',
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF2563EB),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final red = Colors.red.shade800;
    final my = _myTasks;
    final all = _allSorted;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: red,
        elevation: 0,
        title: const Text(
          'Dashboard Staff',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [
                    red,
                    Colors.red.shade700,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tugas & antrian laporan',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _key.isEmpty
                        ? 'Isi NIM/NIP saat login agar penugasan cocok dengan akun demo (`staff`).'
                        : 'Login: $staffUsername • ${_myTasks.length} tugas untuk Anda',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Daftar tugas saya',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Tiket yang ditugaskan ke akun Anda.',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 12),
            if (my.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Text(
                  _key.isEmpty
                      ? 'Belum ada konteks akun.'
                      : 'Tidak ada penugasan. Coba login dengan username `staff` (demo) atau tunggu admin menugaskan tiket.',
                  style: const TextStyle(fontSize: 13, color: Colors.black54),
                ),
              )
            else
              ...my.map((t) => _ticketCard(t, compactAssignee: false)),
            const SizedBox(height: 24),
            const Text(
              'Semua laporan yang masuk',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Antrian global untuk koordinasi dengan admin dan pelapor.',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 12),
            ...all.map((t) => _ticketCard(t, compactAssignee: true)),
          ],
        ),
      ),
    );
  }
}
