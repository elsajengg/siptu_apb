import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

import 'report_create_page.dart';
import 'report_detail_page.dart';
import '../home/home_shell.dart';
import 'package:provider/provider.dart';
import '../../providers/report_provider.dart';

class ReportFeedPage extends StatefulWidget {
  const ReportFeedPage({super.key});

  @override
  State<ReportFeedPage> createState() => _ReportFeedPageState();
}

class _ReportFeedPageState extends State<ReportFeedPage> {
  final String _currentUser =
      'mahasiswa_aktif'; // Simulate current logged-in user

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReportProvider>().loadFeed();
    });
  }

  void _like(String reportId, bool currentlyLiked) {
    context.read<ReportProvider>().toggleLike(reportId, _currentUser);
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(milliseconds: 900),
        content: Text(
          currentlyLiked
              ? 'Dukungan dibatalkan.'
              : 'Terima kasih sudah mendukung laporan ini.',
        ),
      ),
    );
  }

  Future<void> _openCreate() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const ReportCreatePage(currentUser: 'mahasiswa_aktif'),
      ),
    );
    if (mounted) {
      await context.read<ReportProvider>().loadFeed();
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ReportProvider>();
    final _reports = provider.reports;
    final topReports = [..._reports]
      ..sort((a, b) {
        final byLikes = b.likes.compareTo(a.likes);
        if (byLikes != 0) return byLikes;
        return b.createdAt.compareTo(a.createdAt);
      });
    final top3 = topReports.take(3).toList();
    final totalDukungan = _reports.fold<int>(0, (sum, r) => sum + r.likes);
    final totalSelesai = _reports
        .where((r) => r.status.toLowerCase() == 'selesai')
        .length;
    final totalDiproses = _reports
        .where((r) => r.status.toLowerCase() == 'diproses')
        .length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.red.shade900, Colors.red.shade700],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          _buildHeader(
            top3: top3,
            totalDukungan: totalDukungan,
            totalDiproses: totalDiproses,
            totalSelesai: totalSelesai,
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: context.read<ReportProvider>().loadFeed,
              child: provider.loading && _reports.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 10, 16, 90),
                      itemCount: _reports.length,
                      itemBuilder: (context, i) {
                        return _ReportCard(
                          key: ValueKey(_reports[i].id),
                          report: _reports[i],
                          currentUser: _currentUser,
                          onLike: () => _like(
                            _reports[i].id,
                            _reports[i].likedBy.contains(_currentUser),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.red.shade800,
        onPressed: _openCreate,
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Buat Pengaduan',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildHeader({
    required List<Report> top3,
    required int totalDukungan,
    required int totalDiproses,
    required int totalSelesai,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: LinearGradient(
                colors: [Colors.red.shade900, Colors.red.shade700],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.shade200.withAlpha((0.6 * 255).round()),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Pantau laporan kampus, beri dukungan, dan bantu percepat tindak lanjut.',
                    style: TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha((0.15 * 255).round()),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.local_fire_department,
                        size: 16,
                        color: Colors.amber.shade300,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Trending',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _StatsChip(
                  icon: Icons.thumb_up_alt_outlined,
                  label: 'Total Dukungan',
                  value: '$totalDukungan',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatsChip(
                  icon: Icons.settings_suggest_outlined,
                  label: 'Diproses',
                  value: '$totalDiproses',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatsChip(
                  icon: Icons.task_alt_outlined,
                  label: 'Selesai',
                  value: '$totalSelesai',
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (top3.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: const Center(
                child: Text(
                  'Belum ada pelaporan yang bisa dirangking.',
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ),
            )
          else
            SizedBox(
              height: 126,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: top3.length,
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (_, i) {
                  final item = top3[i];
                  return _TopReportCard(
                    key: ValueKey('${item.id}-${item.likes}'),
                    report: item,
                    rank: i + 1,
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final Report report;
  final String currentUser;
  final VoidCallback onLike;

  const _ReportCard({
    super.key,
    required this.report,
    required this.currentUser,
    required this.onLike,
  });

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'diproses':
        return const Color(0xFFF97316);
      case 'selesai':
        return const Color(0xFF16A34A);
      default:
        return const Color(0xFF6B7280);
    }
  }

  @override
  Widget build(BuildContext context) {
    final time = _formatTime(report.createdAt);
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => ReportDetailPage(report: report)),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE5E7EB)),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((0.05 * 255).round()),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: const Color(0xFFFEE2E2),
                  foregroundColor: const Color(0xFF991B1B),
                  child: Text(
                    report.createdBy.trim().isEmpty
                        ? '?'
                        : report.createdBy.trim()[0].toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              report.title,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            time,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.black45,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '@${report.createdBy} • ${report.category}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              report.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, color: Color(0xFF4B5563)),
            ),
            if ((report.coverPhotoPath ?? '').trim().isNotEmpty) ...[
              const SizedBox(height: 10),
              _ReportPhoto(
                photoPath: report.coverPhotoPath!.trim(),
                photoBytes: report.coverPhotoBytes,
              ),
            ],
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.place, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    report.location,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: const Color(0xFFF3F4F6),
                  ),
                  child: Text(
                    report.category,
                    style: const TextStyle(fontSize: 11),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: _statusColor(
                      report.status,
                    ).withAlpha((0.10 * 255).round()),
                  ),
                  child: Text(
                    report.status,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: _statusColor(report.status),
                    ),
                  ),
                ),
                const Spacer(),
                UpvoteButtonWidget(
                  upvotes: report.likes,
                  isUpvoted: report.likedBy.contains(currentUser),
                  onToggle: onLike,
                ),
              ],
            ),
            if (report.staffFeedback.isNotEmpty) ...[
              const Divider(height: 18),
              Text(
                'Update staff: ${report.staffName}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF166534),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                report.staffFeedback,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatsChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatsChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF991B1B)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF111827),
                  ),
                ),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.black54,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportPhoto extends StatelessWidget {
  final String photoPath;
  final Uint8List? photoBytes;

  const _ReportPhoto({required this.photoPath, this.photoBytes});

  @override
  Widget build(BuildContext context) {
    if (photoBytes != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Image.memory(
            photoBytes!,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _imageFallback(),
          ),
        ),
      );
    }
    final isUrl =
        photoPath.startsWith('http://') || photoPath.startsWith('https://');
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: isUrl
            ? Image.network(
                photoPath,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _imageFallback(),
              )
            : (!kIsWeb
                  ? Image.file(
                      File(photoPath),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _imageFallback(),
                    )
                  : _imageFallback()),
      ),
    );
  }

  Widget _imageFallback() {
    return Container(
      color: const Color(0xFFF3F4F6),
      alignment: Alignment.center,
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.broken_image_outlined, color: Colors.black38, size: 28),
          SizedBox(height: 6),
          Text(
            'Foto tidak tersedia',
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

class _TopReportCard extends StatelessWidget {
  final Report report;
  final int rank;

  const _TopReportCard({super.key, required this.report, required this.rank});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 235,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          colors: [Colors.red.shade800, Colors.red.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha((0.2 * 255).round()),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Top $rank',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.thumb_up_alt_rounded,
                size: 16,
                color: Colors.white,
              ),
              const SizedBox(width: 4),
              Text(
                '${report.likes}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            report.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
          const Spacer(),
          Text(
            '@${report.createdBy}',
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

String _formatTime(DateTime dt) {
  final hh = dt.hour.toString().padLeft(2, '0');
  final mm = dt.minute.toString().padLeft(2, '0');
  return '$hh:$mm';
}

class UpvoteButtonWidget extends StatelessWidget {
  final int upvotes;
  final bool isUpvoted;
  final VoidCallback onToggle;

  const UpvoteButtonWidget({
    super.key,
    required this.upvotes,
    required this.isUpvoted,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final color = isUpvoted ? Colors.red.shade800 : Colors.black54;
    final bgColor = isUpvoted ? Colors.red.shade50 : Colors.transparent;
    final borderColor = isUpvoted ? Colors.red.shade200 : Colors.black12;

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 300),
      tween: Tween<double>(begin: 1.0, end: isUpvoted ? 1.15 : 1.0),
      curve: Curves.elasticOut,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onToggle,
              borderRadius: BorderRadius.circular(8),
              splashColor: Colors.red.withOpacity(0.2),
              highlightColor: Colors.red.withOpacity(0.1),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: bgColor,
                  border: Border.all(color: borderColor, width: 1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.keyboard_arrow_up_rounded,
                      size: 22,
                      color: color,
                    ),
                    Text(
                      '$upvotes',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
