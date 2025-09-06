import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/sync_provider.dart';

class SyncStatusCard extends StatelessWidget {
  const SyncStatusCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SyncProvider>(
      builder: (_, sync, __) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(
              children: [
                Icon(sync.isOnline ? Icons.cloud_done : Icons.cloud_off,
                    color: sync.isOnline ? Colors.green : Colors.orange),
                const SizedBox(width: 8),
                const Text('Sync Status', style: TextStyle(fontWeight: FontWeight.bold)),
                const Spacer(),
                if (sync.isSyncing)
                  const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
              ],
            ),
            const SizedBox(height: 8),
            Text(sync.isOnline ? 'Connected' : 'Offline',
                style: TextStyle(
                  color: sync.isOnline ? Colors.green : Colors.orange,
                  fontWeight: FontWeight.w600,
                )),
            const SizedBox(height: 4),
            Row(
              children: [
                const Text('Pending: '),
                Chip(
                  label: Text('${sync.pendingSyncCount}'),
                  backgroundColor: Colors.grey[100],
                ),
                const Spacer(),
                if (sync.isOnline && !sync.isSyncing && sync.pendingSyncCount > 0)
                  ElevatedButton.icon(
                    onPressed: sync.syncData,
                    icon: const Icon(Icons.sync),
                    label: const Text('Sync Now'),
                  ),
              ],
            ),
          ]),
        ),
      ),
    );
  }
}