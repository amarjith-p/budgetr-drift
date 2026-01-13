import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import '../models/credit_models.dart';
import '../services/credit_service.dart';

class StatementVerificationSheet extends StatefulWidget {
  final List<CreditTransactionModel> dangerousTxns;
  final DateTime statementDate;

  const StatementVerificationSheet(
      {super.key, required this.dangerousTxns, required this.statementDate});

  @override
  State<StatementVerificationSheet> createState() =>
      _StatementVerificationSheetState();
}

class _StatementVerificationSheetState
    extends State<StatementVerificationSheet> {
  final Set<String> _movedToNextIds = {};
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final currency =
        NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    final dateStr = DateFormat('dd MMM').format(widget.statementDate);

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xff0D1B2A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
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
          const SizedBox(height: 20),
          Row(
            children: [
              const Icon(Icons.verified_user_outlined,
                  color: Colors.orangeAccent),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Verify Statement ($dateStr)",
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            "These transactions occurred just before your bill generation. Please confirm if they settled in this bill or moved to the next one.",
            style:
                TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13),
          ),
          const SizedBox(height: 24),

          // LIST OF TRANSACTIONS
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: widget.dangerousTxns.length,
              itemBuilder: (context, index) {
                final txn = widget.dangerousTxns[index];
                final isMoved = _movedToNextIds.contains(txn.id);

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(txn.category,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                            Text(
                              DateFormat('dd MMM').format(txn.date),
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.5),
                                  fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        currency.format(txn.amount),
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 12),
                      Switch(
                        value: isMoved,
                        activeColor: Colors.orangeAccent,
                        onChanged: (val) {
                          setState(() {
                            if (val)
                              _movedToNextIds.add(txn.id);
                            else
                              _movedToNextIds.remove(txn.id);
                          });
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                "Toggle ON to move to Next Cycle",
                style: TextStyle(
                    color: Colors.orangeAccent.withOpacity(0.7), fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _confirmSettlements,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3A86FF),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Text("Confirm & Update",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmSettlements() async {
    setState(() => _isLoading = true);
    final service = GetIt.I<CreditService>();

    try {
      for (var txn in widget.dangerousTxns) {
        final shouldMove = _movedToNextIds.contains(txn.id);

        // Update both verified status and statement cycle
        final updatedTxn = CreditTransactionModel(
          id: txn.id,
          cardId: txn.cardId,
          amount: txn.amount,
          date: txn.date,
          bucket: txn.bucket,
          type: txn.type,
          category: txn.category,
          subCategory: txn.subCategory,
          notes: txn.notes,
          linkedExpenseId: txn.linkedExpenseId,
          isSettlementVerified: true, // MARK AS VERIFIED
          includeInNextStatement: shouldMove, // APPLY USER CHOICE
        );

        await service.updateTransaction(updatedTxn);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      // Handle error
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
