import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../../core/design/budgetr_colors.dart';
import '../../../core/design/budgetr_styles.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/modern_loader.dart';
import '../../../core/widgets/status_bottom_sheet.dart'; // Re-use your status sheet
import '../services/database_viewer_service.dart';

class DatabaseViewerScreen extends StatefulWidget {
  const DatabaseViewerScreen({super.key});

  @override
  State<DatabaseViewerScreen> createState() => _DatabaseViewerScreenState();
}

class _DatabaseViewerScreenState extends State<DatabaseViewerScreen> {
  final DatabaseViewerService _service = GetIt.I<DatabaseViewerService>();

  List<String> _tables = [];
  String? _selectedTable;
  String? _primaryKeyCol; // Store the detected PK column name

  bool _isLoadingTables = true;
  bool _isLoadingData = false;

  List<Map<String, dynamic>> _currentData = [];
  List<String> _columns = [];

  @override
  void initState() {
    super.initState();
    _loadTables();
  }

  Future<void> _loadTables() async {
    try {
      final tables = await _service.getAllTableNames();
      if (mounted) {
        setState(() {
          _tables = tables;
          _isLoadingTables = false;
          if (tables.isNotEmpty) {
            _loadTableData(tables.first);
          }
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingTables = false);
    }
  }

  Future<void> _loadTableData(String tableName) async {
    setState(() {
      _selectedTable = tableName;
      _isLoadingData = true;
      _currentData = [];
      _columns = [];
      _primaryKeyCol = null;
    });

    try {
      // 1. Get Data
      final data = await _service.getTableData(tableName);
      // 2. Get Primary Key (Essential for Edit/Delete)
      final pk = await _service.getPrimaryKeyColumn(tableName);

      List<String> cols = [];
      if (data.isNotEmpty) {
        cols = data.first.keys.toList();
      }

      if (mounted) {
        setState(() {
          _currentData = data;
          _columns = cols;
          _primaryKeyCol = pk;
          _isLoadingData = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading table: $e");
      if (mounted) setState(() => _isLoadingData = false);
    }
  }

  // --- ACTIONS ---

  Future<void> _deleteRow(Map<String, dynamic> row) async {
    if (_primaryKeyCol == null) {
      _showError("Cannot delete: No Primary Key found for this table.");
      return;
    }

    final pkVal = row[_primaryKeyCol];

    showStatusSheet(
      context: context,
      title: "Delete Row?",
      message:
          "Are you sure you want to delete the record where $_primaryKeyCol = $pkVal?",
      icon: Icons.delete_forever_rounded,
      color: BudgetrColors.error,
      buttonText: "Delete",
      cancelButtonText: "Cancel",
      onDismiss: () async {
        try {
          await _service.deleteRow(_selectedTable!, _primaryKeyCol!, pkVal);
          _showSuccess("Row deleted");
          _loadTableData(_selectedTable!); // Refresh
        } catch (e) {
          _showError("Delete failed: $e");
        }
      },
    );
  }

  Future<void> _editRow(Map<String, dynamic> row) async {
    if (_primaryKeyCol == null) {
      _showError("Cannot edit: No Primary Key found.");
      return;
    }

    // We'll collect controllers to retrieve values later
    final Map<String, TextEditingController> controllers = {};

    // Create a controller for each column, pre-filled with current value
    for (var col in _columns) {
      controllers[col] =
          TextEditingController(text: row[col]?.toString() ?? '');
    }

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: BudgetrColors.cardSurface,
        title: Text("Edit Row", style: BudgetrStyles.h3),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: _columns.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final colName = _columns[index];
              final isPk = colName == _primaryKeyCol;

              return TextField(
                controller: controllers[colName],
                enabled: !isPk, // Disable editing of Primary Key
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: colName + (isPk ? " (PK - Locked)" : ""),
                  labelStyle: TextStyle(
                      color: isPk ? Colors.white38 : BudgetrColors.accent),
                  enabledBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.white.withOpacity(0.3)),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: BudgetrColors.accent),
                  ),
                  filled: true,
                  fillColor: Colors.black12,
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: BudgetrColors.accent),
            onPressed: () async {
              Navigator.pop(ctx);
              _saveEdits(row[_primaryKeyCol], controllers);
            },
            child: const Text("Save Changes",
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _saveEdits(dynamic originalPkValue,
      Map<String, TextEditingController> controllers) async {
    final Map<String, dynamic> updates = {};

    // Basic type inference (everything from TextField is String)
    // In a real generic editor, type handling is complex.
    // Here we try to map back to original types if possible or strictly save as string/int.

    controllers.forEach((col, controller) {
      if (col == _primaryKeyCol) return; // Don't include PK in updates
      updates[col] = controller.text;
    });

    try {
      await _service.updateRow(
          _selectedTable!, _primaryKeyCol!, originalPkValue, updates);
      _showSuccess("Row updated");
      _loadTableData(_selectedTable!);
    } catch (e) {
      _showError("Update failed: $e");
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: BudgetrColors.error),
    );
  }

  void _showSuccess(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: BudgetrColors.success),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BudgetrColors.background,
      appBar: AppBar(
        title: const Text("Database Viewer"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoadingTables
          ? const Center(child: ModernLoader())
          : Column(
              children: [
                // 1. Selector Area
                Container(
                  padding: const EdgeInsets.all(16),
                  color: BudgetrColors.cardSurface.withOpacity(0.5),
                  child: Row(
                    children: [
                      const Text("Table: ",
                          style: TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedTable,
                              dropdownColor: BudgetrColors.cardSurface,
                              isExpanded: true,
                              icon: const Icon(Icons.arrow_drop_down,
                                  color: BudgetrColors.accent),
                              style: const TextStyle(color: Colors.white),
                              items: _tables.map((table) {
                                return DropdownMenuItem(
                                  value: table,
                                  child: Text(table),
                                );
                              }).toList(),
                              onChanged: (val) {
                                if (val != null) _loadTableData(val);
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        icon: const Icon(Icons.refresh,
                            color: BudgetrColors.accent),
                        onPressed: () => _selectedTable != null
                            ? _loadTableData(_selectedTable!)
                            : _loadTables(),
                      ),
                    ],
                  ),
                ),

                // 2. Data Area
                Expanded(
                  child: _isLoadingData
                      ? const Center(child: ModernLoader())
                      : _currentData.isEmpty
                          ? Center(
                              child: Text(
                                _selectedTable == null
                                    ? "Select a table"
                                    : "Table is empty",
                                style: const TextStyle(color: Colors.white24),
                              ),
                            )
                          : SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: DataTable(
                                  headingRowColor: WidgetStateProperty.all(
                                      Colors.white.withOpacity(0.05)),
                                  dataRowColor: WidgetStateProperty.all(
                                      Colors.transparent),
                                  dividerThickness: 0.5,
                                  horizontalMargin: 20,
                                  columnSpacing: 30,
                                  border: TableBorder(
                                    horizontalInside: BorderSide(
                                        color: Colors.white.withOpacity(0.1),
                                        width: 0.5),
                                  ),
                                  columns: [
                                    const DataColumn(
                                        label: Text("ACTIONS",
                                            style: TextStyle(
                                                color: BudgetrColors.warning,
                                                fontWeight: FontWeight.bold))),
                                    ..._columns.map((col) {
                                      final isPk = col == _primaryKeyCol;
                                      return DataColumn(
                                        label: Text(
                                          col + (isPk ? "*" : ""),
                                          style: TextStyle(
                                            color: isPk
                                                ? BudgetrColors.success
                                                : BudgetrColors.accent,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      );
                                    }),
                                  ],
                                  rows: _currentData.map((row) {
                                    return DataRow(
                                      cells: [
                                        // ACTION CELL
                                        DataCell(
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                icon: const Icon(Icons.edit,
                                                    color: BudgetrColors.accent,
                                                    size: 20),
                                                onPressed: () => _editRow(row),
                                                tooltip: "Edit Row",
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.delete,
                                                    color: BudgetrColors.error,
                                                    size: 20),
                                                onPressed: () =>
                                                    _deleteRow(row),
                                                tooltip: "Delete Row",
                                              ),
                                            ],
                                          ),
                                        ),
                                        // DATA CELLS
                                        ..._columns.map((col) {
                                          final val = row[col];
                                          return DataCell(
                                            Text(
                                              val?.toString() ?? 'NULL',
                                              style: const TextStyle(
                                                  color: Colors.white70,
                                                  fontSize: 13),
                                            ),
                                          );
                                        }),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                ),

                // Footer
                if (!_isLoadingData && _currentData.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    color: Colors.black26,
                    child: Text(
                      "${_currentData.length} records • Primary Key: ${_primaryKeyCol ?? 'None'}",
                      textAlign: TextAlign.center,
                      style:
                          const TextStyle(color: Colors.white38, fontSize: 12),
                    ),
                  ),
              ],
            ),
    );
  }
}
