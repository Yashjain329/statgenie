import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chart_provider.dart';

class DynamicCharts extends StatelessWidget {
  const DynamicCharts({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ChartProvider>(
      builder: (_, chart, __) {
        if (chart.analysisResult == null) {
          return const Center(child: Text('No data available for charts'));
        }
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _chartCard('Distribution Analysis (Pie)', _pie(chart.pieChartData)),
            const SizedBox(height: 12),
            _chartCard('Category Analysis (Bar)', _bars(chart.barChartData)),
            const SizedBox(height: 12),
            _chartCard('Trend Analysis (Line)', _line(chart.lineChartData)),
            const SizedBox(height: 12),
            _chartCard('Distribution Histogram', _hist(chart.histogramData)),
          ],
        );
      },
    );
  }

  Widget _chartCard(String title, Widget child) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          SizedBox(height: 260, child: child),
        ]),
      ),
    );
  }

  Widget _pie(List<Map<String, dynamic>> data) {
    if (data.isEmpty) return const Center(child: Text('No data'));
    final colors = [Colors.teal, Colors.deepPurpleAccent, Colors.orange, Colors.green, Colors.pink];
    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 30,
        sections: data.asMap().entries.map((e) {
          final i = e.key;
          final item = e.value;
          return PieChartSectionData(
            color: colors[i % colors.length],
            value: (item['value'] as num).toDouble(),
            title: '${item['label']}',
            radius: 80,
            titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
          );
        }).toList(),
      ),
    );
  }

  Widget _bars(List<Map<String, dynamic>> data) {
    if (data.isEmpty) return const Center(child: Text('No data'));
    final maxY = data.map((e) => (e['value'] as num).toDouble()).fold<double>(0, (p, c) => c > p ? c : p) * 1.2;
    return BarChart(
      BarChartData(
        maxY: maxY == 0 ? 1 : maxY,
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (v, meta) {
                final i = v.toInt();
                if (i < 0 || i >= data.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    data[i]['category'],
                    style: const TextStyle(fontSize: 10),
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        barGroups: data.asMap().entries.map((e) {
          return BarChartGroupData(
            x: e.key,
            barRods: [
              BarChartRodData(
                toY: (e.value['value'] as num).toDouble(),
                color: Colors.deepPurpleAccent,
                width: 18,
              )
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _line(List<Map<String, dynamic>> data) {
    if (data.isEmpty) return const Center(child: Text('No data'));
    final dx = data.map((p) => (p['x'] as num).toDouble());
    final dy = data.map((p) => (p['y'] as num).toDouble());
    final minX = dx.reduce((a, b) => a < b ? a : b);
    final maxX = dx.reduce((a, b) => a > b ? a : b);
    final minY = dy.reduce((a, b) => a < b ? a : b);
    final maxY = dy.reduce((a, b) => a > b ? a : b);

    return LineChart(
      LineChartData(
        minX: minX,
        maxX: maxX,
        minY: minY * 0.95,
        maxY: maxY * 1.05,
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: true),
        titlesData: const FlTitlesData(),
        lineBarsData: [
          LineChartBarData(
            isCurved: true,
            barWidth: 3,
            color: Colors.teal,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(show: true, color: Colors.teal.withOpacity(0.15)),
            spots: data.map((p) => FlSpot((p['x'] as num).toDouble(), (p['y'] as num).toDouble())).toList(),
          )
        ],
      ),
    );
  }

  Widget _hist(List<Map<String, dynamic>> data) {
    if (data.isEmpty) return const Center(child: Text('No data'));
    final maxY = data.map((e) => (e['count'] as num).toDouble()).fold<double>(0, (p, c) => c > p ? c : p) * 1.2;
    return BarChart(
      BarChartData(
        maxY: maxY == 0 ? 1 : maxY,
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (v, meta) {
                final i = v.toInt();
                if (i < 0 || i >= data.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text((data[i]['binStart'] as num).toStringAsFixed(0), style: const TextStyle(fontSize: 10)),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        barGroups: data.asMap().entries.map((e) {
          return BarChartGroupData(
            x: e.key,
            barRods: [
              BarChartRodData(
                toY: (e.value['count'] as num).toDouble(),
                color: Colors.orange,
                width: 14,
              )
            ],
          );
        }).toList(),
      ),
    );
  }
}