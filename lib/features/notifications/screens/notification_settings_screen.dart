// import 'package:flutter/material.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../../../core/design/budgetr_colors.dart';
// import '../../../core/design/budgetr_styles.dart';
// import '../services/notification_service.dart';

// class NotificationSettingsScreen extends StatefulWidget {
//   const NotificationSettingsScreen({super.key});

//   @override
//   State<NotificationSettingsScreen> createState() =>
//       _NotificationSettingsScreenState();
// }

// class _NotificationSettingsScreenState
//     extends State<NotificationSettingsScreen> {
//   final NotificationService _service = NotificationService();
//   bool _isLoading = true;

//   // -- State Variables --
//   bool _dailyReminderEnabled = false;
//   TimeOfDay _dailyReminderTime = const TimeOfDay(hour: 20, minute: 0);

//   @override
//   void initState() {
//     super.initState();
//     _loadSettings();
//   }

//   Future<void> _loadSettings() async {
//     final prefs = await SharedPreferences.getInstance();
//     setState(() {
//       _dailyReminderEnabled = prefs.getBool('daily_reminder_enabled') ?? false;
//       final hour = prefs.getInt('daily_reminder_hour') ?? 20;
//       final minute = prefs.getInt('daily_reminder_minute') ?? 0;
//       _dailyReminderTime = TimeOfDay(hour: hour, minute: minute);
//       _isLoading = false;
//     });
//   }

//   Future<void> _saveSettings() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setBool('daily_reminder_enabled', _dailyReminderEnabled);
//     await prefs.setInt('daily_reminder_hour', _dailyReminderTime.hour);
//     await prefs.setInt('daily_reminder_minute', _dailyReminderTime.minute);

//     // Update the actual notification schedule
//     await _service.scheduleDailyReminder(
//       time: _dailyReminderTime,
//       isActive: _dailyReminderEnabled,
//     );
//   }

//   Future<void> _toggleDailyReminder(bool value) async {
//     if (value) {
//       final granted = await _service.requestPermissions();
//       if (!granted && mounted) {
//         _showPermissionDeniedDialog();
//         return;
//       }
//     }
//     setState(() => _dailyReminderEnabled = value);
//     await _saveSettings();
//   }

//   Future<void> _pickTime() async {
//     final picked = await showTimePicker(
//       context: context,
//       initialTime: _dailyReminderTime,
//       builder: (context, child) {
//         // Theme the time picker to match the app
//         return Theme(
//           data: Theme.of(context).copyWith(
//             timePickerTheme: TimePickerThemeData(
//               backgroundColor: BudgetrColors.cardSurface,
//               hourMinuteTextColor: Colors.white,
//               dayPeriodTextColor: Colors.white70,
//               dialHandColor: BudgetrColors.accent,
//               dialBackgroundColor: Colors.white10,
//               entryModeIconColor: BudgetrColors.accent,
//             ),
//             textButtonTheme: TextButtonThemeData(
//               style: TextButton.styleFrom(
//                 foregroundColor: BudgetrColors.accent,
//               ),
//             ),
//           ),
//           child: child!,
//         );
//       },
//     );

//     if (picked != null && picked != _dailyReminderTime) {
//       setState(() => _dailyReminderTime = picked);
//       if (_dailyReminderEnabled) {
//         await _saveSettings(); // Reschedule if already enabled
//       }
//     }
//   }

