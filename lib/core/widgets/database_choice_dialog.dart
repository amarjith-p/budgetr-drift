import 'package:flutter/material.dart';
import '../services/service_locator.dart';
import '../design/budgetr_colors.dart'; // Assuming this exists from your files

class DatabaseChoiceDialog extends StatelessWidget {
  final bool
      isSwitching; // True if switching from settings, False if initial setup

  const DatabaseChoiceDialog({super.key, this.isSwitching = false});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF1E1E1E),
      title:
          const Text("Select Database", style: TextStyle(color: Colors.white)),
      content: const Text(
        "Choose where to store your financial data.\n\n"
        "• Cloud (Firestore): Sync across devices, requires internet.\n"
        "• Local (Drift): Offline-first, data stays on this device.",
        style: TextStyle(color: Colors.white70),
      ),
      actions: [
        TextButton(
          onPressed: () => _select(context, DatabaseType.firestore),
          child: const Text("Cloud (Firebase)",
              style: TextStyle(color: Colors.blueAccent)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.purpleAccent),
          onPressed: () => _select(context, DatabaseType.drift),
          child: const Text("Local (Drift)",
              style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  Future<void> _select(BuildContext context, DatabaseType type) async {
    await ServiceLocator.switchDatabase(type);
    if (context.mounted) {
      Navigator.pop(context);
      // If we are switching, we might want to restart the app or nav to Home
      if (isSwitching) {
        // Trigger a rebuild or navigation to root
      }
    }
  }
}
