import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import '../../../core/design/budgetr_colors.dart';
import '../../../core/design/budgetr_styles.dart';
import '../services/goal_loan_service.dart';
import '../models/goal_loan_models.dart';
import '../widgets/add_goal_sheet.dart';

class GoalDetailScreen extends StatefulWidget {
  final GoalModel goal;
  const GoalDetailScreen({super.key, required this.goal});

  @override
  State<GoalDetailScreen> createState() => _GoalDetailScreenState();
}

class _GoalDetailScreenState extends State<GoalDetailScreen> {
  final _amountCtrl = TextEditingController();
  int _inputMode = 0;
  DateTime _txnDate = DateTime.now();
  bool _isAdding = false;
  bool _showDetails = false;

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // [FIX] Watch the specific Goal ID for real-time metadata updates (Name, Color, etc.)
    return StreamBuilder<GoalModel>(
        stream: GetIt.I<GoalLoanService>().watchGoal(widget.goal.id),
        initialData: widget.goal, // Show stale data while loading fresh
        builder: (context, goalSnap) {
          // If the goal is deleted, this might return null, handle gracefully
          if (!goalSnap.hasData && goalSnap.data == null) {
            return const Scaffold(
                backgroundColor: Color(0xFF0F172A),
                body: Center(child: CircularProgressIndicator()));
          }

          final liveGoal = goalSnap.data ?? widget.goal;
          final color = Color(liveGoal.color);

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
              // [FIX] Use liveGoal.name so title updates instantly
              title: Text(liveGoal.name.toUpperCase(),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2)),
              actions: [
                _buildAppBarButton(
                  icon: Icons.edit,
                  color: Colors.blueAccent,
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      // [FIX] Pass liveGoal so the edit sheet gets current data
                      builder: (_) => AddGoalSheet(goalToEdit: liveGoal),
                    );
                  },
                ),
                const SizedBox(width: 8),
                _buildAppBarButton(
                    icon: Icons.delete_outline,
                    color: BudgetrColors.error,
                    onTap: () => _confirmDeleteGoal(liveGoal.id)),
                const SizedBox(width: 12),
              ],
            ),
            body: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    // [FIX] Pass liveGoal to dashboard
                    child: _buildDashboardSection(liveGoal, color),
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
                          _buildTabButton("INVEST / WITHDRAW", 0, color),
                          _buildTabButton("CURRENT VALUE", 1, color),
                        ],
                      ),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    // [FIX] Pass liveGoal id
                    child: _buildTransactionForm(liveGoal.id, color),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(16, 32, 16, 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("ACTIVITY LEDGER",
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
                _buildLedgerList(liveGoal.id, color),
                const SliverToBoxAdapter(child: SizedBox(height: 50)),
              ],
            ),
          );
        });
  }

  // [NEW] Helper for Unique AppBar Buttons
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

  Widget _buildTabButton(String label, int index, Color color) {
    final isSelected = _inputMode == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          _inputMode = index;
          _amountCtrl.clear();
        }),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(label,
              style: TextStyle(
                  color: isSelected ? color : Colors.white38,
                  fontWeight: FontWeight.bold,
                  fontSize: 11)),
        ),
      ),
    );
  }

  // [FIX] Removed internal watchGoal, relying on passed liveGoal
  Widget _buildDashboardSection(GoalModel liveGoal, Color accentColor) {
    final currentVal = liveGoal.currentAmount;

    return StreamBuilder<List<AssetLogModel>>(
      stream: GetIt.I<GoalLoanService>().getLogsForParent(liveGoal.id),
      builder: (context, snapshot) {
        double totalPrincipal = 0;
        double totalReturns = 0;

        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          final logs = snapshot.data!;
          for (var log in logs) {
            totalPrincipal += (log.amount - log.interestComponent);
            totalReturns += log.interestComponent;
          }
        } else {
          if (currentVal > 0) totalPrincipal = currentVal;
        }

        final target = liveGoal.targetAmount;
        final isSurplus = currentVal >= target;
        final surplusAmount = currentVal - target;
        final rawProgress = (target == 0) ? 0.0 : (currentVal / target);
        final visualProgress = rawProgress.clamp(0.0, 1.0);

        final statusColor = isSurplus ? const Color(0xFFFFD700) : accentColor;
        final currencyFmt = NumberFormat('#,##0.00');

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
                border: Border.all(
                    color: isSurplus
                        ? statusColor.withOpacity(0.3)
                        : Colors.white.withOpacity(0.05)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                            Row(
                              children: [
                                const Text("Portfolio Value",
                                    style: TextStyle(
                                        color: Colors.white54, fontSize: 14)),
                                if (isSurplus) ...[
                                  const SizedBox(width: 8),
                                  const Icon(Icons.check_circle,
                                      size: 14, color: Color(0xFFFFD700))
                                ]
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text("₹${currencyFmt.format(currentVal)}",
                                style: TextStyle(
                                    color: isSurplus
                                        ? const Color(0xFFFFD700)
                                        : Colors.white,
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: -0.5)),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: isSurplus
                                  ? Border.all(
                                      color: statusColor.withOpacity(0.3))
                                  : null),
                          child: Text(
                              "${(rawProgress * 100).toStringAsFixed(1)}%",
                              style: TextStyle(
                                  color: statusColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14)),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(
                            value: visualProgress,
                            backgroundColor: Colors.black26,
                            color: statusColor,
                            minHeight: 8,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("₹0.00",
                                style: TextStyle(
                                    color: Colors.white24, fontSize: 12)),
                            Text("Target: ₹${currencyFmt.format(target)}",
                                style: const TextStyle(
                                    color: Colors.white54, fontSize: 12)),
                          ],
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Divider(height: 1, color: Colors.white10),
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      children: [
                        Expanded(
                            child:
                                _buildStatColumn("Invested", totalPrincipal)),
                        Container(
                            width: 1,
                            height: 40,
                            color: Colors.white10,
                            margin: const EdgeInsets.symmetric(horizontal: 12)),
                        Expanded(
                            child: _buildStatColumn("Returns", totalReturns,
                                valueColor: totalReturns >= 0
                                    ? BudgetrColors.success
                                    : BudgetrColors.error)),
                        Container(
                            width: 1,
                            height: 40,
                            color: Colors.white10,
                            margin: const EdgeInsets.symmetric(horizontal: 12)),
                        Expanded(
                            child: _buildStatColumn(
                                isSurplus ? "Surplus" : "Remaining",
                                isSurplus
                                    ? surplusAmount
                                    : (target - currentVal),
                                valueColor: isSurplus
                                    ? const Color(0xFF00E676)
                                    : Colors.white)),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () => setState(() => _showDetails = !_showDetails),
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
                          Text(_showDetails ? "Hide Info" : "View Asset Info",
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
                          border:
                              Border(top: BorderSide(color: Colors.white10))),
                      child: Column(
                        children: [
                          _buildDetailRow(
                              "Goal Purpose", liveGoal.purpose ?? "--"),
                          const SizedBox(height: 12),
                          _buildDetailRow(
                              "Asset Type", liveGoal.investmentType),
                          const SizedBox(height: 12),
                          _buildDetailRow("Reference ID",
                              liveGoal.identificationNumber ?? "--"),
                          const SizedBox(height: 12),
                          _buildDetailRow(
                              "Start Date",
                              DateFormat('dd MMM yyyy')
                                  .format(liveGoal.startDate)),
                          const SizedBox(height: 12),
                          _buildDetailRow(
                              "Target Date",
                              liveGoal.deadline != null
                                  ? DateFormat('dd MMM yyyy')
                                      .format(liveGoal.deadline!)
                                  : "No Deadline"),
                          if (liveGoal.expectedReturn != null) ...[
                            const SizedBox(height: 12),
                            _buildDetailRow(
                                "Exp. Return", "${liveGoal.expectedReturn}%"),
                          ]
                        ],
                      ),
                    )
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (!isSurplus && snapshot.hasData && snapshot.data!.isNotEmpty)
              _buildSmartInsights(
                  currentVal: currentVal,
                  target: target,
                  startDate: liveGoal.startDate,
                  deadline: liveGoal.deadline,
                  totalPrincipal: totalPrincipal,
                  expectedReturn: liveGoal.expectedReturn),
          ],
        );
      },
    );
  }

  Widget _buildSmartInsights({
    required double currentVal,
    required double target,
    required DateTime startDate,
    required DateTime? deadline,
    required double totalPrincipal,
    required double? expectedReturn,
  }) {
    final now = DateTime.now();
    final monthsActive = now.difference(startDate).inDays / 30;
    final effectiveMonths = monthsActive < 1 ? 1.0 : monthsActive;
    final avgMonthly = totalPrincipal / effectiveMonths;

    String label = "STATUS";
    String value = "On Track";
    Color color = BudgetrColors.success;
    IconData icon = Icons.check_circle;
    String subText = "Projected to finish early.";

    if (deadline != null) {
      final monthsRemaining = deadline.difference(now).inDays / 30;

      if (monthsRemaining > 0) {
        double requiredMonthly = 0;
        if (expectedReturn != null && expectedReturn > 0) {
          double r = (expectedReturn / 100) / 12;
          double n = monthsRemaining;
          double fvExisting = currentVal * pow((1 + r), n);
          double gap = target - fvExisting;
          if (gap > 0) {
            requiredMonthly = (gap * r) / (pow((1 + r), n) - 1);
          }
        } else {
          requiredMonthly = (target - currentVal) / monthsRemaining;
        }

        if (avgMonthly < requiredMonthly) {
          final shortfall = requiredMonthly - avgMonthly;
          label = "SHORTFALL / MO";
          value = "₹${NumberFormat.compact().format(shortfall)}";
          color = const Color(0xFFFF5252);
          icon = Icons.warning_amber_rounded;
          subText = expectedReturn != null && expectedReturn > 0
              ? "Assuming ${expectedReturn}% growth."
              : "Increase savings to hit target.";
        }
      } else {
        label = "STATUS";
        value = "Overdue";
        color = BudgetrColors.error;
        icon = Icons.error_outline;
        subText = "Target deadline passed.";
      }
    } else {
      if (avgMonthly > 0) {
        final monthsToGo = (target - currentVal) / avgMonthly;
        final finishDate = now.add(Duration(days: (monthsToGo * 30).toInt()));
        label = "EST. FINISH";
        value = DateFormat('MMM yyyy').format(finishDate);
        color = Colors.blueAccent;
        icon = Icons.event;
        subText = "Based on current pace.";
      }
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _buildInsightTile(
                "CUR. SPEED",
                "₹${NumberFormat.compact().format(avgMonthly)}/mo",
                Icons.speed,
                Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(label,
                          style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                              letterSpacing: 0.5)),
                      Icon(icon, size: 14, color: color),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(value,
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18)),
                  const SizedBox(height: 4),
                  Text(subText,
                      style:
                          const TextStyle(color: Colors.white54, fontSize: 10),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ),
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

  Widget _buildTransactionForm(String goalId, Color accentColor) {
    final isRevalue = _inputMode == 1;
    final hint = isRevalue ? "Enter Current Value (₹)" : "Enter Amount (₹)";
    final helper = isRevalue
        ? "We will calculate the Profit/Loss automatically."
        : "Investments add to Principal.";

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
                  onPressed:
                      _isAdding ? null : () => _submitTransaction(goalId),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
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
                      : Text(isRevalue ? "UPDATE VALUE" : "DEPOSIT",
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

  Widget _buildLedgerList(String goalId, Color color) {
    return StreamBuilder<List<AssetLogModel>>(
      stream: GetIt.I<GoalLoanService>().getLogsForParent(goalId),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const SliverToBoxAdapter(child: SizedBox());
        final logs = snapshot.data!;
        if (logs.isEmpty) {
          return const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(40),
              child: Center(
                  child: Text("No history available",
                      style: TextStyle(color: Colors.white24))),
            ),
          );
        }
        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final log = logs[index];
              final principal = log.amount - log.interestComponent;
              final isReval = log.type == 'Goal_Revaluation';

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  title: Row(
                    children: [
                      Text(DateFormat('dd/MM/yy').format(log.date),
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 13)),
                      const SizedBox(width: 12),
                      Container(width: 1, height: 12, color: Colors.white10),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          isReval
                              ? "Captai Gain/Loss"
                              : (principal > 0 ? "Deposit" : "Withdrawal"),
                          style: const TextStyle(
                              color: Colors.white, fontSize: 13),
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
                          if (principal != 0)
                            Text(
                                "${principal > 0 ? '+' : ''}${NumberFormat('#,##0.00').format(principal)}",
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14)),
                          if (log.interestComponent != 0)
                            Text(
                                "${log.interestComponent > 0 ? '+' : ''}${NumberFormat('#,##0.00').format(log.interestComponent)} (P&L)",
                                style: TextStyle(
                                    color: log.interestComponent >= 0
                                        ? BudgetrColors.success
                                        : BudgetrColors.error,
                                    fontSize: 11)),
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

  Future<void> _submitTransaction(String goalId) async {
    final amount = double.tryParse(_amountCtrl.text);
    if (amount == null) return;
    setState(() => _isAdding = true);
    try {
      if (_inputMode == 0) {
        await GetIt.I<GoalLoanService>()
            .addGoalContribution(goalId, amount, "Investment", _txnDate);
      } else {
        await GetIt.I<GoalLoanService>()
            .adjustGoalValue(goalId, amount, "Valuation Update", _txnDate);
      }
      if (mounted) {
        _amountCtrl.clear();
        FocusScope.of(context).unfocus();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Portfolio Updated"),
            backgroundColor: BudgetrColors.success,
            duration: Duration(seconds: 1)));
      }
    } catch (e) {
      // Error
    } finally {
      if (mounted) setState(() => _isAdding = false);
    }
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
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
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

  void _confirmDeleteGoal(String goalId) {
    _showConfirmationSheet(
      title: "Delete Goal?",
      subtitle:
          "This will permanently remove the goal and all related transaction history. This action cannot be undone.",
      buttonText: "DELETE GOAL",
      onPressed: () async {
        Navigator.pop(context);
        await GetIt.I<GoalLoanService>().deleteGoal(goalId);
        if (mounted) Navigator.pop(context);
      },
    );
  }

  void _confirmDeleteLog(String logId) {
    _showConfirmationSheet(
      title: "Revoke Entry?",
      subtitle:
          "This transaction will be removed from your ledger and portfolio balances will be reverted.",
      buttonText: "REVOKE",
      onPressed: () async {
        Navigator.pop(context);
        await GetIt.I<GoalLoanService>().deleteGoalLog(logId);
      },
    );
  }
}
