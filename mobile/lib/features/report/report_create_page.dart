import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../data/api_service.dart';
import '../../providers/report_provider.dart';
import 'report_success_page.dart';

class ReportCreatePage extends StatefulWidget {
  final String? initialLocation;

  const ReportCreatePage({super.key, this.initialLocation});

  @override
  State<ReportCreatePage> createState() => _ReportCreatePageState();
}

class _ReportCreatePageState extends State<ReportCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _roomDetailCtrl = TextEditingController();
  final _picker = ImagePicker();

  List<Map<String, dynamic>> _rooms = [];
  List<Map<String, dynamic>> _facilities = [];
  int? _selectedRoomId;
  int? _selectedFacilityId;
  bool _loadingRooms = true;
  bool _loadingFacilities = true;
  bool _submitting = false;
  final List<XFile> _photos = [];
  final List<Uint8List> _photoBytes = [];

  @override
  void initState() {
    super.initState();
    _locationCtrl.text = widget.initialLocation ?? '';
    _loadRooms();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _locationCtrl.dispose();
    _roomDetailCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadRooms() async {
    final result = await ApiService.getRooms();
    if (!mounted) return;

    if (result['success'] == true) {
      final rooms = (result['data'] as List<dynamic>)
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();
      setState(() {
        _rooms = rooms;
        _loadingRooms = false;
        _loadingFacilities = rooms.isNotEmpty;
        if (rooms.isNotEmpty) {
          _selectedRoomId = rooms.first['id'] as int;
          _applyRoom(rooms.first, overwriteLocation: false);
        } else {
          _loadingFacilities = false;
        }
      });
      if (rooms.isNotEmpty) {
        await _loadFacilities(roomId: _selectedRoomId);
      }
      return;
    }

    setState(() {
      _loadingRooms = false;
      _loadingFacilities = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result['message'] ?? 'Gagal memuat ruangan')),
    );
  }

  Future<void> _loadFacilities({int? roomId}) async {
    setState(() {
      _loadingFacilities = true;
      _facilities = [];
      _selectedFacilityId = null;
    });

    final result = await ApiService.getFacilities(roomId: roomId);
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
        }
      });
      return;
    }

    setState(() => _loadingFacilities = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result['message'] ?? 'Gagal memuat fasilitas')),
    );
  }

  void _applyRoom(Map<String, dynamic> room, {bool overwriteLocation = true}) {
    if (!overwriteLocation && _locationCtrl.text.isNotEmpty) return;

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

  Future<void> _pick(ImageSource source) async {
    if (_photos.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maksimal 5 foto per laporan.')),
      );
      return;
    }

    try {
      if (source == ImageSource.gallery) {
        final files = await _picker.pickMultiImage(
          maxWidth: 1440,
          imageQuality: 85,
        );
        if (!mounted || files.isEmpty) return;
        await _appendPhotos(files);
        return;
      }

      final file = await _picker.pickImage(
        source: source,
        maxWidth: 1440,
        imageQuality: 85,
      );
      if (!mounted || file == null) return;
      await _appendPhotos([file]);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Gagal akses kamera/galeri. Pastikan izin aplikasi sudah aktif.',
          ),
        ),
      );
    }
  }

  Future<void> _appendPhotos(List<XFile> files) async {
    final remaining = 5 - _photos.length;
    final selected = files.take(remaining).toList();
    final bytes = <Uint8List>[];
    for (final file in selected) {
      bytes.add(await file.readAsBytes());
    }
    if (!mounted) return;
    setState(() {
      _photos.addAll(selected);
      _photoBytes.addAll(bytes);
    });
  }

  Future<void> _submit() async {
    if (_submitting) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    if (_selectedFacilityId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih room dan kategori fasilitas dulu.'),
        ),
      );
      return;
    }

    setState(() => _submitting = true);
    final result = await ApiService.createReport(
      facilityId: _selectedFacilityId!,
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      location: _locationCtrl.text.trim(),
      roomDetail: _roomDetailCtrl.text.trim(),
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

    try {
      await Future.wait([
        context.read<ReportProvider>().loadFeed(),
        context.read<ReportProvider>().loadMine(),
      ]);
    } catch (_) {
      // Laporan sudah tersimpan; refresh list tidak boleh membuat tombol terkunci.
    }
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ReportSuccessPage(
          keptData: {
            'ticket': (result['data']?['ticket_number'] ?? '').toString(),
            'location': _locationCtrl.text.trim(),
            'room_detail': _roomDetailCtrl.text.trim(),
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF111827),
        elevation: 0,
        title: const Text(
          'Buat Pengaduan',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
          ),
          child: SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _submitting ? null : _submit,
              icon: Icon(
                _submitting ? Icons.hourglass_top_rounded : Icons.send_rounded,
                size: 18,
              ),
              label: Text(_submitting ? 'Mengirim...' : 'Kirim Pengaduan'),
              style: ElevatedButton.styleFrom(
                backgroundColor: red,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade300,
                elevation: 0,
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
          children: [
            _IntroPanel(red: red),
            const SizedBox(height: 16),
            _FormSection(
              title: 'Lokasi dan fasilitas',
              icon: Icons.location_on_outlined,
              children: [
                _FieldLabel(
                  label: 'Room',
                  child: DropdownButtonFormField<int>(
                    initialValue: _selectedRoomId,
                    isExpanded: true,
                    decoration: _fieldDecoration(
                      hint: _loadingRooms
                          ? 'Memuat room...'
                          : 'Pilih gedung dan ruangan',
                      icon: Icons.meeting_room_outlined,
                    ),
                    items: _rooms.map((room) {
                      return DropdownMenuItem<int>(
                        value: room['id'] as int,
                        child: Text(
                          '${room['building_name']}, ${room['room_name']}',
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: _loadingRooms || _rooms.isEmpty
                        ? null
                        : (value) {
                            if (value == null) return;
                            final room = _rooms.firstWhere(
                              (item) => item['id'] == value,
                            );
                            setState(() {
                              _selectedRoomId = value;
                              _applyRoom(room);
                            });
                            _loadFacilities(roomId: value);
                          },
                    validator: (value) =>
                        value == null ? 'Room wajib dipilih' : null,
                  ),
                ),
                const SizedBox(height: 14),
                _FieldLabel(
                  label: 'Kategori fasilitas',
                  child: DropdownButtonFormField<int>(
                    initialValue: _selectedFacilityId,
                    isExpanded: true,
                    decoration: _fieldDecoration(
                      hint: _loadingFacilities
                          ? 'Memuat fasilitas...'
                          : 'Pilih kategori fasilitas',
                      icon: Icons.handyman_outlined,
                    ),
                    items: _facilities.map((facility) {
                      return DropdownMenuItem<int>(
                        value: facility['id'] as int,
                        child: Text(
                          '${facility['category'] ?? '-'} - ${facility['name']}',
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: _loadingFacilities || _facilities.isEmpty
                        ? null
                        : (value) {
                            if (value == null) return;
                            setState(() {
                              _selectedFacilityId = value;
                            });
                          },
                    validator: (value) => value == null
                        ? 'Kategori fasilitas wajib dipilih'
                        : null,
                  ),
                ),
                if (_selectedFacility != null) ...[
                  const SizedBox(height: 8),
                  _InfoStrip(
                    text:
                        'Fasilitas: ${_selectedFacility!['name'] ?? '-'} | Kategori: ${_selectedFacility!['category'] ?? '-'}',
                  ),
                ] else if (!_loadingFacilities) ...[
                  const SizedBox(height: 8),
                  const _InfoStrip(
                    text:
                        'Belum ada fasilitas untuk room ini. Pilih room lain atau isi data seeder.',
                  ),
                ],
                const SizedBox(height: 14),
                _FieldLabel(
                  label: 'Lokasi',
                  child: TextFormField(
                    controller: _locationCtrl,
                    decoration: _fieldDecoration(
                      hint: 'Contoh: Gedung SBS, Lab Programming',
                      icon: Icons.place_outlined,
                    ),
                    validator: (value) =>
                        (value == null || value.trim().isEmpty)
                        ? 'Tempat wajib diisi'
                        : null,
                  ),
                ),
                const SizedBox(height: 14),
                _FieldLabel(
                  label: 'Detail ruangan',
                  helper: 'Contoh: dekat pintu, sisi kanan, bilik kedua.',
                  child: TextFormField(
                    controller: _roomDetailCtrl,
                    textInputAction: TextInputAction.next,
                    decoration: _fieldDecoration(
                      hint: 'Tulis detail posisi kerusakan',
                      icon: Icons.pin_drop_outlined,
                    ),
                    validator: (value) =>
                        (value == null || value.trim().isEmpty)
                        ? 'Detail ruangan wajib diisi'
                        : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _FormSection(
              title: 'Detail laporan',
              icon: Icons.assignment_outlined,
              children: [
                _FieldLabel(
                  label: 'Judul',
                  child: TextFormField(
                    controller: _titleCtrl,
                    textInputAction: TextInputAction.next,
                    decoration: _fieldDecoration(
                      hint: 'Contoh: AC ruang kelas tidak dingin',
                      icon: Icons.title_rounded,
                    ),
                    validator: (value) =>
                        (value == null || value.trim().isEmpty)
                        ? 'Judul wajib diisi'
                        : null,
                  ),
                ),
                const SizedBox(height: 14),
                _FieldLabel(
                  label: 'Deskripsi',
                  helper: 'Jelaskan kondisi, waktu kejadian, dan dampaknya.',
                  child: TextFormField(
                    controller: _descCtrl,
                    minLines: 4,
                    maxLines: 6,
                    decoration: _fieldDecoration(
                      hint: 'Tulis deskripsi laporan...',
                    ),
                    validator: (value) =>
                        (value == null || value.trim().isEmpty)
                        ? 'Deskripsi wajib diisi'
                        : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _FormSection(
              title: 'Foto pendukung',
              icon: Icons.image_outlined,
              trailing: Text(
                '${_photos.length}/5',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6B7280),
                  fontWeight: FontWeight.w800,
                ),
              ),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _PhotoActionButton(
                        icon: Icons.photo_library_outlined,
                        label: 'Galeri',
                        onTap: () => _pick(ImageSource.gallery),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _PhotoActionButton(
                        icon: Icons.camera_alt_outlined,
                        label: 'Kamera',
                        onTap: () => _pick(ImageSource.camera),
                      ),
                    ),
                  ],
                ),
                if (_photos.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 104,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _photos.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 10),
                      itemBuilder: (context, index) {
                        return _PhotoPreview(
                          bytes: _photoBytes[index],
                          onRemove: () {
                            setState(() {
                              _photos.removeAt(index);
                              _photoBytes.removeAt(index);
                            });
                          },
                        );
                      },
                    ),
                  ),
                ] else ...[
                  const SizedBox(height: 10),
                  const _InfoStrip(
                    text:
                        'Tambahkan foto agar staff lebih mudah memahami kondisi.',
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration({required String hint, IconData? icon}) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: icon == null ? null : Icon(icon, size: 20),
      filled: true,
      fillColor: const Color(0xFFF9FAFB),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF991B1B), width: 1.4),
      ),
    );
  }
}

class _IntroPanel extends StatelessWidget {
  final Color red;

  const _IntroPanel({required this.red});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFFEE2E2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.campaign_outlined, color: red),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Isi laporan dengan singkat dan jelas. Foto pendukung akan membantu proses verifikasi.',
              style: TextStyle(
                fontSize: 13,
                height: 1.45,
                color: Color(0xFF4B5563),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FormSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget? trailing;
  final List<Widget> children;

  const _FormSection({
    required this.title,
    required this.icon,
    required this.children,
    this.trailing,
  });

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
              Icon(icon, size: 20, color: const Color(0xFF991B1B)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF111827),
                  ),
                ),
              ),
              ?trailing,
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;
  final String? helper;
  final Widget child;

  const _FieldLabel({required this.label, required this.child, this.helper});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: Color(0xFF374151),
          ),
        ),
        if (helper != null) ...[
          const SizedBox(height: 3),
          Text(
            helper!,
            style: const TextStyle(fontSize: 11, color: Colors.black45),
          ),
        ],
        const SizedBox(height: 7),
        child,
      ],
    );
  }
}

class _InfoStrip extends StatelessWidget {
  final String text;

  const _InfoStrip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
      ),
    );
  }
}

class _PhotoActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _PhotoActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF111827),
        side: const BorderSide(color: Color(0xFFD1D5DB)),
        padding: const EdgeInsets.symmetric(vertical: 13),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}

class _PhotoPreview extends StatelessWidget {
  final Uint8List bytes;
  final VoidCallback onRemove;

  const _PhotoPreview({required this.bytes, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.memory(
            bytes,
            width: 126,
            height: 104,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              width: 126,
              height: 104,
              color: const Color(0xFFF3F4F6),
              alignment: Alignment.center,
              child: const Icon(Icons.broken_image_outlined),
            ),
          ),
        ),
        Positioned(
          top: 6,
          right: 6,
          child: InkWell(
            onTap: onRemove,
            borderRadius: BorderRadius.circular(999),
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 14),
            ),
          ),
        ),
      ],
    );
  }
}
