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
              title: "Planned Payments",
              subtitle: "TIMELINE",
              trailingIcon: Icons.add_rounded,
              onTrailingPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const RecurringEditorScreen())),
            ),
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
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return _buildEmptyState();
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
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

    return GestureDetector(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) => RecurringEditorScreen(pattern: item))),
      child: GlassCard(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(16))),
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
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        shape: BoxShape.circle),
                    child: Icon(
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
                        Text("${item.category} • ${item.bucket}",
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                                fontSize: 12)),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text("₹${item.amount.toStringAsFixed(0)}",
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                      if (!item.autoExecute)
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white10,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              minimumSize: const Size(60, 24)),
                          onPressed: () {
                            GetIt.I<RecurringService>().manualExecute(item.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text("Processing...")));
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
          ],
        ),
      ),
    );
  }
}
