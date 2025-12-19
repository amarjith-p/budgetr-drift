import 'package:budget/features/dashboard/widgets/modern_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/models/custom_data_models.dart';
import '../../../core/services/firestore_service.dart';
import '../screens/template_editor_screen.dart';
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

  // FIX 1: Accept 'existingRecords' so we can calculate the next Serial No.
  void _showEntrySheet(
    List<CustomRecord> existingRecords, [
    CustomRecord? recordToEdit,
  ]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DynamicEntrySheet(
        template: widget.template,
        existingRecords: existingRecords, // Pass the list here
        recordToEdit: recordToEdit,
      ),
    );
  }

  void _editTemplate() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (c) => TemplateEditorScreen(templateToEdit: widget.template),
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
              f.type == CustomFieldType.date ||
              f.type == CustomFieldType.serial,
        )
        .toList();
    final validY = widget.template.fields
        .where(
          (f) =>
              f.type == CustomFieldType.number ||
              f.type == CustomFieldType.currency,
        )
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
                ModernDropdownPill<String>(
                  label: xField ?? 'X-Axis (Date/Text)',
                  isActive: xField != null,
                  icon: Icons.horizontal_rule,
                  onTap: () => showSelectionSheet<String>(
                    context: context,
                    title: 'X-Axis',
                    items: validX.map((f) => f.name).toList(),
                    labelBuilder: (s) => s,
                    onSelect: (v) => setModalState(() => xField = v),
                    selectedItem: xField,
                  ),
                ),
                const SizedBox(height: 16),
                ModernDropdownPill<String>(
                  label: yField ?? 'Y-Axis (Number)',
                  isActive: yField != null,
                  icon: Icons.vertical_align_bottom,
                  onTap: () => showSelectionSheet<String>(
                    context: context,
                    title: 'Y-Axis',
                    items: validY.map((f) => f.name).toList(),
                    labelBuilder: (s) => s,
                    onSelect: (v) => setModalState(() => yField = v),
                    selectedItem: yField,
                  ),
                ),
              ],
            ),
            actions: [
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

    // FIX 2: StreamBuilder is now at the top level
    // This allows us to access 'records' for the FloatingActionButton
    return StreamBuilder<List<CustomRecord>>(
      stream: _service.getCustomRecords(widget.template.id),
      builder: (context, snapshot) {
        final records = snapshot.data ?? [];

        return Scaffold(
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () =>
                _showEntrySheet(records), // Pass records for auto-increment
            icon: const Icon(Icons.add),
            label: const Text('Add Entry'),
          ),
          body: Builder(
            builder: (context) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text("Error: ${snapshot.error}"));
              }

              // Calculate Totals
              Map<String, double> totals = {};
              for (var field in widget.template.fields) {
                if ((field.type == CustomFieldType.number ||
                        field.type == CustomFieldType.currency) &&
                    field.isSumRequired) {
                  totals[field.name] = records.fold(0.0, (sum, r) {
                    final rawVal = r.data[field.name];
                    double val = 0.0;
                    if (rawVal is num) {
                      val = rawVal.toDouble();
                    } else if (rawVal is String) {
                      val = double.tryParse(rawVal) ?? 0.0;
                    }
                    return sum + val;
                  });
                }
              }

              return ListView(
                padding: const EdgeInsets.only(bottom: 100),
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8, right: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: _editTemplate,
                            icon: const Icon(
                              Icons.edit_note,
                              color: Colors.blueAccent,
                            ),
                            tooltip: 'Edit Sheet Structure',
                          ),
                          IconButton(
                            onPressed: _deleteSheet,
                            icon: const Icon(
                              Icons.delete_forever_outlined,
                              color: Colors.redAccent,
                            ),
                            tooltip: 'Delete this Sheet',
                          ),
                        ],
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
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: Colors.white54),
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
                            // Data Rows
                            ...records.map(
                              (r) => DataRow(
                                cells: [
                                  ...widget.template.fields.map((f) {
                                    final val = r.data[f.name];
                                    String display = '-';
                                    if (val != null) {
                                      if (f.type == CustomFieldType.date &&
                                          val is DateTime) {
                                        display = DateFormat(
                                          'dd MMM yyyy',
                                        ).format(val);
                                      } else if (f.type ==
                                          CustomFieldType.currency) {
                                        double numVal = 0.0;
                                        if (val is num)
                                          numVal = val.toDouble();
                                        else if (val is String)
                                          numVal = double.tryParse(val) ?? 0.0;
                                        display =
                                            '${f.currencySymbol}${numVal.toStringAsFixed(2)}';
                                      } else if (f.type ==
                                          CustomFieldType.serial) {
                                        // Serial Formatting
                                        display =
                                            '${f.serialPrefix ?? ''}$val${f.serialSuffix ?? ''}';
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
                                        IconButton(
                                          icon: const Icon(
                                            Icons.edit,
                                            size: 18,
                                            color: Colors.blueAccent,
                                          ),
                                          // FIX 3: Pass existing records when editing too!
                                          onPressed: () =>
                                              _showEntrySheet(records, r),
                                          constraints: const BoxConstraints(),
                                          padding: EdgeInsets.zero,
                                        ),
                                        const SizedBox(width: 8),
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

                            // Grand Total Row
                            if (totals.isNotEmpty)
                              DataRow(
                                color: MaterialStateProperty.all(
                                  Theme.of(context).colorScheme.primaryContainer
                                      .withOpacity(0.3),
                                ),
                                cells: [
                                  ...widget.template.fields.map((f) {
                                    if (totals.containsKey(f.name)) {
                                      String amount = totals[f.name]!
                                          .toStringAsFixed(2);
                                      if (f.type == CustomFieldType.currency) {
                                        amount = '${f.currencySymbol}$amount';
                                      }
                                      return DataCell(
                                        Text(
                                          amount,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            fontSize: 13,
                                          ),
                                        ),
                                      );
                                    } else if (f ==
                                        widget.template.fields.first) {
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
      },
    );
  }

  Widget _buildChart(List<CustomRecord> records, String xKey, String yKey) {
    var sorted = List<CustomRecord>.from(records)
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    List<FlSpot> spots = [];
    double minY = double.infinity;
    double maxY = double.negativeInfinity;

    // Linear Regression Variables
    double sumX = 0;
    double sumY = 0;
    double sumXY = 0;
    double sumXX = 0;
    int n = sorted.length;

    for (int i = 0; i < n; i++) {
      double val = 0.0;
      var raw = sorted[i].data[yKey];
      // Safe parsing for chart data
      if (raw is num)
        val = raw.toDouble();
      else if (raw is String)
        val = double.tryParse(raw) ?? 0.0;

      spots.add(FlSpot(i.toDouble(), val));

      if (val < minY) minY = val;
      if (val > maxY) maxY = val;

      sumX += i;
      sumY += val;
      sumXY += (i * val);
      sumXX += (i * i);
    }

    if (spots.isEmpty) return const SizedBox.shrink();

    // Calculate Best Fit Line (y = mx + c)
    List<FlSpot> trendSpots = [];
    if (n > 1) {
      double slope = (n * sumXY - sumX * sumY) / (n * sumXX - sumX * sumX);
      double intercept = (sumY - slope * sumX) / n;
      for (int i = 0; i < n; i++) {
        trendSpots.add(FlSpot(i.toDouble(), slope * i + intercept));
      }
    } else {
      trendSpots.add(FlSpot(0, spots[0].y));
    }

    // Gradient Logic
    List<Color> gradientColors;
    List<double> gradientStops;

    if (minY >= 0) {
      gradientColors = [Colors.green, Colors.green];
      gradientStops = [0.0, 1.0];
    } else if (maxY <= 0) {
      gradientColors = [Colors.red, Colors.red];
      gradientStops = [0.0, 1.0];
    } else {
      double zeroStop = (0 - minY) / (maxY - minY);
      zeroStop = zeroStop.clamp(0.0, 1.0);
      gradientColors = [Colors.red, Colors.red, Colors.green, Colors.green];
      gradientStops = [0.0, zeroStop, zeroStop, 1.0];
    }

    // Dynamic Interval (Count / 4)
    double interval = 1.0;
    if (sorted.length > 4) {
      interval = (sorted.length / 4).ceilToDouble();
    }

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
          // Uses getTooltipColor (Supported in newer fl_chart)
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (spot) =>
                  const Color(0xFF263238).withOpacity(0.9),
              tooltipRoundedRadius: 8,
              getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                return touchedBarSpots.map((barSpot) {
                  // Hide Trend Line Tooltip
                  if (barSpot.barIndex == 0) return null;

                  final index = barSpot.x.toInt();
                  if (index >= 0 && index < sorted.length) {
                    final d = sorted[index].data[xKey];
                    String xLabel = '';
                    if (d is DateTime) {
                      xLabel = DateFormat('dd MMM yyyy').format(d);
                    } else if (d is int) {
                      xLabel = d.toString();
                    } else {
                      xLabel = d.toString();
                    }

                    return LineTooltipItem(
                      '$xLabel\n',
                      const TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      children: [
                        TextSpan(
                          text: NumberFormat.decimalPattern().format(barSpot.y),
                          style: TextStyle(
                            color: barSpot.y < 0
                                ? Colors.redAccent
                                : Colors.greenAccent,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    );
                  }
                  return null;
                }).toList();
              },
            ),
          ),
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
                interval: interval,
                getTitlesWidget: (val, meta) {
                  int index = val.toInt();
                  if (index >= 0 &&
                      index < sorted.length &&
                      val == index.toDouble()) {
                    final d = sorted[index].data[xKey];
                    String label = '';
                    if (d is DateTime)
                      label = DateFormat('dd MMM yy').format(d);
                    else if (d is String)
                      label = d.length > 5 ? d.substring(0, 5) : d;
                    else
                      label = d.toString();

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
            // Trend Line
            LineChartBarData(
              spots: trendSpots,
              isCurved: false,
              barWidth: 2,
              color: Colors.white.withOpacity(0.3),
              dashArray: [5, 5],
              dotData: const FlDotData(show: false),
            ),
            // Data Line
            LineChartBarData(
              spots: spots,
              isCurved: true,
              barWidth: 3,
              gradient: LinearGradient(
                colors: gradientColors,
                stops: gradientStops,
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: spot.y < 0 ? Colors.red : Colors.green,
                    strokeWidth: 2,
                    strokeColor: Colors.white,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: gradientColors
                      .map((c) => c.withOpacity(0.1))
                      .toList(),
                  stops: gradientStops,
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
