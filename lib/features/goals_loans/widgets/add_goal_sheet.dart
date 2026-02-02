import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import '../../../core/design/budgetr_colors.dart';
import '../../../core/design/budgetr_styles.dart';
import '../models/goal_loan_models.dart';
import '../services/goal_loan_service.dart';

class AddGoalSheet extends StatefulWidget {
  final GoalModel? goalToEdit; // [NEW] Optional goal for editing
  const AddGoalSheet({super.key, this.goalToEdit});

  @override
  State<AddGoalSheet> createState() => _AddGoalSheetState();
}

class _AddGoalSheetState extends State<AddGoalSheet> {
  // Controllers
  final _nameCtrl = TextEditingController();
  final _purposeCtrl = TextEditingController();
  final _idNoCtrl = TextEditingController();
  final _currentValueCtrl = TextEditingController();
  final _targetValueCtrl = TextEditingController();
  final _returnRateCtrl = TextEditingController();
  String? _validationError;

  // State Variables
  String _investmentType = 'Select Type';
  DateTime _startDate = DateTime.now();
  DateTime? _targetDate;

  final List<String> _investmentTypes = [
    'Mutual Fund',
    'Stocks',
    'Bonds',
    'Fixed Deposit',
    'Recurring Deposit',
    'Savings Deposit',
    'Gold',
    'Real Estate',
    'Others'
  ];

