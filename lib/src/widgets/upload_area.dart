import 'dart:io';
import 'package:flutter/material.dart';

class UploadArea extends StatefulWidget {
  final File? selectedFile;
  final VoidCallback onFilePicked;
  final Function(File) onFileDropped;

  const UploadArea({
    super.key,
    this.selectedFile,
    required this.onFilePicked,
    required this.onFileDropped,
  });

  @override
  State<UploadArea> createState() => _UploadAreaState();
}

class _UploadAreaState extends State<UploadArea> {
  bool _isDragOver = false;

  @override
  Widget build(BuildContext context) {
    final borderColor = _isDragOver ? Theme.of(context).colorScheme.primary : Colors.grey[300]!;

    return GestureDetector(
      onTap: widget.onFilePicked,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        height: 200,
        decoration: BoxDecoration(
          color: _isDragOver ? Theme.of(context).colorScheme.primary.withOpacity(0.06) : Colors.grey[50],
          border: Border.all(color: borderColor, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: widget.selectedFile != null ? _filePreview() : _prompt(),
      ),
    );
  }

  Widget _prompt() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.cloud_upload_outlined, size: 56, color: Colors.grey[500]),
        const SizedBox(height: 12),
        Text('Tap to select file', style: TextStyle(fontSize: 16, color: Colors.grey[700])),
        const SizedBox(height: 4),
        Text('CSV, XLSX, XLS supported', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
      ],
    );
  }

  Widget _filePreview() {
    final f = widget.selectedFile!;
    final name = f.path.split('/').last;
    final size = f.lengthSync();

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.description, size: 48, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(name, maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w600)),
        ),
        const SizedBox(height: 6),
        Text('${(size / (1024 * 1024)).toStringAsFixed(2)} MB', style: TextStyle(color: Colors.grey[600])),
        const SizedBox(height: 12),
        TextButton(onPressed: widget.onFilePicked, child: const Text('Choose different file')),
      ],
    );
  }
}