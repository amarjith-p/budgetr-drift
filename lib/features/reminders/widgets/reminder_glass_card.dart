import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/database/app_database.dart';
import 'countdown_timer_widget.dart';

class ReminderGlassCard extends StatelessWidget {
  final ReminderEntry reminder;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const ReminderGlassCard({
    super.key,
    required this.reminder,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isOverdue = reminder.targetDate.isBefore(now);
    final daysLeft = reminder.targetDate.difference(now).inDays;

    Color statusColor = isOverdue
        ? Colors.redAccent.withOpacity(0.6) // Muted if expired
        : (daysLeft == 0 ? Colors.amber : const Color(0xFF00B4D8));

    String statusText =
        isOverdue ? "EXPIRED" : (daysLeft == 0 ? "DUE TODAY" : "PENDING");

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Slidable(
        key: ValueKey(reminder.id),
        startActionPane: ActionPane(
          motion: const DrawerMotion(),
          extentRatio: 0.25,
          children: [
            SlidableAction(
              onPressed: (context) {
                HapticFeedback.mediumImpact();
                onEdit();
              },
              backgroundColor: const Color(0xFF00B4D8).withOpacity(0.9),
              foregroundColor: Colors.white,
              icon: Icons.edit_outlined,
              label: 'Edit',
              borderRadius:
                  const BorderRadius.horizontal(left: Radius.circular(8)),
            ),
          ],
        ),
        endActionPane: ActionPane(
          motion: const DrawerMotion(),
          extentRatio: 0.25,
          children: [
            SlidableAction(
              onPressed: (context) {
                HapticFeedback.mediumImpact();
                onDelete(); // Triggers the confirmation sheet
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
        child: GlassCard(
          borderRadius: 8,
          margin: EdgeInsets.zero,
          padding: const EdgeInsets.all(0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Strip
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(8)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      statusText,
                      style: TextStyle(
                          color: statusColor,
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1),
                    ),
                    Text(
                      DateFormat('hh:mm a').format(reminder.targetDate),
                      style: TextStyle(
                          color: statusColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment:
                      CrossAxisAlignment.start, // Align to top for full notes
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: isOverdue
                          ? Colors.white10
                          : statusColor.withOpacity(0.1),
                      child: Icon(
                        reminder.isNotificationEnabled
                            ? Icons.notifications_active
                            : Icons.notifications_none,
                        color: isOverdue ? Colors.white24 : Colors.white,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            reminder.title,
                            style: TextStyle(
                                color:
                                    isOverdue ? Colors.white54 : Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14),
                          ),
                          const SizedBox(height: 6),
                          // FULL NOTES: Restrictions removed
                          if (reminder.notes != null &&
                              reminder.notes!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: Text(
                                reminder.notes!,
                                style: TextStyle(
                                    color: Colors.white.withOpacity(0.5),
                                    fontSize: 12),
                              ),
                            ),
                          Text(
                            DateFormat('dd MMMM yyyy')
                                .format(reminder.targetDate),
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.3),
                                fontSize: 10,
                                fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    CountdownTimerWidget(
                        targetDate: reminder.targetDate, color: statusColor),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
