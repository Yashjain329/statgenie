import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/data_provider.dart';
import '../../providers/sync_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DataProvider>().loadDatasets();
      context.read<SyncProvider>().checkSyncStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('StatGenie'), actions: const [_OnlineBadge()]),
      body: RefreshIndicator(
        onRefresh: () async {
          await context.read<DataProvider>().loadDatasets();
          await context.read<SyncProvider>().checkSyncStatus();
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _welcome(context),
            const SizedBox(height: 16),
            _quickStats(context),
            const SizedBox(height: 16),
            _recent(context),
          ],
        ),
      ),
    );
  }

  Widget _welcome(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    return Card(
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.person)),
        title: const Text('Welcome back!'),
        subtitle: Text(user?.email ?? ''),
      ),
    );
  }

  Widget _quickStats(BuildContext context) {
    final data = context.watch<DataProvider>();
    final total = data.datasets.length;
    final pending = data.datasets.where((e) => e.pendingSync).length;

    return Row(
      children: [
        Expanded(child: _stat('Total Datasets', '$total', Icons.dataset)),
        const SizedBox(width: 12),
        Expanded(child: _stat('Pending Sync', '$pending', Icons.sync_problem)),
      ],
    );
  }

  Widget _stat(String label, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(child: Text(label)),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _recent(BuildContext context) {
    final list = context.watch<DataProvider>().datasets.take(5).toList();
    return Card(
      child: Column(
        children: [
          const ListTile(title: Text('Recent Datasets')),
          if (list.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('No datasets yet. Upload to get started.'),
            )
          else
            ...list.map((d) => ListTile(
              leading: const Icon(Icons.description),
              title: Text(d.name),
              subtitle: Text('${d.fileSize ?? 0} bytes • ${d.createdAt.toIso8601String()}'),
              trailing: d.pendingSync ? const Icon(Icons.sync, color: Colors.orange) : const Icon(Icons.check, color: Colors.green),
            )),
        ],
      ),
    );
  }
}

class _OnlineBadge extends StatelessWidget {
  const _OnlineBadge();

  @override
  Widget build(BuildContext context) {
    return Consumer<SyncProvider>(
      builder: (_, sync, __) => Padding(
        padding: const EdgeInsets.all(8),
        child: Chip(
          label: Text(sync.isOnline ? 'Online' : 'Offline', style: const TextStyle(color: Colors.white)),
          backgroundColor: sync.isOnline ? Colors.green : Colors.orange,
        ),
      ),
    );
  }
}