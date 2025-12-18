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

  // Updated: Handle both Add and Edit
  void _showEntrySheet([CustomRecord? recordToEdit]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DynamicEntrySheet(
        template: widget.template,
        recordToEdit: recordToEdit, // Pass existing record
      ),
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
              // NEW: Remove Chart Option
              if (widget.template.xAxisField != null)
                TextButton(
                  onPressed: () async {
                    widget.template.xAxisField = null;
                    widget.template.yAxisField = null;
                    await _service.updateCustomTemplate(widget.template);
                    if (mounted) Navigator.pop(context);
                  },
                  child: const Text(
                    'Remove Chart',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
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

  Future<void> _deleteSheet() async {
    bool confirm =
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete Sheet?'),
            content: Text(
              'Are you sure you want to delete "${widget.template.name}"?\n\nThis will permanently delete the sheet structure AND all its entered data.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text(
                  'Delete Forever',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ) ??
        false;

    if (confirm) {
      await _service.deleteCustomTemplate(widget.template.id);
    }
  }

  Future<void> _deleteRecord(String id) async {
    bool confirm =
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Delete Entry?'),
            content: const Text('This cannot be undone.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ) ??
        false;

    if (confirm) {
      await _service.deleteCustomRecord(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showEntrySheet(), // Add Mode
        icon: const Icon(Icons.add),
        label: const Text('Add Entry'),
      ),
      body: StreamBuilder<List<CustomRecord>>(
        stream: _service.getCustomRecords(widget.template.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final records = snapshot.data ?? [];

          // Calculate Totals
          Map<String, double> totals = {};
          for (var field in widget.template.fields) {
            if (field.type == CustomFieldType.number && field.isSumRequired) {
              totals[field.name] = records.fold(
                0.0,
                (sum, r) =>
                    sum + ((r.data[field.name] as num?)?.toDouble() ?? 0.0),
              );
            }
          }

          return ListView(
            padding: const EdgeInsets.only(bottom: 100),
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 8, right: 8),
                  child: IconButton(
                    onPressed: _deleteSheet,
                    icon: const Icon(
                      Icons.delete_forever_outlined,
                      color: Colors.redAccent,
                    ),
                    tooltip: 'Delete this Sheet',
                  ),
                ),
              ),

              // Chart Section
              if (widget.template.xAxisField != null &&
                  widget.template.yAxisField != null &&
                  records.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Trend Analysis',
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(color: Colors.white54),
                      ),
                      InkWell(
                        onTap: _configureChart,
                        child: const Icon(
                          Icons.settings,
                          size: 16,
                          color: Colors.white54,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 250,
                  child: _buildChart(
                    records,
                    widget.template.xAxisField!,
                    widget.template.yAxisField!,
                  ),
                ),
                const SizedBox(height: 24),
              ] else if (records.isNotEmpty) ...[
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 16, bottom: 8),
                    child: TextButton.icon(
                      onPressed: _configureChart,
                      icon: const Icon(Icons.show_chart, size: 18),
                      label: const Text('Add Chart'),
                    ),
                  ),
                ),
              ],

              // Data Table
              if (records.isNotEmpty)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white24),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DataTable(
                      headingRowColor: MaterialStateProperty.all(
                        Colors.white.withOpacity(0.1),
                      ),
                      dataRowColor: MaterialStateProperty.all(
                        Colors.transparent,
                      ),
                      columnSpacing: 24,
                      border: TableBorder.symmetric(
                        inside: BorderSide(
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
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
                        const DataColumn(label: Text('Actions')),
                      ],
                      rows: [
                        // 1. Data Rows
                        ...records.map(
                          (r) => DataRow(
                            cells: [
                              ...widget.template.fields.map((f) {
                                final val = r.data[f.name];
                                String display = '-';
                                if (val != null) {
                                  if (f.type == CustomFieldType.date &&
                                      val is DateTime) {
                                    display = DateFormat('dd MMM').format(val);
                                  } else {
                                    display = val.toString();
                                  }
                                }
                                return DataCell(Text(display));
                              }),
                              DataCell(
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Edit Button
                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit,
                                        size: 18,
                                        color: Colors.blueAccent,
                                      ),
                                      onPressed: () => _showEntrySheet(r),
                                      constraints: const BoxConstraints(),
                                      padding: EdgeInsets.zero,
                                    ),
                                    const SizedBox(width: 12),
                                    // Delete Button
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        size: 18,
                                        color: Colors.redAccent,
                                      ),
                                      onPressed: () => _deleteRecord(r.id),
                                      constraints: const BoxConstraints(),
                                      padding: EdgeInsets.zero,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // 2. Footer Total Row
                        if (totals.isNotEmpty)
                          DataRow(
                            color: MaterialStateProperty.all(
                              Theme.of(
                                context,
                              ).colorScheme.primaryContainer.withOpacity(0.2),
                            ),
                            cells: [
                              ...widget.template.fields.map((f) {
                                if (totals.containsKey(f.name)) {
                                  // Full decimal display (e.g. 12345.67)
                                  return DataCell(
                                    Text(
                                      totals[f.name]!.toStringAsFixed(2),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  );
                                } else if (f == widget.template.fields.first) {
                                  return const DataCell(
                                    Text(
                                      'TOTAL',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  );
                                }
                                return const DataCell(Text(''));
                              }),
                              const DataCell(Text('')),
                            ],
                          ),
                      ],
                    ),
                  ),
                )
              else
                const Padding(
                  padding: EdgeInsets.only(top: 80),
                  child: Center(
                    child: Text(
                      "No records yet.\nTap + to add data.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white38),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildChart(List<CustomRecord> records, String xKey, String yKey) {
    var sorted = List<CustomRecord>.from(records)
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    List<FlSpot> spots = [];
    for (int i = 0; i < sorted.length; i++) {
      double val = 0.0;
      var raw = sorted[i].data[yKey];
      if (raw is num)
        val = raw.toDouble();
      else if (raw is String)
        val = double.tryParse(raw) ?? 0.0;

      spots.add(FlSpot(i.toDouble(), val));
    }

    if (spots.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.only(right: 16, top: 16, bottom: 8),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
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
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (val, _) => Text(
                  NumberFormat.compact().format(val),
                  style: const TextStyle(fontSize: 10),
                ),
              ),
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

                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(label, style: const TextStyle(fontSize: 10)),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              barWidth: 3,
              color: Theme.of(context).colorScheme.primary,
              dotData: const FlDotData(show: true),
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
