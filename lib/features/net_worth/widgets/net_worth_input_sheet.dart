import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/models/net_worth_model.dart';
import '../../../core/widgets/calculator_keyboard.dart';
import '../services/net_worth_service.dart';

class NetWorthInputSheet extends StatefulWidget {
  const NetWorthInputSheet({super.key});

  @override
  State<NetWorthInputSheet> createState() => _NetWorthInputSheetState();
}

class _NetWorthInputSheetState extends State<NetWorthInputSheet> {
  final _netWorthService = NetWorthService();
  final ScrollController _scrollController = ScrollController();

  final TextEditingController _assetsController = TextEditingController();
  final TextEditingController _liabilitiesController = TextEditingController();
  final FocusNode _assetsFocus = FocusNode();
  final FocusNode _liabilitiesFocus = FocusNode();

  DateTime _selectedDate = DateTime.now();
  double _currentNetWorth = 0.0;

  TextEditingController? _activeController;
  bool _isKeyboardVisible = false;
  bool _useSystemKeyboard = false;

  @override
  void initState() {
    super.initState();
    _assetsController.addListener(_calculate);
    _liabilitiesController.addListener(_calculate);
  }

  @override
  void dispose() {
    _assetsController.dispose();
    _liabilitiesController.dispose();
    _assetsFocus.dispose();
    _liabilitiesFocus.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _calculate() {
    final assets = double.tryParse(_assetsController.text) ?? 0.0;
    final liabilities = double.tryParse(_liabilitiesController.text) ?? 0.0;
    setState(() => _currentNetWorth = assets - liabilities);
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
    if (_activeController == _assetsController) {
      _setActive(_liabilitiesController, _liabilitiesFocus);
    } else {
      _closeKeyboard();
    }
  }

  // --- NEW: Handle Previous Field ---
  void _handlePrevious() {
    if (_activeController == _liabilitiesController) {
      _setActive(_assetsController, _assetsFocus);
    } else {
      _closeKeyboard();
    }
  }

  Future<void> _save() async {
    _closeKeyboard();
    final assets = double.tryParse(_assetsController.text) ?? 0.0;
    final liabilities = double.tryParse(_liabilitiesController.text) ?? 0.0;

    final record = NetWorthRecord(
      id: '',
      date: _selectedDate,
      amount: assets - liabilities,
    );

    await _netWorthService.addNetWorthRecord(record);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _currentNetWorth >= 0
        ? const Color(0xFF00E676)
        : const Color(0xFFFF5252);

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      color: const Color(0xff0D1B2A),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Column(
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Update Net Worth",
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
                                DateFormat('dd MMM yyyy').format(_selectedDate),
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
                  _buildInput(
                    "Total Assets",
                    _assetsController,
                    _assetsFocus,
                    const Color(0xFF00E676),
                  ),
                  const SizedBox(height: 16),
                  _buildInput(
                    "Total Liabilities",
                    _liabilitiesController,
                    _liabilitiesFocus,
                    const Color(0xFFFF5252),
                  ),
                ],
              ),
            ),
          ),

          // --- STICKY BOTTOM BAR ---
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Calculated Net Worth:",
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    Text(
                      NumberFormat.currency(
                        locale: 'en_IN',
                        symbol: '₹',
                      ).format(_currentNetWorth),
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(
                            color: Colors.white.withOpacity(0.2),
                          ),
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
                          "Save Record",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // --- KEYBOARD ---
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

  Widget _buildInput(
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
            color: accent,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
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
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          decoration: InputDecoration(
            prefixText: '₹ ',
            prefixStyle: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 20,
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
