// lib/features/dashboard/screens/custom_budgets_screen.dart
import 'package:budget/core/design/budgetr_colors.dart';
import 'package:budget/core/design/budgetr_styles.dart';
import 'package:budget/core/widgets/futuristic_loader.dart';
import 'package:budget/core/widgets/modern_app_bar.dart';
import 'package:budget/features/dashboard/models/category_budget_models.dart';
import 'package:budget/features/dashboard/services/category_budget_service.dart';
import 'package:budget/features/dashboard/widgets/add_category_budget_sheet.dart';
import 'package:budget/features/dashboard/widgets/category_allocation_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

class CustomBudgetsScreen extends StatefulWidget {
  const CustomBudgetsScreen({super.key});

  @override
  State<CustomBudgetsScreen> createState() => _CustomBudgetsScreenState();
}

class _CustomBudgetsScreenState extends State<CustomBudgetsScreen> {
  final CategoryBudgetService _service = GetIt.I<CategoryBudgetService>();
  final _currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

  bool _showActive = true;

  void _showAddSheet([CategoryBudgetSummaryModel? existingModel]) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (_) =>
          AddCategoryBudgetSheet(existingBudget: existingModel?.budget),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Column(
          children: [
            ModernAppBar(
              title: "Matrix Budgets",
              subtitle: "CUSTOM SPENDING LIMITS",
              trailingIcon: Icons.add_circle_outline_rounded,
              onTrailingPressed: () => _showAddSheet(),
            ),
            Expanded(
              child: StreamBuilder<List<CategoryBudgetSummaryModel>>(
                stream: _service.watchCategoryBudgets(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: FuturisticLoader(
                            size: 80, label: "SYNCING BUDGET BLUEPRINT..."));
                  }

                  final allBudgets = snapshot.data ?? [];

                  // Split Budgets
                  final activeBudgets =
                      allBudgets.where((b) => !b.budget.isClosed).toList();
                  final settledBudgets =
                      allBudgets.where((b) => b.budget.isClosed).toList();
                  final displayBudgets =
                      _showActive ? activeBudgets : settledBudgets;

                  return CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            // 1. iOS-Style Fluid Segmented Control
                            _buildPremiumTabToggle(),

                            const SizedBox(height: 24),

                            // 2. Section Header
                            if (displayBudgets.isNotEmpty)
                              Padding(
                                padding:
                                    const EdgeInsets.only(bottom: 16, left: 4),
                                child: Text(
                                  _showActive
                                      ? "ACTIVE ALLOCATIONS"
                                      : "SETTLED ARCHIVE",
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.4),
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                              ),
                          ]),
                        ),
                      ),

                      // 3. Dynamic List or Empty State
                      if (displayBudgets.isEmpty)
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: _buildPremiumEmptyState(),
                        )
                      else
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final item = displayBudgets[index];
                                return CategoryAllocationListItem(
                                  model: item,
                                  currencyFormat: _currencyFormat,
                                  onEdit: item.budget.isClosed
                                      ? null
                                      : () => _showAddSheet(item),
                                  onSettle: item.budget.isClosed
                                      ? null
                                      : () => _service
                                          .settleCategoryBudget(item.budget.id),
                                  onDelete: () => _service
                                      .deleteCategoryBudget(item.budget.id),
                                );
                              },
                              childCount: displayBudgets.length,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a high-end, fluid segmented control similar to native iOS/Premium Finance apps
  Widget _buildPremiumTabToggle() {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Stack(
        children: [
          // The sliding active pill background
          AnimatedAlign(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOutCubic,
            alignment:
                _showActive ? Alignment.centerLeft : Alignment.centerRight,
            child: FractionallySizedBox(
              widthFactor: 0.5,
              child: Container(
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B), // Elevated surface color
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                  border: Border.all(
                      color: Colors.white.withOpacity(0.1), width: 0.5),
                ),
              ),
            ),
          ),

          // The clickable text areas
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    if (!_showActive) {
                      HapticFeedback.selectionClick();
                      setState(() => _showActive = true);
                    }
                  },
                  child: Center(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: TextStyle(
                        color: _showActive ? Colors.white : Colors.white54,
                        fontWeight:
                            _showActive ? FontWeight.bold : FontWeight.w600,
                        fontSize: 14,
                      ),
                      child: const Text("Active"),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    if (_showActive) {
                      HapticFeedback.selectionClick();
                      setState(() => _showActive = false);
                    }
                  },
                  child: Center(
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: TextStyle(
                        color: !_showActive ? Colors.white : Colors.white54,
                        fontWeight:
                            !_showActive ? FontWeight.bold : FontWeight.w600,
                        fontSize: 14,
                      ),
                      child: const Text("Settled"),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// A much cleaner, more professional empty state
  Widget _buildPremiumEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.02),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Center(
            child: Icon(
              _showActive
                  ? Icons.dashboard_customize_rounded
                  : Icons.inventory_2_rounded,
              size: 40,
              color: BudgetrColors.accent.withOpacity(0.4),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          _showActive ? "No Active Budgets" : "Archive is Empty",
          style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.5),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text(
            _showActive
                ? "Tap the '+' icon to create a matrix budget using categories and buckets."
                : "Closed and settled matrix budgets will securely live here for reference.",
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 14,
                height: 1.5),
          ),
        ),
        const SizedBox(height: 60),
      ],
    );
  }
}
