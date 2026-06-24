import 'package:budget/features/backup_restore/screens/backup_screen.dart';
import 'package:budget/features/balance_sheet/screens/balance_sheet_screen.dart';
import 'package:budget/features/ghost_transactions/screens/ghost_transactions_screen.dart';
import 'package:budget/features/investments/screens/portfolio_dashboard.dart';
import 'package:budget/features/notifications/services/system_notification_service.dart';
import 'package:budget/features/recurring/screens/recurring_dashboard.dart';
import 'package:budget/features/reminders/screens/reminders_dashboard_screen.dart';
import 'package:budget/features/settings/screens/category_manager_screen.dart';
import '../../net_worth/services/net_worth_service.dart';
import 'package:budget/features/settings/screens/settings_screen.dart';
import 'package:budget/features/settlement/screens/settlement_screen.dart';
import 'package:budget/features/trip_mode/screens/trip_dashboard_screen.dart';
import 'package:budget/features/vault/screens/vault_auth_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'package:google_fonts/google_fonts.dart';
import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/design/budgetr_colors.dart';
import '../../../core/services/service_locator.dart';

// Services
import '../../daily_expense/services/expense_service.dart';
import '../../dashboard/services/dashboard_service.dart';
import '../../backup_restore/services/backup_service.dart';
import '../../credit_tracker/services/credit_service.dart';
import '../../settings/services/settings_service.dart';

// Models
import '../../dashboard/models/dashboard_transaction.dart';
import '../../../core/models/financial_record_model.dart';
import '../../credit_tracker/models/credit_models.dart';
import '../../daily_expense/models/expense_models.dart';

// Screens
import '../../dashboard/screens/dashboard_screen.dart';
import '../../daily_expense/screens/daily_expense_screen.dart';
import '../../credit_tracker/screens/credit_tracker_screen.dart';
import '../../custom_entry/screens/custom_entry_dashboard.dart';
import '../../goals_loans/screens/goals_loans_dashboard.dart';
import '../../investment/screens/investment_screen.dart';
import '../../net_worth/screens/net_worth_screen.dart';
import '../../settings/screens/configuration_menu_screen.dart';

import '../widgets/home_app_bar.dart';

// ============================================================================
// [NEW] Data Model for Grid Items
// ============================================================================
class HomeFeatureItem {
  final String id;
  final String title;
  final IconData icon;
  final Color color;
  final Widget Function() pageBuilder;
  final Stream<bool>? warningStream;

  HomeFeatureItem({
    required this.id,
    required this.title,
    required this.icon,
    required this.color,
    required this.pageBuilder,
    this.warningStream,
  });
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final expenseService = locator<ExpenseService>();
  final dashboardService = locator<DashboardService>();
  final creditService = locator<CreditService>();
  final settingsService = locator<SettingsService>();
  final netWorthService = locator<NetWorthService>();

  bool _isBalanceVisible = false;
  final BackupService _backupService = BackupService();
  bool _needsBackup = false;
  bool _isBudgetMode = false;
  DateTime? _lastBackPressTime;
  final PageController _toolsPageController = PageController();
  int _currentToolPage = 0;
  bool _showTopBanner = false;

  late Stream<bool> _creditShortfallStream;

  // ============================================================================
  // [NEW] Feature Registry & Drag-and-Drop State Arrays
  // ============================================================================
  late final Map<String, HomeFeatureItem> _featureRegistry;

