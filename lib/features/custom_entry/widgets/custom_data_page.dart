import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/models/custom_data_models.dart';
import '../../../core/services/firestore_service.dart';
import 'dynamic_entry_sheet.dart';

class CustomDataPage extends StatefulWidget {
  final CustomTemplate template;
  const CustomDataPage({super.key, required this.template});

  @override
  State<CustomDataPage> createState() => _CustomDataPageState();
}

class _CustomDataPageState extends State<CustomDataPage>
    with AutomaticKeepAliveClientMixin {
  final FirestoreService _service = FirestoreService();

  @override
  bool get wantKeepAlive => true;

  void _showAddSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DynamicEntrySheet(template: widget.template),
    );
  }

  void _configureChart() {
    String? xField = widget.template.xAxisField;
    String? yField = widget.template.yAxisField;

    final validX = widget.template.fields
        .where(
          (f) =>
              f.type == CustomFieldType.string ||
              f.type == CustomFieldType.date,
        )
        .toList();
    final validY = widget.template.fields
        .where((f) => f.type == CustomFieldType.number)
        .toList();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return AlertDialog(
            title: const Text('Configure Chart'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButton<String>(
                  hint: const Text('X-Axis (Date/Text)'),
                  value: xField,
                  isExpanded: true,
                  items: validX
                      .map(
                        (f) => DropdownMenuItem(
                          value: f.name,
                          child: Text(f.name),
                        ),
                      )
                      .toList(),
                  onChanged: (val) => setModalState(() => xField = val),
                ),
                const SizedBox(height: 16),
                DropdownButton<String>(
                  hint: const Text('Y-Axis (Number)'),
                  value: yField,
                  isExpanded: true,
                  items: validY
                      .map(
                        (f) => DropdownMenuItem(
                          value: f.name,
                          child: Text(f.name),
                        ),
                      )
                      .toList(),
                  onChanged: (val) => setModalState(() => yField = val),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () async {
                  widget.template.xAxisField = xField;
                  widget.template.yAxisField = yField;
                  await _service.updateCustomTemplate(widget.template);
                  if (mounted) Navigator.pop(context);
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      body: StreamBuilder<List<CustomRecord>>(
        stream: _service.getCustomRecords(widget.template.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());

          final records = snapshot.data ?? [];

          Map<String, double> totals = {};
          for (var field in widget.template.fields) {
            if (field.type == CustomFieldType.number && field.isSumRequired) {
              totals[field.name] = records.fold(
                0.0,
                (sum, r) => sum + (r.data[field.name] ?? 0.0),
              );
            }
          }

          return Column(
            children: [
              if (totals.isNotEmpty)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primaryContainer.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Wrap(
                    spacing: 20,
                    runSpacing: 10,
                    children: totals.entries
                        .map(
                          (e) => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                e.key,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white70,
                                ),
                              ),
                              Text(
                                NumberFormat.compact().format(e.value),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        )
                        .toList(),
                  ),
                ),

              if (widget.template.xAxisField != null &&
                  widget.template.yAxisField != null &&
                  records.isNotEmpty)
                _buildChart(
                  records,
                  widget.template.xAxisField!,
                  widget.template.yAxisField!,
                ),

              if (records.isNotEmpty)
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: TextButton.icon(
                      onPressed: _configureChart,
                      icon: const Icon(Icons.show_chart),
                      label: const Text('Configure Chart'),
                    ),
                  ),
                ),

              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: [
                        ...widget.template.fields.map(
                          (f) => DataColumn(
                            label: Text(
                              f.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const DataColumn(label: Text('')),
                      ],
                      rows: records
                          .map(
                            (r) => DataRow(
                              cells: [
                                ...widget.template.fields.map((f) {
                                  final val = r.data[f.name];
                                  String display = '-';
                                  if (val != null) {
                                    if (f.type == CustomFieldType.date)
                                      display = DateFormat(
                                        'dd MMM',
                                      ).format(val);
                                    else
                                      display = val.toString();
                                  }
                                  return DataCell(Text(display));
                                }),
                                DataCell(
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      size: 16,
                                      color: Colors.grey,
                                    ),
                                    onPressed: () =>
                                        _service.deleteCustomRecord(r.id),
                                  ),
                                ),
                              ],
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddSheet,
        icon: const Icon(Icons.add),
        label: const Text('Add Entry'),
      ),
    );
  }

  Widget _buildChart(List<CustomRecord> records, String xKey, String yKey) {
    var sorted = List<CustomRecord>.from(records)
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    List<FlSpot> spots = [];
    for (int i = 0; i < sorted.length; i++) {
      double val = (sorted[i].data[yKey] ?? 0.0).toDouble();
      spots.add(FlSpot(i.toDouble(), val));
    }

    return Container(
      height: 200,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: FlTitlesData(
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (val, meta) {
                  int index = val.toInt();
                  if (index >= 0 && index < sorted.length) {
                    final d = sorted[index].data[xKey];
                    String label = '';
                    if (d is DateTime)
                      label = DateFormat('dd/MM').format(d);
                    else if (d is String)
                      label = d.length > 3 ? d.substring(0, 3) : d;
                    return Text(label, style: const TextStyle(fontSize: 10));
                  }
                  return const Text('');
                },
              ),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              barWidth: 3,
              color: Theme.of(context).colorScheme.primary,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
