import 'package:flutter/material.dart';

import '../models/report.dart';
import 'report_image.dart';

String _reportDisplayName(String createdBy) {
  if (createdBy.trim().isEmpty) return 'Pengguna';
  final raw = createdBy.trim();
  final head = raw.split(RegExp(r'[._]')).firstWhere(
        (s) => s.isNotEmpty,
        orElse: () => raw,
      );
  if (head.isEmpty) return 'Pengguna';
  return head[0].toUpperCase() + head.substring(1).toLowerCase();
}

String _reportHandle(String createdBy) {
  final h = createdBy.trim().isEmpty ? 'pengguna' : createdBy.trim();
  return h.startsWith('@') ? h : '@$h';
}

String _reportShortTime(DateTime d) {
  final now = DateTime.now();
  var diff = now.difference(d);
  if (diff.isNegative) diff = Duration.zero;
  if (diff.inMinutes < 1) return 'baru';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m';
  if (diff.inHours < 24) return '${diff.inHours}j';
  if (diff.inDays < 7) return '${diff.inDays}h';
  return '${d.day}/${d.month}/${d.year}';
}

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

/// Kartu laporan bergaya postingan sosial: avatar, nama, @handle, waktu, teks, foto responsif.
class ReportPostCard extends StatelessWidget {
  const ReportPostCard({
    super.key,
    required this.report,
    required this.onLike,
  });

  final Report report;
  final VoidCallback onLike;

  double _imageMaxHeight(BuildContext context) {
    final sh = MediaQuery.sizeOf(context).height;
    final sw = MediaQuery.sizeOf(context).width;
    return (sh * 0.28).clamp(140.0, (sw * 0.72).clamp(200.0, 280.0));
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final name = _reportDisplayName(report.createdBy);
    final handle = _reportHandle(report.createdBy);
    final time = _reportShortTime(report.createdAt);
    final statusC = _statusColor(report.status);
    final initial =
        name.isNotEmpty ? name.substring(0, 1).toUpperCase() : '?';

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _openDetail(context),
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE8EAEE)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor:
                    scheme.primary.withValues(alpha: 0.14),
                child: Text(
                  initial,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: scheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 4,
                            runSpacing: 2,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                ),
                              ),
                              Icon(
                                Icons.verified_rounded,
                                size: 16,
                                color: scheme.primary,
                              ),
                              Text(
                                '$handle · $time',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: statusC.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            report.status,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: statusC,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      report.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      report.description,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.45,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${report.location} · ${report.category}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    if (report.images.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _PostMedia(
                        src: report.images.first,
                        extraCount: report.images.length - 1,
                        maxHeight: _imageMaxHeight(context),
                      ),
                    ],
                    const SizedBox(height: 10),
                    _ActionRow(
                      scheme: scheme,
                      likes: report.likes,
                      onLike: onLike,
                    ),
                    if (report.staffFeedback.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      _StaffReply(
                        name: report.staffName,
                        text: report.staffFeedback,
                      ),
                    ] else ...[
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFB),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.hourglass_empty_rounded,
                              size: 16,
                              color: Colors.grey.shade500,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Menunggu tanggapan staff.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openDetail(BuildContext context) {
    final maxImg = (MediaQuery.sizeOf(context).height * 0.38)
        .clamp(180.0, 360.0);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final dn = _reportDisplayName(report.createdBy);
        final av = dn.isNotEmpty ? dn.substring(0, 1).toUpperCase() : '?';
        return DraggableScrollableSheet(
          initialChildSize: 0.78,
          minChildSize: 0.45,
          maxChildSize: 0.96,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 20,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(18, 10, 18, 28),
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.14),
                        child: Text(
                          av,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              dn,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              '${_reportHandle(report.createdBy)} · ${_reportShortTime(report.createdAt)}',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  if (report.images.isNotEmpty) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxHeight: maxImg),
                        child: PageView.builder(
                          itemCount: report.images.length,
                          itemBuilder: (context, i) {
                            return ColoredBox(
                              color: const Color(0xFFF3F4F6),
                              child: reportImage(
                                report.images[i],
                                fit: BoxFit.contain,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    if (report.images.length > 1)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'Geser untuk foto lain · ${report.images.length} total',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                  ],
                  Text(
                    report.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    report.description,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _detailLine(Icons.place_outlined, report.location),
                  _detailLine(Icons.category_outlined, report.category),
                  _detailLine(Icons.flag_outlined, 'Status: ${report.status}'),
                  const SizedBox(height: 18),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  const Text(
                    'Feedback staff',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  if (report.staffFeedback.isNotEmpty)
                    Text(
                      '${report.staffName}\n${report.staffFeedback}',
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.45,
                        color: Colors.grey.shade800,
                      ),
                    )
                  else
                    Text(
                      'Belum ada feedback.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  static Widget _detailLine(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade800),
            ),
          ),
        ],
      ),
    );
  }
}

class _PostMedia extends StatelessWidget {
  const _PostMedia({
    required this.src,
    required this.extraCount,
    required this.maxHeight,
  });

  final String src;
  final int extraCount;
  final double maxHeight;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: ColoredBox(
        color: const Color(0xFFF0F2F5),
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: double.infinity,
              height: maxHeight,
              child: reportImage(src, fit: BoxFit.contain),
            ),
            if (extraCount > 0)
              Positioned(
                bottom: 8,
                right: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '+$extraCount foto',
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
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.scheme,
    required this.likes,
    required this.onLike,
  });

  final ColorScheme scheme;
  final int likes;
  final VoidCallback onLike;

  @override
  Widget build(BuildContext context) {
    final iconColor = Colors.grey.shade600;

    Widget iconBtn(IconData icon, {VoidCallback? onTap}) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, size: 20, color: iconColor),
        ),
      );
    }

    return Row(
      children: [
        iconBtn(Icons.chat_bubble_outline_rounded),
        const Spacer(),
        iconBtn(Icons.repeat_rounded),
        const Spacer(),
        InkWell(
          onTap: onLike,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.favorite_border_rounded,
                  size: 20,
                  color: scheme.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  '$likes',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
          ),
        ),
        const Spacer(),
        iconBtn(Icons.bookmark_border_rounded),
        const Spacer(),
        iconBtn(Icons.share_rounded),
      ],
    );
  }
}

class _StaffReply extends StatelessWidget {
  const _StaffReply({required this.name, required this.text});

  final String name;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFBBF7D0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.support_agent_rounded,
              size: 20, color: Colors.green.shade700),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Colors.green.shade900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  text,
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    color: Colors.grey.shade800,
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
