import 'package:flutter/material.dart';
import 'export_page.dart';

class ReportItem {
  final String id;
  final String title;
  final String description;
  final String category;
  final String location;
  final String requester;
  final DateTime date;
  final int upvotes;
  String status;
  String? assignedStaff;
  DateTime? completedDate;

  ReportItem({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.location,
    required this.requester,
    required this.date,
    required this.upvotes,
    this.status = 'pending',
    this.assignedStaff,
    this.completedDate,
  });

  String get formattedDate {
    return '${date.day.toString().padLeft(2, '0')} '
        '${_monthName(date.month)} ${date.year}';
  }

  String? get formattedCompletedDate {
    if (completedDate == null) return null;
    return '${completedDate!.day.toString().padLeft(2, '0')} '
        '${_monthName(completedDate!.month)} ${completedDate!.year}';
  }

  static String _monthName(int month) {
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
    return months[month - 1];
  }
}

class StaffOption {
  final String id;
  final String name;
  final String specialization;
  final int activeTask;

  StaffOption({
    required this.id,
    required this.name,
    required this.specialization,
    required this.activeTask,
  });
}

enum FilterDay { hariIni, kemarin, tujuhHari, custom }

class VerifyReportPage extends StatefulWidget {
  const VerifyReportPage({super.key});

  @override
  State<VerifyReportPage> createState() => _VerifyReportPageState();
}

