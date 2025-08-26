import 'package:flutter/material.dart';

class AdminStubScreen extends StatefulWidget {
  static const route = '/admin';
  const AdminStubScreen({super.key});

  @override
  State<AdminStubScreen> createState() => _AdminStubScreenState();
}

class _AdminStubScreenState extends State<AdminStubScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 17, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Console'),
        bottom: TabBar(
          controller: _tabs,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Dashboard', icon: Icon(Icons.dashboard_customize)),
            Tab(text: 'Transactions', icon: Icon(Icons.receipt_long)),
            Tab(text: 'Clients', icon: Icon(Icons.people_alt)),
            Tab(text: 'Branches', icon: Icon(Icons.store_mall_directory)),
            Tab(text: 'Devices', icon: Icon(Icons.devices_other)),
            Tab(text: 'Audit', icon: Icon(Icons.fact_check_outlined)),
            Tab(text: 'Reports', icon: Icon(Icons.bar_chart_rounded)),
            Tab(text: 'Settings', icon: Icon(Icons.settings_outlined)),
            Tab(text: 'Policies', icon: Icon(Icons.policy_outlined)),
            Tab(
                text: 'Claims',
                icon: Icon(Icons.assignment_turned_in_outlined)),
            Tab(text: 'Documents', icon: Icon(Icons.folder_open)),
            Tab(text: 'Debit Orders', icon: Icon(Icons.swap_horiz_outlined)),
            Tab(text: 'Recons', icon: Icon(Icons.sync_alt_outlined)),
            Tab(text: 'Arrears', icon: Icon(Icons.schedule_outlined)),
            Tab(text: 'Ledger', icon: Icon(Icons.account_balance_outlined)),
            Tab(text: 'Products', icon: Icon(Icons.card_membership_outlined)),
            Tab(text: 'Notifications', icon: Icon(Icons.notifications)),
          ],
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabs,
          children: const [
            _DashboardTab(),
            _TransactionsTab(),
            _ClientsTab(),
            _BranchesTab(),
            _DevicesTab(),
            _AuditTab(),
            _ReportsTab(),
            _SettingsTab(),
            _PoliciesTab(),
            _ClaimsTab(),
            _DocumentsTab(),
            _DebitOrdersTab(),
            _ReconsTab(),
            _ArrearsTab(),
            _LedgerTab(),
            _ProductsTab(),
            _AdminNotificationsTab(),
          ],
        ),
      ),
    );
  }
}

// ---------------- Dashboard ----------------
class _DashboardTab extends StatelessWidget {
  const _DashboardTab();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    // Placeholder data
    final liveFeed = <Map<String, dynamic>>[];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: const [
              _KpiCard(
                  title: 'Today Collected',
                  value: '0',
                  icon: Icons.attach_money),
              _KpiCard(
                  title: 'Transactions', value: '0', icon: Icons.receipt_long),
              _KpiCard(
                  title: 'Fraud Alerts',
                  value: '0',
                  icon: Icons.shield_outlined),
              _KpiCard(
                  title: 'Active Devices',
                  value: '0',
                  icon: Icons.wifi_tethering),
            ],
          ),
          const SizedBox(height: 16),
          Text('Live Feed', style: textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: liveFeed.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final tx = liveFeed[i];
                return ListTile(
                  title: Text('Transaction: ${tx['reference'] ?? ''}'),
                  subtitle: Text(
                      '${tx['client_name'] ?? ''} • ${tx['amount'] ?? ''} • ${tx['method'] ?? ''}'),
                  trailing:
                      Text(tx['created_at']?.toString().substring(0, 16) ?? ''),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  const _KpiCard(
      {required this.title, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: 260,
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: scheme.primaryContainer,
                child: Icon(icon, color: scheme.onPrimaryContainer),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 4),
                    Text(value,
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------- Transactions ----------------
class _TransactionsTab extends StatelessWidget {
  const _TransactionsTab();

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Transactions tab placeholder'));
  }
}

// ---------------- Clients ----------------
class _ClientsTab extends StatelessWidget {
  const _ClientsTab();

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Clients tab placeholder'));
  }
}

// ---------------- Branches ----------------
class _BranchesTab extends StatelessWidget {
  const _BranchesTab();

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Branches tab placeholder'));
  }
}

// ---------------- Devices ----------------
class _DevicesTab extends StatelessWidget {
  const _DevicesTab();

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Devices tab placeholder'));
  }
}

// ---------------- Audit ----------------
class _AuditTab extends StatelessWidget {
  const _AuditTab();

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Audit tab placeholder'));
  }
}

// ---------------- Reports ----------------
class _ReportsTab extends StatelessWidget {
  const _ReportsTab();

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Reports tab placeholder'));
  }
}

// ---------------- Settings ----------------
class _SettingsTab extends StatelessWidget {
  const _SettingsTab();

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Settings tab placeholder'));
  }
}

// ---------------- Policies ----------------
class _PoliciesTab extends StatelessWidget {
  const _PoliciesTab();

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Policies tab placeholder'));
  }
}

// ---------------- Claims ----------------
class _ClaimsTab extends StatelessWidget {
  const _ClaimsTab();

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Claims tab placeholder'));
  }
}

// ---------------- Documents ----------------
class _DocumentsTab extends StatelessWidget {
  const _DocumentsTab();

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Documents tab placeholder'));
  }
}

// ---------------- Debit Orders ----------------
class _DebitOrdersTab extends StatelessWidget {
  const _DebitOrdersTab();

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Debit Orders tab placeholder'));
  }
}

// ---------------- Recons ----------------
class _ReconsTab extends StatelessWidget {
  const _ReconsTab();

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Recons tab placeholder'));
  }
}

// ---------------- Arrears ----------------
class _ArrearsTab extends StatelessWidget {
  const _ArrearsTab();

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Arrears tab placeholder'));
  }
}

// ---------------- Ledger ----------------
class _LedgerTab extends StatelessWidget {
  const _LedgerTab();

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Ledger tab placeholder'));
  }
}

// ---------------- Products/Plans ----------------
class _ProductsTab extends StatelessWidget {
  const _ProductsTab();

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Products tab placeholder'));
  }
}

// ---------------- Admin Notifications ----------------
class _AdminNotificationsTab extends StatelessWidget {
  const _AdminNotificationsTab();

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Notifications tab placeholder'));
  }
}
