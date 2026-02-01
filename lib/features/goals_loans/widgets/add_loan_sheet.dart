import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import '../../../core/design/budgetr_colors.dart';
import '../../../core/design/budgetr_styles.dart';
import '../models/goal_loan_models.dart';
import '../services/goal_loan_service.dart';

class AddLoanSheet extends StatefulWidget {
  const AddLoanSheet({super.key});

  @override
  State<AddLoanSheet> createState() => _AddLoanSheetState();
}

class _AddLoanSheetState extends State<AddLoanSheet> {
  final List<String> _banks = [
    'HDFC Bank',
    'SBI',
    'ICICI Bank',
    'Axis Bank',
    'Kotak Mahindra',
    'Punjab National Bank',
    'Bank of Baroda',
    'IndusInd Bank',
    'Yes Bank',
    'IDFC First',
    'Others'
  ];

  final _nameCtrl = TextEditingController();
  final _accountNoCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _tenureCtrl = TextEditingController();
  final _rateCtrl = TextEditingController();
  final _totalPayableCtrl = TextEditingController();
  final _emiCtrl = TextEditingController();

  String _selectedBank = 'HDFC Bank';
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 365));
  DateTime _emiDate = DateTime.now().add(const Duration(days: 30));

  @override
  void initState() {
    super.initState();
    _amountCtrl.addListener(_calculateLoanDetails);
    _tenureCtrl.addListener(_calculateLoanDetails);
    _rateCtrl.addListener(_calculateLoanDetails);
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _tenureCtrl.dispose();
    _rateCtrl.dispose();
    _totalPayableCtrl.dispose();
    _emiCtrl.dispose();
    super.dispose();
  }

  void _calculateLoanDetails() {
    final principal = double.tryParse(_amountCtrl.text) ?? 0;
    final tenureMonths = int.tryParse(_tenureCtrl.text) ?? 0;
    final annualRate = double.tryParse(_rateCtrl.text) ?? 0;

    if (principal > 0 && tenureMonths > 0 && annualRate > 0) {
      final newEndDate =
          DateTime(_emiDate.year, _emiDate.month + tenureMonths, _emiDate.day);

      // EMI Calculation: [P x R x (1+R)^N]/[(1+R)^N-1]
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
          const Text("Add New Loan",
              style: TextStyle(
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
                      label: "Loan Name",
                      hint: "e.g. Home Loan",
                      icon: Icons.title),
                  const SizedBox(height: 16),
                  _buildBankSelector(),
                  const SizedBox(height: 16),
                  _buildTextField(
                      controller: _accountNoCtrl,
                      label: "Loan Account No",
                      hint: "e.g. L-19283746",
                      icon: Icons.numbers),
                  const SizedBox(height: 32),
                  _buildSectionLabel("TERMS & INTEREST"),
                  Row(
                    children: [
                      Expanded(
                          child: _buildTextField(
                              controller: _amountCtrl,
                              label: "Loan Amount",
                              hint: "Principal",
                              icon: Icons.currency_rupee,
                              isNumber: true)),
                      const SizedBox(width: 16),
                      Expanded(
                          child: _buildTextField(
                              controller: _rateCtrl,
                              label: "Interest Rate",
                              hint: "% p.a.",
                              icon: Icons.percent,
                              isNumber: true)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                          child: _buildTextField(
                              controller: _tenureCtrl,
                              label: "Tenure",
                              hint: "Months",
                              icon: Icons.calendar_view_month,
                              isNumber: true)),
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
                      label: "Total Payable",
                      hint: "Auto-calculated",
                      icon: Icons.account_balance_wallet,
                      isNumber: true),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                          child: _buildTextField(
                              controller: _emiCtrl,
                              label: "EMI Amount",
                              hint: "Monthly",
                              icon: Icons.repeat,
                              isNumber: true)),
                      const SizedBox(width: 16),
                      Expanded(
                          child: _buildDatePicker(
                              label: "First EMI Date",
                              date: _emiDate,
                              onPick: (d) => setState(() {
                                    _emiDate = d;
                                    _calculateLoanDetails(); // [UPDATED] Recalculate end date if EMI date changes
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
                child: const Text("CREATE LOAN",
                    style: TextStyle(
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

  Widget _buildTextField(
      {required TextEditingController controller,
      required String label,
      required String hint,
      required IconData icon,
      bool isNumber = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: isNumber
              ? const TextInputType.numberWithOptions(decimal: true)
              : TextInputType.text,
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

  Widget _buildDatePicker(
      {required String label,
      required DateTime date,
      required Function(DateTime) onPick}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
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
    final totalPayable = double.tryParse(_totalPayableCtrl.text);
    final principal = double.tryParse(_amountCtrl.text); // Get Principal
    final emi = double.tryParse(_emiCtrl.text);
    final rate = double.tryParse(_rateCtrl.text);

    if (_nameCtrl.text.isEmpty || totalPayable == null || totalPayable <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please enter valid loan details")));
      return;
    }

    final loan = LoanModel(
      id: '',
      title: _nameCtrl.text,
      provider: _selectedBank,
      principalAmount: principal ?? 0, // [FIX] Now properly saving Principal
      totalAmount: totalPayable,
      paidAmount: 0,
      interestRate: rate ?? 0,
      type: 'BORROWED',
      startDate: _startDate,
      dueDate: _endDate,
      emiAmount: emi,
      nextPaymentDate: _emiDate,
      isClosed: false,
      notes: "Account: ${_accountNoCtrl.text}",
    );

    GetIt.I<GoalLoanService>().createLoan(loan);
    Navigator.pop(context);
  }
}
