import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/data_provider.dart';
import '../../providers/sync_provider.dart';
import '../../widgets/upload_progress.dart';
import '../../widgets/data_preview.dart';
import '../../widgets/analysis_results.dart';
import '../../models/analysis_result.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});
  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> with SingleTickerProviderStateMixin {
  late TabController _tabs;
  File? _file;
  double progress = 0;
  bool uploading = false;
  AnalysisResult? result;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _pick() async {
    final res = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['csv', 'xlsx', 'xls']);
    if (res != null && res.files.single.path != null) {
      setState(() => _file = File(res.files.single.path!));
    }
  }

  Future<void> _upload() async {
    if (_file == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Select a file first')));
      return;
    }
    setState(() {
      uploading = true;
      progress = 0;
    });

    for (var i = 0; i <= 100; i += 10) {
      await Future.delayed(const Duration(milliseconds: 120));
      if (!mounted) return;
      setState(() => progress = i / 100);
    }

    try {
      if (context.read<SyncProvider>().isOnline) {
        final res = await context.read<DataProvider>().uploadAndAnalyze(_file!);
        setState(() => result = res);
        _tabs.animateTo(2);
      } else {
        await context.read<DataProvider>().storeForLaterSync(_file!);
        _tabs.animateTo(1);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Stored locally. Will sync when online.')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
    } finally {
      if (mounted) setState(() => uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload & Analyze'),
        bottom: TabBar(
          controller: _tabs,
          tabs: const [
            Tab(text: 'Upload', icon: Icon(Icons.cloud_upload)),
            Tab(text: 'Preview', icon: Icon(Icons.preview)),
            Tab(text: 'Results', icon: Icon(Icons.analytics)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              GestureDetector(
                onTap: _pick,
                child: Container(
                  height: 160,
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).colorScheme.primary, width: 2),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white,
                  ),
                  child: Center(
                    child: _file == null
                        ? const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.cloud_upload_outlined, size: 42),
                        SizedBox(height: 8),
                        Text('Tap to select CSV/Excel'),
                      ],
                    )
                        : Text(_file!.path.split('/').last, maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(onPressed: uploading ? null : _upload, child: Text(uploading ? 'Uploading...' : 'Upload & Analyze')),
              ),
              if (uploading) ...[
                const SizedBox(height: 12),
                UploadProgress(progress: progress),
              ],
            ],
          ),
          _file != null
              ? DataPreview(file: _file!)
              : const Center(child: Text('No file selected')),
          result != null
              ? AnalysisResults(results: result!)
              : const Center(child: Text('No analysis yet')),
        ],
      ),
    );
  }
}