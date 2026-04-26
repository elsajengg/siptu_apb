import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'verify_report.dart';

class ExportPage extends StatefulWidget {
  const ExportPage({super.key});

  @override
  State<ExportPage> createState() => _ExportPageState();
}

class _ExportPageState extends State<ExportPage> {
  String _selectedStatus = 'Semua';
  final List<String> _statusOptions = [
    'Semua',
    'Pending',
    'Diterima',
    'Ditolak',
  ];
  bool _isGenerating = false;

  final List<ReportItem> _allReports = [
    ReportItem(
      id: 'TIK-001',
      title: 'Lampu Koridor Gedung B Lantai 3 Mati',
      description:
          'Lampu di koridor gedung B lantai 3 sudah mati selama 3 hari.',
      category: 'Penerangan',
      location: 'Gedung B Lantai 3',
      requester: 'Bagus Faaza',
      date: DateTime.now(),
      upvotes: 24,
      status: 'pending',
    ),
    ReportItem(
      id: 'TIK-002',
      title: 'AC Ruang Kelas 204 Tidak Dingin',
      description:
          'AC di ruang kelas 204 sudah tidak berfungsi sejak seminggu lalu.',
      category: 'Kenyamanan Ruangan',
      location: 'Gedung A Lantai 2',
      requester: 'Elsa Ajeng',
      date: DateTime.now(),
      upvotes: 18,
      status: 'pending',
    ),
    ReportItem(
      id: 'TIK-003',
      title: 'Keran Air Bocor di Toilet Lantai 1',
      description:
          'Keran air di toilet lantai 1 bocor dan menyebabkan lantai licin.',
      category: 'Sanitasi',
      location: 'Gedung C Lantai 1',
      requester: 'Iqbal Hilmi',
      date: DateTime.now().subtract(const Duration(days: 1)),
      upvotes: 12,
      status: 'acc',
      assignedStaff: 'Citra Dewi',
    ),
    ReportItem(
      id: 'TIK-004',
      title: 'Kursi Rusak di Perpustakaan Utama',
      description:
          'Beberapa kursi di perpustakaan sudah rusak dan tidak layak pakai.',
      category: 'Furnitur',
      location: 'Perpustakaan Utama',
      requester: 'Mahasiswa_2023',
      date: DateTime.now().subtract(const Duration(days: 1)),
      upvotes: 9,
      status: 'acc',
      assignedStaff: 'Dendi Pratama',
    ),
    ReportItem(
      id: 'TIK-005',
      title: 'Proyektor Ruang 305 Rusak',
      description:
          'Proyektor di ruang 305 tidak bisa menyala sejak 2 hari lalu.',
      category: 'Elektronik',
      location: 'Gedung B Lantai 3',
      requester: 'Dosen_TI',
      date: DateTime.now().subtract(const Duration(days: 5)),
      upvotes: 7,
      status: 'reject',
    ),
    ReportItem(
      id: 'TIK-006',
      title: 'Toilet Lantai 2 Tersumbat',
      description:
          'Toilet di lantai 2 gedung A tersumbat dan mengeluarkan bau.',
      category: 'Sanitasi',
      location: 'Gedung A Lantai 2',
      requester: 'Budi_23',
      date: DateTime.now().subtract(const Duration(days: 3)),
      upvotes: 15,
      status: 'pending',
    ),
  ];

  List<ReportItem> get _filteredReports {
    if (_selectedStatus == 'Semua') return _allReports;
    final statusMap = {
      'Pending': 'pending',
      'Diterima': 'acc',
      'Ditolak': 'reject',
    };
    return _allReports
        .where((r) => r.status == statusMap[_selectedStatus])
        .toList();
  }

  int get _totalPending =>
      _allReports.where((r) => r.status == 'pending').length;
  int get _totalAcc => _allReports.where((r) => r.status == 'acc').length;
  int get _totalReject => _allReports.where((r) => r.status == 'reject').length;

  String _statusLabel(String status) {
    switch (status) {
      case 'acc':
        return 'Diterima';
      case 'reject':
        return 'Ditolak';
      default:
        return 'Pending';
    }
  }

  String get _formattedNow {
    final now = DateTime.now();
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return '${now.day} ${months[now.month - 1]} ${now.year}';
  }

