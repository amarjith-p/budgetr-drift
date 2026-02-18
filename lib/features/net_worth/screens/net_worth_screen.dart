import 'package:flutter/material.dart';
import '../widgets/net_worth_dashboard_tab.dart';
import '../widgets/net_worth_splits_tab.dart';

// --- DESIGN SYSTEM IMPORTS ---
import '../../../core/design/budgetr_colors.dart';
import '../../../core/design/budgetr_styles.dart';
import '../../../core/design/budgetr_components.dart';
import '../../../core/widgets/glass_card.dart'; // [NEW IMPORT]

class NetWorthScreen extends StatefulWidget {
  const NetWorthScreen({super.key});

  @override
  State<NetWorthScreen> createState() => _NetWorthScreenState();
}

class _NetWorthScreenState extends State<NetWorthScreen> {
  // Removed local color constants in favor of BudgetrColors

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: BudgetrScaffold(
        // [FIX] Removed standard AppBar property
        // Switched to SafeArea > Column layout for Modern Header
        body: SafeArea(
          child: Column(
            children: [
              // 1. MODERN HEADER
              _buildModernHeader(),

              // 2. TAB BAR (Repositioned from AppBar bottom)
              Container(
                height: 56, // Standardized height
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                decoration: BoxDecoration(
                  color: BudgetrColors.cardSurface,
                  borderRadius: BudgetrStyles.radiusM, // Standard radius
                  border: BudgetrStyles.glassBorder, // Unified glass border
                ),
                child: TabBar(
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white54,
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    letterSpacing: 0.5,
                  ),
                  indicator: BoxDecoration(
                    color: BudgetrColors.accent, // Unified Accent Color
                    borderRadius: BudgetrStyles.radiusM,
                    boxShadow:
                        BudgetrStyles.glowBoxShadow(BudgetrColors.accent),
                  ),
                  padding: const EdgeInsets.all(6),
                  tabs: const [
                    Tab(text: "TOTAL NET WORTH"),
                    Tab(text: "SPLITS ANALYSIS"),
                  ],
                ),
              ),

              // 3. TAB VIEW CONTENT
              const Expanded(
                child: TabBarView(
                  children: [NetWorthDashboardTab(), NetWorthSplitsTab()],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- NEW: Modern Header Implementation ---
  Widget _buildModernHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          // Back Button
          GestureDetector(
            onTap: () => Navigator.maybePop(context),
            child: GlassCard(
              borderRadius: 12,
              padding: const EdgeInsets.all(10),
              margin: EdgeInsets.zero,
              color: Colors.white.withOpacity(0.05),
              child: const Icon(Icons.arrow_back_rounded,
                  color: Colors.white70, size: 20),
            ),
          ),

          const SizedBox(width: 16),

          // Title Section
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "OVERVIEW",
                  style: TextStyle(
                    color: Colors.white38,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2.0,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  "Net Worth Analysis",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),

          // Right side spacer to balance the layout (Back button width + spacing)
          const SizedBox(width: 40),
        ],
      ),
    );
  }
}
