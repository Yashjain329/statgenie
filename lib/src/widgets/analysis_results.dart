import 'package:flutter/material.dart';
import '../models/analysis_result.dart';
import 'dynamic_charts.dart';
import 'data_slicers.dart';

class AnalysisResults extends StatefulWidget {
  final AnalysisResult results;
  const AnalysisResults({super.key, required this.results});

  @override
  State<AnalysisResults> createState() => _AnalysisResultsState();
}

class _AnalysisResultsState extends State<AnalysisResults> with SingleTickerProviderStateMixin {
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.results;

    return DefaultTabController(
      length: 5,
      child: Column(
        children: [
          TabBar(
            controller: _tabs,
            isScrollable: true,
            tabs: const [
              Tab(icon: Icon(Icons.dashboard), text: 'Overview'),
              Tab(icon: Icon(Icons.bar_chart), text: 'Charts'),
              Tab(icon: Icon(Icons.table_chart), text: 'Statistics'),
              Tab(icon: Icon(Icons.auto_stories), text: 'Insights'),
              Tab(icon: Icon(Icons.filter_alt), text: 'Filters'),
            ],
          ),
          SizedBox(
            height: 560,
            child: TabBarView(
              controller: _tabs,
              children: [
                // Overview
                ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Row(
                      children: [
                        Expanded(child: _miniStat('Rows', r.shape.rows.toString(), Icons.table_rows, Colors.blue)),
                        const SizedBox(width: 12),
                        Expanded(child: _miniStat('Columns', r.shape.columns.toString(), Icons.view_column, Colors.green)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text('KPIs', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 8),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, childAspectRatio: 1.7, crossAxisSpacing: 12, mainAxisSpacing: 12),
                      itemCount: r.kpis.length,
                      itemBuilder: (_, i) => Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(r.kpis[i].formatted, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 4),
                              Text(r.kpis[i].name, textAlign: TextAlign.center, style: const TextStyle(color: Colors.black54)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Data Quality', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 8),
                            _missingValues(r.missingValues),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // Charts
                const DynamicCharts(),

                // Statistics
                ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    if (r.numericSummary.isNotEmpty) ...[
                      const Text('Numeric Variables', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      const SizedBox(height: 8),
                      ...r.numericSummary.entries.map((e) => _numericCard(e.key, e.value)),
                      const SizedBox(height: 16),
                    ],
                    if (r.categoricalSummary.isNotEmpty) ...[
                      const Text('Categorical Variables', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      const SizedBox(height: 8),
                      ...r.categoricalSummary.entries.map((e) => _categoricalCard(e.key, e.value)),
                    ],
                  ],
                ),

                // Insights (data story)
                ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(r.dataStory.isEmpty ? 'No data story provided.' : r.dataStory,
                            style: const TextStyle(fontSize: 16, height: 1.4)),
                      ),
                    ),
                  ],
                ),

                // Filters
                const DataSlicers(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniStat(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }

  Widget _missingValues(Map<String, int> mv) {
    final total = mv.values.fold<int>(0, (a, b) => a + b);
    if (total == 0) {
      return Row(
        children: const [
          Icon(Icons.check_circle, color: Colors.green),
          SizedBox(width: 8),
          Text('No missing values detected!', style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600)),
        ],
      );
    }
    return Column(
      children: mv.entries
          .where((e) => e.value > 0)
          .map((e) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Expanded(child: Text(e.key)),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: Colors.red.withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
              child: Text('${e.value} missing', style: const TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ))
          .toList(),
    );
  }

  Widget _numericCard(String name, NumericSummary s) {
    TextStyle v = const TextStyle(fontWeight: FontWeight.w600);
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(children: [Expanded(child: Text('Count')), Text('${s.count}', style: v)]),
          Row(children: [Expanded(child: Text('Mean')), Text(s.mean.toStringAsFixed(2), style: v)]),
          Row(children: [Expanded(child: Text('Std')), Text(s.std.toStringAsFixed(2), style: v)]),
          Row(children: [Expanded(child: Text('Min')), Text(s.min.toStringAsFixed(2), style: v)]),
          Row(children: [Expanded(child: Text('Median')), Text(s.q50.toStringAsFixed(2), style: v)]),
          Row(children: [Expanded(child: Text('Max')), Text(s.max.toStringAsFixed(2), style: v)]),
          Row(children: [Expanded(child: Text('Q1')), Text(s.q25.toStringAsFixed(2), style: v)]),
          Row(children: [Expanded(child: Text('Q3')), Text(s.q75.toStringAsFixed(2), style: v)]),
          Row(children: [Expanded(child: Text('Missing')), Text('${s.missing}', style: v)]),
        ]),
      ),
    );
  }

  Widget _categoricalCard(String name, CategoricalSummary c) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(children: [Expanded(child: Text('Unique')), Text('${c.uniqueCount}', style: const TextStyle(fontWeight: FontWeight.w600))]),
          Row(children: [Expanded(child: Text('Missing')), Text('${c.missing}', style: const TextStyle(fontWeight: FontWeight.w600))]),
          const SizedBox(height: 8),
          if (c.top5Values.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Top Values:', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                ...c.top5Values.entries.take(5).map((e) => Row(
                  children: [
                    Expanded(child: Text(e.key)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(12)),
                      child: Text('${e.value}', style: const TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ],
                )),
              ],
            ),
        ]),
      ),
    );
  }
}