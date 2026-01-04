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
  final bool isIgnored;

  const TransactionListItem({
    super.key,
    required this.txn,
    required this.iconData,
    required this.onEdit,
    required this.onDelete,
    required this.onMarkAsRepayment,
    required this.onIgnore,
    required this.isIgnored,
  });

  @override
  State<TransactionListItem> createState() => _TransactionListItemState();
}

class _TransactionListItemState extends State<TransactionListItem> {
  bool _isExpanded = false;

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
                  : (_isExpanded
                      ? Colors.white.withOpacity(0.2)
                      : Colors.white.withOpacity(0.05))),
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
                    if (_isUnverifiedTransfer)
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
                  const SizedBox(height: 8),
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
