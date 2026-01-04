import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/credit_models.dart';

class TransactionListItem extends StatefulWidget {
  final CreditTransactionModel txn;
  final IconData iconData;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onMarkAsRepayment;
  final VoidCallback onIgnore;

  // CHANGED: Updated to Future for loading state support
  final Future<void> Function()? onDeferToNextBill;
  final Future<void> Function()? onVerifySettlement;

  final bool isIgnored;
  final bool showDangerWarning;

  const TransactionListItem({
    super.key,
    required this.txn,
    required this.iconData,
    required this.onEdit,
    required this.onDelete,
    required this.onMarkAsRepayment,
    required this.onIgnore,
    this.onDeferToNextBill,
    this.onVerifySettlement,
    required this.isIgnored,
    this.showDangerWarning = false,
  });

  @override
  State<TransactionListItem> createState() => _TransactionListItemState();
}

class _TransactionListItemState extends State<TransactionListItem> {
  bool _isExpanded = false;

  // NEW: Loading States
  bool _isDeferring = false;
  bool _isVerifying = false;

  bool get _isUnverifiedTransfer =>
      !widget.isIgnored &&
      widget.txn.type == 'Income' &&
      widget.txn.category.toLowerCase() == 'transfer';

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
    final isExpense = widget.txn.type == 'Expense';
    final amountColor = isExpense ? Colors.redAccent : Colors.greenAccent;
    final iconColor = isExpense ? const Color(0xFF3A86FF) : Colors.green;

