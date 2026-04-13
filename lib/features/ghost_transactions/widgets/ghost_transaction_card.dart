import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../../core/database/app_database.dart';

class GhostTransactionCard extends StatefulWidget {
  final GhostTransactionEntry ghost;
  final VoidCallback onDelete;
  final VoidCallback onConfirm;

  const GhostTransactionCard({
    Key? key,
    required this.ghost,
    required this.onDelete,
    required this.onConfirm,
  }) : super(key: key);

  @override
  State<GhostTransactionCard> createState() => _GhostTransactionCardState();
}

class _GhostTransactionCardState extends State<GhostTransactionCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    bool isCredit = widget.ghost.detectedType == 'Credit';
    Color typeColor = isCredit ? Colors.greenAccent : Colors.redAccent;
    IconData typeIcon =
        isCredit ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded;
    String sign = isCredit ? '+' : '-';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Slidable(
        key: ValueKey(widget.ghost.id),
        startActionPane: ActionPane(
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
                  const BorderRadius.horizontal(left: Radius.circular(8)),
            ),
          ],
        ),
        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          extentRatio: 0.35,
          children: [
            SlidableAction(
              onPressed: (context) {
                HapticFeedback.mediumImpact();
                widget.onConfirm();
              },
              backgroundColor: Colors.blueAccent.withOpacity(0.9),
              foregroundColor: Colors.white,
              icon: Icons.check_circle_outline,
              label: 'Confirm',
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                  : [],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      backgroundColor: typeColor.withOpacity(0.1),
                      child: Icon(typeIcon, color: typeColor, size: 20),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // --- UPDATED TITLE: Now shows the Account Name ---
                          Text(
                            widget.ghost.detectedAccount ?? 'Unknown Account',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          // --- UPDATED SUBTITLE: Now shows "Unverified Ghost" ---
                          Row(
                            children: [
                              Icon(
                                widget.ghost.source.startsWith('SMS')
                                    ? Icons.sms_outlined
                                    : Icons.notifications_none,
                                color: Colors.blueAccent.withOpacity(0.8),
                                size: 12,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  "Unverified Ghost",
                                  style: TextStyle(
                                      color: Colors.white.withOpacity(0.6),
                                      fontSize: 11),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "$sign ₹ ${widget.ghost.detectedAmount?.toStringAsFixed(2) ?? "0.00"}",
                          style: TextStyle(
                              color: typeColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 15),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.ghost.detectedDate != null
                              ? DateFormat('dd MMM, hh:mm a')
                                  .format(widget.ghost.detectedDate!)
                              : 'Unknown Date',
                          style: const TextStyle(
                              color: Colors.white38, fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ),
                AnimatedCrossFade(
                  duration: const Duration(milliseconds: 300),
                  firstChild: const SizedBox(width: double.infinity, height: 0),
                  secondChild: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      const Divider(color: Colors.white10),
                      const SizedBox(height: 8),
                      Text(
                        "Raw Message Data:",
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 11,
                            fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.ghost.rawText,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 13, height: 1.4),
                      ),
                      const SizedBox(height: 8),
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
}
