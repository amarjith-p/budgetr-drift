import 'package:flutter/material.dart';

/// A reusable bottom sheet for showing success, error, or warning statuses.
///
/// Usage (Single Button - Standard):
/// ```dart
/// showStatusSheet(
///   context: context,
///   title: "Success",
///   message: "Data saved successfully",
///   icon: Icons.check_circle,
///   color: Colors.green
/// );
/// ```
///
/// Usage (Two Buttons - Confirmation):
/// ```dart
/// showStatusSheet(
///   context: context,
///   title: "Delete?",
///   message: "Are you sure you want to delete this transaction?",
///   icon: Icons.delete_forever,
///   color: Colors.red,
///   buttonText: "Delete",
///   onDismiss: () => performDelete(), // The main action
///   cancelButtonText: "Cancel",       // Triggers two-button mode
///   onCancel: () => print("Cancelled"),
/// );
/// ```
void showStatusSheet({
  required BuildContext context,
  required String title,
  required String message,
  required IconData icon,
  required Color color,
  String buttonText = "Dismiss",
  VoidCallback? onDismiss,
  // New Optional Parameters for Second Button
  String? cancelButtonText,
  VoidCallback? onCancel,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) {
      return Container(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        decoration: const BoxDecoration(
          color: Color(0xff1B263B), // Consistent Dark Theme Background
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 24, top: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Icon Bubble
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: color),
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // Message
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons Logic
            if (cancelButtonText != null)
              // MODE 1: Two Buttons (Cancel + Action)
              Row(
                children: [
                  // Cancel Button
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        if (onCancel != null) onCancel();
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: Colors.white.withOpacity(0.2)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        cancelButtonText,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Main Action Button (e.g. Delete)
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        if (onDismiss != null) onDismiss();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            color, // Use 'color' (e.g. Red) to emphasize action
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        buttonText,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              )
            else
              // MODE 2: Single Button (Original Behavior)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    if (onDismiss != null) onDismiss();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff2C3E50),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(buttonText,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 16),
          ],
        ),
      );
    },
  );
}
