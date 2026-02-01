import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import '../../../core/design/budgetr_colors.dart';
import '../../../core/design/budgetr_styles.dart';
import '../services/goal_loan_service.dart';
import '../models/goal_loan_models.dart';
import '../widgets/add_loan_sheet.dart'; // [NEW] Import for editing

class LoanDetailScreen extends StatefulWidget {
  final LoanModel loan;
  const LoanDetailScreen({super.key, required this.loan});

  @override
  State<LoanDetailScreen> createState() => _LoanDetailScreenState();
}

class _LoanDetailScreenState extends State<LoanDetailScreen> {
  final _amountCtrl = TextEditingController();
  int _paymentMode = 0; // 0 = EMI, 1 = Prepayment
  DateTime _txnDate = DateTime.now();
  bool _isAdding = false;
  bool _showDetails = false;

  @override
  void initState() {
    super.initState();
    if (_paymentMode == 0 && widget.loan.emiAmount != null) {
      _amountCtrl.text = widget.loan.emiAmount!.toStringAsFixed(2);
    }
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = BudgetrColors.error;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F172A),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white70),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.loan.title.toUpperCase(),
            style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2)),
        actions: [
          // [NEW] Edit Button
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white70),
            tooltip: "Edit Loan",
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) =>
                    AddLoanSheet(loanToEdit: widget.loan), // Edit Mode
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.white54),
            tooltip: "Delete Loan",
            onPressed: _confirmDeleteLoan,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: _buildLoanSummary(color),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: Row(
                  children: [
                    _buildTabButton("PAY EMI", 0, color),
                    _buildTabButton(
                        "EXTRA PAYMENT", 1, const Color(0xFF00E676)),
                  ],
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildTransactionForm(color),
            ),
          ),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 32, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("REPAYMENT HISTORY",
                      style: TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0)),
                  Text("INR",
                      style: TextStyle(
                          color: Colors.white24,
                          fontSize: 10,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          _buildLedgerList(color),
          const SliverToBoxAdapter(child: SizedBox(height: 50)),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, int index, Color activeColor) {
    final isSelected = _paymentMode == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _paymentMode = index;
            if (index == 0 && widget.loan.emiAmount != null) {
              _amountCtrl.text = widget.loan.emiAmount!.toStringAsFixed(2);
            } else {
              _amountCtrl.clear();
            }
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color:
                isSelected ? activeColor.withOpacity(0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(label,
              style: TextStyle(
                  color: isSelected ? activeColor : Colors.white38,
                  fontWeight: FontWeight.bold,
                  fontSize: 11)),
        ),
      ),
    );
  }

  Widget _buildLoanSummary(Color themeColor) {
    // [NEW] Use watchLoan for real-time updates of loan details
    return StreamBuilder<LoanModel>(
      stream: GetIt.I<GoalLoanService>().watchLoan(widget.loan.id),
      builder: (context, loanSnapshot) {
        final liveLoan = loanSnapshot.data ?? widget.loan;

        return StreamBuilder<List<AssetLogModel>>(
          stream: GetIt.I<GoalLoanService>().getLogsForParent(liveLoan.id),
          builder: (context, snapshot) {
            double realPaidAmount = 0;
            if (snapshot.hasData) {
              for (var log in snapshot.data!) {
                realPaidAmount += log.amount;
              }
            } else {
              realPaidAmount = liveLoan.paidAmount;
            }

            final outstanding = liveLoan.totalAmount - realPaidAmount;
            final progress = (liveLoan.totalAmount == 0)
                ? 0.0
                : (realPaidAmount / liveLoan.totalAmount).clamp(0.0, 1.0);
            final currencyFmt = NumberFormat('#,##0.00');

            // Calculate Interest Portion
            final totalInterest =
                liveLoan.totalAmount - liveLoan.principalAmount;

            return Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4))
                    ],
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Outstanding Balance",
                                    style: TextStyle(
                                        color: Colors.white54, fontSize: 14)),
                                const SizedBox(height: 6),
                                Text("₹${currencyFmt.format(outstanding)}",
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: -0.5)),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: themeColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                  "${(progress * 100).toStringAsFixed(1)}% Paid",
                                  style: TextStyle(
                                      color: themeColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14)),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: Colors.black26,
                            color: themeColor,
                            minHeight: 8,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Divider(height: 1, color: Colors.white10),

                      // 4-Column Grid for Metrics
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                    child: _buildStatColumn(
                                        "Principal", liveLoan.principalAmount)),
                                Container(
                                    width: 1,
                                    height: 40,
                                    color: Colors.white10,
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 12)),
                                Expanded(
                                    child: _buildStatColumn(
                                        "Repaid", realPaidAmount,
                                        valueColor: BudgetrColors.success)),
                              ],
                            ),
                            const SizedBox(height: 24),
                            Row(
                              children: [
                                Expanded(
                                    child: _buildStatColumn(
                                        "Total Payable", liveLoan.totalAmount)),
                                Container(
                                    width: 1,
                                    height: 40,
                                    color: Colors.white10,
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 12)),
                                Expanded(
                                    child: _buildStatColumn(
                                        "Total Interest", totalInterest,
                                        valueColor: Colors.white54)),
                              ],
                            ),
                          ],
                        ),
                      ),

                      InkWell(
                        onTap: () =>
                            setState(() => _showDetails = !_showDetails),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.2),
                            borderRadius: const BorderRadius.vertical(
                                bottom: Radius.circular(16)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                  _showDetails
                                      ? "Hide Details"
                                      : "View Loan Details",
                                  style: const TextStyle(
                                      color: Colors.white54, fontSize: 12)),
                              const SizedBox(width: 8),
                              Icon(
                                  _showDetails
                                      ? Icons.keyboard_arrow_up
                                      : Icons.keyboard_arrow_down,
                                  color: Colors.white54,
                                  size: 16),
                            ],
                          ),
                        ),
                      ),

                      if (_showDetails)
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: const BoxDecoration(
                              border: Border(
                                  top: BorderSide(color: Colors.white10))),
                          child: Column(
                            children: [
                              _buildDetailRow(
                                  "Bank / Provider", liveLoan.provider),
                              const SizedBox(height: 12),
                              _buildDetailRow(
                                  "Loan Account", liveLoan.notes ?? "--"),
                              const SizedBox(height: 12),
                              _buildDetailRow("Interest Rate",
                                  "${liveLoan.interestRate}% p.a."),
                              const SizedBox(height: 12),
                              _buildDetailRow("EMI Amount",
                                  "₹${NumberFormat('#,##0.00').format(liveLoan.emiAmount ?? 0)}"),
                              const SizedBox(height: 12),
                              _buildDetailRow(
                                  "Next EMI Date",
                                  liveLoan.nextPaymentDate != null
                                      ? DateFormat('dd/MM/yyyy')
                                          .format(liveLoan.nextPaymentDate!)
                                      : "N/A"),
                              const SizedBox(height: 12),
                              _buildDetailRow(
                                  "Start Date",
                                  DateFormat('dd/MM/yyyy')
                                      .format(liveLoan.startDate)),
                              const SizedBox(height: 12),
                              _buildDetailRow(
                                  "End Date",
                                  liveLoan.dueDate != null
                                      ? DateFormat('dd/MM/yyyy')
                                          .format(liveLoan.dueDate!)
                                      : "N/A"),
                            ],
                          ),
                        )
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // [NEW] INTELLIGENT INSIGHTS
                _buildSmartLoanInsights(realPaidAmount, liveLoan.totalAmount,
                    liveLoan.startDate, liveLoan.emiAmount),
              ],
            );
          },
        );
      },
    );
  }

