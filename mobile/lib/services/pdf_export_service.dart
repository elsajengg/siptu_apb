import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

class PdfExportService {
  static Future<XFile> generateTaskReportPdf({
    required String id,
    required String title,
    required String location,
    required String status,
    required String date,
    String? note,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(32),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Center(
                  child: pw.Text(
                    'LAPORAN PERBAIKAN FASILITAS',
                    style: pw.TextStyle(
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.red800,
                    ),
                  ),
                ),
                pw.SizedBox(height: 24),
                pw.Divider(color: PdfColors.grey400),
                pw.SizedBox(height: 16),
                _buildRow('ID Tiket', id),
                _buildRow('Judul', title),
                _buildRow('Lokasi', location),
                _buildRow('Status', status.toUpperCase()),
                _buildRow('Tanggal Selesai', date),
                pw.SizedBox(height: 24),
                pw.Text(
                  'Catatan Teknisi:',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
                ),
                pw.SizedBox(height: 8),
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(12),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey100,
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                    border: pw.Border.all(color: PdfColors.grey300),
                  ),
                  child: pw.Text(
                    note ?? 'Tidak ada catatan tambahan.',
                    style: const pw.TextStyle(fontSize: 12),
                  ),
                ),
                pw.Spacer(),
                pw.Center(
                  child: pw.Text(
                    'Dihasilkan secara otomatis oleh SIPTU Mobile',
                    style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    final bytes = await pdf.save();
    return XFile.fromData(
      bytes,
      mimeType: 'application/pdf',
      name: 'Laporan_SIPTU_$id.pdf',
    );
  }

  static pw.Widget _buildRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 120,
            child: pw.Text(
              label, 
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.grey700)
            ),
          ),
          pw.Text(': ', style: pw.TextStyle(color: PdfColors.grey700)),
          pw.Expanded(
            child: pw.Text(value, style: const pw.TextStyle(color: PdfColors.black)),
          ),
        ],
      ),
    );
  }
}