  List<String> _topGridIds = [
    'dashboard', 'daily_expense', 'credit_tracker', 'custom_entry'
  ];
  List<String> _bottomGridIds = [
    'trip_mode', 'investments', 'goals_loans', 'net_worth', 'balance_sheet',
    'recurring_txns', 'pending_txns', 'settlements', 'secure_vault', 'budget_buckets',
    'reminders', 'settings'
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkBackupStatus();

    _creditShortfallStream = Rx.combineLatest2(
        creditService.getCreditCards(),
        settingsService.watchCreditPayableAccountIds().switchMap((ids) {
          return expenseService.watchAccountsByIds(ids);
        }), (List<CreditCardModel> cards,
            List<ExpenseAccountModel> linkedAccounts) {
      double totalDebt = cards
          .where((c) => c.currentBalance > 0)
          .fold(0.0, (sum, c) => sum + c.currentBalance);
      double allocatedFunds =
          linkedAccounts.fold(0.0, (sum, acc) => sum + acc.currentBalance);

      return (allocatedFunds - totalDebt <= -0.000001) && (totalDebt > 0.01);
    }).shareValue();

    // Initialize all features into the registry
    _featureRegistry = {
      'dashboard': HomeFeatureItem(id: 'dashboard', title: "Budget Dashboard", icon: Icons.donut_large_rounded, color: const Color(0xFF4361EE), pageBuilder: () => const DashboardScreen()),
      'daily_expense': HomeFeatureItem(id: 'daily_expense', title: "Daily Expense", icon: Icons.account_balance_wallet_rounded, color: const Color(0xFF06D6A0), pageBuilder: () => const DailyExpenseScreen()),
      'credit_tracker': HomeFeatureItem(id: 'credit_tracker', title: "Credit Tracker", icon: Icons.credit_card_rounded, color: const Color(0xFFEF476F), pageBuilder: () => const CreditTrackerScreen(), warningStream: _creditShortfallStream),
      'custom_entry': HomeFeatureItem(id: 'custom_entry', title: "Custom Entry", icon: Icons.post_add_rounded, color: const Color(0xFFFFD166), pageBuilder: () => const CustomEntryDashboard()),
      'trip_mode': HomeFeatureItem(id: 'trip_mode', title: "Trip Mode", icon: Icons.flight_takeoff_rounded, color: const Color(0xFF00B4D8), pageBuilder: () => const TripDashboardScreen()),
      'investments': HomeFeatureItem(id: 'investments', title: "Investments", icon: Icons.insights_rounded, color: const Color(0xFFFF7F11), pageBuilder: () => const PortfolioDashboard()),
      'goals_loans': HomeFeatureItem(id: 'goals_loans', title: "Goals & Loans", icon: Icons.rocket_launch_rounded, color: const Color(0xFFE63946), pageBuilder: () => const GoalsLoansDashboard()),
      'net_worth': HomeFeatureItem(id: 'net_worth', title: "Net Worth", icon: Icons.diamond_rounded, color: const Color(0xFFFFB703), pageBuilder: () => const NetWorthScreen()),
      'balance_sheet': HomeFeatureItem(id: 'balance_sheet', title: "Balance Sheet", icon: Icons.balance_sharp, color: const Color(0xFF9D4EDD), pageBuilder: () => const BalanceSheetScreen()),
      'recurring_txns': HomeFeatureItem(id: 'recurring_txns', title: "Recurring Txns", icon: Icons.autorenew_rounded, color: const Color(0xFF2EC4B6), pageBuilder: () => const RecurringDashboard()),
      'pending_txns': HomeFeatureItem(id: 'pending_txns', title: "Pending Txns", icon: Icons.pending_actions_rounded, color: const Color(0xFF2DC653), pageBuilder: () => const GhostTransactionsScreen()),
      'settlements': HomeFeatureItem(id: 'settlements', title: "Settlements", icon: Icons.fact_check_rounded, color: const Color(0xFF9C6644), pageBuilder: () => const SettlementScreen()),
      'secure_vault': HomeFeatureItem(id: 'secure_vault', title: "Secure Vault", icon: Icons.security_rounded, color: const Color(0xFFF72585), pageBuilder: () => const VaultAuthScreen()),
      'budget_buckets': HomeFeatureItem(id: 'budget_buckets', title: "Budget Buckets", icon: Icons.widgets_rounded, color: const Color(0xFFFFE066), pageBuilder: () => const SettingsScreen()),
      'reminders': HomeFeatureItem(id: 'reminders', title: "Reminders", icon: Icons.access_alarm, color: const Color(0xFF4361EE), pageBuilder: () => const RemindersDashboardScreen()),
      'settings': HomeFeatureItem(id: 'settings', title: "Settings", icon: Icons.tune_rounded, color: const Color.fromARGB(255, 252, 252, 252), pageBuilder: () => const ConfigurationMenuScreen()),
    };

    _loadGridOrder();
  }

