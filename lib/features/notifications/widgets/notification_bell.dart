import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../services/notification_service.dart';
import '../screens/notification_center_screen.dart';

class NotificationBell extends StatefulWidget {
  const NotificationBell({super.key});

  @override
  State<NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends State<NotificationBell>
    with WidgetsBindingObserver {
  late Stream<int> _unreadCountStream;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addObserver(this); // Start listening to app lifecycle
    _initStream();
  }

  void _initStream() {
    // Initialize the stream once, holding it in state to prevent infinite rebuilds
    _unreadCountStream = GetIt.I<NotificationService>().getUnreadCount();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // Clean up
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // FIX: When the app wakes up, the database hasn't mutated, so the old stream is stuck.
      // We re-initialize the stream here so `DateTime.now()` is re-evaluated in the query.
      setState(() {
        _initStream();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<int>(
      stream: _unreadCountStream,
      builder: (context, snapshot) {
        final count = snapshot.data ?? 0;

        return Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon:
                  const Icon(Icons.notifications_outlined, color: Colors.white),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => const NotificationCenterScreen()),
                );
              },
            ),
            if (count > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.redAccent,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 16,
                    minHeight: 16,
                  ),
                  child: Text(
                    count > 9 ? '9+' : '$count',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
