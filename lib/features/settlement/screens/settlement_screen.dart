import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../core/models/percentage_config_model.dart';
import '../../../core/models/settlement_model.dart';
import '../../../core/widgets/date_filter_row.dart';
import '../../../core/widgets/modern_loader.dart';
import '../../settings/services/settings_service.dart';
import '../services/settlement_service.dart';
import '../widgets/settlement_chart.dart';
import '../widgets/settlement_input_sheet.dart';
import '../widgets/settlement_table.dart';

// --- DESIGN SYSTEM IMPORTS ---
import '../../../core/design/budgetr_colors.dart';
import '../../../core/design/budgetr_styles.dart';
import '../../../core/design/budgetr_components.dart';

class SettlementScreen extends StatefulWidget {
  const SettlementScreen({super.key});

  @override
  State<SettlementScreen> createState() => _SettlementScreenState();
}

class _SettlementScreenState extends State<SettlementScreen> {
  final _settlementService = SettlementService();
  final _settingsService = SettingsService();
  final _currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

  List<Map<String, int>> _yearMonthData = [];
  List<int> _availableYears = [];
  List<int> _availableMonthsForYear = [];
  int? _selectedYear;
  int? _selectedMonth;

  bool _isLoading = false;
  Settlement? _settlementData;
  PercentageConfig? _percentageConfig;

  @override
  void initState() {
    super.initState();
    _loadDropdownData();
  }

  Future<void> _loadDropdownData() async {
    _yearMonthData = await _settlementService.getAvailableMonthsForSettlement();
    final years = _yearMonthData.map((e) => e['year']!).toSet().toList();
    years.sort((a, b) => b.compareTo(a));
    _availableYears = years;

    _percentageConfig = await _settingsService.getPercentageConfig();

    final now = DateTime.now();
    if (_availableYears.contains(now.year)) {
      _selectedYear = now.year;
      final months = _yearMonthData
          .where((data) => data['year'] == now.year)
          .map((data) => data['month']!)
          .toSet()
          .toList();
      months.sort((a, b) => b.compareTo(a));
      _availableMonthsForYear = months;
      if (_availableMonthsForYear.contains(now.month)) {
        _selectedMonth = now.month;
      }
    }
    setState(() {});
  }

  void _onYearSelected(int? year) {
    setState(() {
      _selectedYear = year;
      _selectedMonth = null;
      _settlementData = null;
      if (year != null) {
        final months = _yearMonthData
            .where((d) => d['year'] == year)
            .map((d) => d['month']!)
            .toSet()
            .toList();
        months.sort((a, b) => b.compareTo(a));
        _availableMonthsForYear = months;
      } else {
        _availableMonthsForYear = [];
      }
    });
  }

  Future<void> _fetchSettlementData() async {
    HapticFeedback.lightImpact();
    if (_selectedYear == null || _selectedMonth == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a year and month.'),
          backgroundColor: BudgetrColors.warning,
        ),
      );
      return;
    }
    setState(() {
      _isLoading = true;
      _settlementData = null;
    });
    final recordId =
        '$_selectedYear${_selectedMonth.toString().padLeft(2, '0')}';
    final settlement = await _settlementService.getSettlementById(recordId);
    setState(() {
      _settlementData = settlement;
      _isLoading = false;
    });
  }

  void _showSettlementInputSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const SettlementInputSheet(),
    ).then((_) {
      if (_selectedYear != null && _selectedMonth != null) {
        _fetchSettlementData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BudgetrScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Settlement Analysis', style: BudgetrStyles.h2),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      // We use a Stack in the body to manually position the FAB at the center bottom
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Date Filter wrapped in Design Token styling
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: BudgetrColors.cardSurface,
                    borderRadius: BudgetrStyles.radiusM,
                    border: BudgetrStyles.glassBorder,
                  ),
                  child: DateFilterRow(
                    selectedYear: _selectedYear,
                    selectedMonth: _selectedMonth,
                    availableYears: _availableYears,
                    availableMonths: _availableMonthsForYear,
                    onYearSelected: _onYearSelected,
                    onMonthSelected: (val) =>
                        setState(() => _selectedMonth = val),
                    showRefresh: false,
                  ),
                ),

                const SizedBox(height: 24),

                // Fetch Button (Explicitly styled to fix fading)
                Center(
                  child: GestureDetector(
                    onTap: _fetchSettlementData,
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.7,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        gradient: BudgetrColors.primaryGradient,
                        borderRadius: BudgetrStyles.radiusM,
                        boxShadow: BudgetrStyles.glowBoxShadow(
                          BudgetrColors.accent,
                        ),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.analytics_outlined,
                            color: Colors.white,
                            size: 20,
                          ),
                          SizedBox(width: 10),
                          Text(
                            'FETCH DATA',
                            style: TextStyle(
                              color: Colors.white, // Solid White
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Content Area
                Expanded(child: _buildContentArea()),
              ],
            ),
          ),

          // Custom "FAB" hidden safely as per new workflow requirement
          /*
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: _showSettlementInputSheet,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    gradient: BudgetrColors.primaryGradient,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: BudgetrStyles.glowBoxShadow(
                      BudgetrColors.accent,
                    ),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.edit_note_rounded, color: Colors.white),
                      SizedBox(width: 12),
                      Text(
                        "Update Settlement",
                        style: TextStyle(
                          color: Colors.white, // Solid White
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          */
        ],
      ),
    );
  }

  Widget _buildContentArea() {
    if (_isLoading) {
      return const Center(child: ModernLoader());
    }
    if (_settlementData == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.bar_chart_rounded,
              size: 60,
              color: Colors.white.withOpacity(0.1),
            ),
            const SizedBox(height: 16),
            Text(
              'Select a month & fetch data\nto view analysis',
              textAlign: TextAlign.center,
              style: BudgetrStyles.body.copyWith(
                color: Colors.white.withOpacity(0.4),
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 100.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Allocation vs. Expense',
            style: BudgetrStyles.h3.copyWith(
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 16),
          SettlementChart(
            settlement: _settlementData!,
            percentageConfig: _percentageConfig,
          ),

          const SizedBox(height: 32),

          Text(
            'Settlement Details',
            textAlign: TextAlign.center,
            style: BudgetrStyles.h3.copyWith(
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 16),
          SettlementTable(
            settlement: _settlementData!,
            percentageConfig: _percentageConfig,
            currencyFormat: _currencyFormat,
          ),
        ],
      ),
    );
  }
}
