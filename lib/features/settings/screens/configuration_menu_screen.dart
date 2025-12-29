import 'package:flutter/material.dart';
import '../../settings/screens/settings_screen.dart';
import 'category_manager_screen.dart';

class ConfigurationMenuScreen extends StatelessWidget {
  const ConfigurationMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xff0D1B2A);
    const cardColor = Color(0xFF1B263B);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Configurations",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildMenuCard(
              context,
              title: "Budget Buckets",
              subtitle: "Configure your 50/30/20 splits",
              icon: Icons.pie_chart_outline,
              color: const Color(0xFF3A86FF),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              ),
            ),
            const SizedBox(height: 16),
            _buildMenuCard(
              context,
              title: "Transaction Categories",
              subtitle: "Manage Income & Expense types",
              icon: Icons.category_outlined,
              color: const Color(0xFFF72585),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CategoryManagerScreen(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1B263B).withOpacity(0.8),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white.withOpacity(0.3),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
