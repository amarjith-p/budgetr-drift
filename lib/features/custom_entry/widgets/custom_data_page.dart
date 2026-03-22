import 'package:budget/core/design/budgetr_colors.dart';
import 'package:budget/core/widgets/futuristic_loader.dart';
import 'package:budget/core/widgets/status_bottom_sheet.dart';
import 'package:budget/features/custom_entry/services/custom_export_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

import 'package:open_file/open_file.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/widgets/modern_dropdown.dart';
import '../../../core/models/custom_data_models.dart';
import '../screens/template_editor_screen.dart';
import '../utils/formula_utils.dart';
import '../widgets/data_view/custom_data_chart.dart';
import 'dynamic_entry_sheet.dart';
import '../services/custom_entry_service.dart';
import '../utils/filter_engine.dart';
import 'data_view/filter_sheet.dart';

class CustomDataPage extends StatefulWidget {
  final CustomTemplate template;
  const CustomDataPage({super.key, required this.template});

  @override
  State<CustomDataPage> createState() => _CustomDataPageState();
}

class _CustomDataPageState extends State<CustomDataPage>
    with AutomaticKeepAliveClientMixin {
  final CustomEntryService _service = GetIt.I<CustomEntryService>();

  final Color _glassColor = const Color(0xFF1B263B).withOpacity(0.5);
  final Color _accentColor = const Color(0xFF3A86FF);
  final Color _bgColor = const Color(0xff0D1B2A);

  late Stream<CustomTemplate?> _templateStream;
  late Stream<List<CustomRecord>> _recordsStream;

  List<FilterCondition> _activeFilters = [];

  int? _sortColumnIndex;
  bool _sortAscending = false;
  final TextEditingController _quickSearchController = TextEditingController();
  String _quickSearchQuery = "";

  bool _isExporting = false;
  String _exportMessage = "";

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _templateStream = _service.watchCustomTemplate(widget.template.id);
    _recordsStream = _service.getCustomRecords(widget.template.id);
  }

  @override
  void dispose() {
    _quickSearchController.dispose();
    super.dispose();
  }

  bool _isSystemTemplate(CustomTemplate t) =>
      t.name.endsWith('AutoTracker') || t.name == "Investment Portfolio";

  DateTime? _tryParseDate(dynamic val) {
    if (val is DateTime) return val;
    if (val is String) return DateTime.tryParse(val);
    return null;
  }

  bool _isRowStale(CustomRecord record, CustomTemplate template) {
    for (var field in template.fields) {
      if (field.type == CustomFieldType.formula &&
          field.formulaExpression != null) {
        String expr = field.formulaExpression!;
        for (var inputField in template.fields) {
          String placeholder = '[${inputField.name}]';
          if (expr.contains(placeholder)) {
            var val = record.data[inputField.name];
            double numVal = 0.0;
            if (val is num) {
              numVal = val.toDouble();
            } else if (val is String) {
              numVal = double.tryParse(val) ?? 0.0;
            }
            String replacement = numVal < 0 ? "($numVal)" : numVal.toString();
            expr = expr.replaceAll(placeholder, replacement);
          }
        }
        try {
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

  List<CustomRecord> _applySmartSorting(
      List<CustomRecord> records, CustomTemplate template) {
    if (_sortColumnIndex != null &&
        _sortColumnIndex! < template.fields.length) {
      final sortField = template.fields[_sortColumnIndex!];

      records.sort((a, b) {
        dynamic valA = a.data[sortField.name];
        dynamic valB = b.data[sortField.name];

        if (valA == null && valB == null) return 0;
        if (valA == null) return -1;
        if (valB == null) return 1;

        int comparison = 0;

        if (valA is num && valB is num) {
          comparison = valA.compareTo(valB);
        } else if (sortField.type == CustomFieldType.date) {
          DateTime? dateA = _tryParseDate(valA);
          DateTime? dateB = _tryParseDate(valB);
          if (dateA != null && dateB != null) {
            comparison = dateA.compareTo(dateB);
          }
        } else {
          comparison = valA.toString().compareTo(valB.toString());
        }

        return _sortAscending ? comparison : -comparison;
      });
      return records;
    } else {
      return records.reversed.toList();
    }
  }

  void _showEntrySheet(
      CustomTemplate template, List<CustomRecord> existingRecords,
      [CustomRecord? recordToEdit]) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DynamicEntrySheet(
        template: template,
        existingRecords: existingRecords,
        recordToEdit: recordToEdit,
      ),
    );
  }

  void _showFilterSheet(CustomTemplate template, List<CustomRecord> records) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterSheet(
        template: template,
        activeFilters: _activeFilters,
        sourceData: records,
        onApply: (filters) {
          setState(() {
            _activeFilters = filters;
          });
        },
      ),
    );
  }

  void _editTemplate(CustomTemplate template) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (c) => TemplateEditorScreen(templateToEdit: template)));
  }

  void _configureChart(CustomTemplate template) {
    String? xField = template.xAxisField;
    String? yField = template.yAxisField;

    final validX = template.fields
        .where((f) =>
            f.type == CustomFieldType.string ||
            f.type == CustomFieldType.date ||
            f.type == CustomFieldType.serial)
        .toList();
    final validY = template.fields
        .where((f) =>
            f.type == CustomFieldType.number ||
            f.type == CustomFieldType.currency ||
            f.type == CustomFieldType.formula)
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
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(24)),
                  border: Border(
                      top: BorderSide(color: Colors.white.withOpacity(0.1))),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(2))),
                    const SizedBox(height: 20),
                    const Text('Configure Chart',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
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
                      Text(errorMessage!,
                          style: const TextStyle(
                              color: Colors.redAccent,
                              fontSize: 13,
                              fontWeight: FontWeight.bold)),
                    ],
                    const SizedBox(height: 32),
                    Row(
                      children: [
                        if (template.xAxisField != null)
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 12.0),
                              child: OutlinedButton(
                                onPressed: () async {
                                  final navigator = Navigator.of(context);
                                  template.xAxisField = null;
                                  template.yAxisField = null;
                                  await _service.updateCustomTemplate(template);
                                  navigator.pop();
                                },
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(
                                      color: Colors.redAccent.withOpacity(0.5)),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16)),
                                ),
                                child: const Text('Remove',
                                    style: TextStyle(color: Colors.redAccent)),
                              ),
                            ),
                          ),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            onPressed: () async {
                              if (xField == null || yField == null) {
                                setInnerState(() => errorMessage =
                                    "Please select both X and Y axes");
                                return;
                              }
                              final navigator = Navigator.of(context);
                              template.xAxisField = xField;
                              template.yAxisField = yField;
                              await _service.updateCustomTemplate(template);
                              navigator.pop();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _accentColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                            ),
                            child: const Text('Save Configuration',
                                style: TextStyle(fontWeight: FontWeight.bold)),
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

  Future<void> _deleteSheet(CustomTemplate template) async {
    showStatusSheet(
      context: context,
      title: "Delete Sheet?",
      message:
          "Are you sure you want to delete '${template.name}'?\nThis will permanently delete the sheet structure and all its entered data.",
      icon: Icons.delete_sweep_sharp,
      color: Colors.redAccent,
      cancelButtonText: "Cancel",
      onCancel: () {},
      buttonText: "Delete",
      onDismiss: () async {
        await _service.deleteCustomTemplate(template.id);
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

  void _showExportSuccessSheet(
      ExportResult result, Color themeColor, String format) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        decoration: BoxDecoration(
          color: _bgColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: themeColor.withOpacity(0.15), shape: BoxShape.circle),
              child:
                  Icon(Icons.check_circle_rounded, color: themeColor, size: 48),
            ),
            const SizedBox(height: 16),
            Text("$format Export Successful",
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.03),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("File Saved to:",
                      style: TextStyle(
                          color: themeColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 11)),
                  const SizedBox(height: 4),
                  Text(result.publicPath,
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 12, height: 1.4)),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: themeColor.withOpacity(0.5)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    icon: Icon(Icons.ios_share_rounded, color: themeColor),
                    label: Text("Share",
                        style: TextStyle(
                            color: themeColor, fontWeight: FontWeight.bold)),
                    onPressed: () {
                      Navigator.pop(ctx);
                      Share.shareXFiles([XFile(result.safeCachePath)],
                          text: "FinStack 360 $format Export");
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: themeColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                    icon: const Icon(Icons.file_open_rounded),
                    label: const Text("Open File",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    onPressed: () async {
                      Navigator.pop(ctx);

                      final String mimeType =
                          format == "PDF" ? "application/pdf" : "text/csv";
                      final openResult = await OpenFile.open(
                          result.safeCachePath,
                          type: mimeType);

                      if (openResult.type != ResultType.done && mounted) {
                        _showError(
                            "Cannot open directly due to Android security. Please use the 'Share' button instead to open in Sheets.");
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Dismiss",
                  style: TextStyle(color: Colors.white54)),
            )
          ],
        ),
      ),
    );
  }

  void _showExportOptions(CustomTemplate template, List<CustomRecord> records,
      Map<String, double> totals) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: _bgColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Export Data",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("Save '${template.name}' to device storage",
                style: TextStyle(color: Colors.white.withOpacity(0.5))),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildExportOption(
                    icon: Icons.picture_as_pdf_rounded,
                    label: "Save PDF",
                    color: const Color(0xFFE71D36),
                    onTap: () async {
                      Navigator.pop(ctx);
                      setState(() {
                        _isExporting = true;
                        _exportMessage = "COMPILING SECURE PDF ARCHIVE...";
                      });

                      try {
                        final result = await CustomExportService()
                            .exportToPdf(template, records, totals);

                        if (mounted) {
                          setState(() => _isExporting = false);
                          _showExportSuccessSheet(
                              result, const Color(0xFFE71D36), "PDF");
                        }
                      } catch (e) {
                        if (mounted) {
                          setState(() => _isExporting = false);
                          _showError("Export failed: $e");
                        }
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildExportOption(
                    icon: Icons.table_chart_rounded,
                    label: "Save CSV",
                    color: const Color(0xFF2EC4B6),
                    onTap: () async {
                      Navigator.pop(ctx);
                      setState(() {
                        _isExporting = true;
                        _exportMessage = "EXTRACTING DATA TO SPREADSHEET...";
                      });

                      try {
                        final result = await CustomExportService()
                            .exportToCsv(template, records, totals);

                        if (mounted) {
                          setState(() => _isExporting = false);
                          _showExportSuccessSheet(
                              result, const Color(0xFF2EC4B6), "CSV");
                        }
                      } catch (e) {
                        if (mounted) {
                          setState(() => _isExporting = false);
                          _showError("Export failed: $e");
                        }
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showError(String errorMsg) {
    showStatusSheet(
      context: context,
      title: "Error",
      message: errorMsg,
      icon: Icons.error_outline_rounded,
      color: Colors.redAccent,
    );
  }

  Widget _buildExportOption(
      {required IconData icon,
      required String label,
      required Color color,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 12),
            Text(label,
                style: TextStyle(color: color, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Stack(
      children: [
        StreamBuilder<CustomTemplate?>(
          stream: _templateStream,
          builder: (context, templateSnapshot) {
            if (templateSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                backgroundColor: Color(0xff0D1B2A),
                body: Center(
                    child: FuturisticLoader(
                        size: 80, label: "CONFIGURING DATATABLE ENGINE...")),
              );
            }

            if (templateSnapshot.data == null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) Navigator.pop(context);
              });
              return const SizedBox();
            }

            final activeTemplate = templateSnapshot.data!;

            return StreamBuilder<List<CustomRecord>>(
              stream: _recordsStream,
              builder: (context, recordSnapshot) {
                final rawRecords = recordSnapshot.data ?? [];

                var records =
                    FilterEngine.applyFilters(rawRecords, _activeFilters);

                if (_quickSearchQuery.isNotEmpty) {
                  records = records.where((r) {
                    return r.data.values.any((val) =>
                        val != null &&
                        val
                            .toString()
                            .toLowerCase()
                            .contains(_quickSearchQuery.toLowerCase()));
                  }).toList();
                }

                records = _applySmartSorting(records, activeTemplate);

                return Scaffold(
                  backgroundColor: Colors.transparent,
                  floatingActionButton: _isSystemTemplate(activeTemplate)
                      ? null
                      : Container(
                          height: 56,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: const LinearGradient(
                              colors: [Color(0xFF3A86FF), Color(0xFF3A86FF)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF3A86FF).withOpacity(0.2),
                                blurRadius: 30,
                                offset: const Offset(0, 5),
                                spreadRadius: 0,
                              ),
                            ],
                            border: Border.all(
                                color: Colors.white.withOpacity(0.25),
                                width: 1.5),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () =>
                                  _showEntrySheet(activeTemplate, records),
                              borderRadius: BorderRadius.circular(12),
                              splashColor: Colors.white.withOpacity(0.2),
                              highlightColor: Colors.white.withOpacity(0.1),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(1),
                                      decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.2),
                                          shape: BoxShape.circle),
                                      child: const Icon(Icons.add,
                                          color: Colors.white, size: 20),
                                    ),
                                    const SizedBox(width: 12),
                                    const Text('New Entry',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 12,
                                            letterSpacing: 1)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                  body: Builder(
                    builder: (context) {
                      if (recordSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(
                            child: FuturisticLoader(
                                size: 80, label: "COMPILING ROW DATA..."));
                      }

                      if (recordSnapshot.hasError) {
                        return Center(
                            child: Text("Error: ${recordSnapshot.error}",
                                style: const TextStyle(color: Colors.red)));
                      }

                      Map<String, double> totals = {};

                      if (activeTemplate.name != "Investment Portfolio") {
                        for (var field in activeTemplate.fields) {
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
                      }

                      return ListView(
                        padding: const EdgeInsets.fromLTRB(0, 16, 0, 100),
                        children: [
                          Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: _glassColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: Colors.white.withOpacity(0.05)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "${records.length} Records",
                                  style: TextStyle(
                                      color: Colors.white.withOpacity(0.5),
                                      fontWeight: FontWeight.bold),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      onPressed: () => _showExportOptions(
                                          activeTemplate, records, totals),
                                      icon: const Icon(Icons.ios_share_rounded,
                                          color: Colors.white70, size: 20),
                                      tooltip: 'Export',
                                    ),
                                    IconButton(
                                      onPressed: () => _showFilterSheet(
                                          activeTemplate, rawRecords),
                                      icon: Icon(
                                        _activeFilters.isNotEmpty
                                            ? Icons.filter_alt
                                            : Icons.filter_alt_outlined,
                                        color: _activeFilters.isNotEmpty
                                            ? _accentColor
                                            : Colors.white70,
                                      ),
                                      tooltip: 'Filter Table',
                                    ),
                                    IconButton(
                                      onPressed: () =>
                                          _editTemplate(activeTemplate),
                                      icon: const Icon(
                                          Icons.settings_suggest_outlined,
                                          color: Colors.white70),
                                      tooltip: 'Edit Structure',
                                    ),
                                    IconButton(
                                      onPressed: () =>
                                          _deleteSheet(activeTemplate),
                                      icon: const Icon(Icons.delete_outline,
                                          color: Colors.redAccent),
                                      tooltip: 'Delete Sheet',
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          if (activeTemplate.xAxisField != null &&
                              activeTemplate.yAxisField != null &&
                              records.isNotEmpty) ...[
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: TextButton.icon(
                                  onPressed: () =>
                                      _configureChart(activeTemplate),
                                  icon:
                                      const Icon(Icons.tune_rounded, size: 16),
                                  label: const Text("Configure Chart"),
                                  style: TextButton.styleFrom(
                                    foregroundColor: _accentColor,
                                    textStyle: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold),
                                    visualDensity: VisualDensity.compact,
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              height: 250,
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              padding: const EdgeInsets.only(
                                  right: 16, top: 24, bottom: 8),
                              decoration: BoxDecoration(
                                color: _glassColor,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: Colors.white.withOpacity(0.05)),
                              ),
                              child: CustomDataChart(
                                records: records,
                                xKey: activeTemplate.xAxisField!,
                                yKey: activeTemplate.yAxisField!,
                              ),
                            ),
                            const SizedBox(height: 24),
                          ] else if (records.isNotEmpty) ...[
                            Align(
                              alignment: Alignment.centerRight,
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(right: 16, bottom: 8),
                                child: TextButton.icon(
                                  onPressed: () =>
                                      _configureChart(activeTemplate),
                                  icon: const Icon(Icons.bar_chart, size: 18),
                                  label: const Text('Add Chart'),
                                  style: TextButton.styleFrom(
                                      foregroundColor: _accentColor),
                                ),
                              ),
                            ),
                          ],
                          if (rawRecords.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              child: Container(
                                height: 45,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: Colors.white.withOpacity(0.1)),
                                ),
                                child: TextField(
                                  controller: _quickSearchController,
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 14),
                                  onChanged: (val) =>
                                      setState(() => _quickSearchQuery = val),
                                  decoration: InputDecoration(
                                    hintText: "Quick search any field...",
                                    hintStyle: TextStyle(
                                        color: Colors.white.withOpacity(0.3),
                                        fontSize: 14),
                                    prefixIcon: Icon(Icons.search,
                                        color: Colors.white.withOpacity(0.3),
                                        size: 20),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 12),
                                    suffixIcon: _quickSearchQuery.isNotEmpty
                                        ? IconButton(
                                            icon: const Icon(Icons.close,
                                                color: Colors.white54,
                                                size: 18),
                                            onPressed: () {
                                              _quickSearchController.clear();
                                              setState(
                                                  () => _quickSearchQuery = "");
                                            },
                                          )
                                        : null,
                                  ),
                                ),
                              ),
                            ),
                          if (records.isNotEmpty)
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: _glassColor,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                      color: Colors.white.withOpacity(0.05)),
                                ),
                                child: DataTable(
                                  sortColumnIndex: _sortColumnIndex,
                                  sortAscending: _sortAscending,
                                  headingRowColor: MaterialStateProperty.all(
                                      Colors.white.withOpacity(0.05)),
                                  dataRowColor: MaterialStateProperty.all(
                                      Colors.transparent),
                                  columnSpacing: 24.0,
                                  horizontalMargin: 20,
                                  dividerThickness: 0.5,
                                  border: TableBorder(
                                      horizontalInside: BorderSide(
                                          color: Colors.white.withOpacity(0.05),
                                          width: 1)),
                                  columns: [
                                    ...activeTemplate.fields
                                        .asMap()
                                        .entries
                                        .map((entry) {
                                      int index = entry.key;
                                      var f = entry.value;
                                      // --- [NEW] Check if this column is the active sort ---
                                      bool isSortedColumn =
                                          _sortColumnIndex == index;

                                      return DataColumn(
                                        tooltip: "Tap to sort",
                                        onSort: (columnIndex, ascending) {
                                          setState(() {
                                            _sortColumnIndex = columnIndex;
                                            _sortAscending = ascending;
                                          });
                                        },
                                        label: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              f.name.toUpperCase(),
                                              style: TextStyle(
                                                  color: _accentColor,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12),
                                            ),
                                            // --- [NEW] Add subtle icon for unsorted columns to indicate they are clickable ---
                                            if (!isSortedColumn) ...[
                                              const SizedBox(width: 4),
                                              Icon(Icons.unfold_more_rounded,
                                                  size: 14,
                                                  color: _accentColor
                                                      .withOpacity(0.5)),
                                            ]
                                          ],
                                        ),
                                      );
                                    }),
                                    const DataColumn(label: Text('')),
                                  ],
                                  rows: [
                                    ...records.map((r) {
                                      bool isStale =
                                          _isRowStale(r, activeTemplate);
                                      return DataRow(
                                        color: isStale
                                            ? MaterialStateProperty.all(
                                                Colors.amber.withOpacity(0.1))
                                            : null,
                                        cells: [
                                          ...activeTemplate.fields.map((f) {
                                            final val = r.data[f.name];
                                            String display = '-';
                                            if (val != null) {
                                              if (f.type ==
                                                  CustomFieldType.date) {
                                                final dt = _tryParseDate(val);
                                                if (dt != null) {
                                                  display =
                                                      DateFormat('dd MMM yyyy')
                                                          .format(dt);
                                                } else {
                                                  display = val.toString();
                                                }
                                              } else if (f.type ==
                                                  CustomFieldType.currency) {
                                                double numVal = 0.0;
                                                if (val is num) {
                                                  numVal = val.toDouble();
                                                } else if (val is String) {
                                                  numVal =
                                                      double.tryParse(val) ??
                                                          0.0;
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
                                                f.type ==
                                                    CustomFieldType.formula;

                                            return DataCell(
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(display,
                                                      style: TextStyle(
                                                          color: highlightCell
                                                              ? Colors
                                                                  .amberAccent
                                                              : Colors
                                                                  .white70)),
                                                  if (highlightCell) ...[
                                                    const SizedBox(width: 4),
                                                    const Icon(
                                                        Icons
                                                            .warning_amber_rounded,
                                                        size: 14,
                                                        color: Colors.amber),
                                                  ],
                                                ],
                                              ),
                                            );
                                          }),
                                          DataCell(
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                if (!_isSystemTemplate(
                                                    activeTemplate)) ...[
                                                  IconButton(
                                                    icon: const Icon(Icons.edit,
                                                        size: 16,
                                                        color: Colors.white54),
                                                    onPressed: () =>
                                                        _showEntrySheet(
                                                            activeTemplate,
                                                            records,
                                                            r),
                                                    padding: EdgeInsets.zero,
                                                    constraints:
                                                        const BoxConstraints(),
                                                  ),
                                                  const SizedBox(width: 12),
                                                ],
                                                IconButton(
                                                  icon: const Icon(Icons.delete,
                                                      size: 16,
                                                      color: Colors.redAccent),
                                                  onPressed: () =>
                                                      _deleteRecord(r.id),
                                                  padding: EdgeInsets.zero,
                                                  constraints:
                                                      const BoxConstraints(),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      );
                                    }),
                                    if (totals.isNotEmpty &&
                                        !_isSystemTemplate(activeTemplate))
                                      DataRow(
                                        cells: [
                                          ...activeTemplate.fields.map((f) {
                                            if (totals.containsKey(f.name)) {
                                              String amount = totals[f.name]!
                                                  .toStringAsFixed(2);
                                              if (f.type ==
                                                  CustomFieldType.currency) {
                                                amount =
                                                    '${f.currencySymbol ?? '₹'}$amount';
                                              }
                                              return DataCell(
                                                Text(amount,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: _accentColor,
                                                        fontSize: 13)),
                                              );
                                            } else if (f ==
                                                activeTemplate.fields.first) {
                                              return const DataCell(
                                                Text('TOTAL',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.white,
                                                        fontSize: 11)),
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
                                    Icon(Icons.filter_list_off,
                                        size: 48,
                                        color: Colors.white.withOpacity(0.1)),
                                    const SizedBox(height: 16),
                                    Text("No matching records found",
                                        style: TextStyle(
                                            color:
                                                Colors.white.withOpacity(0.3))),
                                    if (_activeFilters.isNotEmpty ||
                                        _quickSearchQuery.isNotEmpty)
                                      TextButton(
                                        onPressed: () {
                                          setState(() {
                                            _activeFilters.clear();
                                            _quickSearchController.clear();
                                            _quickSearchQuery = "";
                                          });
                                        },
                                        child: Text("Clear Search & Filters",
                                            style:
                                                TextStyle(color: _accentColor)),
                                      )
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
          },
        ),
        if (_isExporting)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.90),
              child: Center(
                child: Material(
                  color: Colors.transparent,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const FuturisticLoader(),
                      const SizedBox(height: 32),
                      Text(
                        _exportMessage,
                        style: const TextStyle(
                            color: Colors.cyanAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            letterSpacing: 2),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
