import 'dart:io';
import 'package:flutter/material.dart';
import '../models/dataset.dart';
import '../models/analysis_result.dart';
import '../services/api_service.dart';
import '../services/database_service.dart';

class DataProvider with ChangeNotifier {
  final ApiService _api = ApiService();
  final DatabaseService _db = DatabaseService.instance;

  List<Dataset> _datasets = [];
  AnalysisResult? _current;
  bool _loading = false;
  String? _error;

  List<Dataset> get datasets => _datasets;
  AnalysisResult? get currentAnalysis => _current;
  bool get isLoading => _loading;
  String? get error => _error;

  Future<void> loadDatasets() async {
    _loading = true; _error = null; notifyListeners();
    try {
      _datasets = await _db.getDatasets();
    } catch (e) {
      _error = 'Failed to load datasets: $e';
    } finally {
      _loading = false; notifyListeners();
    }
  }

  Future<AnalysisResult> uploadAndAnalyze(File file) async {
    _loading = true; _error = null; notifyListeners();
    try {
      final res = await _api.uploadAndAnalyze(file);
      _current = res;

      final ds = Dataset(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: 'current_user_id',
        name: file.path.split('/').last,
        fileSize: await file.length(),
        rowCount: res.shape.rows,
        columnCount: res.shape.columns,
        createdAt: DateTime.now(),
        pendingSync: false,
      );
      await _db.insertDataset(ds);
      _datasets.insert(0, ds);
      return res;
    } catch (e) {
      _error = 'Upload failed: $e';
      rethrow;
    } finally {
      _loading = false; notifyListeners();
    }
  }

  Future<void> storeForLaterSync(File file) async {
    final ds = Dataset(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: 'current_user_id',
      name: file.path.split('/').last,
      fileSize: await file.length(),
      createdAt: DateTime.now(),
      pendingSync: true,
    );
    await _db.insertDataset(ds);
    _datasets.insert(0, ds);
    notifyListeners();
  }
}