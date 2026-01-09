import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/models/custom_data_models.dart';
import '../../utils/filter_engine.dart';

class FilterSheet extends StatefulWidget {
  final CustomTemplate template;
  final List<FilterCondition> activeFilters;
  final List<CustomRecord> sourceData; // NEW: Data for suggestions
  final Function(List<FilterCondition>) onApply;

  const FilterSheet({
    super.key,
    required this.template,
    required this.activeFilters,
    required this.sourceData,
    required this.onApply,
  });

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  late Map<String, FilterCondition> _stagingFilters;
  final Color _bgColor = const Color(0xff0D1B2A);
  final Color _accentColor = const Color(0xFF3A86FF);
  final Color _surfaceColor = const Color(0xFF1B263B);

  @override
  void initState() {
    super.initState();
    _stagingFilters = {
      for (var f in widget.activeFilters) f.fieldName: f,
    };
  }

  void _updateFilter(FilterCondition condition) {
    setState(() {
      if (condition.hasCriteria) {
        _stagingFilters[condition.fieldName] = condition;
      } else {
        _stagingFilters.remove(condition.fieldName);
      }
    });
  }

  void _clearAll() {
    setState(() {
      _stagingFilters.clear();
    });
  }

  void _apply() {
    widget.onApply(_stagingFilters.values.toList());
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    int activeCount = _stagingFilters.length;
    final double bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomPadding),
        child: Column(
          children: [
            // --- HEADER ---
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Filter Data",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        activeCount == 0
                            ? "No active filters"
                            : "$activeCount filters active",
                        style: TextStyle(
                          color:
                              activeCount > 0 ? _accentColor : Colors.white54,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: _clearAll,
                    child: const Text(
                      "Clear All",
                      style: TextStyle(color: Colors.redAccent),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Colors.white10),

            // --- LIST ---
            Expanded(
              child: ListView.builder(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: widget.template.fields.length,
                itemBuilder: (context, index) {
                  final field = widget.template.fields[index];
                  final activeCondition = _stagingFilters[field.name];

                  return _FilterRow(
                    key: ValueKey(field.name),
                    field: field,
                    initialCondition: activeCondition,
                    sourceData: widget.sourceData, // Pass data
                    accentColor: _accentColor,
                    surfaceColor: _surfaceColor,
                    onChanged: _updateFilter,
                  );
                },
              ),
            ),

            // --- FOOTER ---
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: _apply,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _accentColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    "Apply Filters",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- ROW WIDGET ---

class _FilterRow extends StatefulWidget {
  final CustomFieldConfig field;
  final FilterCondition? initialCondition;
  final List<CustomRecord> sourceData;
  final Color accentColor;
  final Color surfaceColor;
  final Function(FilterCondition) onChanged;

  const _FilterRow({
    super.key,
    required this.field,
    this.initialCondition,
    required this.sourceData,
    required this.accentColor,
    required this.surfaceColor,
    required this.onChanged,
  });

  @override
  State<_FilterRow> createState() => _FilterRowState();
}

class _FilterRowState extends State<_FilterRow> {
  late FilterCondition _condition;

  // Controllers
  late TextEditingController _textCtrl;
  late TextEditingController _minCtrl;
  late TextEditingController _maxCtrl;

  // Focus Nodes
  final FocusNode _textFocus = FocusNode();
  final FocusNode _minFocus = FocusNode();
  final FocusNode _maxFocus = FocusNode();

  // Suggestions
  List<String> _allUniqueValues = [];
  List<String> _filteredSuggestions = [];

  @override
  void initState() {
    super.initState();
    _initCondition();
    _initControllers();
    _extractSuggestions(); // Pre-calculate unique values

    _textFocus.addListener(_onFocusChange);
    _minFocus.addListener(_onFocusChange);
    _maxFocus.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (_textFocus.hasFocus || _minFocus.hasFocus || _maxFocus.hasFocus) {
      _scrollToVisible();
    }
  }

  Future<void> _scrollToVisible() async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    try {
      Scrollable.ensureVisible(
        context,
        alignment: 0.5,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } catch (e) {
      // ignore
    }
  }

  void _initCondition() {
    _condition = widget.initialCondition ??
        FilterCondition(
          fieldName: widget.field.name,
          type: widget.field.type,
        );
  }

  void _initControllers() {
    _textCtrl = TextEditingController(text: _condition.textQuery);
    _minCtrl = TextEditingController(
      text: _condition.minVal != null ? _truncateZeros(_condition.minVal!) : '',
    );
    _maxCtrl = TextEditingController(
      text: _condition.maxVal != null ? _truncateZeros(_condition.maxVal!) : '',
    );

    // Initial filter of suggestions
    _filterSuggestions(_textCtrl.text);
  }

  // --- NEW: Extract Unique Values ---
  void _extractSuggestions() {
    if (widget.field.type == CustomFieldType.string ||
        widget.field.type == CustomFieldType.serial) {
      final Set<String> unique = {};
      for (var r in widget.sourceData) {
        final val = r.data[widget.field.name];
        if (val != null && val.toString().trim().isNotEmpty) {
          unique.add(val.toString().trim());
        }
      }
      _allValues = unique.toList()..sort();
    }
  }

  List<String> _allValues = [];

  // --- NEW: Filter Suggestions Logic ---
  void _filterSuggestions(String query) {
    if (_allValues.isEmpty) return;

    setState(() {
      if (query.isEmpty) {
        // Show first 10
        _filteredSuggestions = _allValues.take(10).toList();
      } else {
        // Show matches
        _filteredSuggestions = _allValues
            .where((s) => s.toLowerCase().contains(query.toLowerCase()))
            .take(10)
            .toList();
      }
    });
  }

  @override
  void didUpdateWidget(_FilterRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialCondition == null && _condition.hasCriteria) {
      setState(() {
        _condition = FilterCondition(
          fieldName: widget.field.name,
          type: widget.field.type,
        );
        _textCtrl.clear();
        _minCtrl.clear();
        _maxCtrl.clear();
        _filterSuggestions('');
      });
    }
  }

  String _truncateZeros(double val) {
    return val.toStringAsFixed(2).replaceAll(RegExp(r"([.]*0+)(?!.*\d)"), "");
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    _minCtrl.dispose();
    _maxCtrl.dispose();
    _textFocus.dispose();
    _minFocus.dispose();
    _maxFocus.dispose();
    super.dispose();
  }

  void _emitChange() {
    widget.onChanged(_condition);
  }

  @override
  Widget build(BuildContext context) {
    final isActive = _condition.hasCriteria;
    final summary = isActive ? _condition.summary : "No filter";

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: ExpansionTile(
            backgroundColor: widget.surfaceColor,
            collapsedBackgroundColor: isActive
                ? widget.accentColor.withOpacity(0.1)
                : Colors.transparent,
            maintainState: true,
            title: Text(
              widget.field.name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isActive ? widget.accentColor : Colors.white,
              ),
            ),
            subtitle: Text(
              summary,
              style: TextStyle(
                color: isActive
                    ? widget.accentColor.withOpacity(0.7)
                    : Colors.white38,
                fontSize: 12,
              ),
            ),
            leading: Icon(
              _getIconForType(widget.field.type),
              color: isActive ? widget.accentColor : Colors.white24,
            ),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            children: [
              _buildEditor(),
            ],
            onExpansionChanged: (expanded) {
              if (expanded) {
                _scrollToVisible();
              }
            },
          ),
        ),
      ),
    );
  }

  Widget _buildEditor() {
    final type = widget.field.type;

    if (type == CustomFieldType.string || type == CustomFieldType.serial) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _textCtrl,
            focusNode: _textFocus,
            style: const TextStyle(color: Colors.white),
            decoration: _inputDeco("Search text..."),
            onChanged: (val) {
              _condition = _condition.copyWith(
                textQuery: val,
                clearText: val.isEmpty,
              );
              _filterSuggestions(val);
              _emitChange();
            },
          ),
          if (_filteredSuggestions.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Text("Suggestions:",
                style: TextStyle(color: Colors.white24, fontSize: 11)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _filteredSuggestions.map((s) {
                return InkWell(
                  onTap: () {
                    _textCtrl.text = s;
                    _condition = _condition.copyWith(textQuery: s);
                    _filterSuggestions(s);
                    _emitChange();
                    FocusManager.instance.primaryFocus?.unfocus();
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Text(
                      s,
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      );
    }

    if (type == CustomFieldType.number ||
        type == CustomFieldType.currency ||
        type == CustomFieldType.formula) {
      return Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: _minCtrl,
              focusNode: _minFocus,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDeco("Min"),
              onChanged: (val) {
                _condition = _condition.copyWith(
                  minVal: double.tryParse(val),
                  clearMin: val.isEmpty,
                );
                _emitChange();
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextFormField(
              controller: _maxCtrl,
              focusNode: _maxFocus,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDeco("Max"),
              onChanged: (val) {
                _condition = _condition.copyWith(
                  maxVal: double.tryParse(val),
                  clearMax: val.isEmpty,
                );
                _emitChange();
              },
            ),
          ),
        ],
      );
    }

    if (type == CustomFieldType.date) {
      return Row(
        children: [
          Expanded(
              child: _buildDateBtn("Start Date", _condition.startDate, true)),
          const SizedBox(width: 12),
          Expanded(child: _buildDateBtn("End Date", _condition.endDate, false)),
        ],
      );
    }

    if (type == CustomFieldType.dropdown) {
      final options = widget.field.dropdownOptions ?? [];
      final selected = _condition.selectedOptions ?? [];
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: options.map((opt) {
          final isSelected = selected.contains(opt);
          return FilterChip(
            label: Text(opt),
            selected: isSelected,
            backgroundColor: Colors.white.withOpacity(0.05),
            selectedColor: widget.accentColor.withOpacity(0.2),
            checkmarkColor: widget.accentColor,
            labelStyle: TextStyle(
              color: isSelected ? widget.accentColor : Colors.white70,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: isSelected
                    ? widget.accentColor.withOpacity(0.5)
                    : Colors.transparent,
              ),
            ),
            onSelected: (val) {
              List<String> newSelected = List.from(selected);
              if (val) {
                newSelected.add(opt);
              } else {
                newSelected.remove(opt);
              }
              setState(() {
                _condition = _condition.copyWith(
                  selectedOptions: newSelected,
                  clearOptions: newSelected.isEmpty,
                );
              });
              _emitChange();
            },
          );
        }).toList(),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildDateBtn(String label, DateTime? val, bool isStart) {
    return InkWell(
      onTap: () async {
        final d = await showDatePicker(
          context: context,
          initialDate: val ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2100),
          builder: (context, child) => Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.dark(
                primary: widget.accentColor,
                surface: const Color(0xFF1B263B),
              ),
            ),
            child: child!,
          ),
        );
        if (d != null) {
          setState(() {
            _condition = isStart
                ? _condition.copyWith(startDate: d)
                : _condition.copyWith(endDate: d);
          });
          _emitChange();
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.black26,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: val != null
                ? widget.accentColor.withOpacity(0.5)
                : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                val == null ? label : DateFormat('dd/MM/yy').format(val),
                style: TextStyle(
                  color: val == null ? Colors.white38 : Colors.white,
                  fontSize: 13,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (val != null)
              InkWell(
                onTap: () {
                  setState(() {
                    _condition = isStart
                        ? _condition.copyWith(clearStart: true)
                        : _condition.copyWith(clearEnd: true);
                  });
                  _emitChange();
                },
                child: const Icon(Icons.close, size: 16, color: Colors.white54),
              )
            else
              const Icon(Icons.calendar_today, size: 16, color: Colors.white24),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDeco(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white24),
      filled: true,
      fillColor: Colors.black26,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: widget.accentColor.withOpacity(0.5)),
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
