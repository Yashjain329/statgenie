import 'dart:io';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';

class DataPreview extends StatefulWidget {
  final File file;
  const DataPreview({super.key, required this.file});

  @override
  State<DataPreview> createState() => _DataPreviewState();
}

class _DataPreviewState extends State<DataPreview> {
  List<List<dynamic>> rows = [];
  String? error;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final text = await widget.file.readAsString();
      final parsed = const CsvToListConverter().convert(text);
      setState(() {
        rows = parsed.take(12).toList();
        loading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Preview failed: $e';
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());
    if (error != null) return Center(child: Text(error!));
    if (rows.isEmpty) return const Center(child: Text('No data in file'));

    final headers = rows.first;
    final data = rows.skip(1).toList();
    return Card(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: headers.map((h) => DataColumn(label: Text(h.toString()))).toList(),
          rows: data
              .map((r) => DataRow(cells: r.map((c) => DataCell(Text(c.toString(), overflow: TextOverflow.ellipsis))).toList()))
              .toList(),
        ),
      ),
    );
  }
}