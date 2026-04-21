import 'package:flutter/material.dart';
import 'report_create_page.dart';

class ReportSuccessPage extends StatelessWidget {
  final Map<String, String> keptData;

  const ReportSuccessPage({
    super.key,
    required this.keptData,
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
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.check_circle_rounded,
                    color: red,
                    size: 40 * _phi,
                  ),
                ),
              ),
              SizedBox(height: 16 * _phi),

              // ── Message Part ──────────────────────────────────
              const Text(
                'Laporan Terkirim!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8 * _phi),
              const Text(
                'Terima kasih telah berkontribusi menjaga fasilitas kampus. Tim kami akan segera menindaklanjuti laporan Anda.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32 * _phi),

              // ── Info Card (Kept Data Summary) ──────────────────
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: Column(
                  children: [
                    _buildMiniRow(Icons.person_outline, keptData['nama'] ?? '-'),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Divider(height: 1),
                    ),
                    _buildMiniRow(Icons.place_outlined, keptData['location'] ?? '-'),
                  ],
                ),
              ),
              
              const Spacer(),

              // ── Action Buttons ────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate back to Timeline (Feed)
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade100,
                    foregroundColor: Colors.black87,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Kembali ke Timeline',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
              ),
              SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate back to Create Form with kept data
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReportCreatePage(
                          currentUser: 'mahasiswa_aktif',
                          initialNama: keptData['nama'],
                          initialNIM: keptData['nim'],
                          initialFakultas: keptData['fakultas'],
                          initialLocation: keptData['location'],
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 4,
                    shadowColor: red.withOpacity(0.3),
                  ),
                  child: const Text(
                    'Lapor Kerusakan Lain di Sini',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
              SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMiniRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.black38),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 13, color: Colors.black54),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
