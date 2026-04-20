import 'package:flutter/material.dart';

class StaffData {
  final String id;
  String name;
  String email;
  String password;
  String specialization;

  StaffData({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.specialization,
  });
}

class ManageStaffPage extends StatefulWidget {
  const ManageStaffPage({super.key});

  @override
  State<ManageStaffPage> createState() => _ManageStaffPageState();
}

class _ManageStaffPageState extends State<ManageStaffPage> {
  final List<StaffData> _staffList = [
    StaffData(
      id: 'STF-001',
      name: 'Ahmad Fauzi',
      email: 'ahmad.fauzi@telkomuniversity.ac.id',
      password: '••••••••',
      specialization: 'Penerangan & Elektronik',
    ),
    StaffData(
      id: 'STF-002',
      name: 'Budi Santoso',
      email: 'budi.santoso@telkomuniversity.ac.id',
      password: '••••••••',
      specialization: 'AC & Kenyamanan Ruangan',
    ),
    StaffData(
      id: 'STF-003',
      name: 'Citra Dewi',
      email: 'citra.dewi@telkomuniversity.ac.id',
      password: '••••••••',
      specialization: 'Sanitasi & Kebersihan',
    ),
    StaffData(
      id: 'STF-004',
      name: 'Dendi Pratama',
      email: 'dendi.pratama@telkomuniversity.ac.id',
      password: '••••••••',
      specialization: 'Furnitur & Infrastruktur',
    ),
  ];

  void _showAddStaffDialog() {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    final specCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          'Tambah Staff Baru',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _StaffFormField(
                  controller: nameCtrl,
                  label: 'Nama',
                  icon: Icons.person_outline,
                  validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 10),
                _StaffFormField(
                  controller: emailCtrl,
                  label: 'Email',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 10),
                _StaffFormField(
                  controller: passCtrl,
                  label: 'Password',
                  icon: Icons.lock_outline,
                  obscureText: true,
                  validator: (v) => v!.length < 4 ? 'Minimal 4 karakter' : null,
                ),
                const SizedBox(height: 10),
                _StaffFormField(
                  controller: specCtrl,
                  label: 'Spesialisasi',
                  icon: Icons.build_outlined,
                  validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade800),
            onPressed: () {
              if (formKey.currentState!.validate()) {
                setState(() {
                  _staffList.add(
                    StaffData(
                      id: 'STF-00${_staffList.length + 1}',
                      name: nameCtrl.text,
                      email: emailCtrl.text,
                      password: passCtrl.text,
                      specialization: specCtrl.text,
                    ),
                  );
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Staff berhasil ditambahkan!'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showEditStaffDialog(StaffData staff) {
    final nameCtrl = TextEditingController(text: staff.name);
    final emailCtrl = TextEditingController(text: staff.email);
    final passCtrl = TextEditingController();
    final specCtrl = TextEditingController(text: staff.specialization);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          'Edit Staff',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _StaffFormField(
                  controller: nameCtrl,
                  label: 'Nama',
                  icon: Icons.person_outline,
                  validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 10),
                _StaffFormField(
                  controller: emailCtrl,
                  label: 'Email',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 10),
                _StaffFormField(
                  controller: passCtrl,
                  label: 'Password Baru (kosongkan jika tidak diubah)',
                  icon: Icons.lock_outline,
                  obscureText: true,
                  validator: (v) => null,
                ),
                const SizedBox(height: 10),
                _StaffFormField(
                  controller: specCtrl,
                  label: 'Spesialisasi',
                  icon: Icons.build_outlined,
                  validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade800),
            onPressed: () {
              if (formKey.currentState!.validate()) {
                setState(() {
                  staff.name = nameCtrl.text;
                  staff.email = emailCtrl.text;
                  staff.specialization = specCtrl.text;
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Data staff berhasil diperbarui!'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _deleteStaff(StaffData staff) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Hapus Staff'),
        content: Text('Yakin ingin menghapus "${staff.name}" dari sistem?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              setState(() => _staffList.remove(staff));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${staff.name} berhasil dihapus!'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final red = Colors.red.shade800;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: red,
        elevation: 0,
        title: const Text(
          'Manajemen Staff',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add_outlined, color: Colors.white),
            tooltip: 'Tambah Staff',
            onPressed: _showAddStaffDialog,
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: Column(
        children: [
          // Header info
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.red.shade900, Colors.red.shade700],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.people, color: Colors.white, size: 32),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_staffList.length} Staff Terdaftar',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const Text(
                      'Kelola akun staff fasilitas kampus',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // List Staff
          Expanded(
            child: _staffList.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 60,
                          color: Colors.black26,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Belum ada staff terdaftar',
                          style: TextStyle(color: Colors.black45),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _staffList.length,
                    itemBuilder: (context, index) {
                      final staff = _staffList[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 6,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: red.withOpacity(0.12),
                              child: Text(
                                staff.name[0],
                                style: TextStyle(
                                  color: red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    staff.name,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    staff.email,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.black54,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: red.withOpacity(0.08),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      staff.specialization,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: red,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              children: [
                                IconButton(
                                  onPressed: () => _showEditStaffDialog(staff),
                                  icon: const Icon(Icons.edit_outlined),
                                  color: Colors.blue,
                                  iconSize: 20,
                                  tooltip: 'Edit',
                                ),
                                IconButton(
                                  onPressed: () => _deleteStaff(staff),
                                  icon: const Icon(Icons.delete_outline),
                                  color: Colors.red,
                                  iconSize: 20,
                                  tooltip: 'Hapus',
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddStaffDialog,
        backgroundColor: red,
        icon: const Icon(Icons.person_add_outlined, color: Colors.white),
        label: const Text(
          'Tambah Staff',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

class _StaffFormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _StaffFormField({
    required this.controller,
    required this.label,
    required this.icon,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
      ),
    );
  }
}