class _VerifyReportPageState extends State<VerifyReportPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  FilterDay _selectedFilter = FilterDay.hariIni;
  DateTime? _customDate;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<StaffOption> _staffList = [
    StaffOption(
      id: 'STF-001',
      name: 'Ahmad Fauzi',
      specialization: 'Penerangan & Elektronik',
      activeTask: 2,
    ),
    StaffOption(
      id: 'STF-002',
      name: 'Budi Santoso',
      specialization: 'AC & Kenyamanan Ruangan',
      activeTask: 1,
    ),
    StaffOption(
      id: 'STF-003',
      name: 'Citra Dewi',
      specialization: 'Sanitasi & Kebersihan',
      activeTask: 3,
    ),
    StaffOption(
      id: 'STF-004',
      name: 'Dendi Pratama',
      specialization: 'Furnitur & Infrastruktur',
      activeTask: 0,
    ),
  ];

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
      status: 'done',
      assignedStaff: 'Dendi Pratama',
      completedDate: DateTime.now().subtract(const Duration(hours: 3)),
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
      status: 'done',
      assignedStaff: 'Citra Dewi',
      completedDate: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _searchController.addListener(() {
      setState(
        () => _searchQuery = _searchController.text.toLowerCase().trim(),
      );
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<ReportItem> get _filteredByDate {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return _allReports.where((r) {
      final reportDate = DateTime(r.date.year, r.date.month, r.date.day);
      switch (_selectedFilter) {
        case FilterDay.hariIni:
          return reportDate == today;
        case FilterDay.kemarin:
          return reportDate == today.subtract(const Duration(days: 1));
        case FilterDay.tujuhHari:
          return reportDate.isAfter(today.subtract(const Duration(days: 7)));
        case FilterDay.custom:
          if (_customDate == null) return true;
          final custom = DateTime(
            _customDate!.year,
            _customDate!.month,
            _customDate!.day,
          );
          return reportDate == custom;
      }
    }).toList();
  }

  List<ReportItem> get _filteredReports {
    if (_searchQuery.isEmpty) return _filteredByDate;
    return _filteredByDate.where((r) {
      return r.title.toLowerCase().contains(_searchQuery) ||
          r.id.toLowerCase().contains(_searchQuery) ||
          r.category.toLowerCase().contains(_searchQuery) ||
          r.location.toLowerCase().contains(_searchQuery) ||
          r.requester.toLowerCase().contains(_searchQuery);
    }).toList();
  }

  List<ReportItem> get _pending =>
      _filteredReports.where((r) => r.status == 'pending').toList();
  List<ReportItem> get _acc =>
      _filteredReports.where((r) => r.status == 'acc').toList();
  List<ReportItem> get _done =>
      _filteredReports.where((r) => r.status == 'done').toList();
  List<ReportItem> get _reject =>
      _filteredReports.where((r) => r.status == 'reject').toList();

  Future<void> _pickCustomDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(primary: Colors.red.shade800),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _customDate = picked;
        _selectedFilter = FilterDay.custom;
      });
    }
  }

  // ── Bottom Sheet: Terima + Tugaskan Staff ────────────────────
  void _showTerimaBottomSheet(ReportItem report) {
    StaffOption? selectedStaff;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final red = Colors.red.shade800;

            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 12),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.black12,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.check_circle_outline,
                            color: Colors.green,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Terima & Tugaskan Staff',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Pilih staff yang akan menangani laporan ini',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black45,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                report.title,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.category_outlined,
                                    size: 12,
                                    color: Colors.black45,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    report.category,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  const Icon(
                                    Icons.location_on_outlined,
                                    size: 12,
                                    color: Colors.black45,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      report.location,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Colors.black54,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            report.id,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.orange,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        const Text(
                          'Pilih Staff',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '(${_staffList.length} tersedia)',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black45,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _staffList.length,
                      itemBuilder: (context, index) {
                        final staff = _staffList[index];
                        final isSelected = selectedStaff?.id == staff.id;
                        return GestureDetector(
                          onTap: () =>
                              setSheetState(() => selectedStaff = staff),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? red.withOpacity(0.06)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSelected ? red : Colors.black12,
                                width: isSelected ? 1.5 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: isSelected
                                      ? red
                                      : const Color(0xFFE5E7EB),
                                  radius: 20,
                                  child: Text(
                                    staff.name[0],
                                    style: TextStyle(
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.black54,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        staff.name,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        staff.specialization,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Colors.black54,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${staff.activeTask} tugas aktif',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: staff.activeTask > 2
                                              ? Colors.orange
                                              : Colors.green,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isSelected)
                                  Icon(
                                    Icons.check_circle,
                                    color: red,
                                    size: 20,
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
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
                          backgroundColor: selectedStaff != null
                              ? Colors.green
                              : Colors.grey.shade400,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: selectedStaff == null
                            ? null
                            : () {
                                setState(() {
                                  report.status = 'acc';
                                  report.assignedStaff = selectedStaff!.name;
                                });
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      '✓ Laporan diterima & ditugaskan ke ${selectedStaff!.name}',
                                    ),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              },
                        icon: const Icon(Icons.assignment_ind_outlined),
                        label: Text(
                          selectedStaff != null
                              ? 'Terima & Tugaskan ke ${selectedStaff!.name}'
                              : 'Pilih Staff Terlebih Dahulu',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
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

  void _rejectReport(ReportItem report) {
    final reasonCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Alasan Penolakan'),
        content: TextField(
          controller: reasonCtrl,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Masukkan alasan penolakan...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              setState(() => report.status = 'reject');
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Pengaduan "${report.title}" ditolak.'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text('Tolak'),
          ),
        ],
      ),
    );
  }

  void _showDetailDialog(ReportItem report) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          report.title,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _DetailRow(icon: Icons.tag, label: 'ID', value: report.id),
              _DetailRow(
                icon: Icons.category_outlined,
                label: 'Kategori',
                value: report.category,
              ),
              _DetailRow(
                icon: Icons.location_on_outlined,
                label: 'Lokasi',
                value: report.location,
              ),
              _DetailRow(
                icon: Icons.person_outline,
                label: 'Pelapor',
                value: report.requester,
              ),
              _DetailRow(
                icon: Icons.access_time,
                label: 'Tanggal',
                value: report.formattedDate,
              ),
              _DetailRow(
                icon: Icons.thumb_up_outlined,
                label: 'Upvote',
                value: report.upvotes.toString(),
              ),
              if (report.assignedStaff != null)
                _DetailRow(
                  icon: Icons.assignment_ind_outlined,
                  label: 'Ditugaskan ke',
                  value: report.assignedStaff!,
                ),
              if (report.formattedCompletedDate != null)
                _DetailRow(
                  icon: Icons.check_circle_outline,
                  label: 'Selesai pada',
                  value: report.formattedCompletedDate!,
                ),
              const SizedBox(height: 8),
              const Text(
                'Deskripsi:',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              const SizedBox(height: 4),
              Text(
                report.description,
                style: const TextStyle(fontSize: 13, color: Colors.black87),
              ),
            ],
          ),
        ),
        actions: [
          if (report.status == 'pending') ...[
            TextButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _rejectReport(report);
              },
              icon: const Icon(Icons.close, color: Colors.red),
              label: const Text('Tolak', style: TextStyle(color: Colors.red)),
            ),
            FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () {
                Navigator.pop(context);
                _showTerimaBottomSheet(report);
              },
              icon: const Icon(Icons.check),
              label: const Text('Terima'),
            ),
          ] else
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tutup'),
            ),
        ],
      ),
    );
  }

  String get _filterLabel {
    switch (_selectedFilter) {
      case FilterDay.hariIni:
        return 'Hari Ini';
      case FilterDay.kemarin:
        return 'Kemarin';
      case FilterDay.tujuhHari:
        return '7 Hari';
      case FilterDay.custom:
        if (_customDate != null) {
          return '${_customDate!.day}/${_customDate!.month}/${_customDate!.year}';
        }
        return 'Pilih Tanggal';
    }
  }

  @override
  Widget build(BuildContext context) {
    final red = Colors.red.shade800;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: red,
        elevation: 0,
        title: const Text(
          'Manajemen Pengaduan',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        // ── Tombol Export di AppBar ──────────────────────────
        actions: [
          IconButton(
            icon: const Icon(Icons.download_outlined, color: Colors.white),
            tooltip: 'Export PDF',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ExportPage()),
            ),
          ),
          const SizedBox(width: 4),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: [
            Tab(text: 'Pending (${_pending.length})'),
            Tab(text: 'Diterima (${_acc.length})'),
            Tab(text: 'Selesai (${_done.length})'),
            Tab(text: 'Ditolak (${_reject.length})'),
          ],
        ),
      ),
      body: Column(
        children: [
          // ── Search Bar ─────────────────────────────────────────
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Cari judul, ID, kategori, lokasi, pelapor...',
                hintStyle: const TextStyle(fontSize: 13, color: Colors.black38),
                prefixIcon: const Icon(
                  Icons.search,
                  color: Colors.black38,
                  size: 20,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          Icons.close,
                          size: 18,
                          color: Colors.black45,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          FocusScope.of(context).unfocus();
                        },
                      )
                    : null,
                filled: true,
                fillColor: const Color(0xFFF3F4F6),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: red, width: 1.5),
                ),
              ),
            ),
          ),

          // ── Filter Bar ─────────────────────────────────────────
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Filter Laporan',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _FilterChip(
                        label: 'Hari Ini',
                        isSelected: _selectedFilter == FilterDay.hariIni,
                        color: red,
                        onTap: () =>
                            setState(() => _selectedFilter = FilterDay.hariIni),
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: 'Kemarin',
                        isSelected: _selectedFilter == FilterDay.kemarin,
                        color: red,
                        onTap: () =>
                            setState(() => _selectedFilter = FilterDay.kemarin),
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: '7 Hari Terakhir',
                        isSelected: _selectedFilter == FilterDay.tujuhHari,
                        color: red,
                        onTap: () => setState(
                          () => _selectedFilter = FilterDay.tujuhHari,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: '📅 Pilih Tanggal',
                        isSelected: _selectedFilter == FilterDay.custom,
                        color: red,
                        onTap: _pickCustomDate,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      'Filter: $_filterLabel',
                      style: TextStyle(
                        fontSize: 11,
                        color: red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (_searchQuery.isNotEmpty) ...[
                      const Text(
                        ' • ',
                        style: TextStyle(fontSize: 11, color: Colors.black38),
                      ),
                      Expanded(
                        child: Text(
                          'Pencarian: "$_searchQuery"',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.black54,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // ── Tab Content ────────────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildReportList(_pending),
                _buildReportList(_acc),
                _buildDoneList(_done),
                _buildReportList(_reject),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportList(List<ReportItem> reports) {
    if (reports.isEmpty) {
      final bool isSearching = _searchQuery.isNotEmpty;
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSearching ? Icons.search_off : Icons.inbox_outlined,
              size: 60,
              color: Colors.black26,
            ),
            const SizedBox(height: 12),
            Text(
              isSearching
                  ? 'Tidak ada hasil untuk "$_searchQuery"'
                  : 'Tidak ada laporan untuk $_filterLabel',
              style: const TextStyle(color: Colors.black45),
              textAlign: TextAlign.center,
            ),
            if (isSearching) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => _searchController.clear(),
                child: Text(
                  'Hapus pencarian',
                  style: TextStyle(color: Colors.red.shade800),
                ),
              ),
            ],
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: reports.length,
      itemBuilder: (context, index) {
        final report = reports[index];
        return _ReportCard(
          report: report,
          searchQuery: _searchQuery,
          onTap: () => _showDetailDialog(report),
          onAccept: report.status == 'pending'
              ? () => _showTerimaBottomSheet(report)
              : null,
          onReject: report.status == 'pending'
              ? () => _rejectReport(report)
              : null,
        );
      },
    );
  }

  Widget _buildDoneList(List<ReportItem> reports) {
    if (reports.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle_outline,
              size: 60,
              color: Colors.black26,
            ),
            const SizedBox(height: 12),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Tidak ada hasil untuk "$_searchQuery"'
                  : 'Belum ada laporan yang selesai',
              style: const TextStyle(color: Colors.black45),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: reports.length,
      itemBuilder: (context, index) {
        final report = reports[index];
        return _DoneCard(
          report: report,
          searchQuery: _searchQuery,
          onTap: () => _showDetailDialog(report),
        );
      },
    );
  }
}

