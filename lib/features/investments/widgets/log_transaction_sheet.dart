import 'package:budget/core/design/budgetr_colors.dart';
import 'package:budget/core/widgets/futuristic_loader.dart';
import 'package:budget/core/widgets/status_bottom_sheet.dart';
import 'package:budget/features/investments/models/investment_dto.dart';
import 'package:budget/features/investments/models/investment_log_dto.dart';
import 'package:budget/features/investments/screens/investment_detail_screen.dart';
import 'package:budget/features/investments/services/portfolio_service.dart';
import 'package:budget/features/investments/widgets/compact_calculator_keyboard.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:math_expressions/math_expressions.dart';

enum LogType { invested, valueUpdate }

class LogTransactionSheet extends StatefulWidget {
  final int investmentId;
  final LogType initialType;
  final InvestmentLogDto? logToEdit;

  const LogTransactionSheet({
    super.key,
    required this.investmentId,
    required this.initialType,
    this.logToEdit,
  });

  @override
  State<LogTransactionSheet> createState() => _LogTransactionSheetState();
}

class _LogTransactionSheetState extends State<LogTransactionSheet> {
  late LogType _type;
  final _amountController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  bool _isLoading = false;
  bool _isWithdrawal = false;
  bool _isEditMode = false;

  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.logToEdit != null;

