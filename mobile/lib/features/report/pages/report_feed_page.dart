import 'package:flutter/material.dart';

import '../data/report_dummy_data.dart';
import '../models/report.dart';
import '../widgets/report_post_card.dart';
import 'create_report_page.dart';

class ReportFeedPage extends StatefulWidget {
  const ReportFeedPage({super.key});

  @override
  State<ReportFeedPage> createState() => _ReportFeedPageState();
}

class _ReportFeedPageState extends State<ReportFeedPage> {
  late List<Report> _reports;

  @override
  void initState() {
    super.initState();
    _reports = List.of(kReportDummyList);
  }

  void _like(int index) {
    final r = _reports[index];
    setState(() {
      _reports[index] = Report(
        title: r.title,
        description: r.description,
        location: r.location,
        category: r.category,
        status: r.status,
        createdBy: r.createdBy,
        likes: r.likes + 1,
        staffName: r.staffName,
        staffFeedback: r.staffFeedback,
        createdAt: r.createdAt,
        images: r.images,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final red = scheme.primary;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            pinned: true,
            backgroundColor: red,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('Forum laporan'),
              background: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      red,
                      Color.lerp(red, Colors.black, 0.1)!,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(child: _buildIntroBanner(context)),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(14, 4, 14, 100),
            sliver: SliverList.separated(
              itemCount: _reports.length,
              separatorBuilder: (context, _) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                return ReportPostCard(
                  report: _reports[i],
                  onLike: () => _like(i),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openCreateReport(context),
        icon: const Icon(Icons.edit_document),
        label: const Text('Buat laporan'),
      ),
    );
  }

  Widget _buildIntroBanner(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFFFEE2E2).withValues(alpha: 0.85),
              Colors.white,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFFECACA)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: primary.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(Icons.forum_outlined, color: primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Alur mirip postingan',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: Colors.grey.shade900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Avatar, teks, lalu foto yang menyesuaikan lebar layar — tap kartu untuk detail.',
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.35,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openCreateReport(BuildContext context) async {
    final report = await Navigator.of(context).push<Report>(
      MaterialPageRoute(builder: (_) => const CreateReportPage()),
    );
    if (!context.mounted || report == null) return;
    setState(() => _reports.insert(0, report));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: const Text('Laporan ditambahkan ke feed.'),
      ),
    );
  }
}
