import 'package:flutter/material.dart';
import '../auth/login_page.dart';
import 'completed_tasks_page.dart';
import '../home/home_shell.dart';
import 'widgets/profile_header_widget.dart';
import '../../data/api_service.dart';

class StaffProfilePage extends StatefulWidget {
  const StaffProfilePage({super.key});

  @override
  State<StaffProfilePage> createState() => _StaffProfilePageState();
}

class _StaffProfilePageState extends State<StaffProfilePage> {
  // ── Constants ─────────────────────────────────────────────────────
  static const double _headerHeight = 180.0;
  static const double _avatarRadius = 52.0;
  static const double _sectionMargin = 20.0;

  String _name = ApiService.currentUser?['name']?.toString() ?? '';
  String _position = 'Staff Teknisi Ahli • Fasilitas & Infrastruktur';
  String _email = ApiService.currentUser?['email']?.toString() ?? '';
  String _phone = '';

  @override
  Widget build(BuildContext context) {
    final red = Colors.red.shade800;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: red,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const HomeShell()),
            (route) => false,
          ),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: const Text(
          'Profil Saya',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Header (ProfileHeaderWidget) ────────────────────────
            ProfileHeaderWidget(
              name: _name,
              position: _position,
              nip: ApiService.currentUser?['nip']?.toString() ?? '-',
              onEditTap: _showEditProfileDialog,
            ),

            const SizedBox(height: 28),

            // ── Section: Informasi Akun ───────────────────────────────
            _buildSectionHeader('Informasi Akun'),
            const SizedBox(height: 10),
            _buildActionCard([
              _MenuTile(
                icon: Icons.alternate_email_rounded,
                title: 'Email',
                subtitle: _email,
                onTap: () => _showEditEmailDialog(),
              ),
              _MenuTile(
                icon: Icons.assignment_turned_in_rounded,
                title: 'Riwayat Perbaikan Selesai',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CompletedTasksPage(),
                    ),
                  );
                },
              ),
            ]),

            const SizedBox(height: 24),

            // ── Section: Pengaturan & Keamanan ───────────────────────
            _buildSectionHeader('Pengaturan & Keamanan'),
            const SizedBox(height: 10),
            _buildActionCard([
              _MenuTile(
                icon: Icons.lock_outline_rounded,
                title: 'Ganti Kata Sandi',
                onTap: () => _showChangePasswordDialog(),
              ),
              _MenuTile(
                icon: Icons.logout_rounded,
                title: 'Keluar Dari Aplikasi',
                color: red,
                onTap: () => _handleLogout(context),
              ),
            ]),

            // ── Bottom Padding ────────────────────────────────────────
            const SizedBox(height: 72),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(
        left: _sectionMargin + 4,
        right: _sectionMargin,
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.1,
          color: Color(0xFF374151),
        ),
      ),
    );
  }

  Widget _buildActionCard(List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: _sectionMargin),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: children.asMap().entries.map((e) {
            final idx = e.key;
            final child = e.value;
            if (idx == children.length - 1) return child;
            return Column(
              children: [
                child,
                const Divider(
                  height: 1,
                  indent: 56,
                  endIndent: 0,
                  color: Color(0xFFF3F4F6),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  // ── Dialog Builders ────────────────────────────────────────────────

  void _showEditProfileDialog() {
    final nameCtrl = TextEditingController(text: _name);
    final posCtrl = TextEditingController(text: _position);
    final emailCtrl = TextEditingController(text: _email);
    final phoneCtrl = TextEditingController(text: _phone);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'Edit Profil',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildEditField(nameCtrl, 'Nama Lengkap', Icons.person_outline),
              const SizedBox(height: 16),
              _buildEditField(posCtrl, 'Posisi / Unit', Icons.work_outline),
              const SizedBox(height: 16),
              _buildEditField(
                emailCtrl,
                'Email',
                Icons.alternate_email,
                type: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              _buildEditField(
                phoneCtrl,
                'Nomor Telepon',
                Icons.phone_android_rounded,
                type: TextInputType.phone,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade800,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            onPressed: () async {
              final result = await ApiService.updateProfile(
                name: nameCtrl.text.trim(),
                email: emailCtrl.text.trim(),
              );
              if (!context.mounted || result['success'] != true) return;
              setState(() {
                _name = nameCtrl.text;
                _email = emailCtrl.text;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Profil berhasil diperbarui')),
              );
            },
            child: const Text(
              'Simpan',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditField(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    TextInputType? type,
  }) {
    return TextField(
      controller: ctrl,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }

  void _showEditEmailDialog() {
    final controller = TextEditingController(text: _email);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Edit Email',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: 'Alamat Email',
            hintText: 'nama@telkomuniversity.ac.id',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade800,
            ),
            onPressed: () async {
              final result = await ApiService.updateProfile(
                name: _name,
                email: controller.text.trim(),
              );
              if (!context.mounted || result['success'] != true) return;
              setState(() => _email = controller.text);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Email berhasil diperbarui')),
              );
            },
            child: const Text('Simpan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showEditPhoneDialog() {
    final controller = TextEditingController(text: _phone);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Edit No. Telepon',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: 'Nomor Telepon',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
          keyboardType: TextInputType.phone,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade800,
            ),
            onPressed: () {
              setState(() => _phone = controller.text);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Nomor telepon berhasil diperbarui'),
                ),
              );
            },
            child: const Text('Simpan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Ganti Kata Sandi',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password Sekarang',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Password Baru',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Konfirmasi Password Baru',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade800,
            ),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Kata sandi berhasil diperbarui')),
              );
            },
            child: const Text('Update', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Konfirmasi Logout',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
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
            child: const Text(
              'Ya, Keluar',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Reusable _MenuTile ─────────────────────────────────────────────────

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color? color;
  final VoidCallback onTap;

  const _MenuTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? Colors.grey.shade700;
    final isDestructive = color != null;

    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: subtitle != null ? 4 : 2,
      ),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDestructive
              ? effectiveColor.withOpacity(0.08)
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: effectiveColor, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: isDestructive ? effectiveColor : const Color(0xFF111827),
        ),
      ),
      subtitle: subtitle != null
          ? Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                subtitle!,
                style: const TextStyle(fontSize: 12.5, color: Colors.black45),
              ),
            )
          : null,
      trailing: Icon(
        Icons.chevron_right_rounded,
        size: 20,
        color: isDestructive ? effectiveColor.withOpacity(0.5) : Colors.black26,
      ),
    );
  }
}

// ── BannerPainter sudah dipindah ke widgets/profile_header_widget.dart ──
