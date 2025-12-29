import 'package:flutter/material.dart';
import '../../settings/screens/configuration_menu_screen.dart'; // UPDATED IMPORT

class HomeBottomBar extends StatelessWidget {
  const HomeBottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    final cardColor = const Color(0xFF1B263B).withOpacity(0.6);

    return Container(
      margin: const EdgeInsets.only(bottom: 20, top: 10),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: ListTile(
        onTap: () => Navigator.push(
          context,
          // UPDATED DESTINATION
          MaterialPageRoute(
            builder: (context) => const ConfigurationMenuScreen(),
          ),
        ),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.settings_outlined, color: Colors.white),
        ),
        title: const Text(
          "Configurations",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          "Buckets & Categories",
          style: TextStyle(color: Colors.white.withOpacity(0.5)),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios_rounded,
          color: Colors.white30,
          size: 16,
        ),
      ),
    );
  }
}
