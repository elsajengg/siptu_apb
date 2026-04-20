import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'report_feed_page.dart';
import 'dart:io';

const _categories = <String>[
  'Penerangan',
  'Kenyamanan Ruangan',
  'Sanitasi',
  'Furnitur',
  'Keamanan',
  'Internet & Jaringan',
  'Lainnya',
];

class ReportCreatePage extends StatefulWidget {
  final String currentUser;

  const ReportCreatePage({super.key, required this.currentUser});

  @override
  State<ReportCreatePage> createState() => _ReportCreatePageState();
}

class _ReportCreatePageState extends State<ReportCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();

  late String _category;
  XFile? _photo;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _category = _categories.first;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  Future<void> _pick(ImageSource source) async {
    final picker = ImagePicker();
    try {
      final file = await picker.pickImage(
        source: source,
        maxWidth: 1440,
        imageQuality: 85,
      );
      if (!mounted) return;
      setState(() => _photo = file);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal memilih foto: $e')));
    }
  }

  Future<void> _submit() async {
    if (_submitting) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _submitting = true);
    await Future<void>.delayed(const Duration(milliseconds: 250));
    if (!mounted) return;

    final report = Report(
      id: _makeId(),
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      location: _locationCtrl.text.trim(),
      category: _category,
      status: 'Menunggu',
      createdBy: widget.currentUser,
      likedBy: [],
      staffName: '',
      staffFeedback: '',
      createdAt: DateTime.now(),
      photoPath: _photo?.path,
    );

    Navigator.of(context).pop<Report>(report);
  }

  @override
  Widget build(BuildContext context) {
    final red = Colors.red.shade800;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),

      body: Column(
        children: [
          /// 🔴 HEADER GRADIENT
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 50, 16, 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.red.shade800, Colors.red.shade600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(25),
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                ),
                const SizedBox(width: 8),
                const Text(
                  "Buat Pengaduan",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          /// 📄 FORM
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: Colors.grey.shade200, blurRadius: 10),
                    ],
                  ),

                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Isi Data Pengaduan",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),

                        const SizedBox(height: 16),

                        /// DROPDOWN
                        _inputWrapper(
                          child: DropdownButtonFormField<String>(
                            value: _category,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              prefixIcon: Icon(Icons.category),
                            ),
                            items: _categories
                                .map(
                                  (e) => DropdownMenuItem(
                                    value: e,
                                    child: Text(e),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) =>
                                setState(() => _category = v ?? _category),
                          ),
                        ),

                        const SizedBox(height: 12),

                        /// TITLE
                        _inputWrapper(
                          child: TextFormField(
                            controller: _titleCtrl,
                            decoration: const InputDecoration(
                              hintText: "Judul laporan",
                              border: InputBorder.none,
                              prefixIcon: Icon(Icons.title),
                            ),
                            validator: (v) =>
                                v!.isEmpty ? "Judul wajib diisi" : null,
                          ),
                        ),

                        const SizedBox(height: 12),

                        /// LOCATION
                        _inputWrapper(
                          child: TextFormField(
                            controller: _locationCtrl,
                            decoration: const InputDecoration(
                              hintText: "Lokasi",
                              border: InputBorder.none,
                              prefixIcon: Icon(Icons.place),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        /// DESKRIPSI
                        _inputWrapper(
                          child: TextFormField(
                            controller: _descCtrl,
                            minLines: 4,
                            maxLines: 6,
                            decoration: const InputDecoration(
                              hintText: "Deskripsi laporan...",
                              border: InputBorder.none,
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        /// FOTO BUTTON
                        Row(
                          children: [
                            Expanded(
                              child: _buttonOutline(
                                icon: Icons.photo,
                                text: "Galeri",
                                onTap: () => _pick(ImageSource.gallery),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buttonOutline(
                                icon: Icons.camera_alt,
                                text: "Kamera",
                                onTap: () => _pick(ImageSource.camera),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        /// PREVIEW FOTO
                        if (_photo != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              File(_photo!.path),
                              height: 150,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),

                        const SizedBox(height: 20),

                        /// BUTTON SUBMIT
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: red,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            onPressed: _submit,
                            child: const Text(
                              "Kirim Pengaduan",
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _makeId() {
    final now = DateTime.now();
    final y = now.year.toString().padLeft(4, '0');
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    final hh = now.hour.toString().padLeft(2, '0');
    final mm = now.minute.toString().padLeft(2, '0');
    final ss = now.second.toString().padLeft(2, '0');
    return 'REP-$y$m$d-$hh$mm$ss';
  }

  Widget _inputWrapper({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F2F6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }

  Widget _buttonOutline({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(text),
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
