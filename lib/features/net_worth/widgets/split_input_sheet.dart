import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import '../../../core/design/budgetr_colors.dart';
import '../../../core/design/budgetr_styles.dart';
import '../../../core/models/net_worth_split_model.dart';
import '../../../core/widgets/calculator_keyboard.dart';
import '../services/net_worth_service.dart';

class SplitInputSheet extends StatefulWidget {
  final NetWorthSplitModel? splitToEdit;
  const SplitInputSheet({super.key, this.splitToEdit});

  @override
  State<SplitInputSheet> createState() => _SplitInputSheetState();
}

class _SplitInputSheetState extends State<SplitInputSheet> {
  // Date
  DateTime _selectedDate = DateTime.now();

  // Calculator State
  TextEditingController? _activeController;
  late final List<TextEditingController> _orderedControllers;
  late final List<FocusNode> _orderedFocusNodes;
  late final List<GlobalKey> _fieldKeys; // [NEW] Keys for scrolling

  // 1. Assets
  final _bankCtrl = TextEditingController();
  final _cashInHandCtrl = TextEditingController();
  final _mfCtrl = TextEditingController();
  final _equityCtrl = TextEditingController();
  final _bondCtrl = TextEditingController();
  final _depositCtrl = TextEditingController();
  final _realEstateCtrl = TextEditingController();
  final _otherAssetCtrl = TextEditingController();
  final _assetNoteCtrl = TextEditingController();

  // 2. Liabilities
  final _loanCtrl = TextEditingController();
  final _ccCtrl = TextEditingController();
  final _cclnCtrl = TextEditingController();
  final _otherDebtCtrl = TextEditingController();
  final _liabNoteCtrl = TextEditingController();

  // 3. Cashflow
  final _totInCtrl = TextEditingController();
  final _totExCtrl = TextEditingController();
  final _budInCtrl = TextEditingController();
  final _budExCtrl = TextEditingController();
  final _nonCalcInCtrl = TextEditingController();
  final _nonCalcExCtrl = TextEditingController();
  final _outBucketCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Define Order
    _orderedControllers = [
      _bankCtrl,
      _cashInHandCtrl,
      _mfCtrl,
      _equityCtrl,
      _bondCtrl,
      _depositCtrl,
      _realEstateCtrl,
      _otherAssetCtrl,
      _loanCtrl,
      _ccCtrl,
      _cclnCtrl,
      _otherDebtCtrl,
      _totInCtrl,
      _totExCtrl,
      _budInCtrl,
      _budExCtrl,
      _nonCalcInCtrl,
      _nonCalcExCtrl,
      _outBucketCtrl
    ];

    // Create Focus Nodes
    _orderedFocusNodes =
        List.generate(_orderedControllers.length, (_) => FocusNode());

    // [NEW] Create Global Keys for Auto-Scrolling
    _fieldKeys = List.generate(_orderedControllers.length, (_) => GlobalKey());

