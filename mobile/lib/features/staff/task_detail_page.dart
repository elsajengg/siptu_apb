import 'package:flutter/material.dart';

import '../../data/api_service.dart';
import 'update_status.dart';

class TaskDetailPage extends StatefulWidget {
  final Map<String, dynamic> task;

  const TaskDetailPage({super.key, required this.task});

  @override
  State<TaskDetailPage> createState() => _TaskDetailPageState();
}

class _TaskDetailPageState extends State<TaskDetailPage> {
  late Map<String, dynamic> _task;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _task = Map<String, dynamic>.from(widget.task);
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    final taskId = _intValue(_task['databaseId'] ?? _task['id']);
    if (taskId == null) return;
    setState(() => _loading = true);
    final result = await ApiService.getTask(taskId);
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (result['success'] == true) {
        _task = Map<String, dynamic>.from(result['data'] as Map);
      }
    });
  }

  Future<void> _openUpdate() async {
    final taskId = _intValue(_task['databaseId'] ?? _task['id']);
    final report = _report;
    if (taskId == null) return;
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => UpdateStatusPage(
          taskDatabaseId: taskId,
          taskId: _task['task_number']?.toString() ?? '-',
          taskTitle: report['title']?.toString() ?? '-',
          taskLocation: report['location']?.toString() ?? '-',
          initialStatus: _task['status']?.toString() == 'resolved'
              ? 'Selesai'
              : 'Progress',
        ),
      ),
    );
    if (changed == true) {
      await _loadDetail();
    }
  }

  Map<String, dynamic> get _report =>
      Map<String, dynamic>.from(_task['report'] as Map? ?? {});

  List<Map<String, dynamic>> get _reportPhotos =>
      (_report['photos'] as List<dynamic>? ?? [])
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();

  List<Map<String, dynamic>> get _updates {
    final updates = (_task['updates'] as List<dynamic>? ?? [])
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
    updates.sort(
      (a, b) => (b['created_at']?.toString() ?? '').compareTo(
        a['created_at']?.toString() ?? '',
      ),
    );
    return updates;
  }

  @override
  Widget build(BuildContext context) {
    final red = Colors.red.shade800;
    final report = _report;
    final isResolved =
        _task['status']?.toString() == 'resolved' ||
        report['status']?.toString() == 'resolved';

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: red,
        foregroundColor: Colors.white,
        title: const Text(
          'Detail Tugas',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadDetail,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          children: [
            if (_loading) const LinearProgressIndicator(minHeight: 2),
            _StatusHeader(task: _task),
            const SizedBox(height: 14),
            _SectionCard(
              title: 'Detail Report',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _DetailRow(
                    label: 'Nomor tugas',
                    value: _task['task_number']?.toString() ?? '-',
                  ),
                  _DetailRow(
                    label: 'Nomor tiket',
                    value: report['ticket_number']?.toString() ?? '-',
                  ),
                  _DetailRow(
                    label: 'Judul',
                    value: report['title']?.toString() ?? '-',
                  ),
                  _DetailRow(
                    label: 'Nama pelapor',
                    value:
                        (report['user'] as Map<String, dynamic>?)?['name']
                            ?.toString() ??
                        '-',
                  ),
                  _DetailRow(
                    label: 'Lokasi',
                    value: report['location']?.toString() ?? '-',
                  ),
                  _DetailRow(
                    label: 'Detail ruangan',
                    value: report['room_detail']?.toString() ?? '-',
                  ),
                  _DetailRow(
                    label: 'Kategori',
                    value: report['category']?.toString() ?? '-',
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Deskripsi Report',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    report['description']?.toString() ?? '-',
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: Color(0xFF4B5563),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _SectionCard(
              title: 'Gambar Report',
              child: _PhotoList(photos: _reportPhotos),
            ),
            const SizedBox(height: 14),
            _SectionCard(
              title: 'Feedback Staff',
              action: isResolved
                  ? null
                  : ElevatedButton.icon(
                      onPressed: _openUpdate,
                      icon: const Icon(Icons.edit_note_rounded, size: 18),
                      label: const Text('Update Tugas'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: red,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
              child: _UpdateList(updates: _updates),
            ),
            const SizedBox(height: 14),
            _SectionCard(
              title: 'Feedback User',
              child: _ReporterFeedback(report: report),
            ),
          ],
        ),
      ),
      floatingActionButton: isResolved
          ? null
          : FloatingActionButton.extended(
              onPressed: _openUpdate,
              backgroundColor: red,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add_task_rounded),
              label: const Text('Update Tugas'),
            ),
    );
  }
}

