import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import '../../../core/widgets/glass_card.dart';
import '../services/real_time_notification_manager.dart';
import 'scheduled_notifications_screen.dart';

class NotificationManagerScreen extends StatefulWidget {
  const NotificationManagerScreen({super.key});

  @override
  State<NotificationManagerScreen> createState() =>
      _NotificationManagerScreenState();
}

class _NotificationManagerScreenState extends State<NotificationManagerScreen> {
  late SharedPreferences _prefs;
  bool _isLoading = true;

  // --- PREFERENCE KEYS ---
  static const String kPrefDailyEnabled = 'notif_enable_daily_reminder';
  static const String kPrefDailyTime = 'notif_time_daily';

  static const String kPrefLoanGoalEnabled = 'notif_enable_loangoal';
  static const String kPrefLoanGoalTime = 'notif_time_loangoal';

  static const String kPrefBackupEnabled = 'notif_enable_backup';
  static const String kPrefBackupTime = 'notif_time_backup';

  static const String kPrefCreditEnabled = 'notif_enable_credit';
  static const String kPrefCreditTime = 'notif_time_credit';

  static const String kPrefBudgetEnabled = 'notif_enable_budget';
  static const String kPrefAccountEnabled = 'notif_enable_account';
  static const String kPrefInvestEnabled = 'notif_enable_invest';
  static const String kPrefLowBalanceThreshold = 'notif_config_low_balance';

  // --- STATE VARIABLES ---
  bool _dailyEnabled = true;
  TimeOfDay _dailyTime = const TimeOfDay(hour: 20, minute: 0);

  bool _loanGoalEnabled = true;
  TimeOfDay _loanGoalTime = const TimeOfDay(hour: 9, minute: 0);

  bool _backupEnabled = true;
  TimeOfDay _backupTime = const TimeOfDay(hour: 18, minute: 0);

  bool _creditEnabled = true;
  TimeOfDay _creditTime = const TimeOfDay(hour: 10, minute: 0);

  bool _budgetEnabled = true;
  bool _accountEnabled = true;
  bool _investEnabled = true;
  double _lowBalanceThreshold = 1000.0;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _dailyEnabled = _prefs.getBool(kPrefDailyEnabled) ?? true;
      _dailyTime = _parseTime(_prefs.getString(kPrefDailyTime),
          const TimeOfDay(hour: 20, minute: 0));

      _loanGoalEnabled = _prefs.getBool(kPrefLoanGoalEnabled) ?? true;
      _loanGoalTime = _parseTime(_prefs.getString(kPrefLoanGoalTime),
          const TimeOfDay(hour: 9, minute: 0));

      _backupEnabled = _prefs.getBool(kPrefBackupEnabled) ?? true;
      _backupTime = _parseTime(_prefs.getString(kPrefBackupTime),
          const TimeOfDay(hour: 18, minute: 0));

      _creditEnabled = _prefs.getBool(kPrefCreditEnabled) ?? true;
      _creditTime = _parseTime(_prefs.getString(kPrefCreditTime),
          const TimeOfDay(hour: 10, minute: 0));

