import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../data/api_service.dart';
import '../../providers/report_provider.dart';

class ExportPage extends StatefulWidget {
  const ExportPage({super.key});

  @override
  State<ExportPage> createState() => _ExportPageState();
}

class _ExportPageState extends State<ExportPage> {
  String _selectedStatus = 'Semua';
  final List<String> _statusOptions = ['Semua', 'Pending', 'Diterima', 'Selesai', 'Ditolak'];
  bool _isGenerating = false;
  bool _isLoading = true;
  List<Map<String, dynamic>> _allReports = [];

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    setState(() => _isLoading = true);
    final result = await ApiService.getReports();
    setState(() {
      if (result['success']) {
        _allReports = List<Map<String, dynamic>>.from(result['data'] ?? []);
      }
      _isLoading = false;
    });
  }

  List<Map<String, dynamic>> get _filteredReports {
    if (_selectedStatus == 'Semua') return _allReports;
    final statusMap = {
      'Pending': 'pending',
      'Diterima': 'assigned',
      'Selesai': 'resolved',
      'Ditolak': 'rejected',
    };
    return _allReports.where((r) => r['status'] == statusMap[_selectedStatus]).toList();
  }

  int get _totalPending => _allReports.where((r) => r['status'] == 'pending').length;
  int get _totalAcc => _allReports.where((r) => r['status'] == 'assigned').length;
  int get _totalSelesai => _allReports.where((r) => r['status'] == 'resolved' || r['status'] == 'done').length;
  int get _totalReject => _allReports.where((r) => r['status'] == 'rejected').length;

  String _statusLabel(String? status) {
    return Report.statusLabel(status);
  }

  String get _formattedNow {
    final now = DateTime.now();
    const months = ['Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];
    return '${now.day} ${months[now.month - 1]} ${now.year}';
  }

  Future<void> _generatePdf() async {
    setState(() => _isGenerating = true);
    try {
      final reports = _filteredReports;
      final doc = pw.Document();

      final primaryColor = PdfColor.fromHex('#B91C1C');
      final lightRed = PdfColor.fromHex('#FEE2E2');
      final headerBg = PdfColor.fromHex('#1F2937');
      final rowAlt = PdfColor.fromHex('#F9FAFB');
      final textDark = PdfColor.fromHex('#111827');
      final textMid = PdfColor.fromHex('#374151');
      final textLight = PdfColor.fromHex('#6B7280');
      final borderColor = PdfColor.fromHex('#E5E7EB');

      const double wNo = 28;
      const double wJudul = 190;
      const double wKategori = 100;
      const double wLokasi = 110;
      const double wPelapor = 90;
      const double wStaff = 100;
      const double wStatus = 72;

      pw.Widget headerCell(String text, double w) => pw.Container(
        width: w,
        padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        child: pw.Text(text, style: pw.TextStyle(color: PdfColors.white, fontSize: 8, fontWeight: pw.FontWeight.bold)),
      );

      pw.Widget dataCell(String text, double w, {PdfColor? color, bool center = false}) => pw.Container(
        width: w,
        padding: const pw.EdgeInsets.symmetric(vertical: 7, horizontal: 6),
        child: pw.Text(text, style: pw.TextStyle(fontSize: 8, color: color ?? textMid), textAlign: center ? pw.TextAlign.center : pw.TextAlign.left, maxLines: 3),
      );

      doc.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4.landscape,
          margin: const pw.EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          header: (ctx) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: pw.BoxDecoration(color: primaryColor, borderRadius: pw.BorderRadius.circular(8)),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('SIPTU', style: pw.TextStyle(color: PdfColors.white, fontSize: 22, fontWeight: pw.FontWeight.bold)),
                        pw.SizedBox(height: 2),
                        pw.Text('Sistem Pelaporan Fasilitas Telkom University', style: pw.TextStyle(color: PdfColors.white, fontSize: 9)),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text('Laporan Pengaduan Fasilitas', style: pw.TextStyle(color: PdfColors.white, fontSize: 13, fontWeight: pw.FontWeight.bold)),
                        pw.SizedBox(height: 3),
                        pw.Text('Dicetak: $_formattedNow', style: pw.TextStyle(color: PdfColors.white, fontSize: 9)),
                      ],
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Row(
                children: [
                  _statBox('Total Laporan', _allReports.length.toString(), PdfColor.fromHex('#2563EB')),
                  pw.SizedBox(width: 8),
                  _statBox('Pending', _totalPending.toString(), PdfColor.fromHex('#F97316')),
                  pw.SizedBox(width: 8),
                  _statBox('Diterima', _totalAcc.toString(), PdfColor.fromHex('#16A34A')),
                  pw.SizedBox(width: 8),
                  _statBox('Selesai', _totalSelesai.toString(), PdfColor.fromHex('#2563EB')),
                  pw.SizedBox(width: 8),
                  _statBox('Ditolak', _totalReject.toString(), PdfColor.fromHex('#DC2626')),
                ],
              ),
              pw.SizedBox(height: 8),
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: pw.BoxDecoration(color: lightRed, borderRadius: pw.BorderRadius.circular(6)),
                child: pw.Row(
                  children: [
                    pw.Text('Filter Status: ', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: primaryColor)),
                    pw.Text(_selectedStatus, style: pw.TextStyle(fontSize: 9, color: primaryColor)),
                    pw.Spacer(),
                    pw.Text('Menampilkan ${reports.length} dari ${_allReports.length} laporan', style: pw.TextStyle(fontSize: 9, color: primaryColor)),
                  ],
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Container(
                decoration: pw.BoxDecoration(color: headerBg, borderRadius: const pw.BorderRadius.only(topLeft: pw.Radius.circular(6), topRight: pw.Radius.circular(6))),
                child: pw.Row(
                  children: [
                    headerCell('No', wNo),
                    headerCell('Judul Laporan', wJudul),
                    headerCell('Kategori', wKategori),
                    headerCell('Lokasi', wLokasi),
                    headerCell('Pelapor', wPelapor),
                    headerCell('Staff', wStaff),
                    headerCell('Status', wStatus),
                  ],
                ),
              ),
            ],
          ),
          build: (ctx) => [
            pw.Table(
              border: pw.TableBorder(
                left: pw.BorderSide(color: borderColor, width: 0.5),
                right: pw.BorderSide(color: borderColor, width: 0.5),
                bottom: pw.BorderSide(color: borderColor, width: 0.5),
                horizontalInside: pw.BorderSide(color: borderColor, width: 0.5),
                verticalInside: pw.BorderSide(color: borderColor, width: 0.3),
              ),
              children: reports.asMap().entries.map((entry) {
                final i = entry.key;
                final r = entry.value;
                final isEven = i % 2 == 0;
                final status = r['status'] ?? '';
                final staffName = r['task']?['staff']?['name'] ?? '-';

                return pw.TableRow(
                  decoration: pw.BoxDecoration(color: isEven ? PdfColors.white : rowAlt),
                  children: [
                    dataCell('${i + 1}', wNo, color: textLight, center: true),
                    dataCell(r['title'] ?? '', wJudul, color: textDark),
                    dataCell(r['facility']?['name'] ?? '-', wKategori, color: textMid),
                    dataCell(r['location'] ?? '-', wLokasi, color: textMid),
                    dataCell(r['user']?['name'] ?? '-', wPelapor, color: textMid),
                    dataCell(staffName, wStaff, color: status == 'assigned' ? PdfColor.fromHex('#16A34A') : textLight),
                    dataCell(_statusLabel(status), wStatus, color: textDark),
                  ],
                );
              }).toList(),
            ),
          ],
          footer: (ctx) => pw.Padding(
            padding: const pw.EdgeInsets.only(top: 8),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('SIPTU — Telkom University', style: pw.TextStyle(fontSize: 8, color: textLight)),
                pw.Text('Halaman ${ctx.pageNumber} dari ${ctx.pagesCount}', style: pw.TextStyle(fontSize: 8, color: textLight)),
              ],
            ),
          ),
        ),
      );

      await Printing.layoutPdf(
        onLayout: (format) async => doc.save(),
        name: 'Laporan_SIPTU_$_formattedNow.pdf',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal generate PDF: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  pw.Widget _statBox(String label, String value, PdfColor color) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: pw.BoxDecoration(color: PdfColors.white, borderRadius: pw.BorderRadius.circular(6), border: pw.Border.all(color: color, width: 0.8)),
        child: pw.Row(
          children: [
            pw.Text(value, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: color)),
            pw.SizedBox(width: 8),
            pw.Text(label, style: pw.TextStyle(fontSize: 8, color: PdfColor.fromHex('#6B7280'))),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final red = Colors.red.shade800;
    final reports = _filteredReports;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: red,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Export Data', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(icon: const Icon(Icons.refresh, color: Colors.white), onPressed: _loadReports),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [Colors.red.shade900, Colors.red.shade700], begin: Alignment.topLeft, end: Alignment.bottomRight),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.picture_as_pdf, color: Colors.white, size: 32),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Export Laporan PDF', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                              Text('Total ${_allReports.length} laporan tersedia', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _StatCard(label: 'Total', value: _allReports.length.toString(), color: const Color(0xFF2563EB), icon: Icons.all_inbox_outlined),
                      const SizedBox(width: 8),
                      _StatCard(label: 'Pending', value: _totalPending.toString(), color: const Color(0xFFF97316), icon: Icons.pending_actions_outlined),
                      const SizedBox(width: 8),
                      _StatCard(label: 'Selesai', value: _totalSelesai.toString(), color: const Color(0xFF16A34A), icon: Icons.check_circle_outline),
                      const SizedBox(width: 8),
                      _StatCard(label: 'Ditolak', value: _totalReject.toString(), color: Colors.red, icon: Icons.cancel_outlined),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))]),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Filter Status Laporan', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _statusOptions.map((status) {
                            final isSelected = _selectedStatus == status;
                            return GestureDetector(
                              onTap: () => setState(() => _selectedStatus = status),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSelected ? red : Colors.transparent,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: isSelected ? red : Colors.black26),
                                ),
                                child: Text(status, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isSelected ? Colors.white : Colors.black54)),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))]),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Preview Data', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(color: red.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                                child: Text('${reports.length} laporan', style: TextStyle(fontSize: 12, color: red, fontWeight: FontWeight.w600)),
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 1),
                        reports.isEmpty
                            ? const Padding(
                                padding: EdgeInsets.all(24),
                                child: Column(
                                  children: [
                                    Icon(Icons.inbox_outlined, size: 48, color: Colors.black26),
                                    SizedBox(height: 8),
                                    Text('Tidak ada laporan', style: TextStyle(color: Colors.black45)),
                                  ],
                                ),
                              )
                            : ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: reports.length,
                                separatorBuilder: (_, __) => const Divider(height: 1),
                                itemBuilder: (context, index) {
                                  final r = reports[index];
                                  final status = r['status'] ?? '';
                                  final statusColor = status == 'assigned' ? Colors.green : status == 'rejected' ? Colors.red : status == 'resolved' || status == 'done' ? Colors.blue : Colors.orange;
                                  return ListTile(
                                    dense: true,
                                    leading: CircleAvatar(
                                      backgroundColor: red.withOpacity(0.1),
                                      radius: 16,
                                      child: Text('${index + 1}', style: TextStyle(fontSize: 11, color: red, fontWeight: FontWeight.bold)),
                                    ),
                                    title: Text(r['title'] ?? '', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                                    subtitle: Text('${r['facility']?['name'] ?? '-'} • ${r['location'] ?? '-'}', style: const TextStyle(fontSize: 11, color: Colors.black45), maxLines: 1, overflow: TextOverflow.ellipsis),
                                    trailing: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(color: statusColor.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                                      child: Text(_statusLabel(status), style: TextStyle(fontSize: 10, color: statusColor, fontWeight: FontWeight.w600)),
                                    ),
                                  );
                                },
                              ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        decoration: const BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, -3))]),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: reports.isEmpty ? Colors.grey : red, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
            onPressed: reports.isEmpty || _isGenerating ? null : _generatePdf,
            icon: _isGenerating
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Icon(Icons.picture_as_pdf_outlined),
            label: Text(_isGenerating ? 'Membuat PDF...' : 'Export ${reports.length} Laporan ke PDF', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _StatCard({required this.label, required this.value, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
            Text(label, style: const TextStyle(fontSize: 10, color: Colors.black45)),
          ],
        ),
      ),
    );
  }
}
