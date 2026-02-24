import 'package:budget/core/widgets/futuristic_loader.dart';
import 'package:budget/core/widgets/glass_card.dart';
import 'package:budget/core/widgets/modern_app_bar.dart';
import 'package:budget/features/recurring/models/recurring_models.dart';
import 'package:budget/features/recurring/screens/recurring_editor_screen.dart';
import 'package:budget/features/recurring/services/recurring_service.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

class RecurringDashboard extends StatelessWidget {
  const RecurringDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0D1B2A),
      body: SafeArea(
        child: Column(
          children: [
            ModernAppBar(
              title: "Recurring Transactions",
              subtitle: "AUTOMATED",
              trailingIcon: Icons.add_rounded,
              onTrailingPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const RecurringEditorScreen())),
            ),

            // [IMPROVED] FEATURE RICH FORECASTING
            _buildForecastingCard(),

            Expanded(
              child: StreamBuilder<List<RecurringPatternModel>>(
                stream: GetIt.I<RecurringService>().getPatternsStream(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                        child: Text("Error: ${snapshot.error}",
                            style: const TextStyle(color: Colors.red)));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: FuturisticLoader(
                        size: 80,
                        label: "LOADING TRANSACTIONS...",
                      ),
                    );
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return _buildEmptyState();
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) =>
                        _buildTimelineCard(context, snapshot.data![index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForecastingCard() {
    return StreamBuilder<Map<String, double>>(
        stream: GetIt.I<RecurringService>().getForecastingStream(),
        initialData: const {'liquidity': 0.0, 'bills': 0.0, 'safe': 0.0},
        builder: (context, snapshot) {
          final data = snapshot.data!;
          final liquidity = data['liquidity']!;
          final bills = data['bills']!;
          final safe = data['safe']!;

          // Calculate Health Metrics
          double usageRatio = liquidity == 0 ? 0 : (bills / liquidity);
          if (usageRatio > 1) usageRatio = 1;

          String status;
          Color statusColor;
          IconData statusIcon;

          if (liquidity < bills) {
            status = "CRITICAL";
            statusColor = Colors.redAccent;
            statusIcon = Icons.warning_amber_rounded;
          } else if (usageRatio > 0.5) {
            status = "CAUTION";
            statusColor = Colors.orangeAccent;
            statusIcon = Icons.info_outline;
          } else {
            status = "HEALTHY";
            statusColor = const Color(0xFF00B4D8);
            statusIcon = Icons.check_circle_outline;
          }

          return GlassCard(
              borderRadius: 8,
              margin: const EdgeInsets.only(
                  top: 2, left: 12, right: 12, bottom: 18),
              padding: const EdgeInsets.all(12),
              child: Column(children: [
                // Header: Status Pill
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("30-DAY OUTLOOK",
                                style: TextStyle(
                                    color: Colors.white38,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2)),
                            const SizedBox(height: 4),
                            Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                    color: statusColor.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                        color: statusColor.withOpacity(0.5))),
                                child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(statusIcon,
                                          color: statusColor, size: 12),
                                      const SizedBox(width: 6),
                                      Text(status,
                                          style: TextStyle(
                                              color: statusColor,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w900))
                                    ]))
                          ]),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text("FREE TO SPEND",
                                style: TextStyle(
                                    color: Colors.white38,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold)),
                            Text("₹${safe.toStringAsFixed(2)}",
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold))
                          ])
                    ]),
                const SizedBox(height: 20),

                // Visual Bar
                ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: usageRatio,
                      backgroundColor: Colors.white10,
                      valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                      minHeight: 8,
                    )),
                const SizedBox(height: 8),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                          "${(usageRatio * 100).toStringAsFixed(2)}% Committed",
                          style: TextStyle(color: statusColor, fontSize: 10)),
                      Text("Total Money: ₹${liquidity.toStringAsFixed(2)}",
                          style: const TextStyle(
                              color: Colors.white38, fontSize: 10))
                    ]),

                const SizedBox(height: 16),
                Container(height: 1, color: Colors.white10),
                const SizedBox(height: 16),

                // Breakdown
                Row(children: [
                  Expanded(
                      child: _miniStat(
                          Icons.account_balance_wallet,
                          "Total Money",
                          "₹${liquidity.toStringAsFixed(2)}",
                          Colors.white70)),
                  Container(width: 1, height: 30, color: Colors.white10),
                  Expanded(
                      child: Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: _miniStat(Icons.receipt_long, "Upcoming Bills",
                              "₹${bills.toStringAsFixed(2)}", Colors.white))),
                ])
              ]));
        });
  }

  Widget _miniStat(IconData icon, String label, String value, Color color) {
    return Row(children: [
      Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05), shape: BoxShape.circle),
          child: Icon(icon, color: Colors.white54, size: 16)),
      const SizedBox(width: 12),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style: const TextStyle(
                color: Colors.white30,
                fontSize: 10,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(value,
            style: TextStyle(
                color: color, fontSize: 14, fontWeight: FontWeight.bold))
      ])
    ]);
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today_rounded,
              size: 60, color: Colors.white.withOpacity(0.1)),
          const SizedBox(height: 16),
          Text("No Scheduled Payments",
              style: TextStyle(color: Colors.white.withOpacity(0.5))),
        ],
      ),
    );
  }

  Widget _buildTimelineCard(BuildContext context, RecurringPatternModel item) {
    final now = DateTime.now();
    final isOverdue = item.nextRunAt.isBefore(now);
    final daysLeft = item.nextRunAt.difference(now).inDays;

    Color statusColor = isOverdue
        ? Colors.redAccent
        : (daysLeft == 0 ? Colors.amber : const Color(0xFF00B4D8));
    String statusText = isOverdue
        ? "OVERDUE"
        : (daysLeft == 0 ? "DUE TODAY" : "IN $daysLeft DAYS");

    final hasLogo = item.website != null && item.website!.isNotEmpty;
    final logoUrl =
        "https://www.google.com/s2/favicons?domain=${item.website}&sz=64";

    return GestureDetector(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => RecurringEditorScreen(pattern: item))),
      child: GlassCard(
        borderRadius: 8,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(4),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(8))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(DateFormat('MMM dd • hh:mm a').format(item.nextRunAt),
                      style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12)),
                  Text(statusText,
                      style: TextStyle(
                          color: statusColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w900)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    padding: hasLogo
                        ? const EdgeInsets.all(4)
                        : const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        shape: BoxShape.circle),
                    child: hasLogo
                        ? ClipOval(
                            child: Image.network(logoUrl,
                                errorBuilder: (c, e, s) => const Icon(
                                    Icons.receipt_long,
                                    color: Colors.white)))
                        : Icon(
                            item.type == 'Income'
                                ? Icons.arrow_downward
                                : Icons.receipt_long,
                            color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.name,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16)),
                        Row(children: [
                          if (item.isVariable)
                            Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 4, vertical: 2),
                                margin: const EdgeInsets.only(right: 6),
                                decoration: BoxDecoration(
                                    color: Colors.orange.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(4)),
                                child: const Text("VARIABLE",
                                    style: TextStyle(
                                        fontSize: 8, color: Colors.orange))),
                          Text("${item.category} • ${item.bucket}",
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.5),
                                  fontSize: 12)),
                        ])
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      item.isVariable
                          ? const Text("Waiting",
                              style:
                                  TextStyle(color: Colors.orange, fontSize: 14))
                          : Text("₹${item.amount.toStringAsFixed(0)}",
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16)),
                      const SizedBox(height: 4),
                      if (item.isVariable || !item.autoExecute)
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white10,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              minimumSize: const Size(60, 24)),
                          onPressed: () {
                            if (item.isVariable) {
                              _showVariablePaySheet(context, item);
                            } else {
                              GetIt.I<RecurringService>()
                                  .manualExecute(item.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text("Processing...")));
                            }
                          },
                          child: const Text("PAY NOW",
                              style:
                                  TextStyle(fontSize: 10, color: Colors.white)),
                        )
                    ],
                  ),
                ],
              ),
            ),
            if (daysLeft <= 3 && !isOverdue)
              InkWell(
                  onTap: () {
                    GetIt.I<RecurringService>().skipNextOccurrence(item.id);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("Skipped next occurrence")));
                  },
                  child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                          border:
                              Border(top: BorderSide(color: Colors.white10))),
                      child: const Text("Skip Next Occurrence",
                          style:
                              TextStyle(color: Colors.white38, fontSize: 10))))
          ],
        ),
      ),
    );
  }

  void _showVariablePaySheet(BuildContext context, RecurringPatternModel item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _VariablePaySheet(item: item),
    );
  }
}

