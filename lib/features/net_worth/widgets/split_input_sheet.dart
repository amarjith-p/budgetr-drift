import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/models/net_worth_split_model.dart';
import '../../../core/widgets/calculator_keyboard.dart';
import '../services/net_worth_service.dart';

class SplitInputSheet extends StatefulWidget {
  const SplitInputSheet({super.key});

  @override
  State<SplitInputSheet> createState() => _SplitInputSheetState();
}

class _SplitInputSheetState extends State<SplitInputSheet> {
  final _netWorthService = NetWorthService();
  final ScrollController _scrollController = ScrollController();

  // Controllers
  final _netIncomeCtrl = TextEditingController();
  final _netExpenseCtrl = TextEditingController();
  final _capGainCtrl = TextEditingController();
  final _capLossCtrl = TextEditingController();
  final _nonCalcIncomeCtrl = TextEditingController();
  final _nonCalcExpenseCtrl = TextEditingController();

  // Focus Nodes
  final _netIncomeFocus = FocusNode();
  final _netExpenseFocus = FocusNode();
  final _capGainFocus = FocusNode();
  final _capLossFocus = FocusNode();
  final _nonCalcIncomeFocus = FocusNode();
  final _nonCalcExpenseFocus = FocusNode();

  DateTime _selectedDate = DateTime.now();

  // Keyboard State
  TextEditingController? _activeController;
  bool _isKeyboardVisible = false;
  bool _useSystemKeyboard = false;

