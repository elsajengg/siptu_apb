import 'package:flutter/material.dart';

/// Widget header halaman Profil Staff.
/// Berisi background merah + ClipPath melengkung, avatar melayang,
/// tombol edit di pojok kanan atas, serta teks Nama, Jabatan, dan Badge NIP.
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

  static const double _redHeight = 220.0;
  static const double _avatarRadius = 52.0;

  @override
  Widget build(BuildContext context) {
    final red = Colors.red.shade800;

    return Column(
      children: [
        // ── Stack: Background merah + Avatar melayang ──────────────
        SizedBox(
          // Total tinggi = area merah + setengah avatar yang melayang keluar
          height: _redHeight + _avatarRadius,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // 1. Background merah dengan ClipPath lengkung bawah
              ClipPath(
                clipper: _CurvedBottomClipper(),
                child: Container(
                  width: double.infinity,
                  height: _redHeight,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.red.shade900, red],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: _DecorativePainterLayer(redHeight: _redHeight),
                ),
              ),

              // 2. Tombol edit — pojok kanan atas area merah
              Positioned(
                top: 16,
                right: 20,
                child: _EditButton(onTap: onEditTap),
              ),

              // 3. Avatar — tepat di garis batas bawah background merah
              //    Center horizontal, offset vertikal agar setengah di merah, setengah di putih
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Center(
                  child: _ProfileAvatar(radius: _avatarRadius, red: red),
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

// ── Sub-widgets ─────────────────────────────────────────────────────

class _EditButton extends StatelessWidget {
  final VoidCallback onTap;
  const _EditButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.4), width: 1.5),
        ),
        child: const Icon(Icons.edit_outlined, color: Colors.white, size: 18),
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  final double radius;
  final Color red;
  const _ProfileAvatar({required this.radius, required this.red});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        border: Border.all(color: Colors.white, width: 4.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.14),
            blurRadius: 20,
            spreadRadius: 1,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: CircleAvatar(
        radius: radius,
        backgroundColor: Colors.grey.shade100,
        child: Icon(Icons.person, size: radius * 1.1, color: red.withOpacity(0.3)),
      ),
    );
  }
}

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

class _DecorativePainterLayer extends StatelessWidget {
  final double redHeight;
  const _DecorativePainterLayer({required this.redHeight});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(double.infinity, redHeight),
      painter: _BannerPainter(),
    );
  }
}

/// ClipPath yang memotong bagian bawah container menjadi kurva lembut.
class _CurvedBottomClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 40);
    path.quadraticBezierTo(
      size.width / 2, size.height + 30, // titik kontrol (kurva membuncit ke bawah)
      size.width, size.height - 40,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _BannerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.06)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size.width * 0.78, size.height * 0.15),
      size.width * 0.34,
      paint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.06, size.height * 0.8),
      size.width * 0.25,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
