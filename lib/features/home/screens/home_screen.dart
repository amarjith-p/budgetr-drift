import 'dart:ui';
import 'package:flutter/material.dart';
import '../../dashboard/screens/dashboard_screen.dart';
import '../../settlement/screens/settlement_screen.dart';
import '../../settings/screens/settings_screen.dart';
import '../../mutual_funds/screens/mf_tracker_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0D1B2A),
      body: Stack(
        children: [
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF3A86FF).withOpacity(0.3),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -150,
            right: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF00A6FB).withOpacity(0.2),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(24.0),
              children: [
                const SizedBox(height: 40),
                Text(
                  'BudGetR',
                  style: TextStyle(
                    fontSize: 16,
                    color: const Color(0xFF90E0EF).withOpacity(0.8),
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'FinTracK',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 40),
                _GlassMenuCard(
                  icon: Icons.account_balance_wallet_outlined,
                  title: 'Budgets',
                  subtitle: 'View & manage monthly Budgets',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DashboardScreen(),
                    ),
                  ),
                ),
                _GlassMenuCard(
                  icon: Icons.analytics_outlined,
                  title: 'Settlement Analysis',
                  subtitle: 'View spending habits',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettlementScreen(),
                    ),
                  ),
                ),
                _GlassMenuCard(
                  icon: Icons.ssid_chart_outlined,
                  title: 'Mutual Funds',
                  subtitle: 'Track investments',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MfTrackerScreen(),
                    ),
                  ),
                ),
                _GlassMenuCard(
                  icon: Icons.settings_suggest_outlined,
                  title: 'Configuration',
                  subtitle: 'Adjust calculation percentages',
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsScreen(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassMenuCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _GlassMenuCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const Color accentColor = Color(0xFF3A86FF);

    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            highlightColor: accentColor.withOpacity(0.1),
            splashColor: accentColor.withOpacity(0.2),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withOpacity(0.15),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(icon, color: accentColor, size: 36),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Text(
                          subtitle,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white54,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
