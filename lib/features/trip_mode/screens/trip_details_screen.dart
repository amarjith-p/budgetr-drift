import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:open_file/open_file.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/design/budgetr_colors.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/status_bottom_sheet.dart';
import '../../../core/widgets/futuristic_loader.dart';
import '../../../core/database/app_database.dart';
import '../../../core/constants/icon_constants.dart';
import '../../../core/services/category_service.dart';
import '../../../core/models/transaction_category_model.dart';
import '../../credit_tracker/models/credit_models.dart';
import '../../credit_tracker/services/credit_service.dart';
import '../../daily_expense/models/expense_models.dart';
import '../../daily_expense/services/expense_service.dart';

import '../services/trip_service.dart';
import '../services/trip_report_service.dart';

class TripDetailsScreen extends StatefulWidget {
  final TripRecord trip;

  const TripDetailsScreen({super.key, required this.trip});

  @override
  State<TripDetailsScreen> createState() => _TripDetailsScreenState();
}

class _TripDetailsScreenState extends State<TripDetailsScreen> {
  final TripService _tripService = GetIt.I<TripService>();
  final CreditService _creditService = GetIt.I<CreditService>();
  final ExpenseService _expenseService = GetIt.I<ExpenseService>();
  final CategoryService _categoryService = GetIt.I<CategoryService>();

  List<TripTransactionDto> _currentTransactions = [];
  bool _isGeneratingPdf = false;

  // [NEW] Local state variable for instant UI updates
  late bool _isPaused;

  // MULTI-SELECTION STATE
  final Set<String> _selectedCategories = {};

  Map<String, String> _accountNames = {};
  Map<String, String> _bankNames = {};
  Map<String, IconData> _categoryIcons = {};
  bool _isLoadingMetaData = true;

  @override
  void initState() {
    super.initState();
    // [NEW] Initialize local state with the passed trip data
    _isPaused = widget.trip.isPaused;
    _loadMetaData();
  }

