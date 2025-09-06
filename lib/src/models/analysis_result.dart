class AnalysisResult {
  final DataShape shape;
  final Map<String, int> missingValues;
  final Map<String, NumericSummary> numericSummary;
  final Map<String, CategoricalSummary> categoricalSummary;
  final List<KPI> kpis;
  final Charts charts;
  final String dataStory;
  final Map<String, Slicer> slicers;
  final Map<String, dynamic> activeFilters;

  AnalysisResult({
    required this.shape,
    required this.missingValues,
    required this.numericSummary,
    required this.categoricalSummary,
    required this.kpis,
    required this.charts,
    required this.dataStory,
    required this.slicers,
    required this.activeFilters,
  });

  factory AnalysisResult.fromJson(Map<String, dynamic> json) => AnalysisResult(
    shape: DataShape.fromJson(json['shape']),
    missingValues: Map<String, int>.from(json['missing_values'] ?? {}),
    numericSummary: (json['numeric_summary'] as Map<String, dynamic>? ?? {}).map(
          (k, v) => MapEntry(k, NumericSummary.fromJson(v)),
    ),
    categoricalSummary: (json['categorical_summary'] as Map<String, dynamic>? ?? {}).map(
          (k, v) => MapEntry(k, CategoricalSummary.fromJson(v)),
    ),
    kpis: (json['kpis'] as List? ?? []).map((e) => KPI.fromJson(e)).toList(),
    charts: Charts.fromJson(json['charts'] ?? {}),
    dataStory: json['data_story'] ?? '',
    slicers: (json['slicers'] as Map<String, dynamic>? ?? {}).map(
          (k, v) => MapEntry(k, Slicer.fromJson(v)),
    ),
    activeFilters: json['active_filters'] ?? {},
  );
}

class DataShape {
  final int rows;
  final int columns;
  DataShape({required this.rows, required this.columns});
  factory DataShape.fromJson(Map<String, dynamic> json) => DataShape(rows: json['rows'], columns: json['columns']);
}

class NumericSummary {
  final int count;
  final double mean;
  final double std;
  final double min;
  final double q25;
  final double q50;
  final double q75;
  final double max;
  final int missing;
  final Outliers outliers;

  NumericSummary({
    required this.count,
    required this.mean,
    required this.std,
    required this.min,
    required this.q25,
    required this.q50,
    required this.q75,
    required this.max,
    required this.missing,
    required this.outliers,
  });

  factory NumericSummary.fromJson(Map<String, dynamic> json) => NumericSummary(
    count: (json['count'] ?? 0) as int,
    mean: (json['mean'] ?? 0).toDouble(),
    std: (json['std'] ?? 0).toDouble(),
    min: (json['min'] ?? 0).toDouble(),
    q25: (json['25%'] ?? 0).toDouble(),
    q50: (json['50%'] ?? 0).toDouble(),
    q75: (json['75%'] ?? 0).toDouble(),
    max: (json['max'] ?? 0).toDouble(),
    missing: (json['missing'] ?? 0) as int,
    outliers: Outliers.fromJson(json['outliers'] ?? {'lower_bound': 0, 'upper_bound': 0}),
  );
}

class Outliers {
  final double lowerBound;
  final double upperBound;
  Outliers({required this.lowerBound, required this.upperBound});
  factory Outliers.fromJson(Map<String, dynamic> json) =>
      Outliers(lowerBound: (json['lower_bound'] ?? 0).toDouble(), upperBound: (json['upper_bound'] ?? 0).toDouble());
}

class CategoricalSummary {
  final int missing;
  final int uniqueCount;
  final Map<String, int> top5Values;
  CategoricalSummary({required this.missing, required this.uniqueCount, required this.top5Values});
  factory CategoricalSummary.fromJson(Map<String, dynamic> json) => CategoricalSummary(
    missing: (json['missing'] ?? 0) as int,
    uniqueCount: (json['unique_count'] ?? 0) as int,
    top5Values: Map<String, int>.from(json['top_5_values'] ?? {}),
  );
}

class KPI {
  final String name;
  final dynamic value;
  KPI({required this.name, required this.value});
  factory KPI.fromJson(Map<String, dynamic> json) => KPI(name: json['name'] ?? '', value: json['value']);
  String get formatted => value is num ? (value as num).toStringAsFixed(2) : value.toString();
}

class Charts {
  final ChartData? density;
  final ChartData? box;
  final ChartData? pie;
  Charts({this.density, this.box, this.pie});
  factory Charts.fromJson(Map<String, dynamic> json) => Charts(
    density: json['density'] != null ? ChartData.fromJson(json['density']) : null,
    box: json['box'] != null ? ChartData.fromJson(json['box']) : null,
    pie: json['pie'] != null ? ChartData.fromJson(json['pie']) : null,
  );
}

class ChartData {
  final Map<String, dynamic> figure;
  final String summary;
  ChartData({required this.figure, required this.summary});
  factory ChartData.fromJson(Map<String, dynamic> json) => ChartData(figure: json['figure'] ?? {}, summary: json['summary'] ?? '');
}

class Slicer {
  final String type;
  final List<String>? options;
  final dynamic min;
  final dynamic max;
  Slicer({required this.type, this.options, this.min, this.max});
  factory Slicer.fromJson(Map<String, dynamic> json) => Slicer(
    type: json['type'] ?? 'categorical',
    options: json['options'] != null ? List<String>.from(json['options']) : null,
    min: json['min'],
    max: json['max'],
  );
}