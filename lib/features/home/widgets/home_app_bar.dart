import 'package:budget/features/notifications/widgets/notification_bell.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/services/service_locator.dart';
import '../../../core/database/app_database.dart';
import '../../trip_mode/services/trip_service.dart';
import '../../trip_mode/screens/trip_dashboard_screen.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool needsBackup;
  final VoidCallback? onBackupTap;

  const HomeAppBar({
    super.key,
    this.needsBackup = false,
    this.onBackupTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final tripService = locator<TripService>();

    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      title: Row(
        children: [
          // Avatar
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1.5,
              ),
              image: const DecorationImage(
                image: AssetImage('assets/images/avatar.png'),
                fit: BoxFit.cover,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // App Title
          RichText(
            text: TextSpan(
              style: GoogleFonts.robotoSlab(
                fontSize: 24,
                letterSpacing: 3.2,
                color: const Color.fromARGB(255, 255, 255, 255),
              ),
              children: const [
                TextSpan(
                  text: 'Bud',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                TextSpan(
                  text: 'Get',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Color.fromARGB(255, 255, 255, 255),
                  ),
                ),
                TextSpan(
                  text: 'R',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Color.fromARGB(255, 255, 255, 255),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
      actions: [
        // Backup Overdue Warning Icon
        if (needsBackup)
          IconButton(
            tooltip: 'Backup Overdue!',
            icon: const Icon(
              Icons.warning_amber_rounded,
              color: Colors.redAccent,
            ),
            onPressed: onBackupTap,
          ),

        // Active / Paused Trip Mode Indicator
        StreamBuilder<TripRecord?>(
          stream: tripService.getActiveTrip(),
          builder: (context, snapshot) {
            final activeTrip = snapshot.data;

            if (activeTrip != null) {
              // [NEW] Dynamic Icon and Color based on Pause status
              final isPaused = activeTrip.isPaused;

              return IconButton(
                tooltip: isPaused ? 'Trip Mode Paused' : 'Trip Mode Active',
                icon: Icon(
                  isPaused
                      ? Icons.flight_land_rounded
                      : Icons.flight_takeoff_rounded,
                  color: isPaused
                      ? Colors.orangeAccent
                      : const Color.fromARGB(255, 5, 146, 0),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TripDashboardScreen(),
                    ),
                  );
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),

        const NotificationBell(),
      ],
    );
  }
}
