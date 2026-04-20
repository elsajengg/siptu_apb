import 'package:flutter/material.dart';

/// Beranda ringkas untuk pelapor (mahasiswa/dosen); laporan utama di tab Forum.
class PelaporHomePage extends StatelessWidget {
  const PelaporHomePage({super.key, required this.displayName});

  final String displayName;

  @override
  Widget build(BuildContext context) {
    final red = Colors.red.shade800;
    final name = displayName.trim().isEmpty ? 'Pengguna' : displayName.trim();

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: red,
        title: const Text(
          'Beranda',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Halo, $name',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Laporkan kerusakan fasilitas lewat tab Laporan. Anda bisa membuat tiket baru dan melihat forum dukungan.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: red,
                        minimumSize: const Size.fromHeight(48),
                      ),
                      onPressed: () {
                        DefaultTabController.of(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Buka tab Laporan di bawah untuk forum & buat laporan.',
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.forum_outlined),
                      label: const Text('Ke forum laporan'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Peran Pelapor tidak melihat dashboard admin/staff.',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
