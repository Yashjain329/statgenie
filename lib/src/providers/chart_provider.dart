import 'package:flutter/material.dart';
import '../models/analysis_result.dart';

class ChartProvider with ChangeNotifier {
  AnalysisResult? _result;
  Map<String, dynamic> _filters = {};
  List<Map<String, dynamic>> _pie = [];
  List<Map<String, dynamic>> _bar = [];
  List<Map<String, dynamic>> _line = [];
  List<Map<String, dynamic>> _hist = [];

  AnalysisResult? get analysisResult => _result;
  Map<String, dynamic> get activeFilters => _filters;

  void setAnalysisResult(AnalysisResult r) {
    _result = r;
    _filters = Map.from(r.activeFilters);
    _recompute();
  }

  void updateFilter(String field, dynamic value) {
    if (value == null) {
      _filters.remove(field);
    } else {
      _filters[field] = value;
    }
    _recompute();
  }

  void clearFilters() {
    _filters.clear();
    _recompute();
  }

  List<Map<String, dynamic>> get pieChartData => _pie;
  List<Map<String, dynamic>> get barChartData => _bar;
  List<Map<String, dynamic>> get lineChartData => _line;
  List<Map<String, dynamic>> get histogramData => _hist;

  void _recompute() {
    // For now, derive from summaries (server-side slicing can be added later)
    if (_result == null) return;

    // Pie/Bar from first categorical top5
    if (_result!.categoricalSummary.isNotEmpty) {
      final entry = _result!.categoricalSummary.entries.first;
      _pie = entry.value.top5Values.entries.map((e) => {'label': e.key, 'value': e.value.toDouble()}).toList();
      _bar = entry.value.top5Values.entries.map((e) => {'category': e.key, 'value': e.value.toDouble()}).toList();
    } else {
      _pie = []; _bar = [];
    }

    // Line from first numeric percentiles
    if (_result!.numericSummary.isNotEmpty) {
      final s = _result!.numericSummary.values.first;
      _line = [
        {'x': 0, 'y': s.min},
        {'x': 25, 'y': s.q25},
        {'x': 50, 'y': s.q50},
        {'x': 75, 'y': s.q75},
        {'x': 100, 'y': s.max},
      ];
      final range = (s.max - s.min).abs();
      final bin = range == 0 ? 1 : range / 10.0;
      _hist = List.generate(10, (i) {
        final start = s.min + i * bin;
        return {'binStart': start, 'binEnd': start + bin, 'count': (s.count / 10).round()};
      });
    } else {
      _line = []; _hist = [];
    }

    notifyListeners();
  }
}