    if (widget.splitToEdit != null) {
      final s = widget.splitToEdit!;
      _selectedDate = s.date;

      _bankCtrl.text = _fmt(s.bankAccounts);
      _cashInHandCtrl.text = _fmt(s.cashInHand);
      _mfCtrl.text = _fmt(s.mutualFunds);
      _equityCtrl.text = _fmt(s.equity);
      _bondCtrl.text = _fmt(s.bonds);
      _depositCtrl.text = _fmt(s.deposits);
      _realEstateCtrl.text = _fmt(s.realEstate);
      _otherAssetCtrl.text = _fmt(s.otherAssets);
      _assetNoteCtrl.text = s.assetNotes ?? '';

      _loanCtrl.text = _fmt(s.loans);
      _ccCtrl.text = _fmt(s.creditCardOutstanding);
      _cclnCtrl.text = _fmt(s.creditLineOutstanding);
      _otherDebtCtrl.text = _fmt(s.otherDebts);
      _liabNoteCtrl.text = s.liabilityNotes ?? '';

      _totInCtrl.text = _fmt(s.totalIncome);
      _totExCtrl.text = _fmt(s.totalExpense);
      _budInCtrl.text = _fmt(s.budgetedIncome);
      _budExCtrl.text = _fmt(s.budgetedExpense);
      _nonCalcInCtrl.text = _fmt(s.nonCalcIncome);
      _nonCalcExCtrl.text = _fmt(s.nonCalcExpense);
      _outBucketCtrl.text = _fmt(s.outOfBucketExpense);
    }
  }

  @override
  void dispose() {
    for (var node in _orderedFocusNodes) {
      node.dispose();
    }
    _bankCtrl.dispose();
    _cashInHandCtrl.dispose();
    _mfCtrl.dispose();
    _equityCtrl.dispose();
    _bondCtrl.dispose();
    _depositCtrl.dispose();
    _realEstateCtrl.dispose();
    _otherAssetCtrl.dispose();
    _assetNoteCtrl.dispose();
    _loanCtrl.dispose();
    _ccCtrl.dispose();
    _cclnCtrl.dispose();
    _otherDebtCtrl.dispose();
    _liabNoteCtrl.dispose();
    _totInCtrl.dispose();
    _totExCtrl.dispose();
    _budInCtrl.dispose();
    _budExCtrl.dispose();
    _nonCalcInCtrl.dispose();
    _nonCalcExCtrl.dispose();
    _outBucketCtrl.dispose();
    super.dispose();
  }

  String _fmt(double v) => v == 0 ? '' : v.toString();
  double _val(TextEditingController c) => double.tryParse(c.text) ?? 0.0;

  // --- CALCULATOR LOGIC ---

  void _onKeyPress(String value) {
    if (_activeController != null) {
      CalculatorKeyboard.handleKeyPress(_activeController!, value);
    }
  }

  void _onBackspace() {
    if (_activeController != null) {
      CalculatorKeyboard.handleBackspace(_activeController!);
    }
  }

  void _onEquals() {
    if (_activeController != null) {
      CalculatorKeyboard.handleEquals(_activeController!);
    }
  }

  void _onClear() {
    if (_activeController != null) {
      _activeController!.clear();
    }
  }

  // [NEW] Helper to scroll to field
  void _scrollToField(int index) {
    // Small delay to allow keyboard layout update if needed, then scroll
    Future.delayed(const Duration(milliseconds: 100), () {
      final context = _fieldKeys[index].currentContext;
      if (context != null) {
        Scrollable.ensureVisible(context,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            alignment: 0.5 // Center the field in the viewport
            );
      }
    });
  }

  void _onNext() {
    if (_activeController == null) return;
    final index = _orderedControllers.indexOf(_activeController!);
    if (index < _orderedControllers.length - 1) {
      final nextIndex = index + 1;
      setState(() {
        _activeController = _orderedControllers[nextIndex];
      });
      _orderedFocusNodes[nextIndex].requestFocus();
      _scrollToField(nextIndex); // [FIX] Trigger Scroll
    } else {
      setState(() => _activeController = null);
      FocusScope.of(context).unfocus();
    }
  }

  void _onPrev() {
    if (_activeController == null) return;
    final index = _orderedControllers.indexOf(_activeController!);
    if (index > 0) {
      final prevIndex = index - 1;
      setState(() {
        _activeController = _orderedControllers[prevIndex];
      });
      _orderedFocusNodes[prevIndex].requestFocus();
      _scrollToField(prevIndex); // [FIX] Trigger Scroll
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = _activeController != null
        ? 0.0
        : MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.92,
      decoration: const BoxDecoration(
        color: BudgetrColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
          Text(
              widget.splitToEdit == null ? "Add Net Worth Entry" : "Edit Entry",
              style: BudgetrStyles.h3),
          const SizedBox(height: 16),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDateSelector(),
                  const SizedBox(height: 24),
                  _buildSectionHeader("ASSETS", Icons.account_balance_wallet,
                      BudgetrColors.success),
                  _buildGrid([
                    _buildField(_bankCtrl, "Bank Accounts"),
                    _buildField(_cashInHandCtrl, "Cash in Hand"),
                    _buildField(_mfCtrl, "Mutual Funds"),
                    _buildField(_equityCtrl, "Equity / Stocks"),
                    _buildField(_bondCtrl, "Bonds"),
                    _buildField(_depositCtrl, "Deposits (FD/RD)"),
                    _buildField(_realEstateCtrl, "Real Estate"),
                    _buildField(_otherAssetCtrl, "Other Assets"),
                  ]),
                  const SizedBox(height: 18),
                  _buildNoteField(_assetNoteCtrl, "Asset Notes"),
                  const SizedBox(height: 24),
                  _buildSectionHeader(
                      "LIABILITIES", Icons.credit_score, BudgetrColors.error),
                  _buildGrid([
                    _buildField(_loanCtrl, "Loans"),
                    _buildField(_ccCtrl, "Credit Card Due"),
                    _buildField(_cclnCtrl, "Credit Line Due"),
                    _buildField(_otherDebtCtrl, "Other Debts"),
                  ]),
                  const SizedBox(height: 18),
                  _buildNoteField(_liabNoteCtrl, "Liability Notes"),
                  const SizedBox(height: 24),
                  _buildSectionHeader("OTHER MONTHLY CASHFLOWS",
                      Icons.swap_horiz, Colors.blueAccent),
                  _buildGrid([
                    _buildField(_totInCtrl, "Total Income"),
                    _buildField(_totExCtrl, "Total Expense"),
                    _buildField(_budInCtrl, "Budgeted Income"),
                    _buildField(_budExCtrl, "Budgeted Expense"),
                    _buildField(_nonCalcInCtrl, "Non-Calc Income"),
                    _buildField(_nonCalcExCtrl, "Non-Calc Expense"),
                    _buildField(_outBucketCtrl, "Out of Bucket Exp"),
                  ]),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),

          // Save Button
          Container(
            padding: EdgeInsets.fromLTRB(20, 16, 20, bottomPadding + 20),
            decoration: BoxDecoration(
                color: BudgetrColors.background,
                border: Border(
                    top: BorderSide(color: Colors.white.withOpacity(0.1)))),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                    backgroundColor: BudgetrColors.accent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                child: const Text("SAVE ENTRY",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white)),
              ),
            ),
          ),

          // Calculator
          if (_activeController != null)
            CalculatorKeyboard(
              onKeyPress: _onKeyPress,
              onBackspace: _onBackspace,
              onClear: _onClear,
              onEquals: _onEquals,
              onNext: _onNext,
              onPrevious: _onPrev,
              onClose: () {
                setState(() => _activeController = null);
                FocusScope.of(context).unfocus();
              },
              onSwitchToSystem: () {
                setState(() => _activeController = null);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Text(title,
              style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 1.2)),
          const SizedBox(width: 8),
          Expanded(child: Divider(color: color.withOpacity(0.3))),
        ],
      ),
    );
  }

  Widget _buildGrid(List<Widget> children) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: children
          .map((c) => SizedBox(
              width: (MediaQuery.of(context).size.width - 52) / 2, child: c))
          .toList(),
    );
  }

  Widget _buildField(TextEditingController ctrl, String label) {
    final isActive = _activeController == ctrl;
    final index = _orderedControllers.indexOf(ctrl);
    final focusNode = index != -1 ? _orderedFocusNodes[index] : null;
    final key = index != -1 ? _fieldKeys[index] : null; // [NEW] Get Key

    return Column(
      key: key, // [NEW] Assign GlobalKey for scrolling
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                color: isActive ? BudgetrColors.accent : Colors.white54,
                fontSize: 11,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal),
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          focusNode: focusNode,
          readOnly: true,
          showCursor: true,
          onTap: () {
            setState(() {
              _activeController = ctrl;
            });
            focusNode?.requestFocus();
            if (index != -1) _scrollToField(index); // Scroll on tap too
          },
          style: const TextStyle(color: Colors.white, fontSize: 13),
          decoration: InputDecoration(
            hintText: "0.00",
            hintStyle: const TextStyle(color: Colors.white24),
            filled: true,
            fillColor: isActive
                ? BudgetrColors.accent.withOpacity(0.1)
                : Colors.white.withOpacity(0.05),
            isDense: true,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                    color:
                        isActive ? BudgetrColors.accent : Colors.transparent)),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                    color:
                        isActive ? BudgetrColors.accent : Colors.transparent)),
          ),
        ),
      ],
    );
  }

  Widget _buildNoteField(TextEditingController ctrl, String hint) {
    return TextField(
      controller: ctrl,
      onTap: () {
        setState(() => _activeController = null);
      },
      style: const TextStyle(color: Colors.white, fontSize: 13),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white24),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildDateSelector() {
    return GestureDetector(
      onTap: () async {
        setState(() => _activeController = null);
        FocusScope.of(context).unfocus();
        final d = await showDatePicker(
            context: context,
            initialDate: _selectedDate,
            firstDate: DateTime(2000),
            lastDate: DateTime.now(),
            builder: (c, child) =>
                Theme(data: ThemeData.dark(), child: child!));
        if (d != null) setState(() => _selectedDate = d);
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.calendar_month, color: Colors.white70, size: 18),
            const SizedBox(width: 8),
            Text(DateFormat('dd MMM yyyy').format(_selectedDate),
                style: const TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }

  void _save() {
    final split = NetWorthSplitModel(
      id: widget.splitToEdit?.id ?? '',
      date: _selectedDate,
      bankAccounts: _val(_bankCtrl),
      cashInHand: _val(_cashInHandCtrl),
      mutualFunds: _val(_mfCtrl),
      equity: _val(_equityCtrl),
      bonds: _val(_bondCtrl),
      deposits: _val(_depositCtrl),
      realEstate: _val(_realEstateCtrl),
      otherAssets: _val(_otherAssetCtrl),
      assetNotes: _assetNoteCtrl.text,
      loans: _val(_loanCtrl),
      creditCardOutstanding: _val(_ccCtrl),
      creditLineOutstanding: _val(_cclnCtrl),
      otherDebts: _val(_otherDebtCtrl),
      liabilityNotes: _liabNoteCtrl.text,
      totalIncome: _val(_totInCtrl),
      totalExpense: _val(_totExCtrl),
      budgetedIncome: _val(_budInCtrl),
      budgetedExpense: _val(_budExCtrl),
      nonCalcIncome: _val(_nonCalcInCtrl),
      nonCalcExpense: _val(_nonCalcExCtrl),
      outOfBucketExpense: _val(_outBucketCtrl),
    );

    if (widget.splitToEdit != null) {
      GetIt.I<NetWorthService>().updateSplit(split);
    } else {
      GetIt.I<NetWorthService>().createSplit(split);
    }
    Navigator.pop(context);
  }
}
