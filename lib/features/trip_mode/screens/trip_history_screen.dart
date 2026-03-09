import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../core/design/budgetr_colors.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/modern_app_bar.dart';
import '../../../core/widgets/status_bottom_sheet.dart';
import '../../../core/database/app_database.dart';

import '../services/trip_service.dart';
import 'trip_details_screen.dart';

class TripHistoryScreen extends StatelessWidget {
  const TripHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = GetIt.I<TripService>();
    final dateFormat = DateFormat('MMM dd, yyyy');

    return Scaffold(
      backgroundColor: BudgetrColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const ModernAppBar(
              title: "Trip History",
              subtitle: "PAST ADVENTURES",
              trailingIcon: null, // No trailing icon needed here
            ),
            Expanded(
              child: StreamBuilder<List<TripRecord>>(
                stream: service.getCompletedTrips(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: CircularProgressIndicator(
                            color: BudgetrColors.accent));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.flight_land_rounded,
                              size: 60, color: Colors.white.withOpacity(0.1)),
                          const SizedBox(height: 16),
                          Text("No completed trips found.",
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.4),
                                  fontSize: 16)),
                        ],
                      ),
                    );
                  }

                  final trips = snapshot.data!;
                  return ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: trips.length,
                    itemBuilder: (context, index) {
                      final trip = trips[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Slidable(
                          key: ValueKey(trip.id),
                          endActionPane: ActionPane(
                            motion: const ScrollMotion(),
                            children: [
                              SlidableAction(
                                onPressed: (_) =>
                                    _confirmDelete(context, trip, service),
                                backgroundColor: BudgetrColors.error,
                                foregroundColor: Colors.white,
                                icon: Icons.delete_outline_rounded,
                                label: 'Delete',
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ],
                          ),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          TripDetailsScreen(trip: trip)));
                            },
                            child: GlassCard(
                              margin: EdgeInsets.zero,
                              padding: const EdgeInsets.all(16),
                              borderRadius: 16,
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.05),
                                        shape: BoxShape.circle),
                                    child: const Icon(Icons.flight_land_rounded,
                                        color: Colors.white54, size: 24),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(trip.tripName,
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16)),
                                        const SizedBox(height: 4),
                                        Text(
                                            "${dateFormat.format(trip.startDate)} - ${trip.endDate != null ? dateFormat.format(trip.endDate!) : 'Unknown'}",
                                            style: const TextStyle(
                                                color: Colors.white54,
                                                fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.chevron_right_rounded,
                                      color: Colors.white38),
                                ],
                              ),
                            ),
                          ),
                        ),
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

  void _confirmDelete(
      BuildContext context, TripRecord trip, TripService service) {
    showStatusSheet(
      context: context,
      title: "Delete Trip?",
      message:
          "Are you sure you want to delete '${trip.tripName}'? This action cannot be undone.",
      icon: Icons.delete_forever_rounded,
      color: BudgetrColors.error,
      buttonText: "Delete",
      cancelButtonText: "Cancel",
      onDismiss: () => service.deleteTrip(trip.id),
    );
  }
}
