import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import '../../../core/design/budgetr_colors.dart';
import '../../../core/design/budgetr_styles.dart';
import '../models/goal_loan_models.dart';
import '../services/goal_loan_service.dart';

class AddLoanSheet extends StatefulWidget {
  final LoanModel? loanToEdit;
  const AddLoanSheet({super.key, this.loanToEdit});

  @override
  State<AddLoanSheet> createState() => _AddLoanSheetState();
}

class _AddLoanSheetState extends State<AddLoanSheet> {
  final List<String> _banks = [
    'HDFC Bank',
    'State Bank of India',
    'ICICI Bank',
    'Axis Bank',
    'Kotak Mahindra Bank',
    'Punjab National Bank',
    'Bank of Baroda',
    'IndusInd Bank',
    'Yes Bank',
    'IDFC FIRST Bank',
    'Canara Bank',
    'Union Bank of India',
    'Standard Chartered',
    'American Express',
    'Citi Bank',
    'HSBC',
    'RBL Bank',
    'Federal Bank',
    'IDBI Bank',
    'UCO Bank',
    'AU Bank',
    'ESAF Small Finance Bank',
    'Bandhan Bank',
    'South Indian Bank',
    'DBS Bank',
    'Punjab & Sind Bank',
    'Indian Bank',
    'Bank of India',
    'Central Bank of India',
    'Bank of Maharashtra',
    'Indian Overseas Bank',
    'Others',
  ];

  // --- Controllers ---
  final _nameCtrl = TextEditingController();
  final _accountNoCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _tenureCtrl = TextEditingController();
  final _rateCtrl = TextEditingController();
  final _totalPayableCtrl = TextEditingController();
  final _emiCtrl = TextEditingController();
  String? _validationError;

  // --- Focus Nodes (For 'Next' Keyboard Action) ---
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _accountNoFocus = FocusNode();
  final FocusNode _amountFocus = FocusNode();
  final FocusNode _rateFocus = FocusNode();
  final FocusNode _tenureFocus = FocusNode();
  final FocusNode _totalPayableFocus = FocusNode();
  final FocusNode _emiFocus = FocusNode();

