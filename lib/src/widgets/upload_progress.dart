import 'package:flutter/material.dart';

class UploadProgress extends StatelessWidget {
  final double progress;
  const UploadProgress({super.key, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LinearProgressIndicator(value: progress),
        const SizedBox(height: 6),
        Text('${(progress * 100).toStringAsFixed(0)}%'),
      ],
    );
  }
}