// --- SMART LOAN INSIGHTS ---
  Widget _buildSmartLoanInsights(
      double paid, double total, DateTime start, double? emi) {
    final now = DateTime.now();
    final remaining = total - paid;
    final dueDate = widget.loan.dueDate; // Use the stored End Date

    // Default values
    String statusLabel = "STATUS";
    String statusValue = "--";
    Color statusColor = Colors.white;
    String debtFreeLabel = "DEBT FREE";
    String debtFreeValue = "--";

    if (remaining <= 10) {
      // Tolerance for rounding errors
      // Loan Closed
      statusLabel = "STATUS";
      statusValue = "Closed";
      statusColor = BudgetrColors.success;
      debtFreeValue = "Achieved";
    } else if (emi != null && emi > 0 && dueDate != null) {
      // 1. Calculate Expected Progress based on Schedule
      // We compare 'Now' vs 'Start' to see how many months have passed in the schedule
      // We calculate full months to avoid day-to-day fluctuations
      final monthsSinceStart =
          (now.year - start.year) * 12 + (now.month - start.month);
      final adjustedMonths = max(0, monthsSinceStart);

      final expectedPaid = adjustedMonths * emi;

      // 2. Determine Status (Ahead/Behind)
      // Tolerance of 0.9 EMI (If you paid this month's bill early, you are technically 'Ahead' until the due date passes)
      if (paid >= (expectedPaid + (emi * 0.9))) {
        // You have paid more than required for today
        final extraPaid = paid - expectedPaid;
        // If extra is significant (more than 1 EMI), show "Ahead"
        if (extraPaid >= emi) {
          final monthsAhead = (extraPaid / emi).floor();
          statusLabel = "SCHEDULE";
          statusValue = "$monthsAhead Mo. Ahead";
          statusColor = const Color(0xFF00E676); // Green
        } else {
          statusLabel = "STATUS";
          statusValue = "On Time";
          statusColor = BudgetrColors.success;
        }
      } else if (paid < (expectedPaid - (emi * 0.5))) {
        final overdue = expectedPaid - paid;
        statusLabel = "OVERDUE";
        statusValue = "₹${NumberFormat.compact().format(overdue)}";
        statusColor = BudgetrColors.error;
      } else {
        statusLabel = "STATUS";
        statusValue = "On Track";
        statusColor = Colors.blueAccent;
      }

      // 3. Calculate Debt Free Date (Projected)
      // Instead of adding days to Now, we subtract time from Due Date if prepaid

      // How many EMIs are actually remaining mathematically?
      final installmentsLeft = (remaining / emi).ceil();

      // When is the next payment technically due?
      // If we use 'now' as anchor, we include the current month if not paid.
      // But a better approach for projection:
      // Projected Date = Start Date + (Total Installments Needed) Months

      // Total installments needed for the WHOLE loan based on current behavior
      // = Already Paid Count (paid/emi) + Remaining Count (remaining/emi)
      // This accounts for prepayments shortening the tenure.

      final totalMonthsNeeded =
          (widget.loan.totalAmount / emi).ceil(); // Original Tenure
      final currentTenureMonths = ((paid + remaining) / emi)
          .ceil(); // Should match original unless total changed

      // Let's stick to the simplest projection:
      // If I pay EMI every month from *Today* onwards, when do I finish?
      // But we must align with the payment cycle.

      DateTime projectedFinish;

      if (statusValue.contains("Ahead")) {
        // If ahead, we finish earlier than Due Date
        // Calculate months saved
        final monthsSaved = (paid - expectedPaid) / emi;
        // Subtract saved months from Due Date
        // We use a safe date subtraction logic
        final totalMonthsOriginal =
            (dueDate.year - start.year) * 12 + (dueDate.month - start.month);
        final newDurationMonths = totalMonthsOriginal - monthsSaved.floor();

        projectedFinish = DateTime(start.year + (newDurationMonths ~/ 12),
            start.month + (newDurationMonths % 12), start.day);
      } else {
        // If on track or behind, assume we finish on the scheduled Due Date
        // We don't push the date further for overdue (usually), unless we assume default.
        // For "On Track", strictly show the Scheduled Date.
        projectedFinish = dueDate;
      }

      debtFreeValue = DateFormat('MMM yyyy').format(projectedFinish);
    } else {
      // Non-EMI Loan (Velocity Based fallback)
      final monthsElapsed = max(1, now.difference(start).inDays / 30);
      final avgSpeed = paid / monthsElapsed;

      if (avgSpeed > 0) {
        final monthsLeft = remaining / avgSpeed;
        final finishDate = now.add(Duration(days: (monthsLeft * 30).toInt()));
        statusLabel = "AVG SPEED";
        statusValue = "₹${NumberFormat.compact().format(avgSpeed)}/mo";
        statusColor = Colors.white70;
        debtFreeValue = DateFormat('MMM yyyy').format(finishDate);
      } else {
        statusValue = "No Payments";
        debtFreeValue = "Unknown";
      }
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
              child: _buildInsightTile(
                  statusLabel, statusValue, Icons.analytics, statusColor)),
          const SizedBox(width: 12),
          Expanded(
              child: _buildInsightTile(debtFreeLabel, debtFreeValue,
                  Icons.event_available, Colors.white)),
        ],
      ),
    );
  }

  Widget _buildInsightTile(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 12, color: Colors.white38),
              const SizedBox(width: 6),
              Expanded(
                child: Text(label,
                    style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 10,
                        fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(value,
              style: TextStyle(
                  color: color, fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildTransactionForm(Color themeColor) {
    final isPrepay = _paymentMode == 1;
    final hint = isPrepay ? "Enter Extra Amount (₹)" : "EMI Amount (₹)";
    final helper = isPrepay
        ? "Extra payments reduce your principal & interest."
        : "Record your monthly installment.";
    final btnColor = isPrepay ? const Color(0xFF00E676) : themeColor;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(helper,
              style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 12,
                  fontStyle: FontStyle.italic)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _amountCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle:
                        const TextStyle(color: Colors.white12, fontSize: 18),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.05),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(height: 1, color: Colors.white.withOpacity(0.05)),
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () async {
                    final d = await showDatePicker(
                        context: context,
                        initialDate: _txnDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                        builder: (c, child) =>
                            Theme(data: ThemeData.dark(), child: child!));
                    if (d != null) setState(() => _txnDate = d);
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today,
                            size: 14, color: Colors.white70),
                        const SizedBox(width: 8),
                        Text(DateFormat('dd/MM/yyyy').format(_txnDate),
                            style: const TextStyle(
                                color: Colors.white, fontSize: 12)),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: _isAdding ? null : _submitTransaction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: btnColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                  child: _isAdding
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : Text(isPrepay ? "ADD EXTRA" : "PAY EMI",
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildLedgerList(Color themeColor) {
    return StreamBuilder<List<AssetLogModel>>(
      stream: GetIt.I<GoalLoanService>().getLogsForParent(widget.loan.id),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const SliverToBoxAdapter(child: SizedBox());
        final logs = snapshot.data!;

        if (logs.isEmpty) {
          return const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: Center(
                  child: Text("No payments recorded",
                      style: TextStyle(color: Colors.white24))),
            ),
          );
        }

        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final log = logs[index];
              final isExtra = log.type == 'Loan_Prepayment';

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(12),
                  border: isExtra
                      ? Border.all(
                          color: const Color(0xFF00E676).withOpacity(0.3))
                      : null,
                ),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  title: Row(
                    children: [
                      Text(DateFormat('dd MMM').format(log.date),
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 13)),
                      const SizedBox(width: 12),
                      Container(width: 1, height: 12, color: Colors.white10),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Row(
                          children: [
                            Text(
                              isExtra ? "Extra Payment" : "EMI Payment",
                              style: TextStyle(
                                  color: isExtra
                                      ? const Color(0xFF00E676)
                                      : Colors.white,
                                  fontSize: 13,
                                  fontWeight: isExtra
                                      ? FontWeight.bold
                                      : FontWeight.normal),
                            ),
                            if (isExtra) ...[
                              const SizedBox(width: 6),
                              const Icon(Icons.star,
                                  size: 10, color: Color(0xFF00E676))
                            ]
                          ],
                        ),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text("Paid",
                              style: TextStyle(
                                  color: Colors.white38, fontSize: 10)),
                          Text(
                              "₹${NumberFormat('#,##0.00').format(log.amount)}",
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15)),
                        ],
                      ),
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: () => _confirmDeleteLog(log.id),
                        child: Icon(Icons.delete_outline,
                            color: Colors.white.withOpacity(0.3), size: 18),
                      ),
                    ],
                  ),
                ),
              );
            },
            childCount: logs.length,
          ),
        );
      },
    );
  }

  Widget _buildStatColumn(String label, double val,
      {Color valueColor = Colors.white}) {
    return Column(
      children: [
        Text(label,
            style: const TextStyle(color: Colors.white38, fontSize: 11),
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
        const SizedBox(height: 4),
        Text(
          "₹${NumberFormat('#,##0.00').format(val)}",
          style: TextStyle(
              color: valueColor, fontSize: 15, fontWeight: FontWeight.bold),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(color: Colors.white38, fontSize: 13)),
        Text(value,
            style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w500)),
      ],
    );
  }

  Future<void> _submitTransaction() async {
    final amount = double.tryParse(_amountCtrl.text);
    if (amount == null || amount <= 0) return;

    setState(() => _isAdding = true);

    try {
      await GetIt.I<GoalLoanService>().addLoanPayment(widget.loan.id, amount,
          _paymentMode == 0 ? 'EMI' : 'PREPAYMENT', _txnDate);

      if (mounted) {
        _amountCtrl.clear();
        FocusScope.of(context).unfocus();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Payment Recorded"),
            backgroundColor: BudgetrColors.success,
            duration: Duration(seconds: 1)));
      }
    } catch (e) {
      // Error
    } finally {
      if (mounted) setState(() => _isAdding = false);
    }
  }

  void _confirmDeleteLoan() {
    _showConfirmationSheet(
        title: "Delete Loan?",
        subtitle:
            "This will permanently delete this loan record and all payment history.",
        buttonText: "DELETE LOAN",
        onPressed: () async {
          Navigator.pop(context);
          await GetIt.I<GoalLoanService>().deleteLoan(widget.loan.id);
          if (mounted) Navigator.pop(context);
        });
  }

  void _confirmDeleteLog(String logId) {
    _showConfirmationSheet(
        title: "Revoke Payment?",
        subtitle:
            "This payment will be removed and your outstanding balance will increase.",
        buttonText: "REVOKE",
        onPressed: () async {
          Navigator.pop(context);
          await GetIt.I<GoalLoanService>().deleteLoanLog(logId);
        });
  }

  void _showConfirmationSheet({
    required String title,
    required String subtitle,
    required String buttonText,
    required VoidCallback onPressed,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Color(0xFF1E293B),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            const Icon(Icons.warning_amber_rounded,
                size: 48, color: Color(0xFFFF5252)),
            const SizedBox(height: 16),
            Text(title,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white54, fontSize: 14)),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                    child: TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text("Cancel",
                            style: TextStyle(color: Colors.white70)))),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF5252),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(buttonText,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
