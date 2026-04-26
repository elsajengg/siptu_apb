import 'package:flutter/material.dart';
import '../auth/login_page.dart';

class AdminProfilePage extends StatefulWidget {
  const AdminProfilePage({super.key});

  @override
  State<AdminProfilePage> createState() => _AdminProfilePageState();
}

class _AdminProfilePageState extends State<AdminProfilePage> {
  // ── Data dummy admin ─────────────────────────────────────────
  String _name = 'Super Admin';
  String _position = 'Administrator • SIPTU';
  String _email = 'admin@telkomuniversity.ac.id';
  String _phone = '+62 811-2233-4455';
  final String _adminId = 'ADM-2024-001';
  bool _notifPengaduan = true;

  final Color _red = Colors.red.shade800;

  // ── Edit Profil ──────────────────────────────────────────────
  void _showEditProfileDialog() {
    final nameCtrl = TextEditingController(text: _name);
    final posCtrl = TextEditingController(text: _position);
    final emailCtrl = TextEditingController(text: _email);
    final phoneCtrl = TextEditingController(text: _phone);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFFF5F5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Edit Profil',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildFormField(
                  controller: nameCtrl,
                  label: 'Nama Lengkap',
                  icon: Icons.person_outline,
                  validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 12),
                _buildFormField(
                  controller: posCtrl,
                  label: 'Posisi / Unit',
                  icon: Icons.work_outline,
                  validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 12),
                _buildFormField(
                  controller: emailCtrl,
                  label: 'Email',
                  icon: Icons.alternate_email,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 12),
                _buildFormField(
                  controller: phoneCtrl,
                  label: 'Nomor Telepon',
                  icon: Icons.smartphone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal', style: TextStyle(color: _red)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: _red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              if (formKey.currentState!.validate()) {
                setState(() {
                  _name = nameCtrl.text;
                  _position = posCtrl.text;
                  _email = emailCtrl.text;
                  _phone = phoneCtrl.text;
                });
                Navigator.pop(context);
                _showSnackBar('Profil berhasil diperbarui!', Colors.green);
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  // ── Edit Email ───────────────────────────────────────────────
  void _showEditEmailDialog() {
    final emailCtrl = TextEditingController(text: _email);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFFF5F5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Edit Email',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        content: _buildFormField(
          controller: emailCtrl,
          label: 'Alamat Email',
          icon: Icons.alternate_email,
          keyboardType: TextInputType.emailAddress,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal', style: TextStyle(color: _red)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: _red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              setState(() => _email = emailCtrl.text);
              Navigator.pop(context);
              _showSnackBar('Email berhasil diperbarui!', Colors.green);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  // ── Edit No. Telepon ─────────────────────────────────────────
  void _showEditPhoneDialog() {
    final phoneCtrl = TextEditingController(text: _phone);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFFF5F5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Edit No. Telepon',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        content: _buildFormField(
          controller: phoneCtrl,
          label: 'Nomor Telepon',
          icon: Icons.smartphone_outlined,
          keyboardType: TextInputType.phone,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal', style: TextStyle(color: _red)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: _red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              setState(() => _phone = phoneCtrl.text);
              Navigator.pop(context);
              _showSnackBar('Nomor telepon berhasil diperbarui!', Colors.green);
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  // ── Ganti Kata Sandi ─────────────────────────────────────────
  void _showChangePasswordDialog() {
    final oldPassCtrl = TextEditingController();
    final newPassCtrl = TextEditingController();
    final confirmPassCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFFFFF5F5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Ganti Kata Sandi',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildFormField(
                  controller: oldPassCtrl,
                  label: 'Password Sekarang',
                  icon: Icons.lock_outline,
                  obscureText: true,
                  validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 12),
                _buildFormField(
                  controller: newPassCtrl,
                  label: 'Password Baru',
                  icon: Icons.lock_reset_outlined,
                  obscureText: true,
                  validator: (v) => v!.length < 6 ? 'Minimal 6 karakter' : null,
                ),
                const SizedBox(height: 12),
                _buildFormField(
                  controller: confirmPassCtrl,
                  label: 'Konfirmasi Password Baru',
                  icon: Icons.lock_reset_outlined,
                  obscureText: true,
                  validator: (v) =>
                      v != newPassCtrl.text ? 'Password tidak cocok' : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal', style: TextStyle(color: _red)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: _red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context);
                _showSnackBar('Kata sandi berhasil diperbarui!', Colors.green);
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  // ── Logout ───────────────────────────────────────────────────
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Keluar Dari Aplikasi'),
        content: const Text(
          'Apakah kamu yakin ingin keluar dari akun Admin ini?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: _red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Navigator.pop(context);
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
            },
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: color));
  }

  // ── Form Field Helper ────────────────────────────────────────
  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: CustomScrollView(
        slivers: [
          // ── Hero Header ──────────────────────────────────────
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: _red,
            iconTheme: const IconThemeData(color: Colors.white),
            actions: [
              // Tombol edit profil di kanan atas
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: CircleAvatar(
                  backgroundColor: Colors.white.withOpacity(0.2),
                  child: IconButton(
                    icon: const Icon(Icons.edit, color: Colors.white, size: 18),
                    onPressed: _showEditProfileDialog,
                    tooltip: 'Edit Profil',
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.red.shade900, Colors.red.shade700],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    // Avatar
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.person,
                        size: 52,
                        color: Colors.red.shade200,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Body ─────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Column(
              children: [
                // Nama & Role
                Container(
                  width: double.infinity,
                  color: Colors.white,
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
                  child: Column(
                    children: [
                      Text(
                        _name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _position,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      // Badge ID Admin
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _red.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: _red.withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.verified_user, size: 14, color: _red),
                            const SizedBox(width: 6),
                            Text(
                              'ID Admin: $_adminId',
                              style: TextStyle(
                                fontSize: 12,
                                color: _red,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // ── Informasi Akun ───────────────────────────
                _SectionLabel(label: 'Informasi Akun'),
                Container(
                  color: Colors.white,
                  child: Column(
                    children: [
                      _InfoTile(
                        icon: Icons.alternate_email,
                        title: 'Email',
                        subtitle: _email,
                        onTap: _showEditEmailDialog,
                      ),
                      const Divider(height: 1, indent: 56),
                      _InfoTile(
                        icon: Icons.smartphone_outlined,
                        title: 'Nomor Telepon',
                        subtitle: _phone,
                        onTap: _showEditPhoneDialog,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // ── Pengaturan & Keamanan ────────────────────
                _SectionLabel(label: 'Pengaturan & Keamanan'),
                Container(
                  color: Colors.white,
                  child: Column(
                    children: [
                      _InfoTile(
                        icon: Icons.lock_outline,
                        title: 'Ganti Kata Sandi',
                        onTap: _showChangePasswordDialog,
                      ),
                      const Divider(height: 1, indent: 56),
                      // Toggle Notifikasi Pengaduan
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.notifications_active_outlined,
                                color: Colors.blue,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Expanded(
                              child: Text(
                                'Notifikasi Pengaduan',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Switch(
                              value: _notifPengaduan,
                              onChanged: (val) =>
                                  setState(() => _notifPengaduan = val),
                              activeColor: _red,
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1, indent: 56),
                      // Tombol Keluar
                      ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.logout_rounded,
                            color: _red,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          'Keluar Dari Aplikasi',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _red,
                          ),
                        ),
                        trailing: Icon(Icons.chevron_right, color: _red),
                        onTap: _showLogoutDialog,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Widget Helper ─────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  const _InfoTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 20, color: Colors.black54),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: const TextStyle(fontSize: 12, color: Colors.black45),
            )
          : null,
      trailing: const Icon(
        Icons.chevron_right,
        color: Colors.black38,
        size: 20,
      ),
    );
  }
}