      _budgetEnabled = _prefs.getBool(kPrefBudgetEnabled) ?? true;
      _accountEnabled = _prefs.getBool(kPrefAccountEnabled) ?? true;
      _investEnabled = _prefs.getBool(kPrefInvestEnabled) ?? true;
      _lowBalanceThreshold =
          _prefs.getDouble(kPrefLowBalanceThreshold) ?? 1000.0;
      _isLoading = false;
    });
  }

  TimeOfDay _parseTime(String? timeStr, TimeOfDay fallback) {
    if (timeStr == null || !timeStr.contains(":")) return fallback;
    final parts = timeStr.split(":");
    return TimeOfDay(
        hour: int.tryParse(parts[0]) ?? fallback.hour,
        minute: int.tryParse(parts[1]) ?? fallback.minute);
  }

  String _formatTimeStr(TimeOfDay time) {
    return "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
  }

  String _format12Hour(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat.jm().format(dt);
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    if (value is bool) await _prefs.setBool(key, value);
    if (value is double) await _prefs.setDouble(key, value);
    if (value is String) await _prefs.setString(key, value);
  }

  Future<void> _rescheduleAll() async {
    final manager = GetIt.I<RealTimeNotificationManager>();
    await manager.rescheduleAll();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Schedules Updated Successfully"),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _pickTime(BuildContext context, TimeOfDay initialTime,
      Function(TimeOfDay) onPicked) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
          child: child!,
        );
      },
    );
    if (picked != null) {
      onPicked(picked);
      _rescheduleAll();
    }
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xff0D1B2A);

    if (_isLoading) {
      return const Scaffold(
          backgroundColor: bgColor,
          body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // 1. MODERN HEADER
            _buildModernHeader(context),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader("SCHEDULED REMINDERS"),

                    // 1. Daily App Reminder
                    _buildConfigCard(
                      title: "Daily Check-in",
                      subtitle: "Reminds you to log expenses",
                      enabled: _dailyEnabled,
                      time: _dailyTime,
                      onToggle: (v) {
                        setState(() => _dailyEnabled = v);
                        _saveSetting(kPrefDailyEnabled, v);
                        _rescheduleAll();
                      },
                      onTimeTap: () => _pickTime(context, _dailyTime, (t) {
                        setState(() => _dailyTime = t);
                        _saveSetting(kPrefDailyTime, _formatTimeStr(t));
                      }),
                    ),

                    // 2. Loans & Goals
                    _buildConfigCard(
                      title: "Loans & Goals",
                      subtitle: "Deadlines and repayment alerts",
                      enabled: _loanGoalEnabled,
                      time: _loanGoalTime,
                      onToggle: (v) {
                        setState(() => _loanGoalEnabled = v);
                        _saveSetting(kPrefLoanGoalEnabled, v);
                        _rescheduleAll();
                      },
                      onTimeTap: () => _pickTime(context, _loanGoalTime, (t) {
                        setState(() => _loanGoalTime = t);
                        _saveSetting(kPrefLoanGoalTime, _formatTimeStr(t));
                      }),
                    ),

                    // 3. Credit Cards
                    _buildConfigCard(
                      title: "Credit Cards",
                      subtitle: "Bill generation and due dates",
                      enabled: _creditEnabled,
                      time: _creditTime,
                      onToggle: (v) {
                        setState(() => _creditEnabled = v);
                        _saveSetting(kPrefCreditEnabled, v);
                        _rescheduleAll();
                      },
                      onTimeTap: () => _pickTime(context, _creditTime, (t) {
                        setState(() => _creditTime = t);
                        _saveSetting(kPrefCreditTime, _formatTimeStr(t));
                      }),
                    ),

                    // 4. Backup Check
                    _buildConfigCard(
                      title: "Backup Verification",
                      subtitle: "Checks if your data is safely backed up",
                      enabled: _backupEnabled,
                      time: _backupTime,
                      onToggle: (v) {
                        setState(() => _backupEnabled = v);
                        _saveSetting(kPrefBackupEnabled, v);
                      },
                      onTimeTap: () => _pickTime(context, _backupTime, (t) {
                        setState(() => _backupTime = t);
                        _saveSetting(kPrefBackupTime, _formatTimeStr(t));
                      }),
                    ),

                    const SizedBox(height: 24),
                    _buildSectionHeader("BACKGROUND MODULES"),

                    _buildSwitch(
                        "Budget Watch", "Bucket overflows", _budgetEnabled,
                        (v) {
                      setState(() => _budgetEnabled = v);
                      _saveSetting(kPrefBudgetEnabled, v);
                    }),
                    _buildSwitch(
                        "Investments", "Volatility, stale data", _investEnabled,
                        (v) {
                      setState(() => _investEnabled = v);
                      _saveSetting(kPrefInvestEnabled, v);
                    }),

                    const SizedBox(height: 24),
                    _buildSectionHeader("ACCOUNT SETTINGS"),
                    _buildSwitch("Account Monitoring", "Low balance alerts",
                        _accountEnabled, (v) {
                      setState(() => _accountEnabled = v);
                      _saveSetting(kPrefAccountEnabled, v);
                    }),
                    if (_accountEnabled)
                      _buildSlider(
                        "Low Balance Threshold",
                        "Alert when below ₹${_lowBalanceThreshold.toStringAsFixed(0)}",
                        _lowBalanceThreshold,
                        100,
                        10000,
                        (v) => setState(() => _lowBalanceThreshold = v),
                        (v) => _saveSetting(kPrefLowBalanceThreshold, v),
                      ),

                    const SizedBox(height: 32),
                    _buildScheduleButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- MODERN HEADER ---
  Widget _buildModernHeader(BuildContext context) {
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
                  "SETTINGS",
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2.0,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  "Notification Manager",
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

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
            color: Colors.white54,
            fontSize: 12,
            letterSpacing: 1.5,
            fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildConfigCard({
    required String title,
    required String subtitle,
    required bool enabled,
    required TimeOfDay time,
    required Function(bool) onToggle,
    required VoidCallback onTimeTap,
  }) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      borderRadius: 12,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(subtitle,
                        style: const TextStyle(
                            color: Colors.white54, fontSize: 12)),
                  ],
                ),
              ),
              Switch(
                value: enabled,
                activeColor: const Color(0xFF00B4D8),
                onChanged: onToggle,
              ),
            ],
          ),
          if (enabled) ...[
            const Divider(color: Colors.white10, height: 24),
            GestureDetector(
              onTap: onTimeTap,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Trigger Time",
                      style: TextStyle(color: Colors.white70, fontSize: 14)),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00B4D8).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: const Color(0xFF00B4D8).withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.access_time,
                            color: Color(0xFF00B4D8), size: 16),
                        const SizedBox(width: 8),
                        Text(
                          _format12Hour(time),
                          style: const TextStyle(
                              color: Color(0xFF00B4D8),
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSwitch(
      String title, String subtitle, bool value, Function(bool) onChanged) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      borderRadius: 12,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(subtitle,
                    style:
                        const TextStyle(color: Colors.white54, fontSize: 12)),
              ],
            ),
          ),
          Switch(
              value: value,
              activeColor: const Color(0xFF00B4D8),
              onChanged: onChanged),
        ],
      ),
    );
  }

  Widget _buildSlider(String title, String subtitle, double value, double min,
      double max, Function(double) onChanged, Function(double) onEnd) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 12, top: 4),
      padding: const EdgeInsets.all(16),
      borderRadius: 12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(subtitle,
              style: const TextStyle(color: Colors.white54, fontSize: 12)),
          const SizedBox(height: 12),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: const Color(0xFF00B4D8),
              inactiveTrackColor: Colors.white10,
              thumbColor: Colors.white,
            ),
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: (max - min) ~/ 100,
              label: value.round().toString(),
              onChanged: onChanged,
              onChangeEnd: onEnd,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.calendar_month_rounded, color: Colors.black87),
        label: const Text("View Scheduled Queue",
            style:
                TextStyle(color: Colors.black87, fontWeight: FontWeight.bold)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => const ScheduledNotificationsScreen()));
        },
      ),
    );
  }
}