  Future<void> _loadMetaData() async {
    try {
      final results = await Future.wait([
        _creditService.getCreditCards().first,
        _expenseService.getAccounts().first,
        _categoryService.getCategories().first,
      ]);

      if (!mounted) return;

      final cards = results[0] as List<CreditCardModel>;
      final accounts = results[1] as List<ExpenseAccountModel>;
      final categories = results[2] as List<TransactionCategoryModel>;

      final Map<String, String> accNames = {};
      final Map<String, String> bankNames = {};

      for (var c in cards) {
        accNames[c.id] = c.name;
        bankNames[c.id] = c.bankName;
      }
      for (var a in accounts) {
        accNames[a.id] = a.name;
        bankNames[a.id] = a.bankName;
      }

      setState(() {
        _accountNames = accNames;
        _bankNames = bankNames;
        _categoryIcons = {
          for (var c in categories)
            if (c.iconCode != null)
              c.name: IconConstants.getIconByCode(c.iconCode!),
        };
        _isLoadingMetaData = false;
      });
    } catch (e) {
      if (mounted) setState(() => _isLoadingMetaData = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTripActive = widget.trip.isActive;
    final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

    return Scaffold(
      backgroundColor: BudgetrColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildCustomAppBar(isTripActive),
            Expanded(
              child: _isLoadingMetaData
                  ? const Center(
                      child: FuturisticLoader(
                          label: "LOADING METADATA...", size: 80))
                  : StreamBuilder<List<TripTransactionDto>>(
                      stream: _tripService.getTripTransactions(widget.trip),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                              child: FuturisticLoader(
                                  label: "ANALYZING TRIP TELEMETRY...",
                                  size: 80));
                        }

                        final rawTxns = snapshot.data!;
                        final txns = rawTxns
                            .where((t) =>
                                t.type == 'Income' || t.type == 'Expense')
                            .toList();

                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (mounted &&
                              _currentTransactions.length != txns.length) {
                            setState(() => _currentTransactions = txns);
                          }
                        });

                        final expenseTxns =
                            txns.where((t) => t.type == 'Expense').toList();
                        final incomeTxns = txns
                            .where(
                                (t) => t.type == 'Income' || t.type == 'Refund')
                            .toList();

                        final totalExpense = expenseTxns.fold(
                            0.0, (sum, item) => sum + item.amount);
                        final totalIncome = incomeTxns.fold(
                            0.0, (sum, item) => sum + item.amount);

                        int daysActive = (widget.trip.endDate ?? DateTime.now())
                            .difference(widget.trip.startDate)
                            .inDays;
                        daysActive = daysActive < 1 ? 1 : daysActive;
                        final dailyAvg = totalExpense / daysActive;

                        // Category Breakdown Calculation
                        Map<String, double> categoryTotals = {};
                        for (var t in expenseTxns) {
                          categoryTotals[t.category] =
                              (categoryTotals[t.category] ?? 0) + t.amount;
                        }
                        final sortedCategories = categoryTotals.entries.toList()
                          ..sort((a, b) => b.value.compareTo(a.value));

                        // MULTI-SELECTION FILTER
                        final displayedTxns = _selectedCategories.isEmpty
                            ? txns
                            : txns
                                .where((t) =>
                                    _selectedCategories.contains(t.category))
                                .toList();

                        final Map<String, List<TripTransactionDto>>
                            groupedTxns = {};
                        for (var t in displayedTxns) {
                          final dateKey =
                              DateFormat('dd MMM yyyy').format(t.date);
                          groupedTxns.putIfAbsent(dateKey, () => []).add(t);
                        }

                        return ListView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          children: [
                            _buildRichSummaryCard(totalExpense, totalIncome,
                                dailyAvg, currencyFormat),
                            const SizedBox(height: 32),

                            if (sortedCategories.isNotEmpty) ...[
                              const Text(
                                "TOP EXPENSE CATEGORIES",
                                style: TextStyle(
                                    color: Colors.white38,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.5),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                height: 130,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  physics: const BouncingScrollPhysics(),
                                  itemCount: sortedCategories.length,
                                  itemBuilder: (context, index) {
                                    final cat = sortedCategories[index];
                                    final isSelected =
                                        _selectedCategories.contains(cat.key);
                                    return _buildCategoryCard(
                                        cat.key,
                                        cat.value,
                                        totalExpense,
                                        currencyFormat,
                                        isSelected);
                                  },
                                ),
                              ),
                              const SizedBox(height: 32),
                            ],

                            // FILTER CLEAR INDICATOR
                            if (_selectedCategories.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        "Showing: ${_selectedCategories.join(', ')}",
                                        style: const TextStyle(
                                            color: Color(0xFFF72585),
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1.0),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    GestureDetector(
                                      onTap: () => setState(
                                          () => _selectedCategories.clear()),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                            color:
                                                Colors.white.withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(20)),
                                        child: const Text("Clear Filters",
                                            style: TextStyle(
                                                color: Colors.white70,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            if (displayedTxns.isEmpty)
                              Center(
                                child: Column(
                                  children: [
                                    const SizedBox(height: 32),
                                    Icon(Icons.receipt_long_outlined,
                                        size: 64,
                                        color: Colors.white.withOpacity(0.1)),
                                    const SizedBox(height: 16),
                                    Text(
                                        _selectedCategories.isNotEmpty
                                            ? "No transactions match your filters"
                                            : "No transactions found",
                                        style: TextStyle(
                                            color:
                                                Colors.white.withOpacity(0.5))),
                                  ],
                                ),
                              ),

                            ...groupedTxns.entries.map((entry) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 16, bottom: 12, left: 4),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 6,
                                          height: 6,
                                          decoration: const BoxDecoration(
                                              color: BudgetrColors.accent,
                                              shape: BoxShape.circle),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          entry.key.toUpperCase(),
                                          style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 1.0),
                                        ),
                                      ],
                                    ),
                                  ),
                                  ...entry.value.map((t) => Slidable(
                                        key: ValueKey(t.id),
                                        endActionPane: ActionPane(
                                          motion: const ScrollMotion(),
                                          children: [
                                            SlidableAction(
                                              onPressed: (_) => _tripService
                                                  .excludeTransaction(
                                                      widget.trip.id, t.id),
                                              backgroundColor:
                                                  BudgetrColors.warning,
                                              foregroundColor: Colors.white,
                                              icon: Icons.hide_source_rounded,
                                              label: 'Exclude',
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                          ],
                                        ),
                                        child: TripTransactionCard(
                                          txn: t,
                                          currencyFormat: currencyFormat,
                                          accountName:
                                              _accountNames[t.sourceId] ??
                                                  "Unknown",
                                          bankName:
                                              _bankNames[t.sourceId] ?? "",
                                          iconData:
                                              _categoryIcons[t.category] ??
                                                  Icons.category_outlined,
                                        ),
                                      )),
                                ],
                              );
                            }),
                            const SizedBox(height: 60),
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

  Widget _buildCustomAppBar(bool isTripActive) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  // [UPDATED] Uses local _isPaused state
                  (isTripActive
                          ? (_isPaused ? "PAUSED TRIP" : "ACTIVE TRIP")
                          : "COMPLETED TRIP")
                      .toUpperCase(),
                  style: TextStyle(
                    color: _isPaused ? Colors.orangeAccent : Colors.white38,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.trip.tripName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
          if (_currentTransactions.isNotEmpty)
            GestureDetector(
              onTap: _isGeneratingPdf ? null : _exportPdf,
              child: GlassCard(
                borderRadius: 12,
                padding: const EdgeInsets.all(10),
                margin: EdgeInsets.zero,
                color: Colors.white.withOpacity(0.05),
                child: _isGeneratingPdf
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: BudgetrColors.accent))
                    : const Icon(Icons.picture_as_pdf_rounded,
                        color: Colors.white70, size: 20),
              ),
            ),
          if (isTripActive) ...[
            const SizedBox(width: 8),
            // [UPDATED] Pause / Resume Toggle uses local state and bottom sheets
            GestureDetector(
              onTap: () {
                if (_isPaused) {
                  _confirmResumeTrip();
                } else {
                  _confirmPauseTrip();
                }
              },
              child: GlassCard(
                borderRadius: 12,
                padding: const EdgeInsets.all(10),
                margin: EdgeInsets.zero,
                color: _isPaused
                    ? Colors.orangeAccent.withOpacity(0.15)
                    : BudgetrColors.accent.withOpacity(0.15),
                border: Border.all(
                    color: _isPaused
                        ? Colors.orangeAccent.withOpacity(0.5)
                        : BudgetrColors.accent.withOpacity(0.5)),
                child: Icon(
                    _isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                    color:
                        _isPaused ? Colors.orangeAccent : BudgetrColors.accent,
                    size: 20),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => _confirmEndTrip(),
              child: GlassCard(
                borderRadius: 12,
                padding: const EdgeInsets.all(10),
                margin: EdgeInsets.zero,
                color: BudgetrColors.error.withOpacity(0.15),
                border: Border.all(color: BudgetrColors.error.withOpacity(0.5)),
                child: const Icon(Icons.stop_circle_rounded,
                    color: BudgetrColors.error, size: 20),
              ),
            ),
          ] else if (_currentTransactions.isEmpty) ...[
            const SizedBox(width: 40),
          ]
        ],
      ),
    );
  }

  // [NEW] Pause Confirmation Sheet
  void _confirmPauseTrip() {
    showStatusSheet(
      context: context,
      title: "Pause Trip?",
      message:
          "Are you sure you want to pause '${widget.trip.tripName}'? Your expenses will not be tracked under this trip until you resume.",
      icon: Icons.pause_circle_filled_rounded,
      color: Colors.orangeAccent,
      buttonText: "Pause Trip",
      onDismiss: () async {
        await _tripService.pauseTrip(widget.trip.id);
        if (mounted) {
          setState(() => _isPaused = true); // Instantly update UI
        }
      },
      cancelButtonText: "Cancel",
      onCancel: () {},
    );
  }

  // [NEW] Resume Confirmation Sheet
  void _confirmResumeTrip() {
    showStatusSheet(
      context: context,
      title: "Resume Trip?",
      message:
          "Are you sure you want to resume '${widget.trip.tripName}'? New expenses will now automatically be tracked under this trip.",
      icon: Icons.play_circle_fill_rounded,
      color: BudgetrColors.accent,
      buttonText: "Resume Trip",
      onDismiss: () async {
        await _tripService.resumeTrip(widget.trip.id);
        if (mounted) {
          setState(() => _isPaused = false); // Instantly update UI
        }
      },
      cancelButtonText: "Cancel",
      onCancel: () {},
    );
  }

  void _confirmEndTrip() {
    showStatusSheet(
      context: context,
      title: "End Trip?",
      message:
          "Are you sure you want to end '${widget.trip.tripName}'? It will be moved to your past adventures history.",
      icon: Icons.flight_land_rounded,
      color: BudgetrColors.error,
      buttonText: "End Trip",
      onDismiss: () async {
        await _tripService.endTrip(widget.trip.id);
        if (context.mounted) Navigator.pop(context);
      },
      cancelButtonText: "Cancel",
      onCancel: () {},
    );
  }

  Widget _buildRichSummaryCard(double totalExpense, double totalIncome,
      double dailyAvg, NumberFormat currencyFormat) {
    final Color cardColor = const Color(0xFF1B263B);
    final Color greenColor = const Color(0xFF00E676);
    final Color redColor = const Color(0xFFFF5252);
    final netSpend = totalExpense - totalIncome;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [cardColor.withOpacity(0.8), cardColor.withOpacity(0.5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("NET TRIP SPEND",
                  style: TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5)),
              const SizedBox(width: 6),
              Icon(Icons.flight_takeoff_rounded,
                  color: Colors.white.withOpacity(0.2), size: 14),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            "${DateFormat('dd MMM yyyy').format(widget.trip.startDate)} - ${widget.trip.endDate != null ? DateFormat('dd MMM yyyy').format(widget.trip.endDate!) : 'Ongoing'}",
            style: TextStyle(
                color: Colors.white.withOpacity(0.3),
                fontSize: 10,
                fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(currencyFormat.format(netSpend),
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                  child: _summaryItem("Total Expense", totalExpense, redColor,
                      Icons.arrow_upward, currencyFormat)),
              Container(width: 1, height: 40, color: Colors.white10),
              Expanded(
                  child: _summaryItem(
                      "Daily Avg",
                      dailyAvg,
                      Colors.orangeAccent,
                      Icons.assessment_outlined,
                      currencyFormat)),
              Container(width: 1, height: 40, color: Colors.white10),
              Expanded(
                  child: _summaryItem("Income/Refund", totalIncome, greenColor,
                      Icons.arrow_downward, currencyFormat)),
            ],
          ),
          if (widget.trip.budget != null && widget.trip.budget! > 0) ...[
            const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Divider(color: Colors.white10, height: 1)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("BUDGET USAGE",
                        style: TextStyle(
                            color: Colors.white54,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0)),
                    const SizedBox(height: 4),
                    Text(
                        "${((totalExpense / widget.trip.budget!) * 100).toStringAsFixed(2)}%",
                        style: TextStyle(
                            color: totalExpense > widget.trip.budget!
                                ? redColor
                                : BudgetrColors.accent,
                            fontSize: 14,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                        totalExpense > widget.trip.budget!
                            ? "OVER BUDGET"
                            : "LEFT TO SPEND",
                        style: TextStyle(
                            color: totalExpense > widget.trip.budget!
                                ? redColor.withOpacity(0.8)
                                : Colors.white54,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0)),
                    const SizedBox(height: 4),
                    Text(
                        currencyFormat
                            .format((widget.trip.budget! - totalExpense).abs()),
                        style: TextStyle(
                            color: totalExpense > widget.trip.budget!
                                ? redColor
                                : greenColor,
                            fontSize: 14,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (totalExpense / widget.trip.budget!).clamp(0.0, 1.0),
                minHeight: 6,
                backgroundColor: Colors.white.withOpacity(0.05),
                color: totalExpense > widget.trip.budget!
                    ? redColor
                    : BudgetrColors.accent,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("₹0",
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.3), fontSize: 10)),
                Text(currencyFormat.format(widget.trip.budget),
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 10,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ]
        ],
      ),
    );
  }

  Widget _summaryItem(String label, double amount, Color color, IconData icon,
      NumberFormat format) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 12),
            const SizedBox(width: 4),
            Text(label,
                style: TextStyle(
                    color: color.withOpacity(0.8),
                    fontSize: 10,
                    fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 4),
        Text(format.format(amount),
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14)),
      ],
    );
  }

  Widget _buildCategoryCard(String category, double amount, double totalExpense,
      NumberFormat currencyFormat, bool isSelected) {
    final double percentage = totalExpense > 0 ? (amount / totalExpense) : 0;

    final borderColor =
        isSelected ? const Color(0xFFF72585) : Colors.white.withOpacity(0.05);
    final bgColor = isSelected
        ? const Color(0xFFF72585).withOpacity(0.1)
        : Colors.white.withOpacity(0.03);

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedCategories.remove(category);
          } else {
            _selectedCategories.add(category);
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 150,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: isSelected ? 1.5 : 1.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8)),
                  child: Icon(
                      _categoryIcons[category] ?? Icons.category_rounded,
                      color:
                          isSelected ? const Color(0xFFF72585) : Colors.white70,
                      size: 16),
                ),
                Text("${(percentage * 100).toStringAsFixed(2)}%",
                    style: TextStyle(
                        color: isSelected
                            ? Colors.white70
                            : Colors.white.withOpacity(0.3),
                        fontSize: 10,
                        fontWeight: FontWeight.bold)),
              ],
            ),
            const Spacer(),
            Text(category,
                style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 4),
            Text(currencyFormat.format(amount),
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: percentage,
              backgroundColor: Colors.white10,
              color: const Color(0xFFF72585),
              minHeight: 4,
              borderRadius: BorderRadius.circular(2),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _exportPdf() async {
    setState(() => _isGeneratingPdf = true);
    try {
      final path = await GetIt.I<TripReportService>()
          .generatePdf(widget.trip, _currentTransactions);
      if (mounted) {
        showStatusSheet(
          context: context,
          title: "Export Successful",
          message: "Report saved successfully to:\n\n$path",
          icon: Icons.check_circle_rounded,
          color: BudgetrColors.success,
          buttonText: "Open File",
          onDismiss: () => OpenFile.open(path),
          cancelButtonText: "Share File",
          onCancel: () => Share.shareXFiles([XFile(path)],
              text: 'Trip Report: ${widget.trip.tripName}'),
        );
      }
    } catch (e) {
      if (mounted) {
        showStatusSheet(
            context: context,
            title: "Export Failed",
            message: e.toString(),
            icon: Icons.error_rounded,
            color: BudgetrColors.error);
      }
    } finally {
      if (mounted) setState(() => _isGeneratingPdf = false);
    }
  }
}

