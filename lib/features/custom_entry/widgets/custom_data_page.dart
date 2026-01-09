import 'package:budget/core/design/budgetr_colors.dart';
import 'package:budget/core/widgets/modern_loader.dart';
import 'package:budget/core/widgets/status_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/widgets/modern_dropdown.dart';
import '../../../core/models/custom_data_models.dart';
import '../screens/template_editor_screen.dart';
import '../utils/formula_utils.dart';
import '../widgets/data_view/custom_data_chart.dart';
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

  final Color _glassColor = const Color(0xFF1B263B).withOpacity(0.5);
  final Color _accentColor = const Color(0xFF3A86FF);
  final Color _bgColor = const Color(0xff0D1B2A);

  @override
  bool get wantKeepAlive => true;

  bool get _isAutoTracker => widget.template.name.endsWith('AutoTracker');

  // --- STALE DATA LOGIC ---
  bool _isRowStale(CustomRecord record) {
    for (var field in widget.template.fields) {
      if (field.type == CustomFieldType.formula &&
          field.formulaExpression != null) {
        String expr = field.formulaExpression!;
        for (var inputField in widget.template.fields) {
          String placeholder = '[${inputField.name}]';
          if (expr.contains(placeholder)) {
            var val = record.data[inputField.name];
            double numVal = 0.0;
            if (val is num)
              numVal = val.toDouble();
            else if (val is String) numVal = double.tryParse(val) ?? 0.0;
            String replacement = numVal < 0 ? "($numVal)" : numVal.toString();
            expr = expr.replaceAll(placeholder, replacement);
          }
        }
        try {
          // Use centralized Utils
          double calculated = FormulaUtils.evaluateRPN(expr);
          double stored = (record.data[field.name] is num)
              ? (record.data[field.name] as num).toDouble()
              : 0.0;
          if ((calculated - stored).abs() > 0.01) return true;
        } catch (e) {
          return true;
        }
      }
    }
    return false;
  }

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
              f.type == CustomFieldType.currency ||
              f.type == CustomFieldType.formula,
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
                    SizedBox(
                      width: double.infinity,
                      child: ModernDropdownPill<String>(
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
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ModernDropdownPill<String>(
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
                                  final navigator = Navigator.of(context);
                                  widget.template.xAxisField = null;
                                  widget.template.yAxisField = null;
                                  await _service.updateCustomTemplate(
                                    widget.template,
                                  );
                                  navigator.pop();
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
                              final navigator = Navigator.of(context);
                              widget.template.xAxisField = xField;
                              widget.template.yAxisField = yField;
                              await _service.updateCustomTemplate(
                                widget.template,
                              );
                              navigator.pop();
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

  Future<void> _deleteSheet() async {
    showStatusSheet(
      context: context,
      title: "Delete Sheet?",
      message:
          "Are you sure you want to delete '${widget.template.name}'?\nThis will permanently delete the sheet structure and all its entered data.",
      icon: Icons.delete_sweep_sharp,
      color: Colors.redAccent,
      cancelButtonText: "Cancel",
      onCancel: () {},
      buttonText: "Delete",
      onDismiss: () async {
        await _service.deleteCustomTemplate(widget.template.id);
      },
    );
  }

  Future<void> _deleteRecord(String id) async {
    showStatusSheet(
      context: context,
      title: "Delete Entry?",
      message:
          "Are you sure you want to remove this entry?\nThis action cannot be undone.",
      icon: Icons.delete_sweep_sharp,
      color: Colors.redAccent,
      cancelButtonText: "Cancel",
      onCancel: () {},
      buttonText: "Delete",
      onDismiss: () async {
        await _service.deleteCustomRecord(id);
      },
    );
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
          floatingActionButton: _isAutoTracker
              ? null
              : FloatingActionButton.extended(
                  heroTag: 'custom_data_fab_${widget.template.id}',
                  backgroundColor: _accentColor,
                  foregroundColor: BudgetrColors.inputFill,
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
                        field.type == CustomFieldType.currency ||
                        field.type == CustomFieldType.formula) &&
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
                padding: const EdgeInsets.fromLTRB(0, 16, 0, 100),
                children: [
                  Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: _glassColor,
                      borderRadius: BorderRadius.circular(12),
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
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: _configureChart,
                          icon: const Icon(Icons.tune_rounded, size: 16),
                          label: const Text("Configure Chart"),
                          style: TextButton.styleFrom(
                            foregroundColor: _accentColor,
                            textStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      height: 250,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      padding:
                          const EdgeInsets.only(right: 16, top: 24, bottom: 8),
                      decoration: BoxDecoration(
                        color: _glassColor,
                        borderRadius: BorderRadius.circular(12),
                        border:
                            Border.all(color: Colors.white.withOpacity(0.05)),
                      ),
                      // New Component Used Here
                      child: CustomDataChart(
                        records: records,
                        xKey: widget.template.xAxisField!,
                        yKey: widget.template.yAxisField!,
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
                          border:
                              Border.all(color: Colors.white.withOpacity(0.05)),
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
                            ...records.map((r) {
                              bool isStale = _isRowStale(r);
                              return DataRow(
                                color: isStale
                                    ? MaterialStateProperty.all(
                                        Colors.amber.withOpacity(0.1),
                                      )
                                    : null,
                                cells: [
                                  ...widget.template.fields.map((f) {
                                    final val = r.data[f.name];
                                    String display = '-';
                                    if (val != null) {
                                      if (f.type == CustomFieldType.date &&
                                          val is DateTime) {
                                        display = DateFormat('dd MMM yyyy')
                                            .format(val);
                                      } else if (f.type ==
                                          CustomFieldType.currency) {
                                        double numVal = 0.0;
                                        if (val is num) {
                                          numVal = val.toDouble();
                                        } else if (val is String) {
                                          numVal = double.tryParse(val) ?? 0.0;
                                        }
                                        display =
                                            '${f.currencySymbol ?? '₹'}${numVal.toStringAsFixed(2)}';
                                      } else if (f.type ==
                                          CustomFieldType.serial) {
                                        display =
                                            '${f.serialPrefix ?? ''}$val${f.serialSuffix ?? ''}';
                                      } else if (f.type ==
                                          CustomFieldType.number) {
                                        display = val.toString();
                                        if (f.serialSuffix != null) {
                                          display += f.serialSuffix!;
                                        }
                                      } else {
                                        display = val.toString();
                                      }
                                    }

                                    bool highlightCell = isStale &&
                                        f.type == CustomFieldType.formula;

                                    return DataCell(
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            display,
                                            style: TextStyle(
                                              color: highlightCell
                                                  ? Colors.amberAccent
                                                  : Colors.white70,
                                            ),
                                          ),
                                          if (highlightCell) ...[
                                            const SizedBox(width: 4),
                                            const Icon(
                                              Icons.warning_amber_rounded,
                                              size: 14,
                                              color: Colors.amber,
                                            ),
                                          ],
                                        ],
                                      ),
                                    );
                                  }),
                                  DataCell(
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (!_isAutoTracker) ...[
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
                                        ],
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
                              );
                            }),
                            if (totals.isNotEmpty && !_isAutoTracker)
                              DataRow(
                                cells: [
                                  ...widget.template.fields.map((f) {
                                    if (totals.containsKey(f.name)) {
                                      String amount =
                                          totals[f.name]!.toStringAsFixed(2);
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
}
