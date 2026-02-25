import 'package:budget/core/design/budgetr_colors.dart';
import 'package:budget/core/widgets/futuristic_loader.dart';
import 'package:budget/features/investments/models/investment_log_dto.dart';
import 'package:budget/features/investments/services/portfolio_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

enum LogType { invested, valueUpdate }

class LogTransactionSheet extends StatefulWidget {
  final int investmentId;
  final LogType initialType;
  final InvestmentLogDto? logToEdit; // [NEW] For Edit Mode

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
        // If amount is negative, it was a withdrawal
        _isWithdrawal = log.amountInvested < 0 || log.type == 'withdrawn';
      }
    } else {
      _type = widget.initialType;
    }
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

    return Container(
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
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: TextStyle(
              color: accentColor,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              prefixText: "₹ ",
              prefixStyle:
                  TextStyle(color: accentColor.withOpacity(0.5), fontSize: 32),
              hintText: "0.00",
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.1)),
              border: InputBorder.none,
            ),
            autofocus:
                !_isEditMode, // Don't autofocus on edit to avoid jarring jump
          ),
          const SizedBox(height: 24),
          InkWell(
            onTap: _pickDate,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                      style: TextStyle(color: Colors.white38, fontSize: 12)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
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
                  ? const FuturisticLoader(
                      size: 20,
                    )
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
    );
  }

  Widget _buildTypeToggle(LogType type, IconData icon) {
    final isSelected = _type == type;
    return GestureDetector(
      onTap: () => setState(() => _type = type),
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
      onTap: () => setState(() => _isWithdrawal = isWithdrawalMode),
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
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) return;

    setState(() => _isLoading = true);
    final service = GetIt.I<PortfolioService>();

    try {
      if (_isEditMode) {
        // [NEW] Edit Logic
        await service.updateLog(
            widget.logToEdit!.id,
            amount,
            _selectedDate,
            _isWithdrawal,
            _type == LogType.invested
                ? (_isWithdrawal ? 'withdrawn' : 'invested')
                : 'valueUpdate');
      } else {
        // Create Logic
        if (_type == LogType.invested) {
          await service.logInvestmentTransaction(
              widget.investmentId, amount, _selectedDate,
              isWithdrawal: _isWithdrawal);
        } else {
          await service.logValueUpdate(
              widget.investmentId, amount, _selectedDate);
        }
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }
}
