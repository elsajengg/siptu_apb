import 'dart:io';
import 'package:flutter/material.dart';
import 'report_feed_page.dart';

class ReportDetailPage extends StatelessWidget {
  final Report report;

  const ReportDetailPage({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final red = Colors.red.shade800;
    final createdAt = _formatDateTime(report.createdAt);

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: red,
        elevation: 0,
        foregroundColor: Colors.white,
        centerTitle: false,
        leading: BackButton(color: Colors.white),
        title: const Text(
          'Detail Pengaduan',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        children: [
          _HeaderCard(report: report, createdAt: createdAt),
          const SizedBox(height: 16),
          if (report.photoPaths.isNotEmpty) _PhotoCard(paths: report.photoPaths),
          if (report.photoPaths.isNotEmpty) const SizedBox(height: 16),
          _BodyCard(report: report),
          const SizedBox(height: 16),
          _StaffCard(report: report),
        ],
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final Report report;
  final String createdAt;

  const _HeaderCard({required this.report, required this.createdAt});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: const Color(0xFFFFE4E1),
                foregroundColor: const Color(0xFF991B1B),
                child: Text(
                  report.createdBy.trim().isEmpty
                      ? '?'
                      : report.createdBy.trim()[0].toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      report.title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _Pill(
                          icon: Icons.category_rounded,
                          label: report.category,
                        ),
                        _Pill(
                          icon: Icons.location_on_rounded,
                          label: report.location,
                        ),
                        _StatusPill(status: report.status),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      '@${report.createdBy} • $createdAt',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black45,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: Color(0xFFF3F4F6)),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(Icons.thumb_up_alt_rounded,
                  size: 18, color: Colors.black38),
              const SizedBox(width: 8),
              Text(
                '${report.likes} dukungan',
                style: const TextStyle(fontSize: 12, color: Colors.black45, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PhotoCard extends StatefulWidget {
  final List<String> paths;

  const _PhotoCard({required this.paths});

  @override
  State<_PhotoCard> createState() => _PhotoCardState();
}

class _PhotoCardState extends State<_PhotoCard> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Stack(
              children: [
                PageView.builder(
                  itemCount: widget.paths.length,
                  onPageChanged: (index) =>
                      setState(() => _currentIndex = index),
                  itemBuilder: (context, index) {
                    final path = widget.paths[index];
                    if (path.startsWith('http://') || path.startsWith('https://')) {
                      return Image.network(
                        path,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _fallback(),
                      );
                    }
                    final file = File(path);
                    if (!file.existsSync()) return _fallback();
                    return Image.file(file, fit: BoxFit.cover);
                  },
                ),
                if (widget.paths.length > 1)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        'Foto ${_currentIndex + 1}/${widget.paths.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (widget.paths.length > 1)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(widget.paths.length, (index) {
                  final isActive = index == _currentIndex;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: isActive ? 18 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: isActive ? Colors.red.shade700 : Colors.black26,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  );
                }),
              ),
            ),
        ],
      ),
    );
  }

  Widget _fallback() {
    return Container(
      color: const Color(0xFFF3F4F6),
      alignment: Alignment.center,
      child: const Text('Foto tidak ditemukan'),
    );
  }
}

class _BodyCard extends StatelessWidget {
  final Report report;

  const _BodyCard({required this.report});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Deskripsi',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Color(0xFF1F2937)),
          ),
          const SizedBox(height: 12),
          Text(
            report.description,
            style: const TextStyle(fontSize: 14, height: 1.5, color: Color(0xFF4B5563)),
          ),
        ],
      ),
    );
  }
}

class _StaffCard extends StatelessWidget {
  final Report report;

  const _StaffCard({required this.report});

  @override
  Widget build(BuildContext context) {
    final hasFeedback = report.staffFeedback.trim().isNotEmpty;
    final hasReporterFeedback =
        (report.reporterRating != null) || report.reporterFeedback.trim().isNotEmpty;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Feedback Staff',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: Color(0xFF1F2937)),
          ),
          const SizedBox(height: 12),
          if (hasFeedback)
            Text(
              report.staffFeedback,
              style: const TextStyle(fontSize: 14, height: 1.5, color: Color(0xFF4B5563)),
            )
          else
            const Text(
              'Petugas sedang meninjau laporan ini. Mohon tunggu update selanjutnya.',
              style: TextStyle(fontSize: 13, color: Colors.black38, height: 1.5),
            ),
          if (report.status.toLowerCase() == 'selesai') ...[
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 12),
            const Text(
              'Feedback Pengaju',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 15,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 10),
            if (report.needsReporterFeedback)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.hourglass_top_rounded, size: 16, color: Color(0xFF92400E)),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Menunggu feedback dari pengaju untuk menutup case ini sepenuhnya.',
                        style: TextStyle(fontSize: 12, color: Color(0xFF78350F), height: 1.4),
                      ),
                    ),
                  ],
                ),
              )
            else if (hasReporterFeedback)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.verified_rounded, size: 16, color: Color(0xFF166534)),
                        const SizedBox(width: 6),
                        const Text(
                          'Feedback sudah dikirim',
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF166534),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        if (report.reporterRating != null)
                          Row(
                            children: List.generate(5, (index) {
                              final active = (index + 1) <= (report.reporterRating ?? 0);
                              return Icon(
                                active ? Icons.star : Icons.star_border,
                                size: 14,
                                color: const Color(0xFFF59E0B),
                              );
                            }),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      report.reporterFeedback.trim().isEmpty
                          ? 'Pengaju tidak menambahkan catatan.'
                          : report.reporterFeedback,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF065F46),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Belum ada feedback dari pengaju.',
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _Pill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.black45),
          const SizedBox(width: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 200),
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String status;

  const _StatusPill({required this.status});

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

  Color _statusBgColor(String status) {
    switch (status.toLowerCase()) {
      case 'menunggu':
        return const Color(0xFFFFF7ED);
      case 'diproses':
        return const Color(0xFFFEF9C3);
      case 'selesai':
        return const Color(0xFFF0FDF4);
      default:
        return const Color(0xFFF9FAFB);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(status);
    final bgColor = _statusBgColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: bgColor,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            status,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: color.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}

String _formatDateTime(DateTime dt) {
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
  ];
  final m = months[(dt.month - 1).clamp(0, 11)];
  final hh = dt.hour.toString().padLeft(2, '0');
  final mm = dt.minute.toString().padLeft(2, '0');
  return '${dt.day} $m ${dt.year} $hh:$mm';
}
