import 'package:flutter/material.dart';
import '../models/dataset.dart';

class RecentActivityCard extends StatelessWidget {
  final Dataset dataset;
  const RecentActivityCard({super.key, required this.dataset});

  @override
  Widget build(BuildContext context) {
    final color = dataset.pendingSync ? Colors.orange : Colors.green;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(dataset.pendingSync ? Icons.sync_problem : Icons.check_circle, color: color),
        ),
        title: Text(dataset.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_formatFileSize(dataset.fileSize ?? 0)),
            const SizedBox(height: 2),
            Text(
              _relative(dataset.createdAt),
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: () {},
      ),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '${bytes}B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
  }

  String _relative(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays >= 1) return '${diff.inDays} day${diff.inDays > 1 ? 's' : ''} ago';
    if (diff.inHours >= 1) return '${diff.inHours} hour${diff.inHours > 1 ? 's' : ''} ago';
    if (diff.inMinutes >= 1) return '${diff.inMinutes} min ago';
    return 'Just now';
  }
}