    return GestureDetector(
      onTap: () => setState(() => _isExpanded = !_isExpanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1B263B).withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: _isUnverifiedTransfer
                  ? Colors.orangeAccent.withOpacity(0.5)
                  : (widget.showDangerWarning
                      ? Colors.orangeAccent.withOpacity(0.3)
                      : (_isExpanded
                          ? Colors.white.withOpacity(0.2)
                          : Colors.white.withOpacity(0.05)))),
          boxShadow: _isExpanded
              ? [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 4))
                ]
              : [],
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                        backgroundColor: iconColor.withOpacity(0.1),
                        child:
                            Icon(widget.iconData, color: iconColor, size: 20)),
                    if (_isUnverifiedTransfer || widget.showDangerWarning)
                      Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                  color: Colors.orangeAccent,
                                  shape: BoxShape.circle))),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.txn.category,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15)),
                      if (widget.txn.subCategory.isNotEmpty &&
                          widget.txn.subCategory != 'General')
                        Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(widget.txn.subCategory,
                                style: TextStyle(
                                    color: Colors.white.withOpacity(0.6),
                                    fontSize: 12))),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                        "${isExpense ? '-' : '+'} ${currency.format(widget.txn.amount)}",
                        style: TextStyle(
                            color: amountColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 15)),
                    const SizedBox(height: 4),
                    Text(DateFormat('dd MMM').format(widget.txn.date.toDate()),
                        style: const TextStyle(
                            color: Colors.white38, fontSize: 11)),
                  ],
                ),
              ],
            ),

            // DANGER ZONE WARNING
            if (widget.showDangerWarning && _isExpanded)
              Container(
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: Colors.orangeAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: Colors.orangeAccent.withOpacity(0.3))),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(Icons.warning_amber_rounded,
                        color: Colors.orangeAccent, size: 16),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                          "Close to Bill Date. Is this included in the bill?",
                          style: TextStyle(
                              color: Colors.orangeAccent,
                              fontSize: 11,
                              fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 12),

                    // YES INCLUDED BUTTON (With Loading)
                    if (widget.onVerifySettlement != null)
                      SizedBox(
                        height: 28,
                        child: TextButton(
                          onPressed: _isVerifying
                              ? null
                              : () async {
                                  setState(() => _isVerifying = true);
                                  try {
                                    await widget.onVerifySettlement!();
                                  } finally {
                                    if (mounted)
                                      setState(() => _isVerifying = false);
                                  }
                                },
                          style: TextButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              backgroundColor:
                                  Colors.orangeAccent.withOpacity(0.2),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8))),
                          child: _isVerifying
                              ? const SizedBox(
                                  width: 12,
                                  height: 12,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.orangeAccent,
                                  ),
                                )
                              : const Text("Yes, Included",
                                  style: TextStyle(
                                      color: Colors.orangeAccent,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold)),
                        ),
                      )
                  ],
                ),
              ),

            // UNVERIFIED TRANSFER WARNING
            if (_isUnverifiedTransfer)
              Container(
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: Colors.orangeAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: Colors.orangeAccent.withOpacity(0.3))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: const [
                      Icon(Icons.warning_amber_rounded,
                          color: Colors.orangeAccent, size: 16),
                      SizedBox(width: 8),
                      Text("Action Required",
                          style: TextStyle(
                              color: Colors.orangeAccent,
                              fontSize: 11,
                              fontWeight: FontWeight.bold))
                    ]),
                    const SizedBox(height: 4),
                    const Text("Is this a Bill Repayment?",
                        style: TextStyle(color: Colors.white70, fontSize: 12)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                            child: GestureDetector(
                                onTap: widget.onMarkAsRepayment,
                                child: Container(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 8),
                                    decoration: BoxDecoration(
                                        color: Colors.green.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                            color:
                                                Colors.green.withOpacity(0.3))),
                                    child: const Center(
                                        child: Text("Mark as Repayment",
                                            style: TextStyle(
                                                color: Colors.green,
                                                fontSize: 11,
                                                fontWeight:
                                                    FontWeight.bold)))))),
                        const SizedBox(width: 8),
                        Expanded(
                            child: GestureDetector(
                                onTap: widget.onIgnore,
                                child: Container(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 8),
                                    decoration: BoxDecoration(
                                        color: Colors.grey.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(6),
                                        border:
                                            Border.all(color: Colors.white12)),
                                    child: const Center(
                                        child: Text("Ignore",
                                            style: TextStyle(
                                                color: Colors.white70,
                                                fontSize: 11)))))),
                      ],
                    )
                  ],
                ),
              ),

            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  const Divider(color: Colors.white10),

                  // DEFER BUTTON (With Loading)
                  if (widget.onDeferToNextBill != null) ...[
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: TextButton.icon(
                        onPressed: _isDeferring
                            ? null
                            : () async {
                                setState(() => _isDeferring = true);
                                try {
                                  await widget.onDeferToNextBill!();
                                } finally {
                                  if (mounted)
                                    setState(() => _isDeferring = false);
                                }
                              },
                        icon: _isDeferring
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Color(0xFF4CC9F0)))
                            : Icon(
                                widget.txn.includeInNextStatement
                                    ? Icons.undo
                                    : Icons.next_plan_outlined,
                                color: const Color(0xFF4CC9F0),
                                size: 18),
                        label: Text(
                          _isDeferring
                              ? "Processing..."
                              : (widget.txn.includeInNextStatement
                                  ? "Move back to Previous Bill"
                                  : "Not in Bill? Move to Next Cycle"),
                          style: const TextStyle(color: Color(0xFF4CC9F0)),
                        ),
                        style: TextButton.styleFrom(
                            backgroundColor:
                                const Color(0xFF4CC9F0).withOpacity(0.1),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8))),
                      ),
                    ),
                  ],

                  if (widget.txn.notes.isNotEmpty) ...[
                    Text("Notes:",
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 11,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(widget.txn.notes,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 13)),
                    const SizedBox(height: 20),
                  ],
                  Row(children: [
                    Expanded(
                        child: _buildActionButton(
                            icon: Icons.edit_outlined,
                            label: "Edit",
                            color: Colors.white,
                            onTap: widget.onEdit)),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _buildActionButton(
                            icon: Icons.delete_outline,
                            label: "Delete",
                            color: Colors.redAccent,
                            onTap: widget.onDelete))
                  ]),
                ],
              ),
              crossFadeState: _isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
          {required IconData icon,
          required String label,
          required Color color,
          required VoidCallback onTap}) =>
      InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color.withOpacity(0.2))),
              child:
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(icon, size: 18, color: color),
                const SizedBox(width: 8),
                Text(label,
                    style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 13))
              ])));
}
