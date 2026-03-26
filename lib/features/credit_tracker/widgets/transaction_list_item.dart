import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:flutter_slidable/flutter_slidable.dart'; // [NEW IMPORT]
import '../models/credit_models.dart';

class TransactionListItem extends StatefulWidget {
  final CreditTransactionModel txn;
  final IconData iconData;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onDuplicate; // [NEW CALLBACK]
  final VoidCallback onMarkAsRepayment;
  final VoidCallback onIgnore;

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
    required this.onDuplicate, // [NEW CALLBACK]
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

  // Loading States
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

    // Determine what metadata exists
    final bool hasSubcategory = widget.txn.subCategory.isNotEmpty &&
        widget.txn.subCategory != 'General';

    // Explicitly kept your restriction: Bucket only applies to expenses
    final bool hasBucket = isExpense && widget.txn.bucket.isNotEmpty;

    // Calculate maximum safe width for text to prevent absolute overflow
    final maxTextWidth = MediaQuery.of(context).size.width * 0.45;

    return Padding(
      // [MOVED] Margin pulled out from AnimatedContainer so Swipe backgrounds don't clip
      padding: const EdgeInsets.only(bottom: 10),
      child: Slidable(
        key: ValueKey(widget.txn.id),
        // --- [NEW] RIGHT SWIPE (Edit & Duplicate) ---
        startActionPane: ActionPane(
          motion: const DrawerMotion(),
          extentRatio: 0.5,
          children: [
            SlidableAction(
              onPressed: (context) {
                HapticFeedback.mediumImpact();
                widget.onEdit();
              },
              backgroundColor: Colors.blueAccent.withOpacity(0.9),
              foregroundColor: Colors.white,
              icon: Icons.edit_outlined,
              label: 'Edit',
              borderRadius:
                  const BorderRadius.horizontal(left: Radius.circular(8)),
            ),
            SlidableAction(
              onPressed: (context) {
                HapticFeedback.mediumImpact();
                widget.onDuplicate();
              },
              backgroundColor: Colors.green.withOpacity(0.9),
              foregroundColor: Colors.white,
              icon: Icons.copy_outlined,
              label: 'Clone',
            ),
          ],
        ),
        // --- [NEW] LEFT SWIPE (Delete) ---
        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          extentRatio: 0.3,
          children: [
            SlidableAction(
              onPressed: (context) {
                HapticFeedback.mediumImpact();
                widget.onDelete();
              },
              backgroundColor: Colors.redAccent.withOpacity(0.9),
              foregroundColor: Colors.white,
              icon: Icons.delete_outline,
              label: 'Delete',
              borderRadius:
                  const BorderRadius.horizontal(right: Radius.circular(8)),
            ),
          ],
        ),
        child: GestureDetector(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            // [SPACE OPTIMIZATION] Tightened padding
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF1B263B).withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
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
                            child: Icon(widget.iconData,
                                color: iconColor, size: 20)),
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
                                  fontSize:
                                      14)), // Adjusted size slightly to match daily expense style

                          // --- [RESPONSIVE WRAP LOGIC] ---
                          if (hasSubcategory || hasBucket)
                            Padding(
                              padding: const EdgeInsets.only(top: 6.0),
                              child: Wrap(
                                spacing: 8,
                                runSpacing: 6,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  // 1. Subcategory
                                  if (hasSubcategory)
                                    Container(
                                      constraints: BoxConstraints(
                                          maxWidth: maxTextWidth),
                                      child: Text(
                                        widget.txn.subCategory,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            color:
                                                Colors.white.withOpacity(0.6),
                                            fontSize: 11),
                                      ),
                                    ),

                                  // 2. Bucket Tag
                                  if (hasBucket)
                                    _buildTag(widget.txn.bucket, maxTextWidth),
                                ],
                              ),
                            )
                          // --- [END RESPONSIVE WRAP LOGIC] ---
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
                        Text(DateFormat('dd MMM').format(widget.txn.date),
                            style: const TextStyle(
                                color: Colors.white38, fontSize: 11)),
                      ],
                    ),
                  ],
                ),

                // DANGER ZONE WARNING (Preserved Workflow)
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
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12),
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

                // UNVERIFIED TRANSFER WARNING (Preserved Workflow)
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
                            style:
                                TextStyle(color: Colors.white70, fontSize: 12)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                                child: GestureDetector(
                                    onTap: widget.onMarkAsRepayment,
                                    child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8),
                                        decoration: BoxDecoration(
                                            color:
                                                Colors.green.withOpacity(0.2),
                                            borderRadius:
                                                BorderRadius.circular(6),
                                            border: Border.all(
                                                color: Colors.green
                                                    .withOpacity(0.3))),
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
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8),
                                        decoration: BoxDecoration(
                                            color: Colors.grey.withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(6),
                                            border: Border.all(
                                                color: Colors.white12)),
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

                // Animated Expanded Details
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 300),

                  // Collapsed state is completely empty to save maximum space
                  firstChild: const SizedBox(width: double.infinity, height: 0),

                  // Expanded Details
                  secondChild: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      const Divider(color: Colors.white10),
                      const SizedBox(height: 8),

                      // --- [RESPONSIVE EXPANDED ROW FIX] ---
                      SizedBox(
                        width: double.infinity,
                        child: Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 8, // Horizontal space before they wrap
                          runSpacing:
                              8, // Vertical space if the Bucket drops to line 2
                          children: [
                            Text(
                              DateFormat('MMMM dd, yyyy, hh:mm a')
                                  .format(widget.txn.date),
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.5),
                                  fontSize: 12),
                            ),
                            if (hasBucket)
                              _buildTag(
                                  "Bucket: ${widget.txn.bucket}", maxTextWidth),
                          ],
                        ),
                      ),
                      // --- [END RESPONSIVE EXPANDED ROW FIX] ---

                      const SizedBox(height: 12),

                      // Defer to next bill feature (Preserved Workflow)
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
                                        strokeWidth: 2,
                                        color: Color(0xFF4CC9F0)))
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
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8))),
                          ),
                        ),
                      ],

                      // Notes moved entirely to Expanded View
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
                        const SizedBox(height: 8),
                      ],
                      // Action buttons removed from here; now handled strictly by the Slidable swipe
                    ],
                  ),
                  crossFadeState: _isExpanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Updated Tag to accept maxWidth and match the styling
  Widget _buildTag(String text, double maxWidth) => Container(
        constraints: BoxConstraints(maxWidth: maxWidth),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.white12),
        ),
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 9,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
}
