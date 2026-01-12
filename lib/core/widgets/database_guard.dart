import 'package:flutter/material.dart';
import '../services/service_locator.dart';
import 'database_choice_dialog.dart';

class DatabaseGuard extends StatefulWidget {
  final Widget child;
  const DatabaseGuard({super.key, required this.child});

  @override
  State<DatabaseGuard> createState() => _DatabaseGuardState();
}

class _DatabaseGuardState extends State<DatabaseGuard> {
  @override
  void initState() {
    super.initState();
    // Check configuration as soon as the widget initializes
    _checkConfiguration();
  }

  void _checkConfiguration() {
    if (!ServiceLocator.isConfigured) {
      // Schedule the dialog to show after the first frame allows it
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showSelectionDialog();
      });
    }
  }

  Future<void> _showSelectionDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: false, // Prevent closing by tapping outside
      builder: (context) => const DatabaseChoiceDialog(),
    );

    // Once the dialog closes (meaning a selection was made), refresh the app state
    if (mounted) {
      setState(() {
        // Triggers a rebuild, now with the correct service loaded
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // We show the child (HomeScreen) immediately.
    // The dialog will pop up *over* it if configuration is missing.
    return widget.child;
  }
}