  @override
  void dispose() {
    _netIncomeCtrl.dispose();
    _netExpenseCtrl.dispose();
    _capGainCtrl.dispose();
    _capLossCtrl.dispose();
    _nonCalcIncomeCtrl.dispose();
    _nonCalcExpenseCtrl.dispose();

    _netIncomeFocus.dispose();
    _netExpenseFocus.dispose();
    _capGainFocus.dispose();
    _capLossFocus.dispose();
    _nonCalcIncomeFocus.dispose();
    _nonCalcExpenseFocus.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToInput(FocusNode node) {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (node.context != null && mounted) {
        Scrollable.ensureVisible(
          node.context!,
          alignment: 0.5,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _setActive(TextEditingController ctrl, FocusNode node) {
    setState(() {
      _activeController = ctrl;
      if (!_useSystemKeyboard) {
        _isKeyboardVisible = true;
        FocusScope.of(context).requestFocus(node);
      } else {
        _isKeyboardVisible = false;
      }
    });
    _scrollToInput(node);
  }

  void _closeKeyboard() {
    setState(() => _isKeyboardVisible = false);
    FocusScope.of(context).unfocus();
  }

  void _switchToSystemKeyboard() {
    setState(() {
      _useSystemKeyboard = true;
      _isKeyboardVisible = false;
    });
    FocusScope.of(context).unfocus();
  }

  void _handleNext() {
    if (_activeController == _netIncomeCtrl)
      _setActive(_netExpenseCtrl, _netExpenseFocus);
    else if (_activeController == _netExpenseCtrl)
      _setActive(_capGainCtrl, _capGainFocus);
    else if (_activeController == _capGainCtrl)
      _setActive(_capLossCtrl, _capLossFocus);
    else if (_activeController == _capLossCtrl)
      _setActive(_nonCalcIncomeCtrl, _nonCalcIncomeFocus);
    else if (_activeController == _nonCalcIncomeCtrl)
      _setActive(_nonCalcExpenseCtrl, _nonCalcExpenseFocus);
    else
      _closeKeyboard();
  }

  // --- NEW: Handle Previous Field ---
  void _handlePrevious() {
    if (_activeController == _nonCalcExpenseCtrl)
      _setActive(_nonCalcIncomeCtrl, _nonCalcIncomeFocus);
    else if (_activeController == _nonCalcIncomeCtrl)
      _setActive(_capLossCtrl, _capLossFocus);
    else if (_activeController == _capLossCtrl)
      _setActive(_capGainCtrl, _capGainFocus);
    else if (_activeController == _capGainCtrl)
      _setActive(_netExpenseCtrl, _netExpenseFocus);
    else if (_activeController == _netExpenseCtrl)
      _setActive(_netIncomeCtrl, _netIncomeFocus);
    else
      _closeKeyboard();
  }

  Future<void> _save() async {
    _closeKeyboard();

    final split = NetWorthSplit(
      id: '',
      date: _selectedDate,
      netIncome: double.tryParse(_netIncomeCtrl.text) ?? 0,
      netExpense: double.tryParse(_netExpenseCtrl.text) ?? 0,
      capitalGain: double.tryParse(_capGainCtrl.text) ?? 0,
      capitalLoss: double.tryParse(_capLossCtrl.text) ?? 0,
      nonCalcIncome: double.tryParse(_nonCalcIncomeCtrl.text) ?? 0,
      nonCalcExpense: double.tryParse(_nonCalcExpenseCtrl.text) ?? 0,
    );

    await _netWorthService.addNetWorthSplit(split);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      color: const Color(0xff0D1B2A),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          // Content
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Header with Date Picker
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Add Split Analysis",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          final d = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime.now(),
                            builder: (context, child) => Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: const ColorScheme.dark(
                                  primary: Color(0xFF2EC4B6),
                                  surface: Color(0xFF1B263B),
                                ),
                              ),
                              child: child!,
                            ),
                          );
                          if (d != null) setState(() => _selectedDate = d);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.1),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.calendar_today,
                                size: 14,
                                color: Colors.white70,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                DateFormat('dd MMM').format(_selectedDate),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // --- Input Fields Grid ---
                  Row(
                    children: [
                      Expanded(
                        child: _buildSplitInput(
                          "Net Income",
                          _netIncomeCtrl,
                          _netIncomeFocus,
                          const Color(0xFF00E676),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildSplitInput(
                          "Net Expense",
                          _netExpenseCtrl,
                          _netExpenseFocus,
                          const Color(0xFFFF5252),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _buildSplitInput(
                          "Capital Gain",
                          _capGainCtrl,
                          _capGainFocus,
                          const Color(0xFF00E676),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildSplitInput(
                          "Capital Loss",
                          _capLossCtrl,
                          _capLossFocus,
                          const Color(0xFFFF5252),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _buildSplitInput(
                          "Other Income",
                          _nonCalcIncomeCtrl,
                          _nonCalcIncomeFocus,
                          const Color(0xFF00E676),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildSplitInput(
                          "Other Expense",
                          _nonCalcExpenseCtrl,
                          _nonCalcExpenseFocus,
                          const Color(0xFFFF5252),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),

          // --- Sticky Action Bar ---
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xff0D1B2A),
              border: Border(
                top: BorderSide(color: Colors.white.withOpacity(0.1)),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: Colors.white.withOpacity(0.2)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      "Cancel",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: const Color(0xFF2EC4B6),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      "Save Split",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // --- Keyboard ---
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            child: _isKeyboardVisible
                ? CalculatorKeyboard(
                    onKeyPress: (v) => CalculatorKeyboard.handleKeyPress(
                      _activeController!,
                      v,
                    ),
                    onBackspace: () =>
                        CalculatorKeyboard.handleBackspace(_activeController!),
                    onClear: () => _activeController!.clear(),
                    onEquals: () =>
                        CalculatorKeyboard.handleEquals(_activeController!),
                    onClose: _closeKeyboard,
                    onSwitchToSystem: _switchToSystemKeyboard,
                    onNext: _handleNext,
                    onPrevious: _handlePrevious, // Added Callback
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildSplitInput(
    String label,
    TextEditingController ctrl,
    FocusNode node,
    Color accent,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: accent.withOpacity(0.9),
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: ctrl,
          focusNode: node,
          readOnly: !_useSystemKeyboard,
          showCursor: true,
          keyboardType: TextInputType.number,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          decoration: InputDecoration(
            prefixText: '₹ ',
            prefixStyle: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 16,
            ),
            hintText: '0',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.1)),
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
            isDense: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          onTap: () => _setActive(ctrl, node),
        ),
      ],
    );
  }
}