  // ============================================================================
  // [NEW] Persist Reordering Configuration
  // ============================================================================
  Future<void> _loadGridOrder() async {
    final prefs = await SharedPreferences.getInstance();
    final top = prefs.getStringList('home_top_grid');
    final bottom = prefs.getStringList('home_bottom_grid');

    if (top != null && bottom != null && (top.length + bottom.length == _featureRegistry.length)) {
      // Validation to ensure app updates don't crash old lists
      bool valid = true;
      for (var id in [...top, ...bottom]) {
        if (!_featureRegistry.containsKey(id)) valid = false;
      }
      if (valid) {
        setState(() {
          _topGridIds = top;
          _bottomGridIds = bottom;
        });
      }
    }
  }

  Future<void> _saveGridOrder() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('home_top_grid', _topGridIds);
    await prefs.setStringList('home_bottom_grid', _bottomGridIds);
  }

  void _swapItems(String draggedId, String targetId) {
    if (draggedId == targetId) return;

    setState(() {
      int draggedIndexTop = _topGridIds.indexOf(draggedId);
      int draggedIndexBottom = _bottomGridIds.indexOf(draggedId);
      int targetIndexTop = _topGridIds.indexOf(targetId);
      int targetIndexBottom = _bottomGridIds.indexOf(targetId);

      if (draggedIndexTop != -1 && targetIndexTop != -1) {
        _topGridIds[draggedIndexTop] = targetId;
        _topGridIds[targetIndexTop] = draggedId;
      } else if (draggedIndexBottom != -1 && targetIndexBottom != -1) {
        _bottomGridIds[draggedIndexBottom] = targetId;
        _bottomGridIds[targetIndexBottom] = draggedId;
      } else if (draggedIndexTop != -1 && targetIndexBottom != -1) {
        _topGridIds[draggedIndexTop] = targetId;
        _bottomGridIds[targetIndexBottom] = draggedId;
      } else if (draggedIndexBottom != -1 && targetIndexTop != -1) {
        _bottomGridIds[draggedIndexBottom] = targetId;
        _topGridIds[targetIndexTop] = draggedId;
      }
      _saveGridOrder();
      HapticFeedback.lightImpact();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _toolsPageController.dispose();
    super.dispose();
  }

  Future<void> _checkBackupStatus() async {
    final overdue = await _backupService.isBackupOverdue();
    if (mounted && overdue != _needsBackup) {
      setState(() {
        _needsBackup = overdue;
        _showTopBanner = overdue;
      });

      if (_needsBackup) {
        Future.delayed(const Duration(seconds: 8), () {
          if (mounted) setState(() => _showTopBanner = false);
        });
      }
    }
  }

  void _handlePopInvoked(bool didPop) {
    if (didPop) return;

    final now = DateTime.now();
    final backButtonHasNotBeenPressedOrSnackBarHasClosed =
        _lastBackPressTime == null ||
            now.difference(_lastBackPressTime!) > const Duration(seconds: 2);

    if (backButtonHasNotBeenPressedOrSnackBarHasClosed) {
      _lastBackPressTime = now;
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.white,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          duration: const Duration(seconds: 2),
          content: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Color(0xFFFF9F1C), size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Press back again to exit",
                  style: GoogleFonts.robotoSlab(color: const Color(0xFF1B263B), fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      SystemNavigator.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: false,
        onPopInvoked: _handlePopInvoked,
        child: Scaffold(
          backgroundColor: const Color(0xFF0A0E12),
          extendBodyBehindAppBar: true,
          appBar: HomeAppBar(
            needsBackup: _needsBackup,
            onBackupTap: () async {
              setState(() => _showTopBanner = false);
              await _backupService.shareBackup();
              _checkBackupStatus();
            },
          ),
          body: Stack(
            children: [
              _buildAmbientGlow(Alignment.topRight, BudgetrColors.accent.withOpacity(0.15)),
              _buildAmbientGlow(Alignment.bottomLeft, const Color(0xFF4361EE).withOpacity(0.1)),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      _buildFinancialOverview(),
                      const SizedBox(height: 20),
                      _buildSectionHeader("Finance Today", showHint: true),
                      const SizedBox(height: 12),
                      Expanded(child: _buildFlexibleFeatureGrid(context)),
                      const SizedBox(height: 20),
                      _buildSectionHeader("More Tools"),
                      const SizedBox(height: 12),
                      _buildCompactQuickActionGrid(context),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 600),
                curve: Curves.elasticOut,
                top: _showTopBanner ? MediaQuery.of(context).padding.top + 55 : -120,
                left: 20,
                right: 20,
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.redAccent.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(color: Colors.redAccent.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))
                      ],
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "Data Backup Overdue! Click the ⚠️ icon above to backup now.",
                            style: GoogleFonts.robotoSlab(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => setState(() => _showTopBanner = false),
                          child: const Icon(Icons.close_rounded, color: Colors.white70, size: 24),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  // ============================================================================
  // [NEW] Dynamic Draggable Wrapper Component
  // ============================================================================
  Widget _buildDraggableSlot(String id, {required bool isTop}) {
    final feature = _featureRegistry[id]!;

    return DragTarget<String>(
      onWillAcceptWithDetails: (data) => data.data != id,
      onAcceptWithDetails: (data) => _swapItems(data.data, id),
      builder: (context, candidateData, rejectedData) {
        final isHovered = candidateData.isNotEmpty;

        // Render based on location
        // Render based on location
        Widget card = isTop
            ? _buildCompactCard(context, feature.title, feature.icon, feature.color, feature.pageBuilder(), warningStream: feature.warningStream)
            : _buildVerticalActionChip(context, feature.title, feature.icon, feature.color, feature.pageBuilder(), warningStream: feature.warningStream);

        // Add a subtle border when hovering to drop
        if (isHovered) {
          card = Container(
            foregroundDecoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withOpacity(0.8), width: 2),
            ),
            child: card,
          );
        }

        return LongPressDraggable<String>(
          key: ValueKey(id), // <--- ADDED KEY TO PREVENT WIDGET STATE GLITCHES
          data: id,
          delay: const Duration(milliseconds: 250),
          onDragStarted: () => HapticFeedback.mediumImpact(),
          feedback: Material(
            color: Colors.transparent,
            child: Opacity(
              opacity: 0.85,
              child: Transform.scale(
                scale: 1.05,
                child: SizedBox(
                  width: isTop ? (MediaQuery.of(context).size.width - 56) / 2 : (MediaQuery.of(context).size.width - 64) / 3,
                  height: isTop ? 140 : 90,
                  child: isTop
                      ? _buildCompactCard(context, feature.title, feature.icon, feature.color, const SizedBox(), warningStream: feature.warningStream)
                      : _buildVerticalActionChip(context, feature.title, feature.icon, feature.color, const SizedBox()),
                ),
              ),
            ),
          ),
          childWhenDragging: Opacity(opacity: 0.3, child: card),
          child: card,
        );
      },
    );
  }

  Widget _buildFlexibleFeatureGrid(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(child: _buildDraggableSlot(_topGridIds[0], isTop: true)),
              const SizedBox(width: 16),
              Expanded(child: _buildDraggableSlot(_topGridIds[1], isTop: true)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: Row(
            children: [
              Expanded(child: _buildDraggableSlot(_topGridIds[2], isTop: true)),
              const SizedBox(width: 16),
              Expanded(child: _buildDraggableSlot(_topGridIds[3], isTop: true)),
            ],
          ),
        ),
      ],
    );
  }

// ============================================================================
  // [UPGRADED] Compact Grid with Cross-Page Drag & Drop Auto-Scroll
  // ============================================================================
  Widget _buildCompactQuickActionGrid(BuildContext context) {
    // Break _bottomGridIds into chunks of 6 per page
    List<List<String>> pages = [];
    for (var i = 0; i < _bottomGridIds.length; i += 6) {
      pages.add(_bottomGridIds.sublist(
          i, i + 6 > _bottomGridIds.length ? _bottomGridIds.length : i + 6));
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 160,
          child: Stack(
            children: [
              // 1. The Slidable Pages
              PageView.builder(
                controller: _toolsPageController,
                onPageChanged: (index) =>
                    setState(() => _currentToolPage = index),
                itemCount: pages.length,
                itemBuilder: (context, pageIndex) {
                  final items = pages[pageIndex];
                  return Column(
                    children: [
                      Row(
                        children: [
                          if (items.isNotEmpty) Expanded(child: _buildDraggableSlot(items[0], isTop: false)) else const Expanded(child: SizedBox.shrink()),
                          const SizedBox(width: 12),
                          if (items.length > 1) Expanded(child: _buildDraggableSlot(items[1], isTop: false)) else const Expanded(child: SizedBox.shrink()),
                          const SizedBox(width: 12),
                          if (items.length > 2) Expanded(child: _buildDraggableSlot(items[2], isTop: false)) else const Expanded(child: SizedBox.shrink()),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          if (items.length > 3) Expanded(child: _buildDraggableSlot(items[3], isTop: false)) else const Expanded(child: SizedBox.shrink()),
                          const SizedBox(width: 12),
                          if (items.length > 4) Expanded(child: _buildDraggableSlot(items[4], isTop: false)) else const Expanded(child: SizedBox.shrink()),
                          const SizedBox(width: 12),
                          if (items.length > 5) Expanded(child: _buildDraggableSlot(items[5], isTop: false)) else const Expanded(child: SizedBox.shrink()),
                        ],
                      ),
                    ],
                  );
                },
              ),

              // 2. Left Hover-to-Scroll Sensor Pad
              if (_currentToolPage > 0)
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: 40,
                  child: DragTarget<String>(
                    onWillAcceptWithDetails: (_) {
                      // Trigger page slide when hovered
                      _toolsPageController.previousPage(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut);
                      return false; // Return false so it doesn't consume the drop!
                    },
                    builder: (context, candidateData, _) {
                      // Subtle visual cue ONLY when hovering with a dragged item
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          gradient: candidateData.isNotEmpty
                              ? LinearGradient(colors: [
                                  Colors.white.withOpacity(0.15),
                                  Colors.transparent
                                ])
                              : null,
                        ),
                        child: candidateData.isNotEmpty
                            ? const Icon(Icons.arrow_back_ios_rounded,
                                color: Colors.white54)
                            : null,
                      );
                    },
                  ),
                ),

              // 3. Right Hover-to-Scroll Sensor Pad
              if (_currentToolPage < pages.length - 1)
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  width: 40,
                  child: DragTarget<String>(
                    onWillAcceptWithDetails: (_) {
                      // Trigger page slide when hovered
                      _toolsPageController.nextPage(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut);
                      return false; // Return false so it doesn't consume the drop!
                    },
                    builder: (context, candidateData, _) {
                      // Subtle visual cue ONLY when hovering with a dragged item
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          gradient: candidateData.isNotEmpty
                              ? LinearGradient(colors: [
                                  Colors.transparent,
                                  Colors.white.withOpacity(0.15)
                                ])
                              : null,
                        ),
                        child: candidateData.isNotEmpty
                            ? const Icon(Icons.arrow_forward_ios_rounded,
                                color: Colors.white54)
                            : null,
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            pages.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 6,
              width: _currentToolPage == index ? 16 : 6,
              decoration: BoxDecoration(
                color: _currentToolPage == index
                    ? const Color(0xFF4361EE)
                    : Colors.white24,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalActionChip(BuildContext context, String label, IconData icon, Color iconColor, Widget page, {Stream<bool>? warningStream}) {
    return _BouncyButton(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => page)),
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white10),
              color: Colors.white.withOpacity(0.03),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: iconColor, size: 22),
                const SizedBox(height: 6),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.robotoSlab(color: Colors.white70, fontSize: 11, height: 1.1),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          
          // --- Mini Warning Badge for Bottom Grid ---
          if (warningStream != null)
            Positioned(
              top: 4,
              right: 4,
              child: StreamBuilder<bool>(
                stream: warningStream,
                builder: (context, snapshot) {
                  if (snapshot.hasData && snapshot.data == true) {
                    return const Icon(Icons.warning_rounded, color: Color(0xFFE71D36), size: 14);
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCompactCard(BuildContext context, String title, IconData icon, Color color, Widget page, {Stream<bool>? warningStream}) {
    return _BouncyButton(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => page)),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: color, size: 36),
                  const SizedBox(height: 10),
                  Text(title, textAlign: TextAlign.center, style: GoogleFonts.robotoSlab(color: Colors.white, fontWeight: FontWeight.w500)),
                ],
              ),
            ),
            if (warningStream != null)
              Positioned(
                top: 8,
                right: 8,
                child: StreamBuilder<bool>(
                  stream: warningStream,
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data == true) {
                      return Container(
                        padding: const EdgeInsets.all(6),
                        child: const Icon(Icons.warning_rounded, color: Color(0xFFE71D36), size: 14),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {bool showHint = false}) {
    return Row(
      children: [
        Text(title, style: GoogleFonts.robotoSlab(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        if (showHint) ...[
          const SizedBox(width: 8),
          Text("(Hold & Drag to Reorder)", style: GoogleFonts.robotoSlab(color: Colors.white38, fontSize: 10)),
        ]
      ],
    );
  }

  Widget _buildAmbientGlow(Alignment alignment, Color color) {
    return Positioned.fill(
      child: Align(
        alignment: alignment,
        child: Container(
          width: 300,
          height: 300,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: color, blurRadius: 100, spreadRadius: 50)],
          ),
        ),
      ),
    );
  }

  Widget _buildFinancialOverview() {
    final now = DateTime.now();

    return StreamBuilder(
      stream: Rx.combineLatest3(
        netWorthService.getAutoCalculatedNetWorth(),
        dashboardService.getMonthlyTransactions(now.year, now.month),
        dashboardService.getFinancialRecords(),
        (double netWorth, List<DashboardTransaction> txns, List<FinancialRecord> records) => [netWorth, txns, records],
      ),
      builder: (context, snapshot) {
        double currentNetWorth = 0.0;
        double monthlyBudget = 0.0;
        double totalSpent = 0.0;

        if (snapshot.hasData) {
          currentNetWorth = snapshot.data![0] as double;
          final txns = snapshot.data![1] as List<DashboardTransaction>;
          final records = snapshot.data![2] as List<FinancialRecord>;

          final recordId = "${now.year}${now.month.toString().padLeft(2, '0')}";
          final currentRecord = records.firstWhere(
            (r) => r.id == recordId,
            orElse: () => FinancialRecord(id: '', year: now.year, month: now.month, salary: 0, extraIncome: 0, emi: 0, effectiveIncome: 0, allocations: {}, allocationPercentages: {}, bucketOrder: [], createdAt: DateTime.now(), updatedAt: DateTime.now()),
          );

          currentRecord.allocations.forEach((key, value) {
            if (key != 'Income') monthlyBudget += value;
          });

          for (var txn in txns) {
            bool exclude = false;
            if (_isBudgetMode) {
              if (txn.bucket == 'Out of Bucket') exclude = true;
              if (txn.category == 'Non-Calculated Expense') exclude = true;
            }
            if (!exclude) {
              if (txn.type == 'Expense' || (txn.type == 'Transfer Out' && txn.sourceType == TransactionSourceType.creditCard)) {
                totalSpent += txn.amount;
              }
            }
          }
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white.withOpacity(0.08), Colors.white.withOpacity(0.03)],
            ),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        Text("Total Net Worth", style: GoogleFonts.robotoSlab(color: Colors.white70, fontSize: 13)),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => setState(() => _isBalanceVisible = !_isBalanceVisible),
                          child: Icon(_isBalanceVisible ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: Colors.white54, size: 18),
                        ),
                      ],
                    ),
                  ),
                  StreamBuilder(
                    stream: Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now()),
                    builder: (context, snapshot) {
                      final now = DateTime.now();
                      final months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
                      final weekdays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
                      final dayName = weekdays[now.weekday - 1];
                      final monthName = months[now.month - 1];
                      final dayNum = now.day.toString().padLeft(2, '0');
                      final dateStr = "$dayName, $dayNum $monthName ${now.year}";

                      int hour = now.hour;
                      final String period = hour >= 12 ? 'PM' : 'AM';
                      hour = hour % 12;
                      if (hour == 0) hour = 12;
                      final timeStr = "${hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')} $period";

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(dateStr, style: GoogleFonts.robotoSlab(color: Colors.white.withOpacity(0.6), fontSize: 11, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 2),
                          Text(timeStr, style: GoogleFonts.robotoSlab(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold, fontFeatures: [const FontFeature.tabularFigures()])),
                        ],
                      );
                    },
                  ),
                ],
              ),
              Text(
                  _isBalanceVisible ? "₹ ${currentNetWorth.toStringAsFixed(2)}" : "₹ ${"*" * currentNetWorth.toStringAsFixed(2).length}",
                  style: GoogleFonts.openSans(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1)),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildMiniStat("Monthly Budget", "    ₹ ${monthlyBudget.toStringAsFixed(2)}", Colors.blueAccent),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(radius: 4, backgroundColor: _isBudgetMode ? Colors.greenAccent : Colors.orangeAccent),
                          const SizedBox(width: 8),
                          Text(_isBudgetMode ? "Budget Spent" : "Spent so far", style: GoogleFonts.robotoSlab(color: Colors.white54, fontSize: 11)),
                          const SizedBox(width: 6),
                          SizedBox(
                            height: 20,
                            width: 20,
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              iconSize: 16,
                              tooltip: "Budget Mode",
                              onPressed: () => setState(() => _isBudgetMode = !_isBudgetMode),
                              icon: Icon(_isBudgetMode ? Icons.savings_rounded : Icons.savings_outlined, color: _isBudgetMode ? const Color(0xFF00B4D8) : Colors.white24),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text("    ₹ ${totalSpent.toStringAsFixed(2)}", style: GoogleFonts.openSans(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }

  Widget _buildMiniStat(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(radius: 4, backgroundColor: color),
            const SizedBox(width: 8),
            Text(label, style: GoogleFonts.robotoSlab(color: Colors.white54, fontSize: 11)),
          ],
        ),
        const SizedBox(height: 4),
        Text(value, style: GoogleFonts.openSans(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
      ],
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkBackupStatus();
    }
  }
}

class _BouncyButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _BouncyButton({required this.child, required this.onTap});

  @override
  State<_BouncyButton> createState() => _BouncyButtonState();
}

class _BouncyButtonState extends State<_BouncyButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}