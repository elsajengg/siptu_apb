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
    final double bannerHeight = size.width / (_phi * 1.4);
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
                  top: bannerHeight - (80 / _phi),
                  child: _buildAvatar(red),
                ),
              ],
            ),

            const SizedBox(height: 70),

            // ── Personal Info & Identity ───────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const Text(
                    'Budi Santoso',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.8,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Staff Teknisi Ahli • Fasilitas & Infrastruktur',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildIdentityChip(red),
                ],
              ),
            ),

            const SizedBox(height: 30 * _phi),

            // ── Stats Row ──────────────────────────────────────────
            _buildStatsGrid(),

            const SizedBox(height: 30 * _phi),

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
              _MenuTile(
                icon: Icons.location_on_outlined,
                title: 'Lokasi Kerja',
                subtitle: 'Gedung Panambulai, Lantai Dasar',
                onTap: () {},
                showChevron: false,
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

  Widget _buildAvatar(Color red) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 4),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 15, offset: Offset(0, 8)),
        ],
      ),
      child: CircleAvatar(
        radius: 60,
        backgroundColor: Colors.grey.shade200,
        child: ClipOval(
          child: Icon(Icons.person, size: 70, color: red.withOpacity(0.5)),
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

  Widget _buildStatsGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _StatBox(label: 'Tugas', value: '142', icon: Icons.task_alt_rounded, color: Colors.blue),
          _StatBox(label: 'Rating', value: '4.9', icon: Icons.star_rounded, color: Colors.amber),
          _StatBox(label: 'Lama Kerja', value: '6th', icon: Icons.work_history_rounded, color: Colors.teal),
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

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatBox({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 24, color: color),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontWeight: FontWeight.w500),
        ),
      ],
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
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(size.width * 0.85, size.height * 0.2), 60, paint);
    canvas.drawCircle(Offset(size.width * 0.1, size.height * 0.7), 100, paint);

    final path = Path()
      ..moveTo(0, size.height * 0.8)
      ..quadraticBezierTo(size.width * 0.5, size.height * 0.9, size.width, size.height * 0.7)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
