import 'package:flutter/material.dart';

/// Widget header halaman Profil Staff.
/// Background merah LURUS (batas bawah horizontal datar),
/// avatar besar overlap di tengah antara merah dan putih,
/// tombol edit di pojok kanan atas.
class ProfileHeaderWidget extends StatelessWidget {
  final String name;
  final String position;
  final String nip;
  final VoidCallback onEditTap;

  const ProfileHeaderWidget({
    super.key,
    required this.name,
    required this.position,
    required this.nip,
    required this.onEditTap,
  });

  // Tinggi area merah (lurus, tanpa curve)
  static const double _redHeight = 250.0;
  // Radius avatar — setengahnya overlap ke merah, setengahnya ke bawah
  static const double _avatarRadius = 72.0;

  @override
  Widget build(BuildContext context) {
    final red = Colors.red.shade800;

    return Column(
      children: [
        // ── Stack: merah lurus + edit button + avatar overlap ──────
        SizedBox(
          height: _redHeight + _avatarRadius, // ruang untuk overlap avatar
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // 1. Background merah — Container kotak biasa, BATAS BAWAH LURUS
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  width: double.infinity,
                  height: _redHeight,
                  color: red,
                  // Dekorasi transparan (hanya lingkaran), TANPA path kurva
                  child: CustomPaint(
                    painter: _CircleDecorPainter(),
                  ),
                ),
              ),

              // 2. Tombol edit — pojok kanan atas, di dalam area merah
              Positioned(
                top: 16,
                right: 20,
                child: GestureDetector(
                  onTap: onEditTap,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.edit, color: Colors.white, size: 18),
                  ),
                ),
              ),

              // 3. Avatar — overlap tepat di garis batas merah & putih
              //    top = _redHeight - _avatarRadius → setengah di merah, setengah di bawah
              Positioned(
                top: _redHeight - _avatarRadius,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    width: _avatarRadius * 2,
                    height: _avatarRadius * 2,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey.shade100,
                      border: Border.all(color: Colors.white, width: 5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 20,
                          spreadRadius: 2,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: _avatarRadius,
                      backgroundColor: Colors.grey.shade100,
                      child: Icon(
                        Icons.person,
                        size: _avatarRadius * 1.15,
                        color: red.withOpacity(0.35),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // ── Teks Identitas ─────────────────────────────────────────
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              Text(
                name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.4,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                position,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.5,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 14),
              _NipBadge(nip: nip, red: red),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Dekorasi hanya lingkaran-lingkaran transparan, TANPA path kurva ──

class _CircleDecorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.06)
      ..style = PaintingStyle.fill;

    // Lingkaran kanan atas
    canvas.drawCircle(
      Offset(size.width * 0.78, size.height * 0.15),
      size.width * 0.34,
      paint,
    );
    // Lingkaran kiri bawah
    canvas.drawCircle(
      Offset(size.width * 0.06, size.height * 0.8),
      size.width * 0.25,
      paint,
    );
    // TIDAK ADA quadraticBezierTo atau path kurva di sini
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── NIP Badge ────────────────────────────────────────────────────────

class _NipBadge extends StatelessWidget {
  final String nip;
  final Color red;
  const _NipBadge({required this.nip, required this.red});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: red.withOpacity(0.07),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: red.withOpacity(0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified_user_rounded, size: 15, color: red),
          const SizedBox(width: 8),
          Text(
            'NIP: $nip',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: red,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ),
    );
  }
}
