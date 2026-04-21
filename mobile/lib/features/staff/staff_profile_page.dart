import 'package:flutter/material.dart';
import '../auth/login_page.dart';

class StaffProfilePage extends StatefulWidget {
  const StaffProfilePage({super.key});

  @override
  State<StaffProfilePage> createState() => _StaffProfilePageState();
}

class _StaffProfilePageState extends State<StaffProfilePage> {
  static const double _phi = 1.61803398875;
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double bannerHeight = size.width / _phi;
    final double avatarDiameter = bannerHeight / _phi;
    final double avatarRadius = avatarDiameter / 2;
    final red = Colors.red.shade800;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Golden Ratio Header (Banner + Avatar) ────────────────
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                _buildBanner(bannerHeight, red),
                Positioned(
                  top: bannerHeight - (avatarDiameter / (_phi * _phi)),
                  child: _buildAvatar(avatarRadius, red),
                ),
              ],
            ),

            SizedBox(height: avatarRadius * _phi),

            // ── Personal Info & Identity ───────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16 * _phi),
              child: Column(
                children: [
                  Text(
                    'Budi Santoso',
                    style: TextStyle(
                      fontSize: 18 * _phi,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4 * _phi),
                  Text(
                    'Staff Teknisi Ahli • Fasilitas & Infrastruktur',
                    style: TextStyle(
                      fontSize: 8 * _phi,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8 * _phi),
                  _buildIdentityChip(red),
                ],
              ),
            ),


            // ── Account & Information Section ──────────────────────
            _buildSectionHeader('Informasi Akun'),
            _buildActionCard([
              _MenuTile(
                icon: Icons.alternate_email_rounded,
                title: 'Email',
                subtitle: 'budi.santoso@telkomuniversity.ac.id',
                onTap: () => _showTopup(context, 'Edit Email'),
              ),
              _MenuTile(
                icon: Icons.phone_android_rounded,
                title: 'Nomor Telepon',
                subtitle: '+62 812-3456-7890',
                onTap: () => _showTopup(context, 'Edit No. Telepon'),
              ),

            ]),

            const SizedBox(height: 20 * _phi),

            // ── Settings & Preferences ─────────────────────────────
            _buildSectionHeader('Pengaturan & Keamanan'),
            _buildActionCard([
              _MenuTile(
                icon: Icons.lock_outline_rounded,
                title: 'Ganti Kata Sandi',
                onTap: () => _showTopup(context, 'Ganti Password'),
              ),
              SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                secondary: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.notifications_active_outlined, size: 20, color: Colors.blue),
                ),
                title: const Text(
                  'Notifikasi Tugas',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
                value: _notificationsEnabled,
                onChanged: (val) => setState(() => _notificationsEnabled = val),
              ),
              _MenuTile(
                icon: Icons.logout_rounded,
                title: 'Keluar Dari Aplikasi',
                color: red,
                onTap: () => _handleLogout(context),
              ),
            ]),

            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildBanner(double height, Color red) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.red.shade900, red, const Color(0xFF7F1D1D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          CustomPaint(
            size: Size(double.infinity, height),
            painter: _BannerPainter(),
          ),
          Positioned(
            top: 50,
            right: 20,
            child: CircleAvatar(
              backgroundColor: Colors.white.withOpacity(0.1),
              child: const Icon(Icons.edit, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(double radius, Color red) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08), 
            blurRadius: 20, 
            offset: const Offset(0, 10)
          ),
        ],
      ),
      child: CircleAvatar(
        radius: radius,
        backgroundColor: Colors.grey.shade100,
        child: ClipOval(
          child: Icon(Icons.person, size: radius * 1.2, color: red.withOpacity(0.4)),
        ),
      ),
    );
  }

  Widget _buildIdentityChip(Color red) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: red.withOpacity(0.08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: red.withOpacity(0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified_user, size: 14, color: red),
          const SizedBox(width: 8),
          Text(
            'NIP: 19850612 201012 1 001',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: red,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, bottom: 12),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            letterSpacing: -0.2,
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard(List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: children.asMap().entries.map((e) {
            final idx = e.key;
            final widget = e.value;
            if (idx == children.length - 1) return widget;
            return Column(
              children: [
                widget,
                const Divider(height: 1, indent: 56),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showTopup(BuildContext context, String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Fitur $title segera hadir!')),
    );
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin keluar dari akun staf?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
            },
            child: const Text('Ya, Keluar', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}


class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color? color;
  final VoidCallback onTap;
  final bool showChevron;

  const _MenuTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.color,
    required this.onTap,
    this.showChevron = true,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (color ?? Colors.grey.shade700).withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color ?? Colors.grey.shade700, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: color ?? Colors.black87,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: const TextStyle(fontSize: 12, color: Colors.black45),
            )
          : null,
      trailing: showChevron
          ? const Icon(Icons.chevron_right_rounded, size: 20, color: Colors.black26)
          : null,
    );
  }
}

class _BannerPainter extends CustomPainter {
  static const double _phi = 1.61803398875;
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.06)
      ..style = PaintingStyle.fill;

    // Abstract circles based on phi
    canvas.drawCircle(Offset(size.width * (1 / _phi), size.height * 0.1), size.width / (_phi * _phi), paint);
    canvas.drawCircle(Offset(size.width * 0.1, size.height * 0.8), size.width / (_phi * 1.5), paint);

    final path = Path()
      ..moveTo(0, size.height * 0.75)
      ..quadraticBezierTo(size.width / _phi, size.height * 0.95, size.width, size.height * 0.65)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
