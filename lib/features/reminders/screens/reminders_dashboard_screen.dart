import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../../core/widgets/modern_app_bar.dart';
import '../../../core/widgets/futuristic_loader.dart';
import '../../../core/database/app_database.dart';
import '../services/reminder_service.dart';
import '../widgets/reminder_glass_card.dart';
import '../widgets/modern_reminder_sheet.dart';

class RemindersDashboardScreen extends StatelessWidget {
  const RemindersDashboardScreen({super.key});

  void _openSheet(BuildContext context, {ReminderEntry? reminder}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ModernReminderSheet(existingReminder: reminder),
    );
  }

  @override
  Widget build(BuildContext context) {
    final service = GetIt.I<ReminderService>();

    return Scaffold(
      backgroundColor: const Color(0xff0D1B2A),
      body: SafeArea(
        child: Column(
          children: [
            ModernAppBar(
              title: "Reminders",
              subtitle: "SCHEDULED ALERTS",
              trailingIcon: Icons.add_alarm_rounded,
              onTrailingPressed: () => _openSheet(context),
            ),
            Expanded(
              child: StreamBuilder<List<ReminderEntry>>(
                // Use watch() to ensure instant UI updates on database changes
                stream: service.watchActiveReminders(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: FuturisticLoader(
                          size: 80, label: "SYNCING PROTOCOLS..."),
                    );
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return _buildEmptyState();
                  }

                  final reminders = snapshot.data!;
                  return ListView.builder(
                    padding: const EdgeInsets.all(12),
                    physics: const BouncingScrollPhysics(),
                    itemCount: reminders.length,
                    itemBuilder: (context, index) {
                      final reminder = reminders[index];
                      return ReminderGlassCard(
                        reminder: reminder,
                        onDelete: () => service.deleteReminder(reminder.id),
                        onEdit: () => _openSheet(context, reminder: reminder),
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_off_rounded,
              size: 60, color: Colors.white.withOpacity(0.05)),
          const SizedBox(height: 16),
          Text("No Active Reminders",
              style: TextStyle(
                  color: Colors.white.withOpacity(0.3),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2)),
        ],
      ),
    );
  }
}
