import 'dart:math';
import 'package:budget/core/widgets/futuristic_loader.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import '../../../core/design/budgetr_colors.dart';
import '../../../core/design/budgetr_styles.dart';
import '../services/goal_loan_service.dart';
import '../models/goal_loan_models.dart';
import '../widgets/add_loan_sheet.dart';

class LoanDetailScreen extends StatefulWidget {
  final LoanModel loan;
  const LoanDetailScreen({super.key, required this.loan});

  @override
  State<LoanDetailScreen> createState() => _LoanDetailScreenState();
}

class _LoanDetailScreenState extends State<LoanDetailScreen> {
  final _amountCtrl = TextEditingController();
  int _paymentMode = 0;
  DateTime _txnDate = DateTime.now();
  bool _isAdding = false;
  bool _showDetails = false;

  // Helper method to accurately add months handling month-end edge cases
  DateTime _addMonths(DateTime date, int months) {
    final newYear = date.year + (date.month + months - 1) ~/ 12;
    final newMonth = (date.month + months - 1) % 12 + 1;
    final lastDayOfNewMonth = DateTime(newYear, newMonth + 1, 0).day;
    final newDay = date.day > lastDayOfNewMonth ? lastDayOfNewMonth : date.day;
    return DateTime(newYear, newMonth, newDay);
  }

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

