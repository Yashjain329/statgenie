import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chart_provider.dart';
import '../models/analysis_result.dart';

class DataSlicers extends StatelessWidget {
  const DataSlicers({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ChartProvider>(
      builder: (_, chart, __) {
        final r = chart.analysisResult;
        if (r == null || r.slicers.isEmpty) {
          return const Center(child: Padding(padding: EdgeInsets.all(16), child: Text('No slicers available')));
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                const Text('Data Filters', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const Spacer(),
                if (chart.activeFilters.isNotEmpty)
                  TextButton(onPressed: chart.clearFilters, child: const Text('Clear all')),
              ],
            ),
            if (chart.activeFilters.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: chart.activeFilters.entries
                    .map((e) => Chip(
                  label: Text('${e.key}: ${e.value}'),
                  onDeleted: () => chart.updateFilter(e.key, null),
                ))
                    .toList(),
              ),
            const SizedBox(height: 12),
            ...r.slicers.entries.map((e) => _SlicerCard(field: e.key, slicer: e.value)),
          ],
        );
      },
    );
  }
}

class _SlicerCard extends StatelessWidget {
  final String field;
  final Slicer slicer;

  const _SlicerCard({required this.field, required this.slicer});

  @override
  Widget build(BuildContext context) {
    final chart = context.read<ChartProvider>();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(field, style: const TextStyle(
              fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          if (slicer.type == 'categorical') _categorical(chart) else
            if (slicer.type == 'numeric') _numeric(chart) else
              _date(chart),
        ]),
      ),
    );
  }

  Widget _categorical(ChartProvider chart) {
    final selected = chart.activeFilters[field];
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        FilterChip(
          label: const Text('All'),
          selected: selected == null,
          onSelected: (ok) => chart.updateFilter(field, null),
        ),
        ...(slicer.options ?? []).map((opt) =>
            FilterChip(
              label: Text(opt),
              selected: selected == opt,
              onSelected: (ok) => chart.updateFilter(field, ok ? opt : null),
            )),
      ],
    );
  }

  Widget _numeric(ChartProvider chart) {
    final minV = (slicer.min as num?)?.toDouble() ?? 0.0;
    final maxV = (slicer.max as num?)?.toDouble() ?? 0.0;
    final current = chart.activeFilters[field] as Map<String, dynamic>?;
    final start = (current?['min'] as num?)?.toDouble() ?? minV;
    final end = (current?['max'] as num?)?.toDouble() ?? maxV;
    final values = ValueNotifier<RangeValues>(RangeValues(start, end));

    return ValueListenableBuilder<RangeValues>(
      valueListenable: values,
      builder: (_, rv, __) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Range: ${rv.start.toStringAsFixed(1)} - ${rv.end
                .toStringAsFixed(1)}',
                style: const TextStyle(color: Colors.black54)),
            RangeSlider(
              values: rv,
              min: minV,
              max: maxV,
              divisions: 100,
              labels: RangeLabels(
                  rv.start.toStringAsFixed(1), rv.end.toStringAsFixed(1)),
              onChanged: (v) => values.value = v,
              onChangeEnd: (v) =>
                  chart.updateFilter(field, {'min': v.start, 'max': v.end}),
            ),
          ],
        );
      },
    );
  }

  Widget _date(ChartProvider chart) {
    final selected = chart.activeFilters[field] as DateTime?;
    final first = DateTime.tryParse('${slicer.min}') ?? DateTime(2000);
    final last = DateTime.tryParse('${slicer.max}') ?? DateTime.now();

    return Builder(
      builder: (ctx) =>
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: selected ?? first,
                      firstDate: first,
                      lastDate: last,
                    );
                    if (picked != null) chart.updateFilter(field, picked);
                  },
                  icon: const Icon(Icons.calendar_today),
                  label: Text(selected == null ? 'Select Date' : 'Change Date'),
                ),
              ),
              if (selected != null) ...[
                const SizedBox(width: 8),
                IconButton(onPressed: () => chart.updateFilter(field, null),
                    icon: const Icon(Icons.clear)),
              ],
            ],
          ),
    );
  }
}