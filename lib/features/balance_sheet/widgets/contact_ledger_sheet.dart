import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import '../../../core/design/budgetr_colors.dart';
import '../models/balance_sheet_model.dart';
import '../services/balance_sheet_service.dart';

class ContactLedgerSheet extends StatelessWidget {
  final String contactName;

  const ContactLedgerSheet({super.key, required this.contactName});

  @override
  Widget build(BuildContext context) {
    final _service = GetIt.I<BalanceSheetService>();
    final _currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: BudgetrColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(10))),
          const SizedBox(height: 24),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      shape: BoxShape.circle),
                  child: const Icon(Icons.person_rounded,
                      color: Colors.white, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("CONTACT LEDGER",
                          style: TextStyle(
                              color: Colors.white38,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5)),
                      const SizedBox(height: 4),
                      Text(contactName.toUpperCase(),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w900)),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        shape: BoxShape.circle),
                    child: const Icon(Icons.close_rounded,
                        color: Colors.white54, size: 20),
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Stream Content
          Expanded(
            child: StreamBuilder<List<BalanceSheetModel>>(
              stream: _service.watchContactEntries(contactName),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return const Center(child: CircularProgressIndicator());

                final entries = snapshot.data!;
                if (entries.isEmpty) {
                  return const Center(
                      child: Text("No records found.",
                          style: TextStyle(color: Colors.white38)));
                }

                // Math Logic
                double oweYou = 0; // Assets
                double youOwe = 0; // Liabilities

                for (var e in entries) {
                  if (!e.isSettled) {
                    double remaining = e.amount - e.settledAmount;
                    if (e.entryType == 'ASSET')
                      oweYou += remaining;
                    else
                      youOwe += remaining;
                  }
                }

                double netBalance = oweYou - youOwe;
                bool youAreOwed = netBalance >= 0;
                Color statusColor =
                    youAreOwed ? BudgetrColors.success : BudgetrColors.error;

                return Column(
                  children: [
                    // Net Balance Card
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                          color: BudgetrColors.cardSurface,
                          borderRadius: BorderRadius.circular(16),
                          border:
                              Border.all(color: statusColor.withOpacity(0.3)),
                          boxShadow: [
                            BoxShadow(
                                color: statusColor.withOpacity(0.1),
                                blurRadius: 15,
                                offset: const Offset(0, 5))
                          ]),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("THEY OWE YOU",
                                      style: TextStyle(
                                          color: Colors.white54,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  Text(_currency.format(oweYou),
                                      style: const TextStyle(
                                          color: BudgetrColors.success,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                              Container(
                                  height: 24,
                                  width: 1,
                                  color: Colors.white.withOpacity(0.1)),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text("YOU OWE THEM",
                                      style: TextStyle(
                                          color: Colors.white54,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  Text(_currency.format(youOwe),
                                      style: const TextStyle(
                                          color: BudgetrColors.error,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ],
                          ),
                          Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Divider(
                                  height: 1,
                                  color: Colors.white.withOpacity(0.1))),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(youAreOwed ? "NET TO RECEIVE" : "NET TO PAY",
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 1)),
                              Text(_currency.format(netBalance.abs()),
                                  style: TextStyle(
                                      color: statusColor,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900)),
                            ],
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Ledger List
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 8),
                        itemCount: entries.length,
                        itemBuilder: (context, index) {
                          final e = entries[index];
                          bool isAsset = e.entryType == 'ASSET';
                          Color eColor = isAsset
                              ? BudgetrColors.success
                              : BudgetrColors.error;
                          double remaining = e.amount - e.settledAmount;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                                color: e.isSettled
                                    ? Colors.white.withOpacity(0.01)
                                    : Colors.white.withOpacity(0.02),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: Colors.white.withOpacity(0.03))),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                      color: e.isSettled
                                          ? Colors.white10
                                          : eColor.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(8)),
                                  child: Icon(
                                      isAsset
                                          ? Icons.call_received_rounded
                                          : Icons.call_made_rounded,
                                      color:
                                          e.isSettled ? Colors.white38 : eColor,
                                      size: 16),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(e.title,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              decoration: e.isSettled
                                                  ? TextDecoration.lineThrough
                                                  : null)),
                                      const SizedBox(height: 4),
                                      Text(
                                          DateFormat('MMM dd, yyyy')
                                              .format(e.date),
                                          style: const TextStyle(
                                              color: Colors.white54,
                                              fontSize: 11)),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                        _currency.format(
                                            e.isSettled ? e.amount : remaining),
                                        style: TextStyle(
                                            color: e.isSettled
                                                ? Colors.white54
                                                : Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14)),
                                    if (!e.isSettled && e.settledAmount > 0)
                                      Padding(
                                          padding:
                                              const EdgeInsets.only(top: 2),
                                          child: Text(
                                              "of ${_currency.format(e.amount)}",
                                              style: const TextStyle(
                                                  color: Colors.white38,
                                                  fontSize: 10))),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    )
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
