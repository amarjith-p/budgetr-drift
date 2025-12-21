import 'package:budget/core/widgets/modern_loader.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/widgets/modern_dropdown.dart';
import '../../../core/models/custom_data_models.dart';
import '../../../core/services/firestore_service.dart';
import '../screens/template_editor_screen.dart';
import 'dynamic_entry_sheet.dart';
import '../services/custom_entry_service.dart';

class CustomDataPage extends StatefulWidget {
  final CustomTemplate template;
  const CustomDataPage({super.key, required this.template});

  @override
  State<CustomDataPage> createState() => _CustomDataPageState();
}

class _CustomDataPageState extends State<CustomDataPage>
    with AutomaticKeepAliveClientMixin {
  final CustomEntryService _service = CustomEntryService();

  // Theme
  final Color _glassColor = const Color(0xFF1B263B).withOpacity(0.5);
  final Color _accentColor = const Color(0xFF3A86FF);
  final Color _bgColor = const Color(0xff0D1B2A);

  // Chart Colors
  final Color _positiveColor = const Color(0xFF00E676);
  final Color _negativeColor = const Color(0xFFFF5252);

  @override
  bool get wantKeepAlive => true;

  void _showEntrySheet(
    List<CustomRecord> existingRecords, [
    CustomRecord? recordToEdit,
  ]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DynamicEntrySheet(
        template: widget.template,
        existingRecords: existingRecords,
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

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          String? errorMessage;

          return StatefulBuilder(
            builder: (context, setInnerState) {
              return Container(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                decoration: BoxDecoration(
                  color: _bgColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  border: Border(
                    top: BorderSide(color: Colors.white.withOpacity(0.1)),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 20),

                    const Text(
                      'Configure Chart',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),

                    ModernDropdownPill<String>(
                      label: xField ?? 'Select X-Axis (Date/Text)',
                      isActive: xField != null,
                      icon: Icons.horizontal_rule,
                      onTap: () => showSelectionSheet<String>(
                        context: context,
                        title: 'X-Axis',
                        items: validX.map((f) => f.name).toList(),
                        labelBuilder: (s) => s,
                        onSelect: (v) => setInnerState(() {
                          xField = v;
                          errorMessage = null;
                        }),
                        selectedItem: xField,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ModernDropdownPill<String>(
                      label: yField ?? 'Select Y-Axis (Number)',
                      isActive: yField != null,
                      icon: Icons.vertical_align_bottom,
                      onTap: () => showSelectionSheet<String>(
                        context: context,
                        title: 'Y-Axis',
                        items: validY.map((f) => f.name).toList(),
                        labelBuilder: (s) => s,
                        onSelect: (v) => setInnerState(() {
                          yField = v;
                          errorMessage = null;
                        }),
                        selectedItem: yField,
                      ),
                    ),

                    if (errorMessage != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        errorMessage!,
                        style: const TextStyle(
                          color: Colors.redAccent,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],

                    const SizedBox(height: 32),

                    Row(
                      children: [
                        if (widget.template.xAxisField != null)
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 12.0),
                              child: OutlinedButton(
                                onPressed: () async {
                                  widget.template.xAxisField = null;
                                  widget.template.yAxisField = null;
                                  await _service.updateCustomTemplate(
                                    widget.template,
                                  );
                                  if (mounted) Navigator.pop(context);
                                },
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                    color: Colors.redAccent.withOpacity(0.5),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: const Text(
                                  'Remove',
                                  style: TextStyle(color: Colors.redAccent),
                                ),
                              ),
                            ),
                          ),

                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: () async {
                              if (xField == null || yField == null) {
                                setInnerState(() {
                                  errorMessage =
                                      "Please select both X and Y axes";
                                });
                                return;
                              }

                              widget.template.xAxisField = xField;
                              widget.template.yAxisField = yField;
                              await _service.updateCustomTemplate(
                                widget.template,
                              );
                              if (mounted) Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _accentColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text(
                              'Save Configuration',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  // ... (Delete methods same as before) ...
  Future<void> _deleteSheet() async {
    bool confirm =
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: const Color(0xFF0D1B2A),
            title: const Text(
              'Delete Sheet?',
              style: TextStyle(color: Colors.white),
            ),
            content: Text(
              'Are you sure you want to delete "${widget.template.name}"?\n\nThis will permanently delete the sheet structure AND all its entered data.',
              style: const TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.white70),
                ),
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
            backgroundColor: const Color(0xFF0D1B2A),
            title: const Text(
              'Delete Entry?',
              style: TextStyle(color: Colors.white),
            ),
            content: const Text(
              'This cannot be undone.',
              style: TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.white70),
                ),
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
    return StreamBuilder<List<CustomRecord>>(
      stream: _service.getCustomRecords(widget.template.id),
      builder: (context, snapshot) {
        final records = snapshot.data ?? [];

        return Scaffold(
          backgroundColor: Colors.transparent,
          floatingActionButton: FloatingActionButton.extended(
            heroTag: 'custom_data_fab_${widget.template.id}',
            backgroundColor: _accentColor,
            onPressed: () => _showEntrySheet(records),
            icon: const Icon(Icons.add),
            label: const Text(
              'Add Entry',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          body: Builder(
            builder: (context) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: ModernLoader());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    "Error: ${snapshot.error}",
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              }

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
                // FIX: Removed large top padding (was 180) to fix gap/scrolling feel
                padding: const EdgeInsets.fromLTRB(0, 16, 0, 100),
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: _glassColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${records.length} Records",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              onPressed: _editTemplate,
                              icon: const Icon(
                                Icons.settings_suggest_outlined,
                                color: Colors.white70,
                              ),
                              tooltip: 'Edit Structure',
                            ),
                            IconButton(
                              onPressed: _deleteSheet,
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.redAccent,
                              ),
                              tooltip: 'Delete Sheet',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

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
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          InkWell(
                            onTap: _configureChart,
                            child: const Icon(
                              Icons.tune,
                              size: 16,
                              color: Colors.white54,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 250,
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      padding: const EdgeInsets.only(
                        right: 16,
                        top: 24,
                        bottom: 8,
                      ),
                      decoration: BoxDecoration(
                        color: _glassColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.05),
                        ),
                      ),
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
                          icon: const Icon(Icons.bar_chart, size: 18),
                          label: const Text('Add Chart'),
                          style: TextButton.styleFrom(
                            foregroundColor: _accentColor,
                          ),
                        ),
                      ),
                    ),
                  ],

                  if (records.isNotEmpty)
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        decoration: BoxDecoration(
                          color: _glassColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.05),
                          ),
                        ),
                        child: DataTable(
                          headingRowColor: MaterialStateProperty.all(
                            Colors.white.withOpacity(0.05),
                          ),
                          dataRowColor: MaterialStateProperty.all(
                            Colors.transparent,
                          ),
                          columnSpacing: 24.0,
                          horizontalMargin: 20,
                          dividerThickness: 0.5,
                          border: TableBorder(
                            horizontalInside: BorderSide(
                              color: Colors.white.withOpacity(0.05),
                              width: 1,
                            ),
                          ),
                          columns: [
                            ...widget.template.fields.map(
                              (f) => DataColumn(
                                label: Text(
                                  f.name.toUpperCase(),
                                  style: TextStyle(
                                    color: _accentColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                            const DataColumn(label: Text('')),
                          ],
                          rows: [
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
                                            '${f.currencySymbol ?? '₹'}${numVal.toStringAsFixed(2)}';
                                      } else if (f.type ==
                                          CustomFieldType.serial) {
                                        display =
                                            '${f.serialPrefix ?? ''}$val${f.serialSuffix ?? ''}';
                                      } else {
                                        display = val.toString();
                                      }
                                    }
                                    return DataCell(
                                      Text(
                                        display,
                                        style: const TextStyle(
                                          color: Colors.white70,
                                        ),
                                      ),
                                    );
                                  }),
                                  DataCell(
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(
                                            Icons.edit,
                                            size: 16,
                                            color: Colors.white54,
                                          ),
                                          onPressed: () =>
                                              _showEntrySheet(records, r),
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                        ),
                                        const SizedBox(width: 12),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete,
                                            size: 16,
                                            color: Colors.redAccent,
                                          ),
                                          onPressed: () => _deleteRecord(r.id),
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (totals.isNotEmpty)
                              DataRow(
                                color: MaterialStateProperty.all(
                                  _accentColor.withOpacity(0.1),
                                ),
                                cells: [
                                  ...widget.template.fields.map((f) {
                                    if (totals.containsKey(f.name)) {
                                      String amount = totals[f.name]!
                                          .toStringAsFixed(2);
                                      if (f.type == CustomFieldType.currency) {
                                        amount =
                                            '${f.currencySymbol ?? '₹'}$amount';
                                      }
                                      return DataCell(
                                        Text(
                                          amount,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: _accentColor,
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
                                            color: Colors.white,
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
                    Padding(
                      padding: const EdgeInsets.only(top: 80),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.table_rows_outlined,
                              size: 48,
                              color: Colors.white.withOpacity(0.1),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "No records found",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.3),
                              ),
                            ),
                          ],
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

  // ... (Chart logic unchanged) ...
  Widget _buildChart(List<CustomRecord> records, String xKey, String yKey) {
    var sorted = List<CustomRecord>.from(records)
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    List<FlSpot> spots = [];
    double minY = double.infinity;
    double maxY = double.negativeInfinity;

    for (int i = 0; i < sorted.length; i++) {
      double val = 0.0;
      var raw = sorted[i].data[yKey];
      if (raw is num)
        val = raw.toDouble();
      else if (raw is String)
        val = double.tryParse(raw) ?? 0.0;

      spots.add(FlSpot(i.toDouble(), val));
      if (val < minY) minY = val;
      if (val > maxY) maxY = val;
    }

    if (spots.isEmpty) return const SizedBox.shrink();

    List<Color> gradientColors = [_positiveColor, _positiveColor];
    List<double> stops = [0.0, 1.0];

    if (minY < 0 && maxY > 0) {
      double zeroPos = (0 - minY) / (maxY - minY);
      gradientColors = [
        _negativeColor,
        _negativeColor,
        _positiveColor,
        _positiveColor,
      ];
      stops = [0.0, zeroPos, zeroPos, 1.0];
    } else if (maxY <= 0) {
      gradientColors = [_negativeColor, _negativeColor];
    }

    double interval = 1.0;
    if (sorted.length > 4) interval = (sorted.length / 4).ceilToDouble();

    return LineChart(
      LineChartData(
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (spot) =>
                const Color(0xFF0D1B2A).withOpacity(0.95),
            tooltipRoundedRadius: 8,
            getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
              return touchedBarSpots.map((barSpot) {
                final index = barSpot.x.toInt();
                if (index >= 0 && index < sorted.length) {
                  final d = sorted[index].data[xKey];
                  String xLabel = (d is DateTime)
                      ? DateFormat('dd MMM').format(d)
                      : d.toString();
                  Color valColor = barSpot.y > 0
                      ? _positiveColor
                      : _negativeColor;

                  return LineTooltipItem(
                    '$xLabel\n',
                    const TextStyle(color: Colors.white70, fontSize: 10),
                    children: [
                      TextSpan(
                        text: NumberFormat.compact().format(barSpot.y),
                        style: TextStyle(
                          color: valColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
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
              reservedSize: 32,
              getTitlesWidget: (val, _) => Text(
                NumberFormat.compact().format(val),
                style: const TextStyle(fontSize: 10, color: Colors.white30),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 42,
              interval: interval,
              getTitlesWidget: (val, meta) {
                int index = val.toInt();
                if (index >= 0 &&
                    index < sorted.length &&
                    val == index.toDouble()) {
                  final d = sorted[index].data[xKey];
                  String label = (d is DateTime)
                      ? DateFormat('dd/MM').format(d)
                      : d.toString();
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(
                      label,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.white30,
                      ),
                    ),
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
            gradient: LinearGradient(
              colors: gradientColors,
              stops: stops,
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
            ),
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                Color dotColor = spot.y > 0 ? _positiveColor : _negativeColor;
                return FlDotCirclePainter(
                  radius: 4,
                  color: dotColor,
                  strokeWidth: 2,
                  strokeColor: Colors.white.withOpacity(0.8),
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: gradientColors.map((c) => c.withOpacity(0.1)).toList(),
                stops: stops,
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
