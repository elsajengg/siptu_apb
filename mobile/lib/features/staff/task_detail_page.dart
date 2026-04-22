import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'update_status.dart';

class TaskDetailPage extends StatelessWidget {
  final Map<String, dynamic> task;
  final List<File>? localImages;
  final String? customNote;

  const TaskDetailPage({
    super.key, 
    required this.task,
    this.localImages,
    this.customNote,
  });

  static const double _phi = 1.61803398875;

  @override
  Widget build(BuildContext context) {
    final red = Colors.red.shade800;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: BackButton(color: red),
        centerTitle: true,
        title: Text(
          'LAPORAN PERBAIKAN',
          style: TextStyle(
            color: red,
            fontWeight: FontWeight.w900,
            fontSize: 14,
            letterSpacing: 2,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UpdateStatusPage(
                    initialStatus: task['status'],
                    initialNote: customNote,
                    initialImages: localImages,
                  ),
                ),
              );
            },
            icon: Icon(Icons.edit_note_rounded, color: red, size: 28),
            tooltip: 'Edit Laporan',
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.share_outlined, color: red),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Official Status Banner ───────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20),
              color: Colors.green.shade600,
              child: Column(
                children: [
                  const Icon(Icons.verified, color: Colors.white, size: 32),
                  const SizedBox(height: 8),
                  Text(
                    'TUGAS ${task['status'].toUpperCase()}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 1,
                    ),
                  ),
                  const Text(
                    'Tervalidasi secara digital oleh SIPTU Mobile',
                    style: TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ],
              ),
            ),

            Padding(
              padding: EdgeInsets.all(20 * _phi),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Document Metadata ─────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildHeaderInfo('NO. TIKET', task['id']),
                      _buildHeaderInfo('TANGGAL SELESAI', '21 April 2026'),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Divider(thickness: 1.5),
                  ),

                  // ── Work Info ─────────────────────────────────────
                  _buildSectionTitle('I. DETAIL PENUGASAN'),
                  const SizedBox(height: 12),
                  _buildDetailRow('Judul Pekerjaan', task['title']),
                  _buildDetailRow('Lokasi Fasilitas', task['location']),
                  _buildDetailRow('Kategori', 'Pemeliharaan Gedung'),
                  _buildDetailRow('Prioritas', 'Tinggi'),
                  
                  SizedBox(height: 24 * _phi),

                  // ── Technician Notes ──────────────────────────────
                  _buildSectionTitle('II. CATATAN TEKNISI'),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Text(
                      customNote ?? 'Perbaikan telah dilakukan pada komponen utama. Seluruh fungsi telah diuji kembali dan berjalan normal. Tidak ada kerusakan tambahan yang ditemukan di area sekitar.',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                        height: 1.6,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 24 * _phi),

                  // ── Visual Documentation ──────────────────────────
                  _buildSectionTitle('III. DOKUMENTASI VISUAL'),
                  const SizedBox(height: 12),
                  _buildPhotoGrid(),
                  
                  const SizedBox(height: 40),

                  // ── Official Footer/Seal ──────────────────────────
                  Center(
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.qr_code_2, size: 48, color: Colors.grey.shade400),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'SIPTU DIGITAL SEAL',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade400,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.black45, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w900,
        color: Colors.black45,
        letterSpacing: 1,
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(fontSize: 13, color: Colors.black54)),
          ),
          const Text(':  ', style: TextStyle(fontSize: 13, color: Colors.black54)),
          Expanded(
            child: label == 'Judul Pekerjaan' 
              ? Hero(
                  tag: 'task_title_${task['id']}',
                  child: Material(
                    color: Colors.transparent,
                    child: Text(
                      value,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87),
                    ),
                  ),
                )
              : Text(
                  value,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87),
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoGrid() {
    if (localImages != null && localImages!.isNotEmpty) {
      return SizedBox(
        height: 150,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: localImages!.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (context, index) {
            return Container(
              width: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(7),
                child: kIsWeb 
                   ? Image.network(localImages![index].path, fit: BoxFit.cover)
                   : Image.file(localImages![index], fit: BoxFit.cover),
              ),
            );
          },
        ),
      );
    }

    return Row(
      children: [
        _buildReportPhoto('https://picsum.photos/400?1'),
        const SizedBox(width: 12),
        _buildReportPhoto('https://picsum.photos/400?2'),
      ],
    );
  }

  Widget _buildReportPhoto(String url) {
    return Expanded(
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(7),
          child: Image.network(url, fit: BoxFit.cover),
        ),
      ),
    );
  }
}
