import 'package:flutter/material.dart';
import '../../data/api_service.dart';

enum FilterDay { hariIni, kemarin, tujuhHari }

class VerifyReportPage extends StatefulWidget {
  final VoidCallback? onBack;
  const VerifyReportPage({super.key, this.onBack});

  @override
  State<VerifyReportPage> createState() => _VerifyReportPageState();
}

class _VerifyReportPageState extends State<VerifyReportPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  FilterDay _selectedFilter = FilterDay.tujuhHari;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  List<Map<String, dynamic>> _allReports = [];
  List<Map<String, dynamic>> _staffList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _searchController.addListener(() {
      setState(
        () => _searchQuery = _searchController.text.toLowerCase().trim(),
      );
    });
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final reportsResult = await ApiService.getReports();
    final staffResult = await ApiService.getStaff();
    setState(() {
      if (reportsResult['success']) {
        _allReports = List<Map<String, dynamic>>.from(
          reportsResult['data'] ?? [],
        );
      }
      if (staffResult['success']) {
        _staffList = List<Map<String, dynamic>>.from(staffResult['data'] ?? []);
      }
      _isLoading = false;
    });
  }

  List<Map<String, dynamic>> get _filteredReports {
    List<Map<String, dynamic>> filtered = _allReports;
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((r) {
        final title = (r['title'] ?? '').toString().toLowerCase();
        final category = (r['facility']?['name'] ?? '')
            .toString()
            .toLowerCase();
        final location = (r['location'] ?? '').toString().toLowerCase();
        return title.contains(_searchQuery) ||
            category.contains(_searchQuery) ||
            location.contains(_searchQuery);
      }).toList();
    }
    return filtered;
  }

  List<Map<String, dynamic>> get _pending =>
      _filteredReports.where((r) => r['status'] == 'pending').toList();
  List<Map<String, dynamic>> get _acc =>
      _filteredReports.where((r) => r['status'] == 'assigned').toList();
  List<Map<String, dynamic>> get _done =>
      _filteredReports.where((r) => r['status'] == 'done').toList();
  List<Map<String, dynamic>> get _reject =>
      _filteredReports.where((r) => r['status'] == 'rejected').toList();

  void _showTerimaBottomSheet(Map<String, dynamic> report) {
    Map<String, dynamic>? selectedStaff;
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
                  Expanded(
                    child: _staffList.isEmpty
                        ? const Center(child: Text('Tidak ada staff tersedia'))
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: _staffList.length,
                            itemBuilder: (context, index) {
                              final staff = _staffList[index];
                              final isSelected =
                                  selectedStaff?['id'] == staff['id'];
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
                                          (staff['name'] ?? '?')[0],
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
                                              staff['name'] ?? '',
                                              style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              staff['email'] ?? '',
                                              style: const TextStyle(
                                                fontSize: 11,
                                                color: Colors.black54,
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
                            : () async {
                                Navigator.pop(context);
                                final result = await ApiService.assignReport(
                                  reportId: report['id'],
                                  staffId: selectedStaff!['id'],
                                );
                                if (!mounted) return;
                                if (result['success']) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '✓ Laporan ditugaskan ke ${selectedStaff!['name']}',
                                      ),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                  _loadData();
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        result['message'] ?? 'Gagal',
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              },
                        icon: const Icon(Icons.assignment_ind_outlined),
                        label: Text(
                          selectedStaff != null
                              ? 'Tugaskan ke ${selectedStaff!['name']}'
                              : 'Pilih Staff Terlebih Dahulu',
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

  void _rejectReport(Map<String, dynamic> report) {
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
            onPressed: () async {
              Navigator.pop(context);
              final result = await ApiService.rejectReport(
                reportId: report['id'],
                reason: reasonCtrl.text,
              );
              if (!mounted) return;
              if (result['success']) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Laporan ditolak'),
                    backgroundColor: Colors.red,
                  ),
                );
                _loadData();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(result['message'] ?? 'Gagal'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Tolak'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final red = Colors.red.shade800;
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: red,
        elevation: 0,
        leading: widget.onBack != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: widget.onBack,
              )
            : null,
        automaticallyImplyLeading: false,
        title: const Text(
          'Manajemen Pengaduan',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadData,
          ),
          IconButton(
            icon: const Icon(Icons.download_outlined, color: Colors.white),
            onPressed: () {},
          ),
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Cari judul, kategori, lokasi...',
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Colors.black38,
                        size: 20,
                      ),
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
                    ),
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildReportList(_pending),
                      _buildReportList(_acc),
                      _buildReportList(_done),
                      _buildReportList(_reject),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildReportList(List<Map<String, dynamic>> reports) {
    if (reports.isEmpty) {
      return const Center(
        child: Text(
          'Tidak ada laporan',
          style: TextStyle(color: Colors.black45),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: reports.length,
        itemBuilder: (context, index) {
          final report = reports[index];
          final status = report['status'] ?? '';
          return Container(
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
                      child: Text(
                        report['title'] ?? '',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: _statusColor(status).withOpacity(0.12),
                      ),
                      child: Text(
                        _statusLabel(status),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _statusColor(status),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  report['location'] ?? '',
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
                const SizedBox(height: 4),
                Text(
                  'Pelapor: ${report['user']?['name'] ?? '-'}',
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
                if (status == 'pending') ...[
                  const SizedBox(height: 10),
                  const Divider(height: 1),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _rejectReport(report),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                          ),
                          icon: const Icon(Icons.close, size: 16),
                          label: const Text('Tolak'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () => _showTerimaBottomSheet(report),
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          icon: const Icon(Icons.check, size: 16),
                          label: const Text('Terima'),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'assigned':
        return const Color(0xFF16A34A);
      case 'rejected':
        return Colors.red;
      case 'done':
        return const Color(0xFF2563EB);
      default:
        return const Color(0xFFF97316);
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'assigned':
        return 'Diterima';
      case 'rejected':
        return 'Ditolak';
      case 'done':
        return 'Selesai';
      default:
        return 'Pending';
    }
  }
}
