import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/report_provider.dart';
import 'report_detail_page.dart';
import 'report_feed_page.dart';

class TopPengaduanPage extends StatelessWidget {
  final List<Report> reports;
  final String currentUser;

  const TopPengaduanPage({
    super.key,
    required this.reports,
    required this.currentUser,
  });

  @override
  Widget build(BuildContext context) {
    final red = Colors.red.shade800;
    final providerReports = context.watch<ReportProvider>().reports;
    final sourceReports = providerReports.isEmpty ? reports : providerReports;
    final sorted = [...sourceReports]
      ..sort((a, b) {
        final byLikes = b.likes.compareTo(a.likes);
        if (byLikes != 0) return byLikes;
        return b.createdAt.compareTo(a.createdAt);
      });

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: red,
        foregroundColor: Colors.white,
        title: const Text(
          'Top Pengaduan',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: sorted.isEmpty
          ? const Center(
              child: Text(
                'Belum ada pengaduan untuk ditampilkan.',
                style: TextStyle(color: Colors.black45),
              ),
            )
          : RefreshIndicator(
              onRefresh: context.read<ReportProvider>().loadFeed,
              child: ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                itemCount: sorted.length,
                itemBuilder: (context, index) {
                  final report = sorted[index];
                  return _TopPengaduanTile(
                    rank: index + 1,
                    report: report,
                    currentUser: currentUser,
                  );
                },
              ),
            ),
    );
  }
}

class _TopPengaduanTile extends StatelessWidget {
  final int rank;
  final Report report;
  final String currentUser;

  const _TopPengaduanTile({
    required this.rank,
    required this.report,
    required this.currentUser,
  });

  @override
  Widget build(BuildContext context) {
    final isLiked = report.likedBy.contains(currentUser);
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => ReportDetailPage(report: report)),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((0.04 * 255).round()),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: rank <= 3
                    ? const Color(0xFFFFFBEB)
                    : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: rank <= 3
                      ? const Color(0xFFFDE68A)
                      : const Color(0xFFE5E7EB),
                ),
              ),
              child: Text(
                '#$rank',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  color: rank <= 3
                      ? const Color(0xFF92400E)
                      : const Color(0xFF4B5563),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    report.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '@${report.createdBy} - ${report.category}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.place_outlined,
                        size: 14,
                        color: Colors.black38,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          report.location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black45,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            UpvoteButtonWidget(
              upvotes: report.likes,
              isUpvoted: isLiked,
              onToggle: () {
                context.read<ReportProvider>().toggleLike(
                  report.id,
                  currentUser,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