class _ReporterFeedback extends StatelessWidget {
  final Map<String, dynamic> report;

  const _ReporterFeedback({required this.report});

  @override
  Widget build(BuildContext context) {
    final rating = report['rating'];
    final notes = report['feedback_notes']?.toString() ?? '';
    if (rating == null && notes.isEmpty) {
      return const Text(
        'User belum memberikan feedback untuk hasil pengerjaan.',
        style: TextStyle(fontSize: 13, color: Colors.black38, height: 1.4),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (rating != null) ...[
            Row(
              children: [
                ...List.generate(5, (index) {
                  return Icon(
                    index < (int.tryParse(rating.toString()) ?? 0)
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                    color: const Color(0xFFF59E0B),
                    size: 20,
                  );
                }),
                const SizedBox(width: 8),
                Text(
                  '$rating/5',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF111827),
                  ),
                ),
              ],
            ),
          ],
          if (notes.isNotEmpty) ...[
            if (rating != null) const SizedBox(height: 10),
            Text(
              notes,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF374151),
                height: 1.45,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusHeader extends StatelessWidget {
  final Map<String, dynamic> task;

  const _StatusHeader({required this.task});

  @override
  Widget build(BuildContext context) {
    final status = _statusLabel(task['status']?.toString());
    final color = _statusColor(status);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.12),
            foregroundColor: color,
            child: Icon(
              status == 'Selesai'
                  ? Icons.task_alt_rounded
                  : Icons.engineering_rounded,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task['task_number']?.toString() ?? '-',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Status: $status',
                  style: TextStyle(
                    fontSize: 12,
                    color: color,
                    fontWeight: FontWeight.w700,
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

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? action;

  const _SectionCard({required this.title, required this.child, this.action});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ),
              ?action,
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 108,
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
          ),
          const Text(': ', style: TextStyle(color: Colors.black45)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF111827),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoList extends StatelessWidget {
  final List<Map<String, dynamic>> photos;

  const _PhotoList({required this.photos});

  @override
  Widget build(BuildContext context) {
    if (photos.isEmpty) {
      return const Text(
        'Tidak ada gambar report.',
        style: TextStyle(fontSize: 13, color: Colors.black38),
      );
    }
    return SizedBox(
      height: 150,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: photos.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final url = ApiService.mediaUrl(photos[index]['path']?.toString());
          return InkWell(
            onTap: () => _showImages(context, [url]),
            borderRadius: BorderRadius.circular(12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                url,
                width: 210,
                height: 150,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _imageFallback(),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _UpdateList extends StatelessWidget {
  final List<Map<String, dynamic>> updates;

  const _UpdateList({required this.updates});

  @override
  Widget build(BuildContext context) {
    if (updates.isEmpty) {
      return const Text(
        'Belum ada feedback staff. Tekan Update Tugas untuk menambahkan progress.',
        style: TextStyle(fontSize: 13, color: Colors.black38, height: 1.4),
      );
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: updates.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        return _UpdateTile(update: updates[index]);
      },
    );
  }
}

class _UpdateTile extends StatelessWidget {
  final Map<String, dynamic> update;

  const _UpdateTile({required this.update});

  @override
  Widget build(BuildContext context) {
    final status = _statusLabel(update['status']?.toString());
    final photos = (update['photos'] as List<dynamic>? ?? [])
        .map((item) => Map<String, dynamic>.from(item as Map))
        .map((photo) => ApiService.mediaUrl(photo['path']?.toString()))
        .where((path) => path.isNotEmpty)
        .toList();
    return InkWell(
      onTap: () => _showUpdateDetail(context, update, photos),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              status == 'Selesai'
                  ? Icons.task_alt_rounded
                  : Icons.engineering_rounded,
              color: _statusColor(status),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        status,
                        style: TextStyle(
                          fontSize: 12,
                          color: _statusColor(status),
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        _formatDate(update['created_at']?.toString()),
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.black38,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    update['notes']?.toString() ?? '-',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF4B5563),
                      height: 1.4,
                    ),
                  ),
                  if (photos.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      '${photos.length} foto proses',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF2563EB),
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded, color: Colors.black26),
          ],
        ),
      ),
    );
  }
}

void _showUpdateDetail(
  BuildContext context,
  Map<String, dynamic> update,
  List<String> photos,
) {
  final status = _statusLabel(update['status']?.toString());
  final author =
      (update['author'] as Map<String, dynamic>?)?['name']?.toString() ??
      'Staff';
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.72,
      maxChildSize: 0.92,
      builder: (context, controller) {
        return ListView(
          controller: controller,
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
          children: [
            Center(
              child: Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Update $status',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 4),
            Text(
              '$author - ${_formatDate(update['created_at']?.toString())}',
              style: const TextStyle(fontSize: 12, color: Colors.black45),
            ),
            const SizedBox(height: 18),
            Text(
              update['notes']?.toString() ?? '-',
              style: const TextStyle(
                fontSize: 14,
                height: 1.55,
                color: Color(0xFF374151),
              ),
            ),
            if (photos.isNotEmpty) ...[
              const SizedBox(height: 18),
              const Text(
                'Foto Proses',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),
              ...photos.map(
                (url) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: () => _showImages(context, photos),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.network(
                        url,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _imageFallback(),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        );
      },
    ),
  );
}

void _showImages(BuildContext context, List<String> urls) {
  showDialog(
    context: context,
    builder: (context) => Dialog(
      insetPadding: const EdgeInsets.all(16),
      backgroundColor: Colors.transparent,
      child: Stack(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 44),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: urls.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) => ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  urls[index],
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      _imageFallback(),
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _imageFallback() {
  return Container(
    width: 210,
    height: 150,
    color: const Color(0xFFF3F4F6),
    alignment: Alignment.center,
    child: const Text(
      'Foto tidak dapat dimuat',
      style: TextStyle(fontSize: 12, color: Colors.black45),
    ),
  );
}

int? _intValue(Object? value) {
  if (value is int) return value;
  return int.tryParse(value?.toString() ?? '');
}

String _statusLabel(String? status) {
  return switch (status) {
    'assigned' => 'Baru',
    'on_progress' => 'Progress',
    'resolved' => 'Selesai',
    'blocked' => 'Terkendala',
    _ => status ?? 'Baru',
  };
}

Color _statusColor(String status) {
  return switch (status.toLowerCase()) {
    'baru' => const Color(0xFFF97316),
    'progress' => const Color(0xFF2563EB),
    'selesai' => const Color(0xFF16A34A),
    'terkendala' => const Color(0xFFDC2626),
    _ => const Color(0xFF6B7280),
  };
}

String _formatDate(String? raw) {
  final date = DateTime.tryParse(raw ?? '');
  if (date == null) return raw?.isNotEmpty == true ? raw! : '-';
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];
  final month = months[(date.month - 1).clamp(0, 11)];
  final hh = date.hour.toString().padLeft(2, '0');
  final mm = date.minute.toString().padLeft(2, '0');
  return '${date.day} $month ${date.year} $hh:$mm';
}