//   void _showPermissionDeniedDialog() {
//     showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         backgroundColor: BudgetrColors.cardSurface,
//         title: const Text(
//           "Permission Required",
//           style: TextStyle(color: Colors.white),
//         ),
//         content: const Text(
//           "To receive synchronization alerts, please enable notifications in your device settings.",
//           style: TextStyle(color: Colors.white70),
//         ),
//         actions: [
//           TextButton(
//             child: const Text("Dismiss"),
//             onPressed: () => Navigator.pop(ctx),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: BudgetrColors.background,
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         title: const Text("Notification Uplink", style: BudgetrStyles.h2),
//         iconTheme: const IconThemeData(color: Colors.white),
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : ListView(
//               padding: const EdgeInsets.all(20),
//               children: [
//                 _buildHeader(),
//                 const SizedBox(height: 30),

//                 // --- Scalable List of Channels ---
//                 _buildNotificationChannelCard(
//                   title: "Daily Ledger Sync",
//                   subtitle: "Reminders to log daily transactions",
//                   icon: Icons.access_time_filled_rounded,
//                   color: const Color(0xFF4CC9F0),
//                   isEnabled: _dailyReminderEnabled,
//                   onToggle: _toggleDailyReminder,
//                   extraContent:
//                       _dailyReminderEnabled ? _buildTimePickerDisplay() : null,
//                 ),
//                 const SizedBox(height: 30),

//                 // --- DEBUG BUTTON ---
//                 Center(
//                   child: TextButton.icon(
//                     onPressed: () async {
//                       await _service.requestPermissions(); // Ensure permission
//                       await _service.showImmediateNotification();
//                     },
//                     icon: const Icon(Icons.bug_report, color: Colors.orange),
//                     label: const Text(
//                       "Test Notification System",
//                       style: TextStyle(color: Colors.orange),
//                     ),
//                   ),
//                 ),

//                 // Example of Scalability: Uncomment to add next feature
//                 // const SizedBox(height: 16),
//                 // _buildNotificationChannelCard(
//                 //   title: "Budget Breach Protocol",
//                 //   subtitle: "Alerts when category limits are exceeded",
//                 //   icon: Icons.warning_amber_rounded,
//                 //   color: BudgetrColors.error,
//                 //   isEnabled: _budgetAlertsEnabled,
//                 //   onToggle: _toggleBudgetAlerts,
//                 // ),
//               ],
//             ),
//     );
//   }

//   Widget _buildHeader() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           "Communication Protocols",
//           style: BudgetrStyles.h3.copyWith(color: Colors.white54),
//         ),
//         const SizedBox(height: 8),
//         const Text(
//           "Configure how the system interacts with your device timeline.",
//           style: TextStyle(color: Colors.white38, fontSize: 13),
//         ),
//       ],
//     );
//   }

//   Widget _buildNotificationChannelCard({
//     required String title,
//     required String subtitle,
//     required IconData icon,
//     required Color color,
//     required bool isEnabled,
//     required ValueChanged<bool> onToggle,
//     Widget? extraContent,
//   }) {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: BudgetrColors.cardSurface.withOpacity(0.6),
//         borderRadius: BudgetrStyles.radiusL,
//         border: Border.all(color: Colors.white.withOpacity(0.05)),
//         boxShadow: isEnabled ? BudgetrStyles.glowBoxShadow(color) : [],
//       ),
//       child: Column(
//         children: [
//           Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: color.withOpacity(0.15),
//                   shape: BoxShape.circle,
//                 ),
//                 child: Icon(icon, color: color, size: 24),
//               ),
//               const SizedBox(width: 16),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       title,
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                         letterSpacing: 0.5,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       subtitle,
//                       style: TextStyle(
//                         color: Colors.white.withOpacity(0.5),
//                         fontSize: 12,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Transform.scale(
//                 scale: 0.8,
//                 child: CupertinoSwitch(
//                   value: isEnabled,
//                   activeColor: color,
//                   trackColor: Colors.white24,
//                   onChanged: onToggle,
//                 ),
//               ),
//             ],
//           ),
//           if (extraContent != null) ...[
//             Padding(
//               padding: const EdgeInsets.symmetric(vertical: 12),
//               child: Divider(color: Colors.white.withOpacity(0.05)),
//             ),
//             extraContent,
//           ],
//         ],
//       ),
//     );
//   }

//   Widget _buildTimePickerDisplay() {
//     return InkWell(
//       onTap: _pickTime,
//       borderRadius: BorderRadius.circular(12),
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//         decoration: BoxDecoration(
//           color: Colors.black26,
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(color: Colors.white10),
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             const Text(
//               "Ping Time",
//               style: TextStyle(
//                 color: Colors.white70,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//             Row(
//               children: [
//                 Text(
//                   _dailyReminderTime.format(context),
//                   style: const TextStyle(
//                     color: BudgetrColors.accent,
//                     fontWeight: FontWeight.bold,
//                     fontSize: 16,
//                   ),
//                 ),
//                 const SizedBox(width: 8),
//                 const Icon(
//                   Icons.edit_outlined,
//                   size: 16,
//                   color: Colors.white30,
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/design/budgetr_colors.dart';
import '../../../core/design/budgetr_styles.dart';
import '../services/notification_service.dart';
import '../managers/daily_logistics_manager.dart';
import '../managers/credit_debt_manager.dart';
import '../managers/wealth_growth_manager.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  final NotificationService _coreService = NotificationService();

  // -- Managers --
  final DailyLogisticsManager _dailyManager = DailyLogisticsManager();
  final CreditDebtManager _creditManager = CreditDebtManager();
  final WealthGrowthManager _wealthManager = WealthGrowthManager();

  bool _isLoading = true;

  // -- State Variables --
  bool _dailyReminderEnabled = false;
  bool _creditAlertsEnabled = false;
  bool _wealthRemindersEnabled = false;
  bool _budgetBreachEnabled = false; // [NEW] Added missing state

  TimeOfDay _dailyReminderTime = const TimeOfDay(hour: 20, minute: 0);

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _dailyReminderEnabled = prefs.getBool('notif_daily_enabled') ?? false;
      _creditAlertsEnabled = prefs.getBool('notif_credit_enabled') ?? false;
      _wealthRemindersEnabled = prefs.getBool('notif_wealth_enabled') ?? false;
      _budgetBreachEnabled =
          prefs.getBool('notif_budget_enabled') ?? false; // [NEW]

      final hour = prefs.getInt('daily_reminder_hour') ?? 20;
      final minute = prefs.getInt('daily_reminder_minute') ?? 0;
      _dailyReminderTime = TimeOfDay(hour: hour, minute: minute);
      _isLoading = false;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notif_daily_enabled', _dailyReminderEnabled);
    await prefs.setBool('notif_credit_enabled', _creditAlertsEnabled);
    await prefs.setBool('notif_wealth_enabled', _wealthRemindersEnabled);
    await prefs.setBool('notif_budget_enabled', _budgetBreachEnabled); // [NEW]

    await prefs.setInt('daily_reminder_hour', _dailyReminderTime.hour);
    await prefs.setInt('daily_reminder_minute', _dailyReminderTime.minute);
  }

  Future<void> _checkPermissions() async {
    final granted = await _coreService.requestPermissions();
    if (!granted && mounted) {
      _showPermissionDeniedDialog();
    }
  }

  // --- Toggle Handlers ---

  Future<void> _toggleDaily(bool value) async {
    if (value) await _checkPermissions();
    setState(() => _dailyReminderEnabled = value);
    await _saveSettings();
    await _dailyManager.scheduleDailyReminder(_dailyReminderTime, value);
  }

  Future<void> _toggleCredit(bool value) async {
    if (value) await _checkPermissions();
    setState(() => _creditAlertsEnabled = value);
    await _saveSettings();
    await _creditManager.syncCreditReminders(value);
  }

  Future<void> _toggleWealth(bool value) async {
    if (value) await _checkPermissions();
    setState(() => _wealthRemindersEnabled = value);
    await _saveSettings();
    await _wealthManager.scheduleWealthReminders(value);
  }

  Future<void> _toggleBudget(bool value) async {
    if (value) await _checkPermissions();
    setState(() => _budgetBreachEnabled = value);
    await _saveSettings();
    // No scheduling needed; this works reactively when expenses are added
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _dailyReminderTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: BudgetrColors.cardSurface,
              hourMinuteTextColor: Colors.white,
              dayPeriodTextColor: Colors.white70,
              dialHandColor: BudgetrColors.accent,
              dialBackgroundColor: Colors.white10,
              entryModeIconColor: BudgetrColors.accent,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: BudgetrColors.accent,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _dailyReminderTime) {
      setState(() => _dailyReminderTime = picked);
      if (_dailyReminderEnabled) {
        await _saveSettings();
        // Reschedule with new time
        await _dailyManager.scheduleDailyReminder(_dailyReminderTime, true);
      }
    }
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: BudgetrColors.cardSurface,
        title: const Text("Permission Required",
            style: TextStyle(color: Colors.white)),
        content: const Text("Notifications are disabled in system settings.",
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
              child: const Text("Dismiss"),
              onPressed: () => Navigator.pop(ctx)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BudgetrColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Uplink Configuration", style: BudgetrStyles.h2),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Text(
                  "Communication Protocols",
                  style: TextStyle(
                      color: Colors.white54,
                      fontSize: 14,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                // 1. Daily Logistics (With Time Picker)
                _buildNotificationChannelCard(
                  title: "Daily Ledger Sync",
                  subtitle: "Remind me to log daily expenses",
                  icon: Icons.access_time_filled_rounded,
                  color: const Color(0xFF4CC9F0),
                  isEnabled: _dailyReminderEnabled,
                  onToggle: _toggleDaily,
                  extraContent:
                      _dailyReminderEnabled ? _buildTimePickerDisplay() : null,
                ),
                const SizedBox(height: 16),

                // 2. Credit Alerts
                _buildNotificationChannelCard(
                  title: "Debt Protocol",
                  subtitle: "Alerts for statement generation & due dates",
                  icon: Icons.credit_card_rounded,
                  color: const Color(0xFFF72585),
                  isEnabled: _creditAlertsEnabled,
                  onToggle: _toggleCredit,
                ),
                const SizedBox(height: 16),

                // 3. Wealth Growth
                _buildNotificationChannelCard(
                  title: "Wealth Growth",
                  subtitle: "Monthly reminders for Net Worth & SIPs",
                  icon: Icons.trending_up_rounded,
                  color: const Color(0xFF7209B7),
                  isEnabled: _wealthRemindersEnabled,
                  onToggle: _toggleWealth,
                ),
                const SizedBox(height: 16),

                // 4. Budget Guardian [NEWLY ADDED]
                _buildNotificationChannelCard(
                  title: "Budget Breach Protocol",
                  subtitle: "Immediate alerts when category limits are crossed",
                  icon: Icons.shield_outlined,
                  color: const Color(0xFFFF006E),
                  isEnabled: _budgetBreachEnabled,
                  onToggle: _toggleBudget,
                ),

                const SizedBox(height: 40),
                Center(
                  child: TextButton.icon(
                    onPressed: () async {
                      await _coreService.cancelAll();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    "All scheduled notifications cleared")));
                      }
                    },
                    icon:
                        const Icon(Icons.delete_outline, color: Colors.white24),
                    label: const Text("Purge All Scheduled Uplinks",
                        style: TextStyle(color: Colors.white24)),
                  ),
                )
              ],
            ),
    );
  }

  Widget _buildNotificationChannelCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isEnabled,
    required ValueChanged<bool> onToggle,
    Widget? extraContent,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: BudgetrColors.cardSurface.withOpacity(0.6),
        borderRadius: BudgetrStyles.radiusL,
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        boxShadow: isEnabled ? BudgetrStyles.glowBoxShadow(color) : [],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: color.withOpacity(0.15), shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(subtitle,
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 12)),
                  ],
                ),
              ),
              Transform.scale(
                scale: 0.8,
                child: CupertinoSwitch(
                  value: isEnabled,
                  activeColor: color,
                  trackColor: Colors.white24,
                  onChanged: onToggle,
                ),
              ),
            ],
          ),
          if (extraContent != null) ...[
            Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Divider(color: Colors.white.withOpacity(0.05))),
            extraContent,
          ],
        ],
      ),
    );
  }

  Widget _buildTimePickerDisplay() {
    return InkWell(
      onTap: _pickTime,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.black26,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Ping Time",
                style: TextStyle(
                    color: Colors.white70, fontWeight: FontWeight.w500)),
            Row(
              children: [
                Text(_dailyReminderTime.format(context),
                    style: const TextStyle(
                        color: BudgetrColors.accent,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
                const SizedBox(width: 8),
                const Icon(Icons.edit_outlined,
                    size: 16, color: Colors.white30),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