class _VariablePaySheet extends StatefulWidget {
  final RecurringPatternModel item;
  const _VariablePaySheet({required this.item});

  @override
  State<_VariablePaySheet> createState() => _VariablePaySheetState();
}

class _VariablePaySheetState extends State<_VariablePaySheet> {
  final TextEditingController _amountCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xff0D1B2A).withOpacity(0.9),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 20,
              spreadRadius: 5)
        ],
      ),
      padding: EdgeInsets.only(
        top: 24,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "PAY ${widget.item.name.toUpperCase()}",
            style: const TextStyle(
                color: Colors.white38,
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5),
          ),
          const SizedBox(height: 16),
          const Text(
            "Enter Amount",
            style: TextStyle(
                color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white10),
            ),
            child: TextField(
              controller: _amountCtrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(
                  color: Color(0xFF00B4D8),
                  fontSize: 32,
                  fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                prefixText: "₹ ",
                prefixStyle: TextStyle(color: Colors.white54, fontSize: 32),
                border: InputBorder.none,
                hintText: "0.00",
                hintStyle: TextStyle(color: Colors.white10),
              ),
              autofocus: true,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00B4D8),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12))),
              onPressed: () {
                final amt = double.tryParse(_amountCtrl.text);
                if (amt != null && amt > 0) {
                  Navigator.pop(context);
                  GetIt.I<RecurringService>()
                      .manualExecute(widget.item.id, overrideAmount: amt);
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Payment Recorded")));
                }
              },
              child: const Text(
                "CONFIRM PAYMENT",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
