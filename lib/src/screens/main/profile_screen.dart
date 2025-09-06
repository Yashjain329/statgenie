import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/sync_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;
    final sync = context.watch<SyncProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: Text(user?.email ?? 'Signed out'),
              subtitle: Text(sync.isOnline ? 'Online' : 'Offline'),
              trailing: ElevatedButton(
                onPressed: () => context.read<AuthProvider>().signOut(),
                child: const Text('Sign out'),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.sync),
              title: const Text('Pending sync'),
              trailing: Chip(label: Text('${sync.pendingSyncCount}')),
            ),
          ),
        ],
      ),
    );
  }
}