class TripTransactionCard extends StatefulWidget {
  final TripTransactionDto txn;
  final NumberFormat currencyFormat;
  final String accountName;
  final String bankName;
  final IconData iconData;

  const TripTransactionCard({
    super.key,
    required this.txn,
    required this.currencyFormat,
    required this.accountName,
    required this.bankName,
    required this.iconData,
  });

  @override
  State<TripTransactionCard> createState() => _TripTransactionCardState();
}

class _TripTransactionCardState extends State<TripTransactionCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final isCredit = widget.txn.source == 'Credit';
    final primaryColor =
        isCredit ? const Color(0xFFE63946) : const Color(0xFF00B4D8);
    final isExpense = widget.txn.type == 'Expense';
    final amountColor = isExpense ? Colors.white : BudgetrColors.success;

    return GestureDetector(
      onTap: () => setState(() => _isExpanded = !_isExpanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: BudgetrColors.cardSurface.withOpacity(0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: _isExpanded
                  ? Colors.white.withOpacity(0.2)
                  : Colors.white.withOpacity(0.05)),
          boxShadow: _isExpanded
              ? [
                  const BoxShadow(
                      color: Colors.black12,
                      blurRadius: 8,
                      offset: Offset(0, 4))
                ]
              : [],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      shape: BoxShape.circle),
                  child: Icon(widget.iconData, color: Colors.white70, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.txn.category,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15)),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                              isCredit
                                  ? Icons.credit_card
                                  : Icons.account_balance,
                              size: 10,
                              color: primaryColor),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              widget.accountName,
                              style: TextStyle(
                                  color: primaryColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                              width: 3,
                              height: 3,
                              decoration: const BoxDecoration(
                                  color: Colors.white24,
                                  shape: BoxShape.circle)),
                          const SizedBox(width: 6),
                          Text(DateFormat('dd MMM').format(widget.txn.date),
                              style: const TextStyle(
                                  color: Colors.white54, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
                Text(
                  "${isExpense ? '' : '+'}${widget.currencyFormat.format(widget.txn.amount)}",
                  style: TextStyle(
                      color: amountColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
              ],
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox(width: double.infinity, height: 0),
              secondChild: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  const Divider(color: Colors.white10),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (widget.bankName.isNotEmpty)
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Bank / Issuer",
                                  style: TextStyle(
                                      color: Colors.white.withOpacity(0.5),
                                      fontSize: 10)),
                              const SizedBox(height: 2),
                              Text(widget.bankName,
                                  style: const TextStyle(
                                      color: Colors.white70, fontSize: 13)),
                            ],
                          ),
                        ),
                      if (widget.txn.subCategory.isNotEmpty &&
                          widget.txn.subCategory != 'General')
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text("Subcategory",
                                  style: TextStyle(
                                      color: Colors.white.withOpacity(0.5),
                                      fontSize: 10)),
                              const SizedBox(height: 2),
                              Text(widget.txn.subCategory,
                                  style: const TextStyle(
                                      color: Colors.white70, fontSize: 13)),
                            ],
                          ),
                        ),
                    ],
                  ),
                  if (widget.txn.notes.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text("Notes",
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 10)),
                    const SizedBox(height: 2),
                    Text(
                      widget.txn.notes,
                      style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          fontStyle: FontStyle.italic),
                    ),
                  ],
                ],
              ),
              crossFadeState: _isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
            ),
          ],
        ),
      ),
    );
  }
}