  String _selectedBank = 'Select Issuer';
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 365));
  DateTime _emiDate = DateTime.now().add(const Duration(days: 30));

  String _type = 'BORROWED';

  @override
  void initState() {
    super.initState();
    if (widget.loanToEdit != null) {
      final l = widget.loanToEdit!;
      _nameCtrl.text = l.title;
      _selectedBank = _banks.contains(l.provider) ? l.provider : 'Others';

      _accountNoCtrl.text = l.notes?.replaceAll("Account: ", "") ?? "";
      _amountCtrl.text = l.principalAmount.toString();
      _rateCtrl.text = l.interestRate.toString();
      _emiCtrl.text = l.emiAmount?.toStringAsFixed(2) ?? "";
      _totalPayableCtrl.text = l.totalAmount.toStringAsFixed(2);

      _startDate = l.startDate;
      if (l.dueDate != null) _endDate = l.dueDate!;
      if (l.nextPaymentDate != null) _emiDate = l.nextPaymentDate!;
      _type = l.type;

      if (l.emiAmount != null && l.emiAmount! > 0) {
        _tenureCtrl.text = (l.totalAmount / l.emiAmount!).round().toString();
      }
    }

    _amountCtrl.addListener(_calculateLoanDetails);
    _tenureCtrl.addListener(_calculateLoanDetails);
    _rateCtrl.addListener(_calculateLoanDetails);
  }

  @override
  void dispose() {
    // Dispose Controllers
    _nameCtrl.dispose();
    _accountNoCtrl.dispose();
    _amountCtrl.dispose();
    _tenureCtrl.dispose();
    _rateCtrl.dispose();
    _totalPayableCtrl.dispose();
    _emiCtrl.dispose();

    // Dispose Focus Nodes
    _nameFocus.dispose();
    _accountNoFocus.dispose();
    _amountFocus.dispose();
    _rateFocus.dispose();
    _tenureFocus.dispose();
    _totalPayableFocus.dispose();
    _emiFocus.dispose();

    super.dispose();
  }

  void _calculateLoanDetails() {
    final principal = double.tryParse(_amountCtrl.text) ?? 0;
    final tenureMonths = int.tryParse(_tenureCtrl.text) ?? 0;
    final annualRate = double.tryParse(_rateCtrl.text) ?? 0;

    if (principal > 0 && tenureMonths > 0 && annualRate > 0) {
      final newEndDate =
          DateTime(_emiDate.year, _emiDate.month + tenureMonths, _emiDate.day);

      final monthlyRate = annualRate / 12 / 100;
      final emi =
          (principal * monthlyRate * pow(1 + monthlyRate, tenureMonths)) /
              (pow(1 + monthlyRate, tenureMonths) - 1);

      final totalPayable = emi * tenureMonths;

      setState(() {
        _endDate = newEndDate;
        _emiCtrl.text = emi.toStringAsFixed(2);
        _totalPayableCtrl.text = totalPayable.toStringAsFixed(2);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.loanToEdit != null;

    return Container(
      height: MediaQuery.of(context).size.height * 0.92,
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
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
          const SizedBox(height: 20),
          Text(isEdit ? "Edit Loan Details" : "Add New Loan",
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1)),
          const SizedBox(height: 24),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionLabel("LOAN DETAILS"),
                  _buildTextField(
                    controller: _nameCtrl,
                    focusNode: _nameFocus,
                    nextFocusNode: _accountNoFocus,
                    label: "Loan Name",
                    hint: "e.g. Home Loan",
                    icon: Icons.title,
                  ),
                  const SizedBox(height: 16),
                  _buildBankSelector(),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _accountNoCtrl,
                    focusNode: _accountNoFocus,
                    nextFocusNode: _amountFocus,
                    label: "Loan Account No",
                    hint: "e.g. L-19283746",
                    icon: Icons.numbers,
                  ),
                  const SizedBox(height: 32),
                  _buildSectionLabel("TERMS & INTEREST"),
                  Row(
                    children: [
                      Expanded(
                          child: _buildTextField(
                        controller: _amountCtrl,
                        focusNode: _amountFocus,
                        nextFocusNode: _rateFocus,
                        label: "Loan Amount",
                        hint: "Principal",
                        icon: Icons.currency_rupee,
                        isNumber: true,
                      )),
                      const SizedBox(width: 16),
                      Expanded(
                          child: _buildTextField(
                        controller: _rateCtrl,
                        focusNode: _rateFocus,
                        nextFocusNode: _tenureFocus,
                        label: "Interest Rate",
                        hint: "% p.a.",
                        icon: Icons.percent,
                        isNumber: true,
                      )),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                          child: _buildTextField(
                        controller: _tenureCtrl,
                        focusNode: _tenureFocus,
                        nextFocusNode: _totalPayableFocus,
                        label: "Tenure",
                        hint: "Months",
                        icon: Icons.calendar_view_month,
                        isNumber: true,
                      )),
                      const SizedBox(width: 16),
                      Expanded(
                          child: _buildDatePicker(
                              label: "Active From",
                              date: _startDate,
                              onPick: (d) => setState(() {
                                    _startDate = d;
                                    _calculateLoanDetails();
                                  }))),
                    ],
                  ),
                  const SizedBox(height: 32),
                  _buildSectionLabel("REPAYMENT SCHEDULE"),
                  _buildTextField(
                    controller: _totalPayableCtrl,
                    focusNode: _totalPayableFocus,
                    nextFocusNode: _emiFocus,
                    label: "Total Payable",
                    hint: "Auto-calculated",
                    icon: Icons.account_balance_wallet,
                    isNumber: true,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                          child: _buildTextField(
                        controller: _emiCtrl,
                        focusNode: _emiFocus,
                        isLast: true,
                        label: "EMI Amount",
                        hint: "Monthly",
                        icon: Icons.repeat,
                        isNumber: true,
                      )),
                      const SizedBox(width: 16),
                      Expanded(
                          child: _buildDatePicker(
                              label: "First EMI Date",
                              date: _emiDate,
                              onPick: (d) => setState(() {
                                    _emiDate = d;
                                    _calculateLoanDetails();
                                  }))),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildDatePicker(
                      label: "Loan End Date (Calculated)",
                      date: _endDate,
                      onPick: (d) => setState(() => _endDate = d)),
                  const SizedBox(height: 100),
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
          Container(
            padding: EdgeInsets.fromLTRB(
                24, 16, 24, MediaQuery.of(context).viewInsets.bottom + 24),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              border: Border(
                  top: BorderSide(color: Colors.white.withOpacity(0.05))),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _saveLoan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: BudgetrColors.error,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(isEdit ? "UPDATE LOAN" : "CREATE LOAN",
                    style: const TextStyle(
                        color: Colors.white,
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

  Widget _buildSectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(text,
          style: const TextStyle(
              color: Colors.white38,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5)),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    FocusNode? focusNode,
    FocusNode? nextFocusNode,
    bool isNumber = false,
    bool isLast = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: isNumber
              ? const TextInputType.numberWithOptions(decimal: true)
              : TextInputType.text,
          textInputAction: isLast ? TextInputAction.done : TextInputAction.next,
          onEditingComplete: () {
            if (nextFocusNode != null) {
              FocusScope.of(context).requestFocus(nextFocusNode);
            } else {
              FocusScope.of(context).unfocus();
            }
          },
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.2)),
            prefixIcon: Icon(icon, color: Colors.white38, size: 20),
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: BudgetrColors.error)),
          ),
        ),
      ],
    );
  }

  Widget _buildBankSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Issuer",
            style: TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () {
            FocusScope.of(context)
                .unfocus(); // Close keyboard before opening sheet
            showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                builder: (ctx) => Container(
                      constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * 0.6),
                      decoration: const BoxDecoration(
                        color: Color(0xFF1E293B),
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(24)),
                      ),
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _banks.length,
                        separatorBuilder: (_, __) =>
                            const Divider(height: 1, color: Colors.white10),
                        itemBuilder: (ctx, i) => ListTile(
                          title: Text(_banks[i],
                              style: const TextStyle(color: Colors.white)),
                          onTap: () {
                            setState(() => _selectedBank = _banks[i]);
                            Navigator.pop(ctx);
                            // Jump to account number after selecting bank
                            FocusScope.of(context)
                                .requestFocus(_accountNoFocus);
                          },
                        ),
                      ),
                    ));
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(_selectedBank,
                    style: const TextStyle(color: Colors.white, fontSize: 16)),
                const Icon(Icons.keyboard_arrow_down, color: Colors.white54),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker({
    required String label,
    required DateTime date,
    required Function(DateTime) onPick,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            FocusScope.of(context).unfocus(); // Close keyboard
            final d = await showDatePicker(
                context: context,
                initialDate: date,
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
                const Icon(Icons.calendar_today,
                    color: Colors.white38, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    DateFormat('dd MMM yyyy').format(date),
                    style: const TextStyle(color: Colors.white),
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

  void _saveLoan() {
    setState(() => _validationError = null);
    final totalPayable = double.tryParse(_totalPayableCtrl.text);
    final principal = double.tryParse(_amountCtrl.text);
    final emi = double.tryParse(_emiCtrl.text);
    final rate = double.tryParse(_rateCtrl.text);

    if (_nameCtrl.text.isEmpty) {
      setState(() => _validationError = "Please enter the Loan Name");
      return;
    }
    if (_selectedBank.isEmpty || _selectedBank == 'Select Issuer') {
      setState(() => _validationError = "Please select loan provider");
      return;
    }
    if (totalPayable == null) {
      setState(() => _validationError = "Total Payable amount is mandatory");
      return;
    }
    if (totalPayable <= 0) {
      setState(() =>
          _validationError = "Total Payable amount must be greater than 0");
      return;
    }
    if (principal == null || principal <= 0) {
      setState(
          () => _validationError = "Principal amount must be greater than 0");
      return;
    }

    final loan = LoanModel(
      id: widget.loanToEdit?.id ?? '',
      title: _nameCtrl.text,
      provider: _selectedBank,
      principalAmount: principal,
      totalAmount: totalPayable,
      paidAmount: widget.loanToEdit?.paidAmount ?? 0,
      interestRate: rate ?? 0,
      type: _type,
      startDate: _startDate,
      dueDate: _endDate,
      emiAmount: emi,
      nextPaymentDate: _emiDate,
      isClosed: false,
      notes: _accountNoCtrl.text,
    );

    if (widget.loanToEdit != null) {
      GetIt.I<GoalLoanService>().updateLoan(loan);
    } else {
      GetIt.I<GoalLoanService>().createLoan(loan);
    }

    Navigator.pop(context);
  }
}
