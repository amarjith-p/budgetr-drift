import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../core/design/budgetr_colors.dart';
import '../../../core/widgets/modern_app_bar.dart';
import '../../../core/widgets/status_bottom_sheet.dart';
import '../../../core/database/app_database.dart';
import '../services/trip_service.dart';
import 'trip_details_screen.dart';

class TripDashboardScreen extends StatefulWidget {
  const TripDashboardScreen({super.key});

  @override
  State<TripDashboardScreen> createState() => _TripDashboardScreenState();
}

class _TripDashboardScreenState extends State<TripDashboardScreen> {
  final TripService service = GetIt.I<TripService>();
  final dateFormat = DateFormat('MMM dd, yyyy');

  void _showStartTripSheet() {
    final nameController = TextEditingController();
    final budgetController = TextEditingController();
    String? nameError;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) =>
          StatefulBuilder(// Use StatefulBuilder for local sheet state
              builder: (BuildContext context, StateSetter setModalState) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Color(0xFF1B263B),
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const Text(
                  "START NEW TRIP",
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 24),

                // Trip Name Input (With Validation)
                const Text("Trip Name",
                    style: TextStyle(color: Colors.white70, fontSize: 14)),
                const SizedBox(height: 8),
                TextField(
                  controller: nameController,
                  style: const TextStyle(color: Colors.white),
                  textCapitalization: TextCapitalization.words,
                  onChanged: (value) {
                    if (nameError != null && value.trim().isNotEmpty) {
                      setModalState(
                          () => nameError = null); // Clear error on typing
                    }
                  },
                  decoration: InputDecoration(
                    hintText: "e.g., Goa Vacation",
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                    filled: true,
                    fillColor: Colors.black12,
                    errorText: nameError,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none),
                    errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: BudgetrColors.error, width: 1)),
                    focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: BudgetrColors.error, width: 1.5)),
                    prefixIcon:
                        const Icon(Icons.flight_takeoff, color: Colors.white38),
                  ),
                ),
                const SizedBox(height: 20),

                // Budget Input
                const Text("Budget (Optional)",
                    style: TextStyle(color: Colors.white70, fontSize: 14)),
                const SizedBox(height: 8),
                TextField(
                  controller: budgetController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Enter amount",
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                    filled: true,
                    fillColor: Colors.black12,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none),
                    prefixIcon: const Icon(Icons.account_balance_wallet,
                        color: Colors.white38),
                  ),
                ),
                const SizedBox(height: 32),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side:
                              BorderSide(color: Colors.white.withOpacity(0.2)),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text("CANCEL",
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF72585),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        onPressed: () async {
                          final name = nameController.text.trim();
                          if (name.isEmpty) {
                            setModalState(
                                () => nameError = "Please enter a trip name");
                            return;
                          }

                          final budget =
                              double.tryParse(budgetController.text.trim());
                          await service.startTrip(name, budget);
                          if (ctx.mounted) Navigator.pop(ctx);
                        },
                        child: const Text("START TRIP",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BudgetrColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const ModernAppBar(
              title: "Trip Mode",
              subtitle: "TRAVEL EXPENSE ISOLATION",
              trailingIcon: null,
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionLabel("CURRENT ADVENTURE"),
                    _buildActiveTripSection(),
                    const SizedBox(height: 32),
                    _buildSectionLabel("PAST ADVENTURES"),
                    _buildHistorySection(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: StreamBuilder<TripRecord?>(
        stream: service.getActiveTrip(),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null)
            return const SizedBox.shrink();
          return FloatingActionButton.extended(
            backgroundColor: const Color(0xFFF72585),
            icon: const Icon(Icons.flight_takeoff_rounded, color: Colors.white),
            label: const Text("Start Trip",
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            onPressed: _showStartTripSheet,
          );
        },
      ),
    );
  }

  Widget _buildActiveTripSection() {
    return StreamBuilder<TripRecord?>(
      stream: service.getActiveTrip(),
      builder: (context, snapshot) {
        final trip = snapshot.data;
        if (trip == null) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.02),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: Colors.white.withOpacity(0.05),
                  style: BorderStyle.solid),
            ),
            child: Column(
              children: [
                Icon(Icons.flight_outlined,
                    color: Colors.white.withOpacity(0.2), size: 40),
                const SizedBox(height: 12),
                Text("No Active Trip",
                    style: TextStyle(color: Colors.white.withOpacity(0.5))),
              ],
            ),
          );
        }

        return _buildTripCard(trip, isActive: true);
      },
    );
  }

  Widget _buildHistorySection() {
    return StreamBuilder<List<TripRecord>>(
      stream: service.getCompletedTrips(),
      builder: (context, snapshot) {
        final trips = snapshot.data ?? [];
        if (trips.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text("No completed trips found.",
                  style: TextStyle(color: Colors.white.withOpacity(0.3))),
            ),
          );
        }

        return Column(
          children: trips
              .map((t) => Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Slidable(
                      key: ValueKey(t.id),
                      endActionPane: ActionPane(
                        motion: const ScrollMotion(),
                        children: [
                          SlidableAction(
                            onPressed: (_) => _confirmDelete(t),
                            backgroundColor: BudgetrColors.error,
                            foregroundColor: Colors.white,
                            icon: Icons.delete_outline_rounded,
                            label: 'Delete',
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ],
                      ),
                      child: _buildTripCard(t, isActive: false),
                    ),
                  ))
              .toList(),
        );
      },
    );
  }

  Widget _buildTripCard(TripRecord trip, {required bool isActive}) {
    // [NEW] Check pause status
    final isPaused = trip.isPaused;

    // [NEW] Change color dynamically based on pause state
    final color = isActive
        ? (isPaused ? Colors.orangeAccent : const Color(0xFFF72585))
        : Colors.white54;

    return GestureDetector(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => TripDetailsScreen(trip: trip))),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isActive
              ? color.withOpacity(0.08)
              : Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: isActive
                  ? color.withOpacity(0.3)
                  : Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isActive
                    ? color.withOpacity(0.2)
                    : Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                  isActive
                      ? (isPaused
                          ? Icons.pause_circle_filled_rounded
                          : Icons.flight_takeoff_rounded)
                      : Icons.flight_land_rounded,
                  color: color,
                  size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    trip.tripName,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isActive
                        ? (isPaused
                            ? "Trip paused. Not tracking expenses."
                            : "Tracking active expenses...")
                        : "${dateFormat.format(trip.startDate)} - ${trip.endDate != null ? dateFormat.format(trip.endDate!) : ''}",
                    style: TextStyle(
                        color: isActive ? color : Colors.white.withOpacity(0.5),
                        fontSize: 12),
                  ),
                ],
              ),
            ),
            // [NEW] Pause/Resume Quick Action inside the card
            if (isActive)
              IconButton(
                icon: Icon(
                    isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                    color: color),
                onPressed: () {
                  if (isPaused) {
                    _confirmResumeTrip(trip);
                  } else {
                    _confirmPauseTrip(trip);
                  }
                },
              ),
            if (!isActive)
              Icon(Icons.arrow_forward_ios_rounded,
                  color: Colors.white.withOpacity(0.2), size: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        label,
        style: const TextStyle(
            color: Colors.white38,
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5),
      ),
    );
  }

  // --- CONFIRMATION SHEETS ---

  void _confirmPauseTrip(TripRecord trip) {
    showStatusSheet(
      context: context,
      title: "Pause Trip?",
      message:
          "Are you sure you want to pause '${trip.tripName}'? Your daily expenses will not be tracked under this trip until you resume.",
      icon: Icons.pause_circle_filled_rounded,
      color: Colors.orangeAccent,
      buttonText: "Pause Trip",
      onDismiss: () => service.pauseTrip(trip.id),
      cancelButtonText: "Cancel",
      onCancel: () {},
    );
  }

  void _confirmResumeTrip(TripRecord trip) {
    showStatusSheet(
      context: context,
      title: "Resume Trip?",
      message:
          "Are you sure you want to resume '${trip.tripName}'? New expenses will now automatically be tracked under this trip.",
      icon: Icons.play_circle_fill_rounded,
      color: BudgetrColors.accent,
      buttonText: "Resume Trip",
      onDismiss: () => service.resumeTrip(trip.id),
      cancelButtonText: "Cancel",
      onCancel: () {},
    );
  }

  void _confirmDelete(TripRecord trip) {
    showStatusSheet(
      context: context,
      title: "Delete Trip?",
      message:
          "Are you sure you want to delete '${trip.tripName}'? All analytical data for this trip will be lost.",
      icon: Icons.delete_forever_rounded,
      color: BudgetrColors.error,
      buttonText: "Delete",
      onDismiss: () => service.deleteTrip(trip.id),
      cancelButtonText: "Cancel",
      onCancel: () {},
    );
  }
}
