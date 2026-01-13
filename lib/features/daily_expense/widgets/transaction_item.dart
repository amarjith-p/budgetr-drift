import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/expense_models.dart';

class TransactionItem extends StatefulWidget {
  final ExpenseTransactionModel txn;
  final IconData iconData;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  // [UPDATED] Optional field to display source account name
  final String? sourceAccountName;

  const TransactionItem({
    super.key,
    required this.txn,
    required this.iconData,
    required this.onEdit,
    required this.onDelete,
    this.sourceAccountName,
  });

  @override
  State<TransactionItem> createState() => _TransactionItemState();
}

class _TransactionItemState extends State<TransactionItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
    final isExpense = widget.txn.type == 'Expense';
    final isTransferOut = widget.txn.type == 'Transfer Out';
    final isTransferIn = widget.txn.type == 'Transfer In';
    Color amountColor;
    Color iconColor;
    IconData icon;
    String title;
    String sign;

    if (isExpense) {
      amountColor = Colors.redAccent;
      iconColor = const Color(0xFF00B4D8);
      icon = widget.iconData;
      title = widget.txn.category;
      sign = '-';
    } else if (isTransferOut) {
      amountColor = Colors.orangeAccent;
      iconColor = Colors.orangeAccent;
      icon = Icons.arrow_outward_rounded;
      final bank = widget.txn.transferAccountBankName ?? '';
      final acc = widget.txn.transferAccountName ?? 'Account';
      title = bank.isNotEmpty ? "Transfer to $bank - $acc" : "Transfer to $acc";
      sign = '-';
    } else if (isTransferIn) {
      amountColor = Colors.greenAccent;
      iconColor = Colors.greenAccent;
      icon = Icons.arrow_downward_rounded;
      final bank = widget.txn.transferAccountBankName ?? '';
      final acc = widget.txn.transferAccountName ?? 'Account';
      title =
          bank.isNotEmpty ? "Transfer from $bank - $acc" : "Transfer from $acc";
      sign = '+';
    } else {
      amountColor = Colors.greenAccent;
      iconColor = Colors.green;
      icon = widget.iconData;
      title = widget.txn.category;
      sign = '+';
    }

    final bool hasSummary = (isExpense && widget.txn.bucket.isNotEmpty) ||
        widget.txn.notes.isNotEmpty ||
        widget.sourceAccountName != null;

    return GestureDetector(
      onTap: () => setState(() => _isExpanded = !_isExpanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: const Color(0xFF1B263B).withOpacity(0.5),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
                color: _isExpanded
                    ? Colors.white.withOpacity(0.2)
                    : Colors.white.withOpacity(0.05)),
            boxShadow: _isExpanded
                ? [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4))
                  ]
                : []),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                    backgroundColor: iconColor.withOpacity(0.1),
                    child: Icon(icon, color: iconColor, size: 20)),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15)),
                      // [UPDATED] Show Source Account Name directly in title block if provided
                      if (widget.sourceAccountName != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4)),
                            child: Text(
                              widget.sourceAccountName!,
                              style: const TextStyle(
                                  color: Colors.blueAccent,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                        )
                      else if (widget.txn.subCategory.isNotEmpty &&
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
                    Text("$sign ${currency.format(widget.txn.amount)}",
                        style: TextStyle(
                            color: amountColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 15)),
                    const SizedBox(height: 4),
                    Text(DateFormat('dd MMM').format(widget.txn.date),
                        style: const TextStyle(
                            color: Colors.white38, fontSize: 11)),
                  ],
                ),
              ],
            ),

            // Animated Summary / Expanded View
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 300),
              // First Child: Summary Line (Visible when Collapsed)
              firstChild: hasSummary
                  ? Container(
                      width: double.infinity,
                      padding: const EdgeInsets.only(
                          top: 8, left: 56), // Align with title
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          if (isExpense && widget.txn.bucket.isNotEmpty)
                            _buildTag(widget.txn.bucket),
                          if (widget.txn.notes.isNotEmpty)
                            Text(
                              widget.txn.notes,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.4),
                                fontSize: 11,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                        ],
                      ),
                    )
                  : const SizedBox(width: double.infinity),

              // Second Child: Expanded Details (Visible when Expanded)
              secondChild: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  const Divider(color: Colors.white10),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('EEEE, hh:mm a').format(widget.txn.date),
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.5), fontSize: 12),
                      ),
                      if (isExpense && widget.txn.bucket.isNotEmpty)
                        _buildTag("Bucket: ${widget.txn.bucket}"),
                    ],
                  ),
                  const SizedBox(height: 12),
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTag(String text) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.white12)),
      child: Text(text,
          style: const TextStyle(
              color: Colors.white70,
              fontSize: 10,
              fontWeight: FontWeight.w500)));

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
