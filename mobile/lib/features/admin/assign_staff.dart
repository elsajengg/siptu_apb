import 'package:flutter/material.dart';
import 'verify_report.dart';

class StaffItem {
  final String id;
  final String name;
  final String email;
  final String specialization;
  final int activeTask;

  StaffItem({
    required this.id,
    required this.name,
    required this.email,
    required this.specialization,
    required this.activeTask,
  });
}

class AssignStaffPage extends StatefulWidget {
  final ReportItem report;

  const AssignStaffPage({super.key, required this.report});

  @override
  State<AssignStaffPage> createState() => _AssignStaffPageState();
}

class _AssignStaffPageState extends State<AssignStaffPage> {
  StaffItem? _selectedStaff;

  final List<StaffItem> _staffList = [
    StaffItem(
      id: 'STF-001',
      name: 'Ahmad Fauzi',
      email: 'ahmad.fauzi@telkomuniversity.ac.id',
      specialization: 'Penerangan & Elektronik',
      activeTask: 2,
    ),
    StaffItem(
      id: 'STF-002',
      name: 'Budi Santoso',
      email: 'budi.santoso@telkomuniversity.ac.id',
      specialization: 'AC & Kenyamanan Ruangan',
      activeTask: 1,
    ),
    StaffItem(
      id: 'STF-003',
      name: 'Citra Dewi',
      email: 'citra.dewi@telkomuniversity.ac.id',
      specialization: 'Sanitasi & Kebersihan',
      activeTask: 3,
    ),
    StaffItem(
      id: 'STF-004',
      name: 'Dendi Pratama',
      email: 'dendi.pratama@telkomuniversity.ac.id',
      specialization: 'Furnitur & Infrastruktur',
      activeTask: 0,
    ),
  ];

  void _assignStaff() {
    if (_selectedStaff == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih staff terlebih dahulu!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Konfirmasi Penugasan'),
        content: Text(
          'Tugaskan "${_selectedStaff!.name}" untuk menangani pengaduan "${widget.report.title}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade800),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${_selectedStaff!.name} berhasil ditugaskan!'),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.pop(context);
            },
            child: const Text('Tugaskan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final red = Colors.red.shade800;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: red,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Tugaskan Staff',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // Info Pengaduan
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
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
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Diterima',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.report.id,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.black45,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  widget.report.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.category_outlined,
                      size: 14,
                      color: Colors.black45,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      widget.report.category,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: Colors.black45,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      widget.report.location,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Pilih Staff
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                const Text(
                  'Pilih Staff',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                Text(
                  '(${_staffList.length} staff tersedia)',
                  style: const TextStyle(fontSize: 12, color: Colors.black45),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _staffList.length,
              itemBuilder: (context, index) {
                final staff = _staffList[index];
                final isSelected = _selectedStaff?.id == staff.id;

                return GestureDetector(
                  onTap: () => setState(() => _selectedStaff = staff),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isSelected ? red.withOpacity(0.06) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? red : Colors.transparent,
                        width: 1.5,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: isSelected
                              ? red
                              : const Color(0xFFE5E7EB),
                          child: Text(
                            staff.name[0],
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black54,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                staff.name,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                staff.specialization,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black54,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${staff.activeTask} tugas aktif',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: staff.activeTask > 2
                                      ? Colors.orange
                                      : Colors.green,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected) Icon(Icons.check_circle, color: red),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Tombol Tugaskan
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: _assignStaff,
                icon: const Icon(Icons.assignment_ind_outlined),
                label: const Text(
                  'Tugaskan Staff',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
