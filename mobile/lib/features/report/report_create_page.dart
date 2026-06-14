import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'report_success_page.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';
import '../../data/api_service.dart';
import '../../providers/report_provider.dart';

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

  List<Map<String, dynamic>> _facilities = [];
  int? _selectedFacilityId;
  bool _loadingFacilities = true;
  List<XFile> _photos = [];
  List<Uint8List> _photoBytes = [];
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _namaCtrl.text = widget.initialNama ?? '';
    _nimCtrl.text = widget.initialNIM ?? '';
    _fakultasCtrl.text = widget.initialFakultas ?? '';
    _locationCtrl.text = widget.initialLocation ?? '';
    _loadFacilities();
  }

  Future<void> _loadFacilities() async {
    final result = await ApiService.getFacilities();
    if (!mounted) return;

    if (result['success'] == true) {
      final facilities = (result['data'] as List<dynamic>)
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();

      setState(() {
        _facilities = facilities;
        _loadingFacilities = false;

        if (facilities.isNotEmpty) {
          _selectedFacilityId = facilities.first['id'] as int;
          _applyFacility(facilities.first, overwriteLocation: false);
        }
      });
      return;
    }

    setState(() => _loadingFacilities = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result['message'] ?? 'Gagal memuat fasilitas')),
    );
  }

  void _applyFacility(
    Map<String, dynamic> facility, {
    bool overwriteLocation = true,
  }) {
    final room = facility['room'] as Map<String, dynamic>?;
    if (room == null || (!overwriteLocation && _locationCtrl.text.isNotEmpty)) {
      return;
    }

    _locationCtrl.text =
        '${room['building_name'] ?? ''}, ${room['room_name'] ?? ''}'.replaceAll(
          RegExp(r'^, |, $'),
          '',
        );
  }

  Map<String, dynamic>? get _selectedFacility {
    for (final facility in _facilities) {
      if (facility['id'] == _selectedFacilityId) return facility;
    }
    return null;
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
        List<Uint8List> newBytes = [];
        for (var f in files) {
          newBytes.add(await f.readAsBytes());
        }
        setState(() {
          _photos = [..._photos, ...files].take(5).toList();
          _photoBytes = [..._photoBytes, ...newBytes].take(5).toList();
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
      final bytes = await file.readAsBytes();
      setState(() {
        _photos = [..._photos, file!].take(5).toList();
        _photoBytes = [..._photoBytes, bytes].take(5).toList();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
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
    if (_selectedFacilityId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih fasilitas terlebih dahulu')),
      );
      return;
    }

    setState(() => _submitting = true);
    final result = await ApiService.createReport(
      facilityId: _selectedFacilityId!,
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      location: _locationCtrl.text.trim(),
      photos: _photos,
    );
    if (!mounted) return;

    if (result['success'] != true) {
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Laporan gagal dikirim')),
      );
      return;
    }

    await Future.wait([
      context.read<ReportProvider>().loadFeed(),
      context.read<ReportProvider>().loadMine(),
    ]);
    if (!mounted) return;

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
    final redDark = Colors.red.shade900;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),

      body: Column(
        children: [
          /// 🔴 HEADER GRADIENT
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 50, 16, 26),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [redDark, red],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(28),
              ),
              boxShadow: [
                BoxShadow(
                  color: red.withAlpha((0.30 * 255).round()),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
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
                const SizedBox(height: 14),
                Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha((0.18 * 255).round()),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                      const Expanded(child: SizedBox()),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Container(
            margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha((0.03 * 255).round()),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.tips_and_updates_outlined,
                  size: 16,
                  color: Colors.black54,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Gunakan galeri untuk pilih banyak foto sekaligus. Maksimal 5 foto per laporan.",
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
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha((0.04 * 255).round()),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
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
                                color: const Color(0xFFFEE2E2),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: const Text(
                                "Step 1 dari 1",
                                style: TextStyle(
                                  color: Color(0xFF991B1B),
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

                        /// FACILITY
                        _inputWrapper(
                          child: DropdownButtonFormField<int>(
                            key: ValueKey(_selectedFacilityId),
                            initialValue: _selectedFacilityId,
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              prefixIcon: Icon(Icons.handyman_outlined),
                              hintText: 'Pilih fasilitas',
                            ),
                            items: _facilities.map((facility) {
                              final room =
                                  facility['room'] as Map<String, dynamic>?;
                              final roomLabel = room == null
                                  ? ''
                                  : ' - ${room['building_name']}, ${room['room_name']}';

                              return DropdownMenuItem<int>(
                                value: facility['id'] as int,
                                child: Text(
                                  '${facility['name']}$roomLabel',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            onChanged: _loadingFacilities
                                ? null
                                : (value) {
                                    if (value == null) return;
                                    final facility = _facilities.firstWhere(
                                      (item) => item['id'] == value,
                                    );
                                    setState(() {
                                      _selectedFacilityId = value;
                                      _applyFacility(facility);
                                    });
                                  },
                            validator: (value) => value == null
                                ? 'Fasilitas wajib dipilih'
                                : null,
                          ),
                        ),

                        if (_selectedFacility != null) ...[
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.category_outlined,
                                  size: 15,
                                  color: Colors.black45,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Kategori: ${_selectedFacility!['category']}',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

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
                            validator: (v) => (v == null || v.isEmpty)
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
                              hintText: "Tempat",
                              border: InputBorder.none,
                              prefixIcon: Icon(Icons.place),
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? "Tempat wajib diisi"
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
                            validator: (v) => (v == null || v.trim().isEmpty)
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
                                color: const Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: const Color(0xFFD1D5DB),
                                ),
                              ),
                              child: Text(
                                '${_photos.length}/5',
                                style: const TextStyle(
                                  color: Color(0xFF374151),
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
                                      child: Container(
                                        width: 120,
                                        height: 96,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: const Color(0xFFE5E7EB),
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          child: Image.memory(
                                            _photoBytes[i],
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                                  return const Icon(
                                                    Icons.broken_image,
                                                  );
                                                },
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 4,
                                      right: 4,
                                      child: InkWell(
                                        onTap: () {
                                          setState(() {
                                            _photos.removeAt(i);
                                            _photoBytes.removeAt(i);
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
                          height: 52,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: red,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: _submit,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _submitting
                                      ? Icons.hourglass_top_rounded
                                      : Icons.send_rounded,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _submitting
                                      ? "Mengirim..."
                                      : "Kirim Pengaduan",
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
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

  Widget _inputWrapper({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(14),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
            color: const Color(0xFFFEE2E2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: const Color(0xFF991B1B)),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}