    return StreamBuilder<LoanModel>(
        stream: GetIt.I<GoalLoanService>().watchLoan(widget.loan.id),
        initialData: widget.loan,
        builder: (context, loanSnapshot) {
          if (!loanSnapshot.hasData && loanSnapshot.data == null) {
            return const Scaffold(
                backgroundColor: Color(0xFF0F172A),
                body: Center(
                    child: FuturisticLoader(
                        size: 80, label: "DECRYPTING LEDGER...")));
          }

          final liveLoan = loanSnapshot.data ?? widget.loan;

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
              title: Text(liveLoan.title.toUpperCase(),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2)),
              actions: [
                _buildAppBarButton(
                  icon: liveLoan.isClosed ? Icons.replay : Icons.verified,
                  color: liveLoan.isClosed ? Colors.orangeAccent : BudgetrColors.success,
                  onTap: () => _confirmToggleLoanStatus(liveLoan),
                ),
                const SizedBox(width: 8),
                _buildAppBarButton(
                  icon: Icons.edit,
                  color: Colors.blueAccent,
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => AddLoanSheet(loanToEdit: liveLoan),
                    );
                  },
                ),
                const SizedBox(width: 8),
                _buildAppBarButton(
                  icon: Icons.delete_outline,
                  color: BudgetrColors.error,
                  onTap: () => _confirmDeleteLoan(liveLoan.id),
                ),
                const SizedBox(width: 12),
              ],
            ),
            body: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    child: _buildLoanSummary(liveLoan, color),
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
                        border:
                            Border.all(color: Colors.white.withOpacity(0.05)),
                      ),
                      child: Row(
                        children: [
                          _buildTabButton(
                              "PAY EMI", 0, color, liveLoan.emiAmount),
                          _buildTabButton("EXTRA PAYMENT", 1,
                              const Color(0xFF00E676), liveLoan.emiAmount),
                        ],
                      ),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildTransactionForm(liveLoan.id, color, liveLoan.isClosed),
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
                _buildLedgerList(liveLoan.id, color),
                const SliverToBoxAdapter(child: SizedBox(height: 50)),
              ],
            ),
          );
        });
  }

  Widget _buildAppBarButton(
      {required IconData icon,
      required Color color,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Icon(icon, size: 20, color: color),
      ),
    );
  }

  Widget _buildTabButton(
      String label, int index, Color activeColor, double? emiAmount) {
    final isSelected = _paymentMode == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _paymentMode = index;
            if (index == 0 && emiAmount != null) {
              _amountCtrl.text = emiAmount.toStringAsFixed(2);
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

  Widget _buildLoanSummary(LoanModel liveLoan, Color themeColor) {
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
        final totalInterest = liveLoan.totalAmount - liveLoan.principalAmount;

        // DB controls the absolute Next EMI Date now, no frontend shifting needed.
        DateTime targetNextEmiDate = liveLoan.nextPaymentDate ?? liveLoan.startDate;

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
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text("Outstanding Balance",
                                      style: TextStyle(
                                          color: Colors.white54, fontSize: 14)),
                                  const SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: () => setState(() => _showDetails = !_showDetails),
                                    child: const Icon(Icons.info_outline, color: Colors.white54, size: 16),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text("₹${currencyFmt.format(outstanding)}",
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: -0.5)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: themeColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                              "${(progress * 100).toStringAsFixed(2)}% Paid",
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
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 12)),
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
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 12)),
                            Expanded(
                                child: _buildStatColumn(
                                    "Total Interest", totalInterest,
                                    valueColor: Colors.white54)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (_showDetails)
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: const BoxDecoration(
                          border:
                              Border(top: BorderSide(color: Colors.white10))),
                      child: Column(
                        children: [
                          _buildDetailRow("Bank / Provider", liveLoan.provider),
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
                              DateFormat('dd/MM/yyyy').format(targetNextEmiDate)),
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
            _buildSmartLoanInsights(realPaidAmount, liveLoan),
          ],
        );
      },
    );
  }

  Widget _buildSmartLoanInsights(double paid, LoanModel liveLoan) {
    final now = DateTime.now();
    final remaining = liveLoan.totalAmount - paid;

    String statusLabel = "STATUS";
    String statusValue = "--";
    Color statusColor = Colors.white;
    String debtFreeLabel = "NEXT DUE";
    String debtFreeValue = "--";

    if (remaining <= 0.01 || liveLoan.isClosed) {
      statusLabel = "STATUS";
      statusValue = "Closed";
      statusColor = BudgetrColors.success;
      debtFreeLabel = "DEBT FREE";
      debtFreeValue = "Achieved";
    } else if (liveLoan.emiAmount != null && liveLoan.emiAmount! > 0) {
      
      // Calculate absolute difference based on the precise database pointer
      DateTime targetDate = liveLoan.nextPaymentDate ?? liveLoan.startDate;
      final todayDay = DateTime(now.year, now.month, now.day);
      final nextDueDay = DateTime(targetDate.year, targetDate.month, targetDate.day);
      
      int monthDiff = (nextDueDay.year - todayDay.year) * 12 + nextDueDay.month - todayDay.month;
      final daysToNextDue = nextDueDay.difference(todayDay).inDays;

      if (monthDiff < 0 || (monthDiff == 0 && nextDueDay.day < todayDay.day)) {
        statusLabel = "STATUS";
        statusValue = "Overdue";
        statusColor = BudgetrColors.error;
      } else if (monthDiff == 0 || monthDiff == 1) {
        statusLabel = "STATUS";
        statusValue = "On Track";
        statusColor = Colors.blueAccent;
      } else {
        statusLabel = "AHEAD";
        statusValue = "${monthDiff - 1} Mo. Ahead";
        statusColor = const Color(0xFF00E676);
      }

      debtFreeLabel = "NEXT EMI IN";
      if (daysToNextDue < 0) {
        debtFreeValue = "Past Due";
      } else if (daysToNextDue == 0) {
        debtFreeValue = "Today";
        if (statusColor != BudgetrColors.error) {
          statusColor = Colors.orangeAccent; 
        }
      } else if (daysToNextDue == 1) {
        debtFreeValue = "Tomorrow";
      } else {
        debtFreeValue = "$daysToNextDue Days";
      }

    } else {
      final monthsElapsed = max(1.0, now.difference(liveLoan.startDate).inDays / 30.0);
      final avgSpeed = paid / monthsElapsed;
      if (avgSpeed > 0) {
        final monthsLeft = remaining / avgSpeed;
        final finishDate = now.add(Duration(days: (monthsLeft * 30).toInt()));
        statusLabel = "AVG SPEED";
        statusValue = "₹${NumberFormat('#,##0.00').format(avgSpeed)}/mo";
        statusColor = Colors.white70;
        debtFreeLabel = "EST. PAYOFF";
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
          SizedBox(
            width: double.infinity,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(value,
                  style: TextStyle(
                      color: color, fontWeight: FontWeight.bold, fontSize: 14)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionForm(String loanId, Color themeColor, bool isClosed) {
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
                  enabled: !isClosed, 
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  style: TextStyle(
                      color: isClosed ? Colors.white38 : Colors.white,
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
                  onTap: isClosed ? null : () async {
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
                        Icon(Icons.calendar_today,
                            size: 14, color: isClosed ? Colors.white24 : Colors.white70),
                        const SizedBox(width: 8),
                        Text(DateFormat('dd/MM/yyyy').format(_txnDate),
                            style: TextStyle(
                                color: isClosed ? Colors.white38 : Colors.white, 
                                fontSize: 12)),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: (_isAdding || isClosed) ? null : () => _submitTransaction(loanId),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isClosed ? Colors.white12 : btnColor,
                    disabledBackgroundColor: Colors.white12,
                    foregroundColor: isClosed ? Colors.white38 : Colors.white,
                    disabledForegroundColor: Colors.white38,
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
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildLedgerList(String loanId, Color themeColor) {
    return StreamBuilder<List<AssetLogModel>>(
      stream: GetIt.I<GoalLoanService>().getLogsForParent(loanId),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SliverToBoxAdapter(child: SizedBox());
        }
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
                            Flexible(
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  alignment: Alignment.centerLeft,
                                  child: Text(
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
                                ),
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
                      Container(
                        constraints: const BoxConstraints(maxWidth: 130), 
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text("Paid",
                                style: TextStyle(
                                    color: Colors.white38, fontSize: 10)),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerRight,
                              child: Text(
                                  "₹${NumberFormat('#,##0.00').format(log.amount)}",
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15)),
                            ),
                          ],
                        ),
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
        FittedBox(
            fit: BoxFit.scaleDown,
            child:Text(
              "₹${NumberFormat('#,##0.00').format(val)}",
              style: TextStyle(
                  color: valueColor, fontSize: 15, fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(color: Colors.white38, fontSize: 13)),
        const SizedBox(width: 16),
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: Text(value,
                textAlign: TextAlign.right,
                style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w500)),
          ),
        ),
      ],
    );
  }

  Future<void> _submitTransaction(String loanId) async {
    final amount = double.tryParse(_amountCtrl.text);
    if (amount == null || amount <= 0) return;

    setState(() => _isAdding = true);

    try {
      await GetIt.I<GoalLoanService>().addLoanPayment(
          loanId, amount, _paymentMode == 0 ? 'EMI' : 'PREPAYMENT', _txnDate);

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

  void _confirmDeleteLoan(String loanId) {
    _showConfirmationSheet(
      title: "Delete Loan?",
      subtitle:
          "This will permanently delete this loan record and all payment history.",
      buttonText: "DELETE LOAN",
      onPressed: () async {
        Navigator.pop(context);
        await GetIt.I<GoalLoanService>().deleteLoan(loanId);
        if (mounted) Navigator.pop(context);
      },
    );
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
      },
    );
  }

  void _confirmToggleLoanStatus(LoanModel loan) {
    final willClose = !loan.isClosed;
    _showConfirmationSheet(
      title: willClose ? "Mark Loan as Closed?" : "Reopen Loan?",
      subtitle: willClose
          ? "This will move the loan to your history. You can still add extra payments if needed."
          : "This will move the loan back to your active dashboard.",
      buttonText: willClose ? "CLOSE LOAN" : "REOPEN LOAN",
      onPressed: () async {
        Navigator.pop(context);
        await GetIt.I<GoalLoanService>().toggleLoanClosure(loan.id, willClose);
      },
    );
  }

  void _showConfirmationSheet(
      {required String title,
      required String subtitle,
      required String buttonText,
      required VoidCallback onPressed}) {
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