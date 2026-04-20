import 'dart:async';
import 'package:flutter/material.dart';

class CountdownTimerWidget extends StatefulWidget {
  final DateTime targetDate;
  final Color color;

  const CountdownTimerWidget(
      {super.key, required this.targetDate, required this.color});

  @override
  State<CountdownTimerWidget> createState() => _CountdownTimerWidgetState();
}

class _CountdownTimerWidgetState extends State<CountdownTimerWidget> {
  Timer? _timer;
  String _timeString = '';
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    _updateTime();
    if (!_isCompleted) {
      _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateTime());
    }
  }

  void _updateTime() {
    final now = DateTime.now();
    final difference = widget.targetDate.difference(now);

    if (difference.isNegative) {
      if (mounted)
        setState(() {
          _isCompleted = true;
          _timeString = "00:00:00";
        });
      _timer?.cancel();
      return;
    }

    if (difference.inHours > 48) {
      if (mounted) setState(() => _timeString = "${difference.inDays} Days");
    } else {
      String twoDigits(int n) => n.toString().padLeft(2, '0');
      final hours = twoDigits(difference.inHours);
      final minutes = twoDigits(difference.inMinutes.remainder(60));
      final seconds = twoDigits(difference.inSeconds.remainder(60));
      if (mounted) setState(() => _timeString = "$hours:$minutes:$seconds");
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _timeString,
          style: TextStyle(
            color: _isCompleted ? Colors.white24 : Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
            fontFamily: 'Orbitron',
          ),
        ),
        Text(
          "REMAINING",
          style: TextStyle(
              color: widget.color.withOpacity(0.5),
              fontSize: 7,
              fontWeight: FontWeight.w900,
              letterSpacing: 1),
        ),
      ],
    );
  }
}