  @override
  void initState() {
    super.initState();
    // [NEW] Pre-fill if editing
    if (widget.goalToEdit != null) {
      final g = widget.goalToEdit!;
      _nameCtrl.text = g.name;
      _purposeCtrl.text = g.purpose ?? '';
      _idNoCtrl.text = g.identificationNumber ?? '';
      _currentValueCtrl.text = g.currentAmount.toString();
      _targetValueCtrl.text = g.targetAmount.toString();
      _returnRateCtrl.text = g.expectedReturn?.toString() ?? '';
      _investmentType = g.investmentType;
      _startDate = g.startDate;
      _targetDate = g.deadline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.goalToEdit != null;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: BudgetrColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // 1. Header
          const SizedBox(height: 16),
          Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 20),
          Text(isEdit ? "Edit Financial Goal" : "New Financial Goal",
              style: BudgetrStyles.h2),
          const SizedBox(height: 24),

          // 2. Form Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Basics
                  _buildTextField(
                      controller: _nameCtrl,
                      label: "Goal Name",
                      hint: "e.g. Retirement Fund",
                      icon: Icons.flag_outlined),
                  const SizedBox(height: 16),
                  _buildTextField(
                      controller: _purposeCtrl,
                      label: "Purpose",
                      hint: "e.g. Wealth Creation",
                      icon: Icons.lightbulb_outline),

                  const SizedBox(height: 16),

                  // Asset Type
                  _buildLabel("Type of Investment"),
                  const SizedBox(height: 8),
                  _buildTypeSelector(),

                  const SizedBox(height: 16),

                  // Identification
                  _buildTextField(
                      controller: _idNoCtrl,
                      label: "Identification No",
                      hint: "Folio No / Account No",
                      icon: Icons.tag),

                  const SizedBox(height: 24),

                  // Valuation Row
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                            controller: _currentValueCtrl,
                            label: "Current Value",
                            hint: "0.00",
                            icon: Icons.currency_rupee,
                            isNumber: true,
                            enabled: !isEdit), // [NEW] Disabled in Edit Mode
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildDatePicker(
                          label: "Start Date",
                          selectedDate: _startDate,
                          onPick: (d) => setState(() => _startDate = d),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Targets Row
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                            controller: _targetValueCtrl,
                            label: "Target Value",
                            hint: "Required",
                            icon: Icons.track_changes,
                            isNumber: true),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildDatePicker(
                          label: "Target Date",
                          selectedDate: _targetDate,
                          isOptional: true,
                          onPick: (d) => setState(() => _targetDate = d),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  _buildTextField(
                      controller: _returnRateCtrl,
                      label: "Exp. Return (%)",
                      hint: "Optional (e.g. 12.5)",
                      icon: Icons.trending_up,
                      isNumber: true),

                  const SizedBox(
                      height: 100), // Bottom padding for FAB/Keyboard
                ],
              ),
            ),
          ),
          if (_validationError != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Center(
                child: Text(
                  _validationError!,
                  style: const TextStyle(
                      color: Color(0xFFE71D36),
                      fontSize: 13,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          // 3. Floating Action Button Container
          Container(
            padding: EdgeInsets.fromLTRB(
                24, 16, 24, MediaQuery.of(context).viewInsets.bottom + 24),
            decoration: BoxDecoration(
              color: BudgetrColors.background,
              border: Border(
                  top: BorderSide(color: Colors.white.withOpacity(0.05))),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _saveGoal,
                style: ElevatedButton.styleFrom(
                  backgroundColor: BudgetrColors.accent,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(isEdit ? "UPDATE GOAL" : "CREATE GOAL",
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        letterSpacing: 1)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET BUILDERS ---

  Widget _buildLabel(String label) {
    return Text(label,
        style: const TextStyle(color: Colors.white70, fontSize: 13));
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isNumber = false,
    bool enabled = true, // [NEW] Added enabled flag
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          enabled: enabled,
          keyboardType: isNumber
              ? const TextInputType.numberWithOptions(decimal: true)
              : TextInputType.text,
          style: TextStyle(color: enabled ? Colors.white : Colors.white38),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.2)),
            prefixIcon: Icon(icon,
                color: enabled ? Colors.white38 : Colors.white24, size: 20),
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: BudgetrColors.accent)),
          ),
        ),
      ],
    );
  }

  Widget _buildTypeSelector() {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
            context: context,
            backgroundColor: Colors.transparent,
            builder: (ctx) => Container(
                  constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.6),
                  decoration: const BoxDecoration(
                    color: BudgetrColors.cardSurface,
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(2))),
                      const SizedBox(height: 16),
                      const Text("Select Investment Type",
                          style: BudgetrStyles.h3),
                      const SizedBox(height: 16),
                      Expanded(
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          itemCount: _investmentTypes.length,
                          separatorBuilder: (_, __) =>
                              const Divider(height: 1, color: Colors.white10),
                          itemBuilder: (ctx, i) {
                            final type = _investmentTypes[i];
                            return ListTile(
                              title: Text(type,
                                  style: const TextStyle(color: Colors.white)),
                              trailing: _investmentType == type
                                  ? const Icon(Icons.check,
                                      color: BudgetrColors.accent)
                                  : null,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              onTap: () {
                                setState(() => _investmentType = type);
                                Navigator.pop(ctx);
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(_investmentType,
                style: const TextStyle(color: Colors.white, fontSize: 16)),
            const Icon(Icons.keyboard_arrow_down, color: Colors.white54),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePicker({
    required String label,
    required DateTime? selectedDate,
    required Function(DateTime) onPick,
    bool isOptional = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label + (isOptional ? " (Optional)" : "")),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final d = await showDatePicker(
                context: context,
                initialDate: selectedDate ?? DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2050),
                builder: (c, child) =>
                    Theme(data: ThemeData.dark(), child: child!));
            if (d != null) onPick(d);
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_month,
                    color: Colors.white38, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    selectedDate == null
                        ? "Select Date"
                        : DateFormat('dd MMM yyyy').format(selectedDate),
                    style: TextStyle(
                        color: selectedDate == null
                            ? Colors.white24
                            : Colors.white),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // --- LOGIC ---

  void _saveGoal() async {
    setState(() => _validationError = null);
    final name = _nameCtrl.text.trim();
    final targetVal = double.tryParse(_targetValueCtrl.text.trim());

    if (name.isEmpty) {
      setState(() => _validationError = "Please enter a Goal Name");
      return;
    }
    if (_investmentType.isEmpty || _investmentType == 'Select Type') {
      setState(() => _validationError = "Please select an Investment Type");
      return;
    }
    if (targetVal == null || targetVal <= 0) {
      setState(() => _validationError = "Please enter a valid Target Value");
      return;
    }

    final currentVal = double.tryParse(_currentValueCtrl.text.trim()) ?? 0.0;
    final expReturn = double.tryParse(_returnRateCtrl.text.trim());

    final goal = GoalModel(
      id: widget.goalToEdit?.id ?? '', // Use existing ID if editing
      name: name,
      purpose: _purposeCtrl.text.trim(),
      investmentType: _investmentType,
      identificationNumber: _idNoCtrl.text.trim(),
      currentAmount: currentVal, // Ignored in update
      targetAmount: targetVal,
      startDate: _startDate,
      deadline: _targetDate,
      expectedReturn: expReturn,
      color: widget.goalToEdit?.color ?? Colors.blueAccent.value,
      // icon: widget.goalToEdit?.icon ?? Icons.flag.codePoint,
      isCompleted: currentVal >= targetVal,
    );

    if (widget.goalToEdit != null) {
      // [NEW] Update existing
      await GetIt.I<GoalLoanService>().updateGoal(goal);
    } else {
      // Create new
      await GetIt.I<GoalLoanService>().createGoal(goal);
    }

    if (mounted) Navigator.pop(context);
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(msg),
          backgroundColor: BudgetrColors.error,
          behavior: SnackBarBehavior.floating),
    );
  }
}
