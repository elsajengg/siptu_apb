import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/report.dart';

/// Form buat laporan baru; mengembalikan [Report] lewat `Navigator.pop` jika berhasil.
class CreateReportPage extends StatefulWidget {
  const CreateReportPage({super.key});

  @override
  State<CreateReportPage> createState() => _CreateReportPageState();
}

class _CreateReportPageState extends State<CreateReportPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _nameCtrl = TextEditingController(text: 'pengguna');
  final _picker = ImagePicker();

  static const _categories = [
    'Penerangan',
    'Kenyamanan Ruangan',
    'Furnitur',
    'Sanitasi',
    'Lainnya',
  ];

  static const int _maxPhotos = 4;

  String _category = _categories.first;
  final List<String> _imageDataUris = [];

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _locationCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _pick(ImageSource source) async {
    if (_imageDataUris.length >= _maxPhotos) return;
    final x = await _picker.pickImage(
      source: source,
      maxWidth: 1600,
      imageQuality: 82,
    );
    if (x == null || !mounted) return;
    final bytes = await x.readAsBytes();
    final mime = x.mimeType ?? 'image/jpeg';
    final b64 = base64Encode(bytes);
    setState(() {
      _imageDataUris.add('data:$mime;base64,$b64');
      if (_imageDataUris.length > _maxPhotos) {
        _imageDataUris.removeRange(_maxPhotos, _imageDataUris.length);
      }
    });
  }

  void _removePhoto(int i) {
    setState(() => _imageDataUris.removeAt(i));
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final report = Report(
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      location: _locationCtrl.text.trim(),
      category: _category,
      status: 'Menunggu',
      createdBy: _nameCtrl.text.trim().isEmpty
          ? 'pengguna'
          : _nameCtrl.text.trim(),
      likes: 0,
      staffName: '',
      staffFeedback: '',
      createdAt: DateTime.now(),
      images: List<String>.from(_imageDataUris),
    );

    Navigator.of(context).pop(report);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final red = scheme.primary;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            expandedHeight: 120,
            pinned: true,
            backgroundColor: red,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('Buat laporan'),
              background: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      red,
                      Color.lerp(red, Colors.black, 0.12)!,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Icon(
                      Icons.add_photo_alternate_outlined,
                      size: 72,
                      color: Colors.white.withValues(alpha: 0.14),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            sliver: SliverToBoxAdapter(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ceritakan kondisi fasilitas. Foto membantu tim memahami lokasi & kerusakan.',
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.4,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _SoftCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.photo_library_outlined,
                                  size: 20, color: red),
                              const SizedBox(width: 8),
                              Text(
                                'Foto laporan',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                  color: Colors.grey.shade900,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '${_imageDataUris.length}/$_maxPhotos',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Opsional, hingga $_maxPhotos foto.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 14),
                          if (_imageDataUris.isEmpty)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 22),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3F4F6),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Column(
                                children: [
                                  Icon(Icons.image_outlined,
                                      size: 40, color: Colors.grey.shade400),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Belum ada foto',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            SizedBox(
                              height: 104,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                itemCount: _imageDataUris.length,
                                separatorBuilder: (context, _) =>
                                    const SizedBox(width: 10),
                                itemBuilder: (context, i) {
                                  return Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(14),
                                        child: Image.memory(
                                          base64Decode(
                                            _imageDataUris[i].split(',').last,
                                          ),
                                          width: 104,
                                          height: 104,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      Positioned(
                                        top: -6,
                                        right: -6,
                                        child: Material(
                                          color: Colors.white,
                                          elevation: 2,
                                          shape: const CircleBorder(),
                                          child: InkWell(
                                            customBorder: const CircleBorder(),
                                            onTap: () => _removePhoto(i),
                                            child: Padding(
                                              padding: const EdgeInsets.all(4),
                                              child: Icon(
                                                Icons.close_rounded,
                                                size: 18,
                                                color: Colors.grey.shade800,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _imageDataUris.length >= _maxPhotos
                                      ? null
                                      : () => _pick(ImageSource.gallery),
                                  icon: const Icon(Icons.collections_outlined),
                                  label: const Text('Galeri'),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: FilledButton.tonalIcon(
                                  onPressed: _imageDataUris.length >= _maxPhotos
                                      ? null
                                      : () => _pick(ImageSource.camera),
                                  icon: const Icon(Icons.photo_camera_outlined),
                                  label: const Text('Kamera'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _SoftCard(
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _titleCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Judul laporan',
                              hintText: 'Ringkas, mis. Lampu koridor mati',
                              prefixIcon: Icon(Icons.title_outlined),
                            ),
                            textCapitalization: TextCapitalization.sentences,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Wajib diisi';
                              }
                              if (v.trim().length < 5) {
                                return 'Minimal 5 karakter';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                          DropdownButtonFormField<String>(
                            // ignore: deprecated_member_use
                            value: _category,
                            decoration: const InputDecoration(
                              labelText: 'Kategori',
                              prefixIcon: Icon(Icons.category_outlined),
                            ),
                            items: _categories
                                .map(
                                  (c) => DropdownMenuItem(
                                    value: c,
                                    child: Text(c),
                                  ),
                                )
                                .toList(),
                            onChanged: (v) {
                              if (v != null) setState(() => _category = v);
                            },
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _locationCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Lokasi',
                              hintText: 'Gedung, lantai, ruangan',
                              prefixIcon: Icon(Icons.place_outlined),
                            ),
                            textCapitalization: TextCapitalization.sentences,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Wajib diisi';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _descCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Deskripsi',
                              hintText:
                                  'Jelaskan kondisi dan kapan mulai terlihat',
                              alignLabelWithHint: true,
                            ),
                            maxLines: 5,
                            textCapitalization: TextCapitalization.sentences,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Wajib diisi';
                              }
                              if (v.trim().length < 20) {
                                return 'Minimal 20 karakter agar staff paham konteksnya';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _nameCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Nama di forum (opsional)',
                              hintText: 'Default: pengguna',
                              prefixIcon: Icon(Icons.badge_outlined),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton(
                        onPressed: _submit,
                        style: FilledButton.styleFrom(
                          backgroundColor: red,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text('Kirim laporan'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: Text(
                        'Demo lokal — foto disimpan sebagai data di memori per sesi.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SoftCard extends StatelessWidget {
  const _SoftCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: const Color(0xFFE8EAEE)),
      ),
      child: child,
    );
  }
}
