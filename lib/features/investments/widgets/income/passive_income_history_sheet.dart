import 'package:budget/core/database/app_database.dart';
import 'package:budget/core/design/budgetr_colors.dart';
import 'package:budget/core/widgets/status_bottom_sheet.dart';
import 'package:budget/features/investments/database/passive_income_tables.dart';
import 'package:budget/features/investments/services/passive_income_service.dart';
import 'package:budget/features/investments/widgets/income/passive_income_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart'; // [Required]
import 'package:intl/intl.dart';

class PassiveIncomeHistorySheet extends StatelessWidget {
  final int investmentId;

  const PassiveIncomeHistorySheet({super.key, required this.investmentId});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Color(0xFF1B263B),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
                color: Colors.white24, borderRadius: BorderRadius.circular(2)),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "INCOME HISTORY",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: Colors.amber),
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) =>
                          PassiveIncomeSheet(investmentId: investmentId),
                    );
                  },
                )
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<PassiveIncomeLog>>(
              stream: PassiveIncomeService().watchLogs(investmentId),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text("No income recorded yet",
                        style: TextStyle(color: Colors.white.withOpacity(0.3))),
                  );
                }

                // Modern List with Auto-Close behavior
                return SlidableAutoCloseBehavior(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: snapshot.data!.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 8), // Clean spacing
                    itemBuilder: (context, index) {
                      final log = snapshot.data![index];

                      return Slidable(
                        key: ValueKey(log.id),

                        // --- SWIPE LEFT: DELETE ACTION ---
                        endActionPane: ActionPane(
                          motion: const ScrollMotion(),
                          extentRatio: 0.25,
                          children: [
                            SizedBox(
                              width: 6,
                            ), // Spacer to prevent accidental taps
                            // Spacer to prevent accidental taps
                            SlidableAction(
                              onPressed: (_) =>
                                  _showDeleteSheet(context, log.id),
                              backgroundColor: const Color(0xFFFE4A49),
                              foregroundColor: Colors.white,
                              icon: Icons.delete_rounded,
                              label: 'Delete',
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 8),
                              borderRadius: BorderRadius.circular(
                                  12), // Matches card style
                            ),
                          ],
                        ),

                        // --- MAIN CONTENT ---
                        child: Container(
                          // Note: Margin removed here, handled by separatorBuilder for better sliding
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.amber.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Text("₹",
                                    style: TextStyle(
                                        color: Colors.amber,
                                        fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      log.type.toUpperCase(),
                                      style: TextStyle(
                                          color: Colors.white.withOpacity(0.5),
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      DateFormat('dd MMM yyyy')
                                          .format(log.date),
                                      style: const TextStyle(
                                          color: Colors.white70, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                "+ ₹${log.amount.toStringAsFixed(0)}",
                                style: const TextStyle(
                                    color: Colors.amber,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteSheet(BuildContext context, int logId) {
    showStatusSheet(
      context: context,
      title: "Delete Income?",
      message: "This will remove this record from your history permanently.",
      icon: Icons.delete_forever_rounded,
      color: Colors.redAccent,
      buttonText: "Delete",
      cancelButtonText: "Cancel",
      onCancel: () {},
      onDismiss: () async {
        await PassiveIncomeService().deleteLog(logId);
      },
    );
  }
}
