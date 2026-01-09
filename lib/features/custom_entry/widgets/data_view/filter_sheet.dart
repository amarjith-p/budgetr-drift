import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/models/custom_data_models.dart';
import '../../../../core/widgets/modern_dropdown.dart';
import '../../utils/filter_engine.dart';

class FilterSheet extends StatefulWidget {
  final CustomTemplate template;
  final List<FilterCondition> activeFilters;
  final Function(List<FilterCondition>) onApply;

  const FilterSheet({
    super.key,
    required this.template,
    required this.activeFilters,
    required this.onApply,
  });

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  // Staging area for filters before applying
  late List<FilterCondition> _filters;
  CustomFieldConfig? _selectedField; // Which column are we editing right now?

  // Controllers for inputs
  final TextEditingController _textCtrl = TextEditingController();
  final TextEditingController _minCtrl = TextEditingController();
  final TextEditingController _maxCtrl = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  List<String> _selectedDropdownOptions = [];

  @override
  void initState() {
    super.initState();
    _filters = List.from(widget.activeFilters);
  }

  void _selectField(CustomFieldConfig field) {
    setState(() {
      _selectedField = field;
      // Load existing values if filter exists
      final existing = _filters.firstWhere(
        (f) => f.fieldName == field.name,
        orElse: () =>
            FilterCondition(fieldName: '', type: CustomFieldType.string),
      );

      if (existing.fieldName.isNotEmpty) {
        _textCtrl.text = existing.textQuery ?? '';
        _minCtrl.text = existing.minVal?.toString() ?? '';
        _maxCtrl.text = existing.maxVal?.toString() ?? '';
        _startDate = existing.startDate;
        _endDate = existing.endDate;
        _selectedDropdownOptions = List.from(existing.selectedOptions ?? []);
      } else {
        _clearInputs();
      }
    });
  }

  void _clearInputs() {
    _textCtrl.clear();
    _minCtrl.clear();
    _maxCtrl.clear();
    _startDate = null;
    _endDate = null;
    _selectedDropdownOptions = [];
  }

  void _saveCurrentFieldFilter() {
    if (_selectedField == null) return;

    // Remove old filter for this field
    _filters.removeWhere((f) => f.fieldName == _selectedField!.name);

    // Create new filter
    final newFilter = FilterCondition(
      fieldName: _selectedField!.name,
      type: _selectedField!.type,
      textQuery: _textCtrl.text.isNotEmpty ? _textCtrl.text : null,
      minVal: double.tryParse(_minCtrl.text),
      maxVal: double.tryParse(_maxCtrl.text),
      startDate: _startDate,
      endDate: _endDate,
      selectedOptions:
          _selectedDropdownOptions.isNotEmpty ? _selectedDropdownOptions : null,
    );

    // Only add if it actually has criteria
    bool hasCriteria = newFilter.textQuery != null ||
        newFilter.minVal != null ||
        newFilter.maxVal != null ||
        newFilter.startDate != null ||
        newFilter.endDate != null ||
        newFilter.selectedOptions != null;

    if (hasCriteria) {
      setState(() {
        _filters.add(newFilter);
        _selectedField = null; // Go back to list
      });
    } else {
      setState(() => _selectedField = null);
    }
  }

