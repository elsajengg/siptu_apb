import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'report_feed_page.dart';
import 'report_success_page.dart';
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
  final String? initialNama;
  final String? initialNIM;
  final String? initialFakultas;
  final String? initialLocation;

  const ReportCreatePage({
    super.key,
    required this.currentUser,
    this.initialNama,
    this.initialNIM,
    this.initialFakultas,
    this.initialLocation,
  });

  @override
  State<ReportCreatePage> createState() => _ReportCreatePageState();
}

class _ReportCreatePageState extends State<ReportCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _namaCtrl = TextEditingController();
  final _nimCtrl = TextEditingController();
  final _fakultasCtrl = TextEditingController();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();

  late String _category;
  List<XFile> _photos = [];
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _category = _categories.first;
    _namaCtrl.text = widget.initialNama ?? '';
    _nimCtrl.text = widget.initialNIM ?? '';
    _fakultasCtrl.text = widget.initialFakultas ?? '';
    _locationCtrl.text = widget.initialLocation ?? '';
  }

  @override
  void dispose() {
    _namaCtrl.dispose();
    _nimCtrl.dispose();
    _fakultasCtrl.dispose();
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  Future<void> _pick(ImageSource source) async {
    final picker = ImagePicker();
    try {
      XFile? file;
      if (source == ImageSource.gallery) {
        final files = await picker.pickMultiImage(
          maxWidth: 1440,
          imageQuality: 85,
        );
        if (!mounted) return;
        if (files.isEmpty) return;
        setState(() {
          _photos = [..._photos, ...files].take(6).toList();
        });
        return;
      } else {
        file = await picker.pickImage(
          source: source,
          maxWidth: 1440,
          imageQuality: 85,
        );
      }
      if (!mounted) return;
      if (file == null) return;
      setState(() {
        _photos = [..._photos, file!].take(6).toList();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        const SnackBar(
          content: Text(
            'Gagal akses kamera/galeri. Pastikan izin sudah diaktifkan di pengaturan aplikasi.',
          ),
        ),
      );
    }
  }

  Future<void> _submit() async {
    if (_submitting) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _submitting = true);
    await Future<void>.delayed(const Duration(milliseconds: 250));
    if (!mounted) return;

    // Generate the report object (mockup for now)
    final createdReport = Report(
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
      photoPaths: _photos.map((e) => e.path).toList(),
    );
    ReportRepository.add(createdReport);

    // Instead of popping, navigate to success page
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ReportSuccessPage(
          keptData: {
            'nama': _namaCtrl.text.trim(),
            'nim': _nimCtrl.text.trim(),
            'fakultas': _fakultasCtrl.text.trim(),
            'location': _locationCtrl.text.trim(),
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final red = Colors.red.shade800;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),

      body: Column(
        children: [
          /// 🔴 HEADER GRADIENT
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 50, 16, 22),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.red.shade900, Colors.red.shade700],
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
                const Expanded(
                  child: Text(
                    "Buat Pengaduan",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha((0.16 * 255).round()),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: const Text(
                    'Form Cepat',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Container(
            margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: Colors.black54),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Gunakan galeri untuk pilih banyak foto sekaligus. Maksimal 6 foto per laporan.",
                    style: TextStyle(fontSize: 12, color: Colors.black54),
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
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                "Form Pengaduan",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEEF2FF),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: const Text(
                                "Step 1 dari 1",
                                style: TextStyle(
                                  color: Color(0xFF3730A3),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          "Isi data selengkap mungkin agar laporan lebih cepat ditindaklanjuti.",
                          style: TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                        const SizedBox(height: 16),
                        _sectionTitle(
                          icon: Icons.report_problem_outlined,
                          title: "Detail Pengaduan",
                        ),
                        const SizedBox(height: 10),

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
                                (v == null || v.isEmpty)
                                    ? "Judul wajib diisi"
                                    : null,
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
                            validator: (v) =>
                                (v == null || v.trim().isEmpty)
                                    ? "Lokasi wajib diisi"
                                    : null,
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
                            validator: (v) =>
                                (v == null || v.trim().isEmpty)
                                    ? "Deskripsi wajib diisi"
                                    : null,
                          ),
                        ),

                        const SizedBox(height: 18),
                        _sectionTitle(
                          icon: Icons.image_outlined,
                          title: "Lampiran Foto",
                        ),
                        const SizedBox(height: 10),

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
                            const SizedBox(width: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF7ED),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFFFED7AA),
                                ),
                              ),
                              child: Text(
                                '${_photos.length}/6',
                                style: const TextStyle(
                                  color: Color(0xFFC2410C),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        /// PREVIEW FOTO
                        if (_photos.isNotEmpty)
                          SizedBox(
                            height: 96,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: _photos.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(width: 8),
                              itemBuilder: (_, i) {
                                return Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.file(
                                        File(_photos[i].path),
                                        width: 120,
                                        height: 96,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Positioned(
                                      top: 4,
                                      right: 4,
                                      child: InkWell(
                                        onTap: () {
                                          setState(() {
                                            _photos.removeAt(i);
                                          });
                                        },
                                        child: Container(
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.black54,
                                          ),
                                          padding: const EdgeInsets.all(4),
                                          child: const Icon(
                                            Icons.close,
                                            size: 14,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
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
                            child: Text(
                              _submitting ? "Mengirim..." : "Kirim Pengaduan",
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color(0xFFFFFFCC),
                                fontWeight: FontWeight.w700,
                              ),
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
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
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
        side: const BorderSide(color: Color(0xFFCBD5E1)),
        foregroundColor: const Color(0xFF0F172A),
        backgroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _sectionTitle({required IconData icon, required String title}) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: const Color(0xFFEEF2FF),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: const Color(0xFF3730A3)),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
