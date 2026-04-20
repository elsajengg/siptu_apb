import 'package:flutter/material.dart';

import 'ticket_models.dart';

class AdminDashboardPage extends StatelessWidget {
  AdminDashboardPage({super.key});

  final List<IncomingTicket> _tickets = kIncomingTickets;
  static const double _phi = 1.61803398875;

  int get _total => _tickets.length;
  int get _menunggu =>
      _tickets.where((t) => t.status.toLowerCase() == 'menunggu').length;
  int get _diproses =>
      _tickets.where((t) => t.status.toLowerCase() == 'diproses').length;
  int get _selesai =>
      _tickets.where((t) => t.status.toLowerCase() == 'selesai').length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red.shade800,
        elevation: 0,
        title: const Text(
          'Dashboard Admin',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            tooltip: 'Cari',
            onPressed: () {},
            icon: const Icon(Icons.search, color: Colors.white),
          ),
          IconButton(
            tooltip: 'Notifikasi',
            onPressed: () {},
            icon: const Icon(Icons.notifications_none, color: Colors.white),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            final isWide = w >= 980; // mode web/desktop
            final gap = 16.0;

            final left = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HeroHeader(
                  total: _total,
                  menunggu: _menunggu,
                  diproses: _diproses,
                  selesai: _selesai,
                ),
                SizedBox(height: gap),
                _QuickActions(
                  onBuatLaporan: () {},
                  onVerifikasi: () {},
                  onTugaskan: () {},
                  onExport: () {},
                ),
                SizedBox(height: gap),
                _buildSummaryCards(context),
                const SizedBox(height: 12),
                _buildTicketTable(context),
              ],
            );

            final right = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionTitle(
                  title: 'Kontrol & Insight',
                  subtitle:
                      'Ringkasan sistem untuk admin: verifikasi, penugasan, dan export.',
                ),
                const SizedBox(height: 10),
                _buildFilterAndLegend(context),
                const SizedBox(height: 12),
                _InsightCard(
                  title: 'Prioritas Hari Ini',
                  items: const [
                    _InsightItem(
                      icon: Icons.warning_amber_rounded,
                      color: Color(0xFFF97316),
                      title: '3 tiket menunggu > 24 jam',
                      subtitle: 'Butuh respon awal agar transparan.',
                    ),
                    _InsightItem(
                      icon: Icons.trending_up,
                      color: Color(0xFF2563EB),
                      title: 'Laporan trending meningkat',
                      subtitle: 'Fokus pada yang dukungannya tinggi.',
                    ),
                    _InsightItem(
                      icon: Icons.verified_outlined,
                      color: Color(0xFF16A34A),
                      title: '2 tiket selesai kemarin',
                      subtitle: 'Kirim update penutupan ke pelapor.',
                    ),
                  ],
                ),
              ],
            );

            if (isWide) {
              // Golden ratio layout: 62% (main) : 38% (side)
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 62, child: left),
                    SizedBox(width: gap * _phi),
                    Expanded(flex: 38, child: right),
                  ],
                ),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  left,
                  const SizedBox(height: 18),
                  right,
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Ringkasan Tiket Fasilitas',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Pantau status laporan yang masuk ke layanan fasilitas kampus.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: const Color(0xFFE5E7EB),
          ),
          child: Row(
            children: const [
              Icon(Icons.account_circle, size: 18, color: Colors.black54),
              SizedBox(width: 6),
              Text(
                'Administrator',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCards(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;
        final children = [
          _SummaryCard(
            label: 'Total Tiket',
            value: _total.toString(),
            color: const Color(0xFF2563EB),
            icon: Icons.all_inbox_outlined,
          ),
          _SummaryCard(
            label: 'Menunggu',
            value: _menunggu.toString(),
            color: const Color(0xFFF97316),
            icon: Icons.pending_actions_outlined,
          ),
          _SummaryCard(
            label: 'Diproses',
            value: _diproses.toString(),
            color: const Color(0xFFEAB308),
            icon: Icons.sync_outlined,
          ),
          _SummaryCard(
            label: 'Selesai',
            value: _selesai.toString(),
            color: const Color(0xFF16A34A),
            icon: Icons.check_circle_outline,
          ),
        ];

        if (isWide) {
          return Row(
            children: children
                .map(
                  (c) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: c,
                    ),
                  ),
                )
                .toList()
              ..removeLast(),
          );
        }

        return GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.7,
          children: children,
        );
      },
    );
  }

  Widget _buildFilterAndLegend(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Row(
                  children: const [
                    Icon(Icons.search, size: 18, color: Colors.black45),
                    SizedBox(width: 8),
                    Text(
                      'Cari judul / ID tiket',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black45,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Row(
                children: const [
                  Icon(Icons.filter_list, size: 18, color: Colors.black54),
                  SizedBox(width: 6),
                  Text(
                    'Filter',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: const [
            _StatusLegendChip(
              label: 'Menunggu',
              color: Color(0xFFF97316),
            ),
            _StatusLegendChip(
              label: 'Diproses',
              color: Color(0xFFEAB308),
            ),
            _StatusLegendChip(
              label: 'Selesai',
              color: Color(0xFF16A34A),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTicketTable(BuildContext context) {
    return Container(
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
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Text(
                  'Semua laporan masuk',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Text(
                  '${_tickets.length} tiket',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Lihat semua',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.red.shade800,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _tickets.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final ticket = _tickets[index];
              return ListTile(
                dense: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                title: Text(
                  ticket.title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 2),
                    Text(
                      '#${ticket.id} • ${ticket.category}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Pelapor: ${ticket.requester} • Update: ${ticket.lastUpdate}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.black45,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (ticket.assignedTo != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Staff: ${ticket.assignedTo}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF2563EB),
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ] else ...[
                      const SizedBox(height: 2),
                      const Text(
                        'Staff: belum ditugaskan',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.black38,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
                trailing: _StatusPill(status: ticket.status),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: color.withOpacity(0.12),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
              Icon(icon, size: 22, color: color),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusLegendChip extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusLegendChip({
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: CircleAvatar(
        backgroundColor: color,
        radius: 6,
      ),
      label: Text(
        label,
        style: const TextStyle(fontSize: 11),
      ),
      backgroundColor: const Color(0xFFF9FAFB),
      padding: const EdgeInsets.symmetric(horizontal: 6),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String status;

  const _StatusPill({required this.status});

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'menunggu':
        return const Color(0xFFF97316);
      case 'diproses':
        return const Color(0xFFEAB308);
      case 'selesai':
        return const Color(0xFF16A34A);
      default:
        return const Color(0xFF6B7280);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: color.withOpacity(0.12),
      ),
      child: Text(
        status,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionTitle({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
      ],
    );
  }
}

class _HeroHeader extends StatelessWidget {
  final int total;
  final int menunggu;
  final int diproses;
  final int selesai;

  const _HeroHeader({
    required this.total,
    required this.menunggu,
    required this.diproses,
    required this.selesai,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          colors: [
            Colors.red.shade900,
            Colors.red.shade700,
            const Color(0xFF7F1D1D),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.confirmation_number_outlined,
                    color: Colors.red.shade800),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Admin • ServiceDesk Kampus',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Monitoring semua tiket, penugasan staff, dan insight operasional.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _HeroStatPill(label: 'Total', value: '$total'),
              _HeroStatPill(label: 'Menunggu', value: '$menunggu'),
              _HeroStatPill(label: 'Diproses', value: '$diproses'),
              _HeroStatPill(label: 'Selesai', value: '$selesai'),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroStatPill extends StatelessWidget {
  final String label;
  final String value;

  const _HeroStatPill({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  final VoidCallback onBuatLaporan;
  final VoidCallback onVerifikasi;
  final VoidCallback onTugaskan;
  final VoidCallback onExport;

  const _QuickActions({
    required this.onBuatLaporan,
    required this.onVerifikasi,
    required this.onTugaskan,
    required this.onExport,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Aksi Cepat',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _ActionTile(
                  icon: Icons.add_circle_outline,
                  color: Colors.red.shade800,
                  title: 'Buat',
                  subtitle: 'Laporan',
                  onTap: onBuatLaporan,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ActionTile(
                  icon: Icons.verified_outlined,
                  color: const Color(0xFF2563EB),
                  title: 'Verifikasi',
                  subtitle: 'Masuk',
                  onTap: onVerifikasi,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ActionTile(
                  icon: Icons.assignment_ind_outlined,
                  color: const Color(0xFFF97316),
                  title: 'Tugaskan',
                  subtitle: 'Staff',
                  onTap: onTugaskan,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ActionTile(
                  icon: Icons.download_outlined,
                  color: const Color(0xFF16A34A),
                  title: 'Export',
                  subtitle: 'Data',
                  onTap: onExport,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: color.withOpacity(0.08),
          border: Border.all(color: color.withOpacity(0.18)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 11, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  final String title;
  final List<_InsightItem> items;

  const _InsightCard({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          ...items.map(
            (it) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: it.color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(it.icon, color: it.color, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          it.title,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          it.subtitle,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightItem {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;

  const _InsightItem({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });
}

