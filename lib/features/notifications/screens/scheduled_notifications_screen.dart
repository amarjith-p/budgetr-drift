import 'package:budget/core/widgets/futuristic_loader.dart';
import 'package:budget/core/widgets/status_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import '../services/system_notification_service.dart';
import '../../../core/widgets/glass_card.dart';

class ScheduledNotificationsScreen extends StatefulWidget {
  const ScheduledNotificationsScreen({super.key});

  @override
  State<ScheduledNotificationsScreen> createState() =>
      _ScheduledNotificationsScreenState();
}

class _ScheduledNotificationsScreenState
    extends State<ScheduledNotificationsScreen> {
  final SystemNotificationService _systemService =
      GetIt.I<SystemNotificationService>();

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xff0D1B2A);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // 1. MODERN HEADER
            _buildModernHeader(context),

            // 2. LIST CONTENT
            Expanded(
              child: FutureBuilder<List<PendingNotificationRequest>>(
                future: _systemService.getPendingNotifications(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: FuturisticLoader(
                            size: 80, label: "FINDING NOTIFICATIONS..."));
                  }
                  if (snapshot.hasError) {
                    return Center(
                        child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text("Failed to load queue:\n${snapshot.error}",
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.redAccent)),
                    ));
                  }

                  final list = snapshot.data!;
                  if (list.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.notifications_off_outlined,
                              color: Colors.white.withOpacity(0.2), size: 64),
                          const SizedBox(height: 16),
                          const Text("No pending notifications",
                              style: TextStyle(color: Colors.white54)),
                        ],
                      ),
                    );
                  }

                  // Sort by ID to keep similar items together
                  list.sort((a, b) => a.id.compareTo(b.id));

                  return ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: list.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = list[index];
                      // Extract trigger info from payload
                      final scheduleInfo = _parseScheduleInfo(item.payload);

                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFF00B4D8).withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.alarm,
                                  color: Color(0xFF00B4D8), size: 20),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.title ?? "No Title",
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    item.body ?? "No Body",
                                    style: const TextStyle(
                                        color: Colors.white70, fontSize: 14),
                                  ),
                                  const SizedBox(height: 8),

                                  // TRIGGER TIME DISPLAY
                                  Row(
                                    children: [
                                      Icon(Icons.access_time_filled,
                                          size: 12,
                                          color: scheduleInfo.isDaily
                                              ? Colors.orangeAccent
                                              : const Color(0xFF00B4D8)),
                                      const SizedBox(width: 6),
                                      Text(
                                        scheduleInfo.displayText,
                                        style: TextStyle(
                                          color: scheduleInfo.isDaily
                                              ? Colors.orangeAccent
                                              : const Color(0xFF00B4D8),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 4),
                                  Text(
                                    "ID: ${item.id} • Ref: ${scheduleInfo.cleanPayload}",
                                    style: const TextStyle(
                                        color: Colors.white38,
                                        fontSize: 10,
                                        fontFamily: 'monospace'),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  color: Colors.redAccent),
                              onPressed: () async {
                                showStatusSheet(
                                  context: context,
                                  title: "Delete Notification?",
                                  message:
                                      "Are you sure you want to delete the scheduled notifications? This action cannot be undone.",
                                  icon: Icons.delete_sweep_sharp,
                                  color: Colors.redAccent,
                                  cancelButtonText: "Cancel",
                                  onCancel: () {},
                                  buttonText: "Delete",
                                  onDismiss: () async {
                                    await _systemService
                                        .cancelNotification(item.id);
                                    setState(() {});
                                  },
                                );
                                // Refresh
                              },
                            ),
                          ],
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

  // --- PARSING LOGIC ---
  _ScheduleDisplayInfo _parseScheduleInfo(String? payload) {
    if (payload == null || payload.isEmpty) {
      return _ScheduleDisplayInfo("Time Unknown", "", false);
    }

    String displayText = "Time Unknown";
    String cleanPayload = payload;
    bool isDaily = false;

    if (payload.contains('|DATE:')) {
      final parts = payload.split('|DATE:');
      cleanPayload = parts[0];
      try {
        final date = DateTime.parse(parts[1]);
        displayText = DateFormat('EEE, MMM d, yyyy • hh:mm:ss a').format(date);
      } catch (_) {}
    } else if (payload.contains('|REPEAT:')) {
      final parts = payload.split('|REPEAT:');
      cleanPayload = parts[0];
      try {
        final timeParts = parts[1].split(':');
        final time = TimeOfDay(
            hour: int.parse(timeParts[0]), minute: int.parse(timeParts[1]));

        // Convert to 12h format manually or via context if available
        final now = DateTime.now();
        final dt = DateTime(
          now.year,
          now.month,
          now.day,
          time.hour,
          time.minute,
        );
        final formattedTime = DateFormat.jm().format(dt);

        displayText = "Daily @ $formattedTime";
        isDaily = true;
      } catch (_) {}
    }

    return _ScheduleDisplayInfo(displayText, cleanPayload, isDaily);
  }

  // --- MODERN HEADER ---
  Widget _buildModernHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
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
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "NOTIFICATIONS QUEUE",
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2.0,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  "Scheduled Items",
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
        ],
      ),
    );
  }
}

class _ScheduleDisplayInfo {
  final String displayText;
  final String cleanPayload;
  final bool isDaily;

  _ScheduleDisplayInfo(this.displayText, this.cleanPayload, this.isDaily);
}
