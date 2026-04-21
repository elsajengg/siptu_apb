import 'package:flutter/material.dart';

class TaskDetailPage extends StatelessWidget {
  final Map<String, dynamic> task;

  const TaskDetailPage({super.key, required this.task});

  static const double _phi = 1.61803398875;

  @override
  Widget build(BuildContext context) {
    final red = Colors.red.shade800;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: red,
        elevation: 0,
        centerTitle: false,
        title: Text(
          'Detail Tugas - ${task['id']}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16 * _phi),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Status Badge ─────────────────────────────────────
            _buildStatusHeader(task['status']),
            SizedBox(height: 20 * _phi),

            // ── Task Information ──────────────────────────────────
            _buildSectionLabel('Informasi Tugas'),
            SizedBox(height: 8 * _phi),
            _buildInfoCard([
              _InfoRow(label: 'Judul Tugas', value: task['title'] ?? 'N/A'),
              _InfoRow(label: 'Lokasi Kerja', value: task['location'] ?? 'N/A'),
              _InfoRow(label: 'Deadline', value: task['deadline'] ?? 'N/A'),
              _InfoRow(label: 'Kategori', value: 'Perbaikan Umum', isLast: true),
            ]),
            SizedBox(height: 24 * _phi),

            // ── Repair Results (Read Only) ────────────────────────
            _buildSectionLabel('Hasil Perbaikan'),
            SizedBox(height: 8 * _phi),
            _buildInfoCard([
              _InfoRow(
                label: 'Selesai Pada', 
                value: '21 April 2026, 14:30', // Mock data
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Catatan Petugas:',
                      style: TextStyle(color: Colors.black45, fontSize: 13),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Perbaikan telah dilakukan sesuai instruksi. Komponen yang rusak telah diganti dengan yang baru.',
                      style: TextStyle(fontSize: 14, color: Colors.black87, height: 1.5),
                    ),
                  ],
                ),
              ),
              const _InfoRow(label: 'Dokumentasi', value: '2 Foto Terlampir', isLast: true),
            ]),
            SizedBox(height: 20 * _phi),

            // ── Mock Photo Gallery ────────────────────────────────
            _buildPhotoGallery(),

            SizedBox(height: 32 * _phi),

            // ── Bottom Action ────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 54,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: red),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(
                  'Tutup Detail',
                  style: TextStyle(color: red, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusHeader(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade100),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green.shade600, size: 24),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tugas Telah $status',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade800,
                  fontSize: 15,
                ),
              ),
              const Text(
                'Terverifikasi oleh sistem',
                style: TextStyle(fontSize: 12, color: Colors.green),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: -0.2),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildPhotoGallery() {
    return Row(
      children: [
        _buildMockPhoto('https://picsum.photos/200?1'),
        const SizedBox(width: 12),
        _buildMockPhoto('https://picsum.photos/200?2'),
      ],
    );
  }

  Widget _buildMockPhoto(String url) {
    return Expanded(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 120,
          color: Colors.grey.shade200,
          child: Image.network(url, fit: BoxFit.cover),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isLast;
  const _InfoRow({required this.label, required this.value, this.isLast = false, isStatus = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(color: Colors.black45, fontSize: 13)),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  value,
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black87),
                ),
              ),
            ],
          ),
        ),
        if (!isLast) Divider(height: 1, color: Colors.grey.shade100),
      ],
    );
  }
}