// ── Widget Helper ─────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? color : Colors.black26),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.black54,
          ),
        ),
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final ReportItem report;
  final String searchQuery;
  final VoidCallback onTap;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;

  const _ReportCard({
    required this.report,
    required this.searchQuery,
    required this.onTap,
    this.onAccept,
    this.onReject,
  });

  Color get _statusColor {
    switch (report.status) {
      case 'acc':
        return const Color(0xFF16A34A);
      case 'reject':
        return Colors.red;
      case 'done':
        return const Color(0xFF2563EB);
      default:
        return const Color(0xFFF97316);
    }
  }

  String get _statusLabel {
    switch (report.status) {
      case 'acc':
        return 'Diterima';
      case 'reject':
        return 'Ditolak';
      case 'done':
        return 'Selesai';
      default:
        return 'Pending';
    }
  }

  Widget _highlightText(
    String text,
    TextStyle baseStyle,
    Color highlightColor,
  ) {
    if (searchQuery.isEmpty) return Text(text, style: baseStyle);
    final lowerText = text.toLowerCase();
    final lowerQuery = searchQuery.toLowerCase();
    final spans = <TextSpan>[];
    int start = 0;
    while (true) {
      final idx = lowerText.indexOf(lowerQuery, start);
      if (idx == -1) {
        spans.add(TextSpan(text: text.substring(start), style: baseStyle));
        break;
      }
      if (idx > start) {
        spans.add(TextSpan(text: text.substring(start, idx), style: baseStyle));
      }
      spans.add(
        TextSpan(
          text: text.substring(idx, idx + searchQuery.length),
          style: baseStyle.copyWith(
            backgroundColor: highlightColor.withOpacity(0.25),
            color: highlightColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
      start = idx + searchQuery.length;
    }
    return RichText(text: TextSpan(children: spans));
  }

  @override
  Widget build(BuildContext context) {
    final highlightColor = Colors.red.shade800;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
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
            Row(
              children: [
                Expanded(
                  child: _highlightText(
                    report.title,
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    highlightColor,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: _statusColor.withOpacity(0.12),
                  ),
                  child: Text(
                    _statusLabel,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.category_outlined,
                  size: 14,
                  color: Colors.black45,
                ),
                const SizedBox(width: 4),
                _highlightText(
                  report.category,
                  const TextStyle(fontSize: 12, color: Colors.black54),
                  highlightColor,
                ),
                const SizedBox(width: 12),
                const Icon(
                  Icons.location_on_outlined,
                  size: 14,
                  color: Colors.black45,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: _highlightText(
                    report.location,
                    const TextStyle(fontSize: 12, color: Colors.black54),
                    highlightColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  Icons.thumb_up_outlined,
                  size: 14,
                  color: Colors.black45,
                ),
                const SizedBox(width: 4),
                Text(
                  '${report.upvotes} upvote',
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.access_time, size: 14, color: Colors.black45),
                const SizedBox(width: 4),
                Text(
                  report.formattedDate,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
                const SizedBox(width: 12),
                const Icon(
                  Icons.person_outline,
                  size: 14,
                  color: Colors.black45,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: _highlightText(
                    report.requester,
                    const TextStyle(fontSize: 12, color: Colors.black54),
                    highlightColor,
                  ),
                ),
              ],
            ),
            if (report.assignedStaff != null) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(
                    Icons.assignment_ind_outlined,
                    size: 14,
                    color: Colors.green,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Ditugaskan ke: ${report.assignedStaff}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
            if (onAccept != null && onReject != null) ...[
              const SizedBox(height: 10),
              const Divider(height: 1),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onReject,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: const Icon(Icons.close, size: 16),
                      label: const Text(
                        'Tolak',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: onAccept,
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      icon: const Icon(Icons.check, size: 16),
                      label: const Text(
                        'Terima',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DoneCard extends StatelessWidget {
  final ReportItem report;
  final String searchQuery;
  final VoidCallback onTap;

  const _DoneCard({
    required this.report,
    required this.searchQuery,
    required this.onTap,
  });

  Widget _highlightText(
    String text,
    TextStyle baseStyle,
    Color highlightColor,
  ) {
    if (searchQuery.isEmpty) return Text(text, style: baseStyle);
    final lowerText = text.toLowerCase();
    final lowerQuery = searchQuery.toLowerCase();
    final spans = <TextSpan>[];
    int start = 0;
    while (true) {
      final idx = lowerText.indexOf(lowerQuery, start);
      if (idx == -1) {
        spans.add(TextSpan(text: text.substring(start), style: baseStyle));
        break;
      }
      if (idx > start) {
        spans.add(TextSpan(text: text.substring(start, idx), style: baseStyle));
      }
      spans.add(
        TextSpan(
          text: text.substring(idx, idx + searchQuery.length),
          style: baseStyle.copyWith(
            backgroundColor: highlightColor.withOpacity(0.25),
            color: highlightColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
      start = idx + searchQuery.length;
    }
    return RichText(text: TextSpan(children: spans));
  }

  @override
  Widget build(BuildContext context) {
    final highlightColor = Colors.red.shade800;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.green.withOpacity(0.2), width: 1),
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
            Row(
              children: [
                Expanded(
                  child: _highlightText(
                    report.title,
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    highlightColor,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.green.withOpacity(0.12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, size: 12, color: Colors.green),
                      SizedBox(width: 4),
                      Text(
                        'Selesai',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.category_outlined,
                  size: 14,
                  color: Colors.black45,
                ),
                const SizedBox(width: 4),
                _highlightText(
                  report.category,
                  const TextStyle(fontSize: 12, color: Colors.black54),
                  highlightColor,
                ),
                const SizedBox(width: 12),
                const Icon(
                  Icons.location_on_outlined,
                  size: 14,
                  color: Colors.black45,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: _highlightText(
                    report.location,
                    const TextStyle(fontSize: 12, color: Colors.black54),
                    highlightColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Divider(height: 1),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(
                  Icons.assignment_ind_outlined,
                  size: 14,
                  color: Colors.green,
                ),
                const SizedBox(width: 4),
                Text(
                  'Ditangani: ${report.assignedStaff ?? "-"}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                if (report.formattedCompletedDate != null) ...[
                  const Icon(
                    Icons.event_available,
                    size: 14,
                    color: Colors.black45,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    report.formattedCompletedDate!,
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.black45),
          const SizedBox(width: 6),
          Text(
            '$label: ',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}
