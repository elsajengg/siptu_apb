import 'package:flutter/material.dart';
import 'task_detail_page.dart';

class TaskSuccessPage extends StatelessWidget {
  final String taskId;
  final String newStatus;

  const TaskSuccessPage({
    super.key,
    required this.taskId,
    required this.newStatus,
  });

  static const double _phi = 1.61803398875;

  @override
  Widget build(BuildContext context) {
    final red = Colors.red.shade800;
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24 * _phi),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ── Success Icon Part ─────────────────────────────
              Container(
                width: 60 * _phi,
                height: 60 * _phi,
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.check_circle_rounded,
                    color: Colors.green.shade600,
                    size: 40 * _phi,
                  ),
                ),
              ),
              SizedBox(height: 16 * _phi),

              // ── Message Part ──────────────────────────────────
              const Text(
                'Update Berhasil!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8 * _phi),
              const Text(
                'Laporan pembaruan tugas Anda telah berhasil dikirim dan tercatat di sistem.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24 * _phi),

              // ── Summary Card ──────────────────────────────────
              _buildSummaryCard(taskId, newStatus),
              
              const Spacer(),

              // ── Action Buttons ────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate back to Home/Dashboard
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Kembali ke Beranda',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
              SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TaskDetailPage(
                          task: {
                            'id': taskId,
                            'title': 'Perbaikan Fasilitas',
                            'status': newStatus,
                            'location': 'Lokasi Terlampir',
                          },
                        ),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Lihat Detail Perbaikan',
                    style: TextStyle(color: red, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
              SizedBox(height: 8 * _phi),
              TextButton(
                onPressed: () {
                  // Pop until we reach the task list (if possible) or just pop back
                  Navigator.of(context).pop();
                },
                child: Text(
                  'Lihat Tugas Lainnya',
                  style: TextStyle(color: red, fontWeight: FontWeight.w600),
                ),
              ),
              SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String taskId, String status) {
    return Container(
      padding: EdgeInsets.all(12 * _phi),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          _buildSummaryRow('ID Tiket', taskId),
          const Divider(height: 24),
          _buildSummaryRow('Status Baru', status, isStatus: true),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isStatus = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.black45, fontSize: 13, fontWeight: FontWeight.w500),
        ),
        if (isStatus)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              value,
              style: TextStyle(
                color: Colors.blue.shade800,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        else
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          ),
      ],
    );
  }
}
