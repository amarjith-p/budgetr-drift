import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../../core/design/budgetr_colors.dart';
import '../../../core/design/budgetr_styles.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/modern_loader.dart';
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
          // Select first table by default if available
          if (tables.isNotEmpty) {
            _selectedTable = tables.first;
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
    });

    try {
      final data = await _service.getTableData(tableName);

      List<String> cols = [];
      if (data.isNotEmpty) {
        cols = data.first.keys.toList();
      }

      if (mounted) {
        setState(() {
          _currentData = data;
          _columns = cols;
          _isLoadingData = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingData = false);
    }
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
                                  columns: _columns.map((col) {
                                    return DataColumn(
                                      label: Text(
                                        col,
                                        style: const TextStyle(
                                          color: BudgetrColors.accent,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                  rows: _currentData.map((row) {
                                    return DataRow(
                                      cells: _columns.map((col) {
                                        final val = row[col];
                                        return DataCell(
                                          Text(
                                            val?.toString() ?? 'NULL',
                                            style: const TextStyle(
                                                color: Colors.white70,
                                                fontSize: 13),
                                          ),
                                        );
                                      }).toList(),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                ),

                // Footer Stats
                if (!_isLoadingData && _currentData.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    color: Colors.black26,
                    child: Text(
                      "${_currentData.length} records found",
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
