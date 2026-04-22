import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'task_success_page.dart';
import '../../data/task_service.dart';
import 'package:intl/intl.dart';

class UpdateStatusPage extends StatefulWidget {
  final String? initialStatus;
  final String? initialNote;
  final List<File>? initialImages;

  const UpdateStatusPage({
    super.key,
    this.initialStatus,
    this.initialNote,
    this.initialImages,
  });

  @override
  State<UpdateStatusPage> createState() => _UpdateStatusPageState();
}

class _UpdateStatusPageState extends State<UpdateStatusPage> {
  static const double _phi = 1.61803398875;
  late String _selectedStatus;
  late final TextEditingController _noteController;
  late final List<File> _images;
  final ImagePicker _picker = ImagePicker();

  final List<String> _statuses = ['Menunggu', 'Diproses', 'Selesai', 'Terkendala'];

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.initialStatus ?? 'Diproses';
    _noteController = TextEditingController(text: widget.initialNote);
    _images = List<File>.from(widget.initialImages ?? []);
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 70,
      );
      if (pickedFile != null) {
        setState(() {
          _images.add(File(pickedFile.path));
        });
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final red = Colors.red.shade800;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: red,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Update Status Tugas',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16 * _phi),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Informasi Tugas'),
            SizedBox(height: 8 * _phi),
            Container(
              padding: EdgeInsets.all(12 * _phi),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12 * _phi),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
                ],
              ),
              child: const Column(
                children: [
                  _InfoRow(label: 'ID Tiket', value: '#TGS-001'),
                  _InfoRow(label: 'Judul', value: 'Perbaikan AC Ruang 302'),
                  _InfoRow(label: 'Kategori', value: 'Kesejukan Ruangan', isLast: true),
                ],
              ),
            ),
            SizedBox(height: 20 * _phi),

            _buildSectionTitle('Pilih Status Baru'),
            SizedBox(height: 8 * _phi),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: _statuses.map((status) {
                final isSelected = _selectedStatus == status;
                return ChoiceChip(
                  label: Text(status),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) setState(() => _selectedStatus = status);
                  },
                  selectedColor: red.withOpacity(0.15),
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: isSelected ? red : Colors.grey.shade300),
                  ),
                  labelStyle: TextStyle(
                    color: isSelected ? red : Colors.black54,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 13,
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 20 * _phi),

            _buildSectionTitle('Dokumentasi Perbaikan'),
            SizedBox(height: 8 * _phi),
            Row(
              children: [
                Expanded(
                  child: _buildImageSourceButton(
                    icon: Icons.camera_alt_outlined,
                    label: 'Kamera',
                    onTap: () => _pickImage(ImageSource.camera),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildImageSourceButton(
                    icon: Icons.photo_library_outlined,
                    label: 'Galeri',
                    onTap: () => _pickImage(ImageSource.gallery),
                  ),
                ),
              ],
            ),
            if (_images.isNotEmpty) ...[
              SizedBox(height: 12 * _phi),
              SizedBox(
                height: 100,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _images.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    return Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(_images[index], width: 100, height: 100, fit: BoxFit.cover),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () => _removeImage(index),
                            child: CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.black54,
                              child: const Icon(Icons.close, size: 14, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
            SizedBox(height: 20 * _phi),

            _buildReportSectionTitle('II. CATATAN TEKNISI'),
            SizedBox(height: 12),
            TextField(
              controller: _noteController,
              maxLines: 4,
              cursorColor: red,
              decoration: InputDecoration(
                hintText: 'Tuliskan deskripsi perbaikan yang telah dilakukan...',
                hintStyle: const TextStyle(fontSize: 13, color: Colors.black26),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.all(16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: red, width: 1.5),
                ),
              ),
            ),
            SizedBox(height: 24 * _phi),

            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () {
                  // Save to TaskService
                  final newTask = CompletedTask(
                    id: '#TGS-001',
                    title: 'Perbaikan AC Ruang 302',
                    location: 'Gedung Kuliah Utama, Lt 3',
                    date: DateFormat('dd MMM yyyy').format(DateTime.now()),
                    status: _selectedStatus,
                    note: _noteController.text,
                    images: _images,
                  );
                  TaskService().addCompletedTask(newTask);

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TaskSuccessPage(
                        taskId: '#TGS-001', 
                        newStatus: _selectedStatus,
                        images: _images,
                        note: _noteController.text,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: red,
                  elevation: 4,
                  shadowColor: red.withOpacity(0.4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text(
                  'Kirim Deskripsi Perbaikan',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: -0.2),
    );
  }

  Widget _buildReportSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w900,
        color: Colors.black26,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildImageSourceButton({required IconData icon, required String label, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.black54, size: 24),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black54)),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isLast;
  const _InfoRow({required this.label, required this.value, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(color: Colors.black54, fontSize: 13)),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            ],
          ),
        ),
        if (!isLast) const Divider(height: 1),
      ],
    );
  }
}