    if (_isEditMode) {
      final log = widget.logToEdit!;
      _selectedDate = log.date;

      if (log.type == 'valueUpdate') {
        _type = LogType.valueUpdate;
        _amountController.text = log.currentValue.abs().toString();
      } else {
        _type = LogType.invested;
        _amountController.text = log.amountInvested.abs().toString();
        _isWithdrawal = log.amountInvested < 0 || log.type == 'withdrawn';
      }
    } else {
      _type = widget.initialType;
    }
  }

  double? _evaluateFinalAmount() {
    try {
      String expression =
          _amountController.text.replaceAll('×', '*').replaceAll('÷', '/');
      if (expression.isEmpty) return null;
      Parser p = Parser();
      Expression exp = p.parse(expression);
      ContextModel cm = ContextModel();
      return exp.evaluate(EvaluationType.REAL, cm);
    } catch (e) {
      return null;
    }
  }

  void _showClosureInterceptionSheet(InvestmentDto inv, double amount) {
    showStatusSheet(
      context: context,
      title: "Full Withdrawal Detected",
      message:
          "It looks like you are withdrawing the entire value of this asset. Would you like to officially Close this investment and realize your final P&L?",
      icon: Icons.auto_awesome,
      color: BudgetrColors.success,
      buttonText: "Close Asset",
      cancelButtonText: "Adjust Amount",
      onCancel: () {},
      onDismiss: () {
        Navigator.pop(context);

        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (c) => CloseInvestmentSheet(investment: inv),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isInvestment = _type == LogType.invested;

    Color accentColor;
    String title;

    if (isInvestment) {
      if (_isWithdrawal) {
        accentColor = Colors.redAccent;
        title = _isEditMode ? "Edit Withdrawal" : "Withdraw Capital";
      } else {
        accentColor = BudgetrColors.accent;
        title = _isEditMode ? "Edit Investment" : "Add Capital";
      }
    } else {
      accentColor = const Color(0xFFF72585);
      title = _isEditMode ? "Edit Value Log" : "Update Market Value";
    }

    // =======================================================================
    // [FIX] SafeArea & SingleChildScrollView added to prevent overflow
    // =======================================================================
    return SafeArea(
      top: true,
      bottom: false,
      child: Container(
        padding: EdgeInsets.only(
          top: 24,
          left: 20,
          right: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        decoration: const BoxDecoration(
          color: Color(0xFF1B263B),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white38,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        _buildTypeToggle(
                            LogType.invested, Icons.swap_horiz_rounded),
                        _buildTypeToggle(
                            LogType.valueUpdate, Icons.trending_up_rounded),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              if (isInvestment) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                          child: _buildTransactionModeToggle("DEPOSIT", false)),
                      Expanded(
                          child: _buildTransactionModeToggle("WITHDRAW", true)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
              Text(
                isInvestment
                    ? (_isWithdrawal ? "Withdrawal Amount" : "Invested Amount")
                    : "Current Total Value",
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _amountController,
                readOnly: true,
                showCursor: true,
                autofocus: false,
                style: TextStyle(
                  color: accentColor,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  prefixText: "₹ ",
                  prefixStyle: TextStyle(
                      color: accentColor.withOpacity(0.5), fontSize: 32),
                  hintText: "0.00",
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.1)),
                  border: InputBorder.none,
                ),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded,
                          color: Colors.white70, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        DateFormat('dd MMMM yyyy').format(_selectedDate),
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      const Text("Change",
                          style:
                              TextStyle(color: Colors.white38, fontSize: 12)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              CompactCalculatorKeyboard(controller: _amountController),
              const SizedBox(height: 24),
              if (_errorMessage != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border:
                        Border.all(color: Colors.redAccent.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline_rounded,
                          color: Colors.redAccent, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                              color: Colors.redAccent,
                              fontSize: 12,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: _isLoading ? null : _saveLog,
                  child: _isLoading
                      ? const FuturisticLoader(size: 20)
                      : Text(
                          _isEditMode
                              ? "UPDATE RECORD"
                              : (isInvestment
                                  ? (_isWithdrawal
                                      ? "LOG WITHDRAWAL"
                                      : "LOG INVESTMENT")
                                  : "UPDATE VALUE"),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeToggle(LogType type, IconData icon) {
    final isSelected = _type == type;
    return GestureDetector(
      onTap: () => setState(() {
        _type = type;
        _errorMessage = null;
      }),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color:
              isSelected ? Colors.white.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 20,
          color: isSelected ? Colors.white : Colors.white38,
        ),
      ),
    );
  }

  Widget _buildTransactionModeToggle(String label, bool isWithdrawalMode) {
    final isSelected = _isWithdrawal == isWithdrawalMode;
    final activeColor =
        isWithdrawalMode ? Colors.redAccent : BudgetrColors.accent;

    return GestureDetector(
      onTap: () => setState(() {
        _isWithdrawal = isWithdrawalMode;
        _errorMessage = null;
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white38,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: BudgetrColors.accent,
            surface: Color(0xFF1B263B),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _saveLog() async {
    setState(() => _errorMessage = null);

    final amount = _evaluateFinalAmount();

    if (amount == null) {
      setState(() =>
          _errorMessage = "Please enter a valid mathematical expression.");
      return;
    }
    if (amount <= 0) return;

    final service = GetIt.I<PortfolioService>();

    if (!_isEditMode && _type == LogType.invested && _isWithdrawal) {
      final allInvestments = await service.watchAllInvestments().first;
      final inv = allInvestments.firstWhere((e) => e.id == widget.investmentId);

      if (amount > inv.currentMarketValue) {
        final fmt = NumberFormat.currency(
            locale: 'en_IN', symbol: '₹', decimalDigits: 2);
        setState(() {
          _errorMessage =
              "Withdrawal cannot exceed the current asset value (${fmt.format(inv.currentMarketValue)}).";
        });
        return;
      }

      if (amount >= (inv.currentMarketValue - 0.50) &&
          inv.currentMarketValue > 0) {
        _showClosureInterceptionSheet(inv, amount);
        return;
      }
    }

    setState(() => _isLoading = true);

    try {
      if (_isEditMode) {
        await service.updateLog(
          widget.logToEdit!.id,
          amount,
          _selectedDate,
          _isWithdrawal,
          _type == LogType.invested ? 'invested' : 'valueUpdate',
        );
      } else {
        if (_type == LogType.invested) {
          if (_isWithdrawal) {
            await service.logSafeWithdrawal(
              widget.investmentId,
              amount,
              _selectedDate,
            );
          } else {
            await service.logInvestmentTransaction(
              widget.investmentId,
              amount,
              _selectedDate,
              isWithdrawal: false,
            );
          }
        } else {
          await service.logValueUpdate(
            widget.investmentId,
            amount,
            _selectedDate,
          );
        }
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("System Error: $e")));
      }
    }
  }
}
