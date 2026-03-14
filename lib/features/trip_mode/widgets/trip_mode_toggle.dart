import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../../../core/design/budgetr_colors.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/database/app_database.dart';
import '../services/trip_service.dart';
import '../screens/trip_details_screen.dart';
import '../screens/trip_history_screen.dart';

class TripModeToggle extends StatelessWidget {
  const TripModeToggle({super.key});

  void _showStartTripDialog(BuildContext context) {
    // [Keep your existing _showStartTripDialog logic here]
    final nameController = TextEditingController();
    final budgetController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: BudgetrColors.cardSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Start Trip Mode',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Trip Name',
                labelStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                enabledBorder: UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.white.withOpacity(0.2))),
                focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: BudgetrColors.accent)),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: budgetController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Budget (Optional)',
                labelStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                enabledBorder: UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: Colors.white.withOpacity(0.2))),
                focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: BudgetrColors.accent)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('CANCEL',
                style: TextStyle(color: Colors.white.withOpacity(0.5))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: BudgetrColors.accent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              if (nameController.text.isNotEmpty) {
                final budget = double.tryParse(budgetController.text);
                await GetIt.I<TripService>()
                    .startTrip(nameController.text, budget);
                if (ctx.mounted) Navigator.pop(ctx);
              }
            },
            child: const Text('START'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<TripRecord?>(
      stream: GetIt.I<TripService>().getActiveTrip(),
      builder: (context, snapshot) {
        final activeTrip = snapshot.data;

        // Visual logic based on pause status
        final isPaused = activeTrip?.isPaused ?? false;
        final baseColor = isPaused ? Colors.orangeAccent : BudgetrColors.accent;

        return GlassCard(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          padding: const EdgeInsets.all(16),
          color: activeTrip != null ? baseColor.withOpacity(0.1) : null,
          border: activeTrip != null
              ? Border.all(color: baseColor.withOpacity(0.5), width: 1)
              : null,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: activeTrip != null
                      ? baseColor.withOpacity(0.2)
                      : Colors.white.withOpacity(0.05),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  activeTrip != null
                      ? (isPaused
                          ? Icons.pause_rounded
                          : Icons.flight_takeoff_rounded)
                      : Icons.flight_rounded,
                  color: activeTrip != null ? baseColor : Colors.white54,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (activeTrip == null) {
                      _showStartTripDialog(context);
                    } else {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  TripDetailsScreen(trip: activeTrip)));
                    }
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activeTrip?.tripName ?? "Start Trip Mode",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        activeTrip != null
                            ? (isPaused
                                ? "Trip Paused"
                                : "Tracking active expenses...")
                            : "Isolate travel expenses",
                        style: TextStyle(
                          color: activeTrip != null
                              ? baseColor.withOpacity(0.8)
                              : Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // ALWAYS VISIBLE HISTORY BUTTON
              IconButton(
                icon: const Icon(Icons.history_rounded, color: Colors.white70),
                tooltip: "Trip History",
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const TripHistoryScreen()));
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
