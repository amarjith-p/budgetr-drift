import 'package:budget/core/widgets/status_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // [NEW IMPORT] For HapticFeedback
import 'package:flutter_slidable/flutter_slidable.dart'; // [NEW IMPORT] For Slidable
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import '../services/notification_service.dart';
import '../../../core/database/app_database.dart';
import '../../../core/widgets/glass_card.dart';

class NotificationCenterScreen extends StatelessWidget {
  const NotificationCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notificationService = GetIt.I<NotificationService>();

    return Scaffold(
      backgroundColor: const Color(0xff0D1B2A),
      body: SafeArea(
        child: Column(
          children: [
            // 1. MODERN HEADER
            _buildModernHeader(context, notificationService),

            // 2. MAIN CONTENT
            Expanded(
              child: StreamBuilder<List<AppNotification>>(
                stream: notificationService.getNotifications(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final list = snapshot.data!;
                  if (list.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.notifications_off_outlined,
                              size: 64, color: Colors.white.withOpacity(0.3)),
                          const SizedBox(height: 16),
                          Text("No Notifications",
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.5))),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: list.length,
                    padding: const EdgeInsets.all(16),
                    itemBuilder: (context, index) {
                      final item = list[index];
                      // [UPDATED] Using Slidable instead of Dismissible
                      return Padding(
                        padding: const EdgeInsets.only(
                            bottom: 12), // Moved margin here
                        child: Slidable(
                          key: ValueKey(item.id),
                          endActionPane: ActionPane(
                            motion: const DrawerMotion(),
                            extentRatio: 0.3,
                            children: [
                              SlidableAction(
                                onPressed: (context) {
                                  HapticFeedback.mediumImpact();
                                  notificationService
                                      .deleteNotification(item.id);
                                },
                                backgroundColor:
                                    Colors.redAccent.withOpacity(0.9),
                                foregroundColor: Colors.white,
                                icon: Icons.delete_sweep_rounded,
                                label: 'Clear',
                                borderRadius: const BorderRadius.horizontal(
                                    right: Radius.circular(12),
                                    left: Radius.circular(
                                        12)), // Matches tile radius
                              ),
                            ],
                          ),
                          child: _NotificationTile(item: item),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Modern Header Implementation ---
  Widget _buildModernHeader(
      BuildContext context, NotificationService notificationService) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          // Back Button
          GestureDetector(
            onTap: () => Navigator.maybePop(context),
            child: GlassCard(
              borderRadius: 12,
              padding: const EdgeInsets.all(10),
              margin: EdgeInsets.zero,
              color: Colors.white.withOpacity(0.05),
              child: const Icon(Icons.arrow_back_rounded,
                  color: Colors.white70, size: 20),
            ),
          ),

          const SizedBox(width: 16),

          // Title Section
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "FinStack 360",
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2.0,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  "Notification Center",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),

          // Mark All Read Button
          GestureDetector(
            onTap: () => notificationService.markAllAsRead(),
            child: GlassCard(
              borderRadius: 12,
              padding: const EdgeInsets.all(10),
              margin: EdgeInsets.zero,
              color: Colors.white.withOpacity(0.05),
              child: const Icon(Icons.done_all_rounded,
                  color: Colors.white70, size: 20),
            ),
          ),

          const SizedBox(width: 12),

          // Clear All Button
          GestureDetector(
            onTap: () => _confirmClearAll(context, notificationService),
            child: GlassCard(
              borderRadius: 12,
              padding: const EdgeInsets.all(10),
              margin: EdgeInsets.zero,
              color: Colors.white.withOpacity(0.05),
              child: const Icon(Icons.delete_outline_rounded,
                  color: Colors.redAccent, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmClearAll(BuildContext context, NotificationService service) {
    showStatusSheet(
      context: context,
      title: "Clear All?",
      message:
          "Are you sure you want to clear all notifications?\nThis will permanently delete all notifications.",
      icon: Icons.delete_sweep_sharp,
      color: Colors.redAccent,
      cancelButtonText: "Cancel",
      onCancel: () {},
      buttonText: "Delete",
      onDismiss: () async {
        service.clearAll();
      },
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final AppNotification item;

  const _NotificationTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final isUnread = !item.isRead;

    return GestureDetector(
      onTap: () async {
        GetIt.I<NotificationService>().markAsRead(item.id);
      },
      child: Container(
        // [REMOVED] margin: const EdgeInsets.only(bottom: 12) -> Moved to Padding wrapping Slidable
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isUnread
              ? const Color(0xFF1B263B)
              : const Color(0xff0D1B2A).withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                isUnread ? Colors.blueAccent.withOpacity(0.5) : Colors.white10,
            width: 1,
          ),
          boxShadow: isUnread
              ? [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4))
                ]
              : null,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _getIconColor(item.type).withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(_getIcon(item.type),
                  color: _getIconColor(item.type), size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight:
                                isUnread ? FontWeight.bold : FontWeight.normal,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      if (isUnread)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                              color: Colors.blueAccent, shape: BoxShape.circle),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.message,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    DateFormat('MMM d, h:mm a').format(item.createdAt),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIcon(String type) {
    switch (type) {
      case 'goal_achieved':
        return Icons.emoji_events_rounded;
      case 'goal_deadline':
        return Icons.timer_outlined;
      case 'loan_overdue':
        return Icons.warning_rounded;
      case 'loan_due':
        return Icons.calendar_month_rounded;
      case 'inv_stale':
        return Icons.access_time_filled_rounded;
      case 'inv_milestone':
        return Icons.emoji_events_rounded;
      case 'inv_volatility':
        return Icons.show_chart_rounded;
      case 'backup_overdue':
        return Icons.cloud_off_rounded;
      case 'restore_success':
        return Icons.cloud_done_rounded;
      case 'negative_balance':
        return Icons.money_off_csred_rounded;
      case 'low_balance':
        return Icons.account_balance_wallet_outlined;
      case 'forgot_log':
        return Icons.history_toggle_off_rounded;
      case 'daily_spike':
        return Icons.whatshot_rounded;
      case 'limit_exceeded':
        return Icons.warning_amber_rounded;
      case 'high_util':
        return Icons.trending_up;
      case 'due_date':
        return Icons.calendar_today_rounded;
      case 'statement':
        return Icons.receipt_long_rounded;
      case 'budget_not_set':
        return Icons.pie_chart_outline;
      case 'budget_closure_pending':
        return Icons.lock_clock_outlined;
      case 'bucket_overflow':
        return Icons.error_outline_rounded;
      case 'budget_approaching':
        return Icons.analytics_outlined;
      case 'global_overrun':
        return Icons.money_off_rounded;
      default:
        return Icons.notifications;
    }
  }

  Color _getIconColor(String type) {
    switch (type) {
      case 'limit_exceeded':
      case 'global_overrun':
      case 'bucket_overflow':
      case 'negative_balance':
      case 'daily_spike':
      case 'inv_volatility':
      case 'loan_overdue':
        return Colors.redAccent;
      case 'restore_success':
      case 'inv_milestone':
      case 'goal_achieved':
        return Colors.greenAccent;
      case 'high_util':
      case 'due_date':
      case 'budget_approaching':
      case 'budget_closure_pending':
      case 'low_balance':
      case 'forgot_log':
      case 'backup_overdue':
      case 'inv_stale':
      case 'goal_deadline':
      case 'loan_due':
        return Colors.orangeAccent;
      case 'statement':
      case 'budget_not_set':
        return Colors.blueAccent;
      default:
        return Colors.grey;
    }
  }
}
