import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import '../../../core/database/app_database.dart';
import '../services/reminder_service.dart';
import '../models/reminder_dto.dart';

class ModernReminderSheet extends StatefulWidget {
  final ReminderEntry? existingReminder;

  const ModernReminderSheet({Key? key, this.existingReminder})
      : super(key: key);

  @override
  State<ModernReminderSheet> createState() => _ModernReminderSheetState();
}

class _ModernReminderSheetState extends State<ModernReminderSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();

  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  bool _isNotificationEnabled = true;

  @override
  void initState() {
    super.initState();
    if (widget.existingReminder != null) {
      _titleController.text = widget.existingReminder!.title;
      _notesController.text = widget.existingReminder!.notes ?? '';
      _selectedDate = widget.existingReminder!.targetDate;
      _selectedTime =
          TimeOfDay.fromDateTime(widget.existingReminder!.targetDate);
      _isNotificationEnabled = widget.existingReminder!.isNotificationEnabled;
    } else {
      _selectedDate = DateTime.now();
      _selectedTime = TimeOfDay.now()
          .replacing(minute: (DateTime.now().minute / 5).ceil() * 5 + 5);
    }
  }

  void _saveReminder() async {
    if (!_formKey.currentState!.validate()) return;

    final targetDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    if (targetDateTime.isBefore(DateTime.now())) {
      // Inline validation for date/time since they aren't TextFields
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xff0D1B2A),
          title:
              const Text("Invalid Time", style: TextStyle(color: Colors.white)),
          content: const Text("Please select a date and time in the future.",
              style: TextStyle(color: Colors.white70)),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx), child: const Text("OK"))
          ],
        ),
      );
      return;
    }

    final model = ReminderModel(
      title: _titleController.text.trim(),
      notes: _notesController.text.trim(),
      targetDate: targetDateTime,
      isNotificationEnabled: _isNotificationEnabled,
    );

    if (widget.existingReminder != null) {
      await GetIt.I<ReminderService>()
          .updateReminder(widget.existingReminder!, model);
    } else {
      await GetIt.I<ReminderService>().addReminder(model);
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xff0D1B2A).withOpacity(0.9),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        padding: EdgeInsets.only(
          top: 20,
          left: 24,
          right: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                    child: Container(
                        width: 30,
                        height: 4,
                        decoration: BoxDecoration(
                            color: Colors.white10,
                            borderRadius: BorderRadius.circular(2)))),
                const SizedBox(height: 20),

                // Title Field with Validation
                TextFormField(
                  controller: _titleController,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Serif'),
                  decoration: InputDecoration(
                    hintText: "Reminder Title",
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.1)),
                    border: InputBorder.none,
                    errorStyle: const TextStyle(
                        color: Colors.redAccent, fontWeight: FontWeight.bold),
                  ),
                  validator: (value) => (value == null || value.isEmpty)
                      ? "Title is required"
                      : null,
                ),

                // Notes Field
                TextFormField(
                  controller: _notesController,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                  maxLines: 3,
                  minLines: 1,
                  decoration: InputDecoration(
                    hintText: "Add detailed notes...",
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.1)),
                    border: InputBorder.none,
                  ),
                ),
                const Divider(color: Colors.white10, height: 32),

                // Selectors
                Row(
                  children: [
                    Expanded(
                        child: _selectorTile(Icons.calendar_today_rounded,
                            DateFormat('dd MMM').format(_selectedDate),
                            () async {
                      final d = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2030));
                      if (d != null) setState(() => _selectedDate = d);
                    })),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _selectorTile(Icons.access_time_rounded,
                            _selectedTime.format(context), () async {
                      final t = await showTimePicker(
                          context: context, initialTime: _selectedTime);
                      if (t != null) setState(() => _selectedTime = t);
                    })),
                  ],
                ),

                const SizedBox(height: 20),
                _switchTile(),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00B4D8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    onPressed: _saveReminder,
                    child: Text(
                        widget.existingReminder != null
                            ? "UPDATE"
                            : "SET REMINDER",
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                            letterSpacing: 1.2)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _selectorTile(IconData icon, String text, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.05))),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF00B4D8), size: 18),
            const SizedBox(width: 10),
            Text(text,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _switchTile() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(12)),
      child: SwitchListTile(
        title: const Text("Push Notification",
            style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600)),
        value: _isNotificationEnabled,
        activeColor: const Color(0xFF00B4D8),
        onChanged: (v) => setState(() => _isNotificationEnabled = v),
        contentPadding: EdgeInsets.zero,
      ),
    );
  }
}