  void _removeFilter(String fieldName) {
    setState(() {
      _filters.removeWhere((f) => f.fieldName == fieldName);
    });
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = const Color(0xff0D1B2A);
    final accentColor = const Color(0xFF3A86FF);

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _selectedField == null
                    ? "Filters"
                    : "Filter: ${_selectedField!.name}",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (_selectedField != null)
                TextButton(
                  onPressed: () => setState(() => _selectedField = null),
                  child: const Text("Back",
                      style: TextStyle(color: Colors.white54)),
                )
              else
                TextButton(
                  onPressed: () {
                    setState(() => _filters.clear());
                    widget.onApply([]);
                    Navigator.pop(context);
                  },
                  child: const Text("Clear All",
                      style: TextStyle(color: Colors.redAccent)),
                ),
            ],
          ),
          const Divider(color: Colors.white10),

          // Body
          Expanded(
            child: _selectedField == null
                ? _buildColumnList(accentColor)
                : _buildFilterEditor(accentColor),
          ),

          // Footer
          if (_selectedField == null)
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  widget.onApply(_filters);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Text("Apply Filters (${_filters.length})",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            )
          else
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _saveCurrentFieldFilter,
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Set Filter",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildColumnList(Color accentColor) {
    return ListView.builder(
      itemCount: widget.template.fields.length,
      itemBuilder: (context, index) {
        final field = widget.template.fields[index];
        final isActive = _filters.any((f) => f.fieldName == field.name);

        return ListTile(
          onTap: () => _selectField(field),
          contentPadding: EdgeInsets.zero,
          title: Text(field.name, style: const TextStyle(color: Colors.white)),
          leading: Icon(
            _getIconForType(field.type),
            color: isActive ? accentColor : Colors.white24,
          ),
          trailing: isActive
              ? IconButton(
                  icon: const Icon(Icons.close,
                      color: Colors.redAccent, size: 18),
                  onPressed: () => _removeFilter(field.name),
                )
              : const Icon(Icons.arrow_forward_ios,
                  color: Colors.white24, size: 14),
        );
      },
    );
  }

  Widget _buildFilterEditor(Color accentColor) {
    final type = _selectedField!.type;

    if (type == CustomFieldType.string || type == CustomFieldType.serial) {
      return Column(
        children: [
          const Text("Records containing:",
              style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 12),
          TextField(
            controller: _textCtrl,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "Enter search text...",
              hintStyle: const TextStyle(color: Colors.white24),
              filled: true,
              fillColor: Colors.white.withOpacity(0.05),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none),
            ),
          ),
        ],
      );
    }

    if (type == CustomFieldType.number ||
        type == CustomFieldType.currency ||
        type == CustomFieldType.formula) {
      return Column(
        children: [
          const Text("Value Range:", style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _minCtrl,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "Min",
                    labelStyle: const TextStyle(color: Colors.white54),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.05),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: _maxCtrl,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "Max",
                    labelStyle: const TextStyle(color: Colors.white54),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.05),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    }

    if (type == CustomFieldType.date) {
      return Column(
        children: [
          const Text("Date Range:", style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 12),
          _buildDateButton(
              "Start Date", _startDate, (d) => setState(() => _startDate = d)),
          const SizedBox(height: 12),
          _buildDateButton(
              "End Date", _endDate, (d) => setState(() => _endDate = d)),
        ],
      );
    }

    if (type == CustomFieldType.dropdown) {
      final options = _selectedField!.dropdownOptions ?? [];
      return ListView(
        children: options.map((opt) {
          final isSelected = _selectedDropdownOptions.contains(opt);
          return CheckboxListTile(
            title: Text(opt, style: const TextStyle(color: Colors.white)),
            value: isSelected,
            activeColor: accentColor,
            checkColor: Colors.white,
            onChanged: (val) {
              setState(() {
                if (val == true) {
                  _selectedDropdownOptions.add(opt);
                } else {
                  _selectedDropdownOptions.remove(opt);
                }
              });
            },
          );
        }).toList(),
      );
    }

    return const Center(
        child: Text("Filtering not supported for this type",
            style: TextStyle(color: Colors.white54)));
  }

  Widget _buildDateButton(
      String label, DateTime? val, Function(DateTime) onSelect) {
    return InkWell(
      onTap: () async {
        final d = await showDatePicker(
          context: context,
          initialDate: val ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
          builder: (context, child) => Theme(
              data: Theme.of(context).copyWith(
                  colorScheme: const ColorScheme.dark(
                      primary: Color(0xFF3A86FF), surface: Color(0xFF1B263B))),
              child: child!),
        );
        if (d != null) onSelect(d);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(val == null ? label : DateFormat('dd MMM yyyy').format(val),
                style: TextStyle(
                    color: val == null ? Colors.white54 : Colors.white)),
            const Icon(Icons.calendar_today, color: Colors.white54, size: 16),
          ],
        ),
      ),
    );
  }

  IconData _getIconForType(CustomFieldType type) {
    switch (type) {
      case CustomFieldType.string:
        return Icons.text_fields;
      case CustomFieldType.number:
        return Icons.dialpad;
      case CustomFieldType.date:
        return Icons.calendar_month;
      case CustomFieldType.currency:
        return Icons.currency_rupee;
      case CustomFieldType.dropdown:
        return Icons.list_alt;
      case CustomFieldType.serial:
        return Icons.tag;
      case CustomFieldType.formula:
        return Icons.functions;
    }
  }
}