  // ── Generate PDF landscape ───────────────────────────────────
  Future<void> _generatePdf() async {
    setState(() => _isGenerating = true);

    try {
      final reports = _filteredReports;
      final doc = pw.Document();

      // Warna
      final primaryColor = PdfColor.fromHex('#B91C1C');
      final lightRed = PdfColor.fromHex('#FEE2E2');
      final headerBg = PdfColor.fromHex('#1F2937');
      final rowAlt = PdfColor.fromHex('#F9FAFB');
      final textDark = PdfColor.fromHex('#111827');
      final textMid = PdfColor.fromHex('#374151');
      final textLight = PdfColor.fromHex('#6B7280');
      final borderColor = PdfColor.fromHex('#E5E7EB');

      // Lebar kolom — total ~755pt (A4 landscape - margin)
      const double wNo = 28;
      const double wId = 65;
      const double wJudul = 190;
      const double wKategori = 100;
      const double wLokasi = 110;
      const double wPelapor = 90;
      const double wStaff = 100;
      const double wStatus = 72;

      // Helper: baris header
      pw.Widget headerCell(String text, double w) => pw.Container(
        width: w,
        padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        child: pw.Text(
          text,
          style: pw.TextStyle(
            color: PdfColors.white,
            fontSize: 8,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      );

      // Helper: sel data
      pw.Widget dataCell(
        String text,
        double w, {
        PdfColor? color,
        bool center = false,
      }) => pw.Container(
        width: w,
        padding: const pw.EdgeInsets.symmetric(vertical: 7, horizontal: 6),
        child: pw.Text(
          text,
          style: pw.TextStyle(fontSize: 8, color: color ?? textMid),
          textAlign: center ? pw.TextAlign.center : pw.TextAlign.left,
          maxLines: 3,
        ),
      );

      doc.addPage(
        pw.MultiPage(
          // ── Landscape A4 ─────────────────────────────────────
          pageFormat: PdfPageFormat.a4.landscape,
          margin: const pw.EdgeInsets.symmetric(horizontal: 28, vertical: 24),

          // ── Header halaman ────────────────────────────────────
          header: (ctx) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Baris judul
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: pw.BoxDecoration(
                  color: primaryColor,
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'SIPTU',
                          style: pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 22,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          'Sistem Pelaporan Fasilitas Telkom University',
                          style: pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                          'Laporan Pengaduan Fasilitas',
                          style: pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 13,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 3),
                        pw.Text(
                          'Dicetak: $_formattedNow',
                          style: pw.TextStyle(
                            color: PdfColors.white,
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 10),

              // Statistik ringkas
              pw.Row(
                children: [
                  _statBox(
                    'Total Laporan',
                    _allReports.length.toString(),
                    PdfColor.fromHex('#2563EB'),
                  ),
                  pw.SizedBox(width: 8),
                  _statBox(
                    'Pending',
                    _totalPending.toString(),
                    PdfColor.fromHex('#F97316'),
                  ),
                  pw.SizedBox(width: 8),
                  _statBox(
                    'Diterima',
                    _totalAcc.toString(),
                    PdfColor.fromHex('#16A34A'),
                  ),
                  pw.SizedBox(width: 8),
                  _statBox(
                    'Ditolak',
                    _totalReject.toString(),
                    PdfColor.fromHex('#DC2626'),
                  ),
                ],
              ),
              pw.SizedBox(height: 8),

              // Info filter
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: pw.BoxDecoration(
                  color: lightRed,
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.Row(
                  children: [
                    pw.Text(
                      'Filter Status: ',
                      style: pw.TextStyle(
                        fontSize: 9,
                        fontWeight: pw.FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    pw.Text(
                      _selectedStatus,
                      style: pw.TextStyle(fontSize: 9, color: primaryColor),
                    ),
                    pw.Spacer(),
                    pw.Text(
                      'Menampilkan ${reports.length} dari '
                      '${_allReports.length} laporan',
                      style: pw.TextStyle(fontSize: 9, color: primaryColor),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 10),

              // Header tabel
              pw.Container(
                decoration: pw.BoxDecoration(
                  color: headerBg,
                  borderRadius: const pw.BorderRadius.only(
                    topLeft: pw.Radius.circular(6),
                    topRight: pw.Radius.circular(6),
                  ),
                ),
                child: pw.Row(
                  children: [
                    headerCell('No', wNo),
                    headerCell('ID Tiket', wId),
                    headerCell('Judul Laporan', wJudul),
                    headerCell('Kategori', wKategori),
                    headerCell('Lokasi', wLokasi),
                    headerCell('Pelapor', wPelapor),
                    headerCell('Staff Penanganan', wStaff),
                    headerCell('Status', wStatus),
                  ],
                ),
              ),
            ],
          ),

          // ── Isi tabel ─────────────────────────────────────────
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
                final staffText = r.status == 'acc'
                    ? (r.assignedStaff ?? '-')
                    : '-';

                return pw.TableRow(
                  decoration: pw.BoxDecoration(
                    color: isEven ? PdfColors.white : rowAlt,
                  ),
                  children: [
                    dataCell('${i + 1}', wNo, color: textLight, center: true),
                    dataCell(r.id, wId, color: textDark),
                    dataCell(r.title, wJudul, color: textDark),
                    dataCell(r.category, wKategori, color: textMid),
                    dataCell(r.location, wLokasi, color: textMid),
                    dataCell(r.requester, wPelapor, color: textMid),
                    dataCell(
                      staffText,
                      wStaff,
                      color: r.status == 'acc'
                          ? PdfColor.fromHex('#16A34A')
                          : textLight,
                    ),
                    dataCell(_statusLabel(r.status), wStatus, color: textDark),
                  ],
                );
              }).toList(),
            ),
          ],

          // ── Footer ────────────────────────────────────────────
          footer: (ctx) => pw.Padding(
            padding: const pw.EdgeInsets.only(top: 8),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'SIPTU — Telkom University',
                  style: pw.TextStyle(fontSize: 8, color: textLight),
                ),
                pw.Text(
                  'Halaman ${ctx.pageNumber} dari ${ctx.pagesCount}',
                  style: pw.TextStyle(fontSize: 8, color: textLight),
                ),
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
          SnackBar(
            content: Text('Gagal generate PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  // ── Helper stat box di PDF ────────────────────────────────────
  pw.Widget _statBox(String label, String value, PdfColor color) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: pw.BoxDecoration(
          color: PdfColors.white,
          borderRadius: pw.BorderRadius.circular(6),
          border: pw.Border.all(color: color, width: 0.8),
        ),
        child: pw.Row(
          children: [
            pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
                color: color,
              ),
            ),
            pw.SizedBox(width: 8),
            pw.Text(
              label,
              style: pw.TextStyle(
                fontSize: 8,
                color: PdfColor.fromHex('#6B7280'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Build UI ──────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final red = Colors.red.shade800;
    final reports = _filteredReports;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: red,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Export Data',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Banner ────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.red.shade900, Colors.red.shade700],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.picture_as_pdf,
                    color: Colors.white,
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Export Laporan PDF',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          'Total ${_allReports.length} laporan tersedia',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Statistik ─────────────────────────────────────
            Row(
              children: [
                _StatCard(
                  label: 'Total',
                  value: _allReports.length.toString(),
                  color: const Color(0xFF2563EB),
                  icon: Icons.all_inbox_outlined,
                ),
                const SizedBox(width: 8),
                _StatCard(
                  label: 'Pending',
                  value: _totalPending.toString(),
                  color: const Color(0xFFF97316),
                  icon: Icons.pending_actions_outlined,
                ),
                const SizedBox(width: 8),
                _StatCard(
                  label: 'Diterima',
                  value: _totalAcc.toString(),
                  color: const Color(0xFF16A34A),
                  icon: Icons.check_circle_outline,
                ),
                const SizedBox(width: 8),
                _StatCard(
                  label: 'Ditolak',
                  value: _totalReject.toString(),
                  color: Colors.red,
                  icon: Icons.cancel_outlined,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Filter Status ─────────────────────────────────
            Container(
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
                  const Text(
                    'Filter Status Laporan',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Pilih status laporan yang ingin di-export',
                    style: TextStyle(fontSize: 12, color: Colors.black45),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _statusOptions.map((status) {
                      final isSelected = _selectedStatus == status;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedStatus = status),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected ? red : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? red : Colors.black26,
                            ),
                          ),
                          child: Text(
                            status,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? Colors.white : Colors.black54,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Preview Data ──────────────────────────────────
            Container(
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
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Preview Data',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${reports.length} laporan',
                            style: TextStyle(
                              fontSize: 12,
                              color: red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
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
                              Icon(
                                Icons.inbox_outlined,
                                size: 48,
                                color: Colors.black26,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Tidak ada laporan untuk filter ini',
                                style: TextStyle(color: Colors.black45),
                              ),
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
                            final statusColor = r.status == 'acc'
                                ? Colors.green
                                : r.status == 'reject'
                                ? Colors.red
                                : Colors.orange;
                            return ListTile(
                              dense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 4,
                              ),
                              leading: CircleAvatar(
                                backgroundColor: red.withOpacity(0.1),
                                radius: 16,
                                child: Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(
                                r.title,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${r.category} • ${r.location}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.black45,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (r.status == 'acc' &&
                                      r.assignedStaff != null)
                                    Text(
                                      'Staff: ${r.assignedStaff}',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Colors.green,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                ],
                              ),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  _statusLabel(r.status),
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: statusColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
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

      // ── Tombol Export ──────────────────────────────────────────
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, -3),
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: reports.isEmpty ? Colors.grey : red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: reports.isEmpty || _isGenerating ? null : _generatePdf,
            icon: _isGenerating
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.picture_as_pdf_outlined),
            label: Text(
              _isGenerating
                  ? 'Membuat PDF...'
                  : 'Export ${reports.length} Laporan ke PDF',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Widget Helper ─────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: Colors.black45),
            ),
          ],
        ),
      ),
    );
  }
}
