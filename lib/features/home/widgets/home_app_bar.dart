import 'package:budget/features/notifications/widgets/notification_bell.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
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
                letterSpacing: 3.2, // Tighter, more cohesive spacing
                color: Color.fromARGB(255, 255, 255, 255),
              ),
              children: [
                TextSpan(
                  text: 'Bud',
                  style:
                      TextStyle(fontWeight: FontWeight.w800), // Lighter start
                ),
                TextSpan(
                  text: 'Get',
                  style: TextStyle(
                    fontWeight: FontWeight.w800, // Emphasize the action "Get"
                    color: Color.fromARGB(255, 255, 255,
                        255), // Use your app's accent color (Cyan/Blue)
                  ),
                ),
                TextSpan(
                  text: 'R',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Color.fromARGB(255, 255, 255, 255), // Anchor the end
                  ),
                ),
              ],
            ),
          )
        ],
      ),
      actions: [
        // IconButton(
        //   onPressed: () {},
        //   icon: const Icon(Icons.notifications_outlined, color: Colors.white70),
        // ),
        const NotificationBell(),
      ],
    );
  }
}
