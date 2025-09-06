import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../models/analysis_result.dart';
import '../../providers/data_provider.dart';
import '../../providers/sync_provider.dart';
import '../../providers/chart_provider.dart';
import '../../widgets/analysis_results.dart';

class UploadDashboardScreen extends StatefulWidget {
  const UploadDashboardScreen({super.key});

  @override
  State<UploadDashboardScreen> createState() => _UploadDashboardScreenState();
}

class _UploadDashboardScreenState extends State<UploadDashboardScreen> {
  File? _selectedFile;
  bool _isUploading = false;
  double _progress = 0;
  AnalysisResult? _result;

  Future<void> _pick() async {
    final res = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv', 'xlsx', 'xls', 'json'],
    );
    if (res != null && res.files.single.path != null) {
      setState(() => _selectedFile = File(res.files.single.path!));
    }
  }

  Future<void> _upload() async {
    if (_selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Select a file first')));
      return;
    }
    setState(() {
      _isUploading = true;
      _progress = 0;
    });

    // Simulated incremental progress
    for (int i = 0; i <= 100; i += 10) {
      await Future.delayed(const Duration(milliseconds: 120));
      if (!mounted) return;
      setState(() => _progress = i / 100);
    }

    try {
      if (context.read<SyncProvider>().isOnline) {
        final res = await context.read<DataProvider>().uploadAndAnalyze(_selectedFile!);
        setState(() => _result = res);
        context.read<ChartProvider>().setAnalysisResult(res);
      } else {
        await context.read<DataProvider>().storeForLaterSync(_selectedFile!);
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Stored locally. Will sync when online.')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final purple = Colors.deepPurpleAccent;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Row(
          children: [
            Image.asset('assets/images/logo.png', width: 28, height: 28, errorBuilder: (_, __, ___) => const SizedBox()),
            const SizedBox(width: 8),
            Text('StatGenie Dashboard',
                style: GoogleFonts.montserrat(color: purple, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        children: [
          Text('Upload Your Data',
              style: GoogleFonts.montserrat(color: purple, fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _pick,
            child: Container(
              height: 180,
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: purple, width: 2, style: BorderStyle.solid),
              ),
              child: Center(
                child: _selectedFile == null
                    ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cloud_upload_outlined, size: 48, color: purple),
                    const SizedBox(height: 16),
                    Text('Tap to select CSV/Excel/JSON',
                        style: GoogleFonts.montserrat(color: Colors.white70)),
                  ],
                )
                    : Text(
                  'Selected: ${_selectedFile!.path.split('/').last}',
                  style: GoogleFonts.montserrat(color: Colors.white),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isUploading ? null : _upload,
              style: ElevatedButton.styleFrom(
                backgroundColor: purple,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: _isUploading
                  ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
                  SizedBox(width: 10),
                  Text('Uploading...'),
                ],
              )
                  : const Text('Upload & Analyze'),
            ),
          ),
          if (_isUploading) ...[
            const SizedBox(height: 12),
            LinearProgressIndicator(value: _progress, color: purple, backgroundColor: Colors.white24),
            const SizedBox(height: 8),
            Text('${(_progress * 100).toStringAsFixed(0)}%', style: const TextStyle(color: Colors.white70)),
          ],
          const SizedBox(height: 28),
          if (_result != null) ...[
            Text('Analysis Results',
                style: GoogleFonts.montserrat(color: purple, fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            // Reuse the same AnalysisResults (dark-safe)
            Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: AnalysisResults(results: _result!),
            ),
          ],
        ],
      ),
    );
  }
}