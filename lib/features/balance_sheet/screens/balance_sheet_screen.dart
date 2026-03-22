import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:rxdart/rxdart.dart';
import '../../../core/design/budgetr_colors.dart';
import '../../../core/widgets/modern_app_bar.dart';
import '../../../core/widgets/status_bottom_sheet.dart';
import '../models/balance_sheet_model.dart';
import '../services/balance_sheet_service.dart';
import '../widgets/add_balance_entry_sheet.dart';
import '../widgets/contact_ledger_sheet.dart';

class BalanceSheetScreen extends StatefulWidget {
  const BalanceSheetScreen({super.key});

  @override
  State<BalanceSheetScreen> createState() => _BalanceSheetScreenState();
}

class _BalanceSheetScreenState extends State<BalanceSheetScreen>
    with SingleTickerProviderStateMixin {
  final BalanceSheetService _service = GetIt.I<BalanceSheetService>();
  final NumberFormat _currency =
      NumberFormat.currency(locale: 'en_IN', symbol: '₹');

  late TabController _tabController;

  final Color _assetColor = const Color(0xFF00E676);
  final Color _liabilityColor = const Color(0xFFFF2A55);
  final Color _surfaceColor = const Color(0xFF161F2E);

  final FocusNode _searchFocusNode = FocusNode();
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';
  String _currentFilter = 'All';
  int _assetLimit = 15;
  int _liabilityLimit = 15;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      backgroundColor: BudgetrColors.background,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => _searchFocusNode.unfocus(),
          behavior: HitTestBehavior.opaque,
          child: Stack(
            children: [
              Column(
                children: [
                  ModernAppBar(
                    title: "Balance Sheet",
                    subtitle: "CRM CUM",
                  ),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: isKeyboardOpen
                        ? const SizedBox(width: double.infinity)
                        : _buildCompactGlowingSummary(),
                  ),
                  _buildPremiumTabBar(),
                  _buildSearchAndFilterBar(),
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildLedgerList(
                            _service.watchAssets(), _assetColor, true),
                        _buildLedgerList(_service.watchLiabilities(),
                            _liabilityColor, false),
                      ],
                    ),
                  ),
                ],
              ),
              if (!isKeyboardOpen) _buildFloatingActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchAndFilterBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Column(
        children: [
          Container(
            height: 40,
            decoration: BoxDecoration(
                color: BudgetrColors.cardSurface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white.withOpacity(0.05))),
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                  hintText: "Search title or contact...",
                  hintStyle:
                      const TextStyle(color: Colors.white38, fontSize: 13),
                  prefixIcon: const Icon(Icons.search_rounded,
                      color: Colors.white38, size: 18),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? GestureDetector(
                          onTap: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                            _searchFocusNode.unfocus();
                          },
                          child: Container(
                            color: Colors.transparent,
                            child: const Icon(Icons.close_rounded,
                                color: Colors.white54, size: 16),
                          ),
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12)),
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['All', 'Pending', 'Overdue', 'Settled'].map((filter) {
                bool isSelected = _currentFilter == filter;
                return GestureDetector(
                  onTap: () {
                    _searchFocusNode.unfocus();
                    setState(() {
                      _currentFilter = filter;
                      _assetLimit = 15;
                      _liabilityLimit = 15;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                        color: isSelected ? _surfaceColor : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: isSelected
                                ? Colors.white.withOpacity(0.2)
                                : Colors.white.withOpacity(0.05))),
                    child: Text(filter,
                        style: TextStyle(
                            color: isSelected ? Colors.white : Colors.white54,
                            fontSize: 12,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.w500)),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactGlowingSummary() {
    return StreamBuilder(
      stream: Rx.combineLatest2(
        _service.watchAssets(),
        _service.watchLiabilities(),
        (List<BalanceSheetModel> assets, List<BalanceSheetModel> liabilities) =>
            [assets, liabilities],
      ),
      builder: (context, snapshot) {
        double totalAssets = 0;
        double totalLiabilities = 0;
        double pendingReceivables = 0;
        double pendingPayables = 0;

        bool isIOU(BalanceSheetModel e) {
          return (e.contactName != null && e.contactName!.trim().isNotEmpty) ||
              e.dueDate != null ||
              [
                'Money Lent',
                'Receivables',
                'Money Borrowed',
                'Personal Loans',
                'Payables'
              ].contains(e.category);
        }

        if (snapshot.hasData) {
          final assets = snapshot.data![0];
          final liabilities = snapshot.data![1];

          totalAssets = assets.fold(0.0, (sum, item) => sum + item.amount);
          totalLiabilities =
              liabilities.fold(0.0, (sum, item) => sum + item.amount);

          pendingReceivables = assets
              .where((e) => !e.isSettled && isIOU(e))
              .fold(0.0, (sum, e) => sum + (e.amount - e.settledAmount));
          pendingPayables = liabilities
              .where((e) => !e.isSettled && isIOU(e))
              .fold(0.0, (sum, e) => sum + (e.amount - e.settledAmount));
        }

        double netEquity = totalAssets - totalLiabilities;
        Color equityColor = netEquity >= 0 ? _assetColor : _liabilityColor;

        return Container(
          margin: const EdgeInsets.fromLTRB(20, 8, 20, 12),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: _surfaceColor.withOpacity(0.6),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: equityColor.withOpacity(0.3), width: 1.5),
            boxShadow: [
              BoxShadow(
                  color: equityColor.withOpacity(0.15),
                  blurRadius: 24,
                  offset: const Offset(0, 8))
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("NET EQUITY",
                            style: TextStyle(
                                color: Colors.white54,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 2)),
                        const SizedBox(height: 4),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(_currency.format(netEquity),
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -1,
                                  shadows: [
                                    Shadow(
                                        color: equityColor.withOpacity(0.6),
                                        blurRadius: 15)
                                  ])),
                        ),
                      ],
                    ),
                  ),
                  Container(
                      height: 36,
                      width: 1,
                      color: Colors.white.withOpacity(0.1),
                      margin: const EdgeInsets.symmetric(horizontal: 16)),
                  Expanded(
                    flex: 4,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                        color: _assetColor,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                              color: _assetColor, blurRadius: 4)
                                        ])),
                                const SizedBox(width: 6),
                                const Text("ASSETS",
                                    style: TextStyle(
                                        color: Colors.white54,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 1)),
                              ],
                            ),
                            Text(_currency.format(totalAssets),
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                        color: _liabilityColor,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                              color: _liabilityColor,
                                              blurRadius: 4)
                                        ])),
                                const SizedBox(width: 6),
                                const Text("LIAB.",
                                    style: TextStyle(
                                        color: Colors.white54,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 1)),
                              ],
                            ),
                            Text(_currency.format(totalLiabilities),
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (pendingReceivables > 0 || pendingPayables > 0) ...[
                const SizedBox(height: 16),
                Divider(height: 1, color: Colors.white.withOpacity(0.1)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (pendingReceivables > 0)
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 12),
                          decoration: BoxDecoration(
                              color: _assetColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: _assetColor.withOpacity(0.2))),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.call_received_rounded,
                                      color: _assetColor, size: 12),
                                  const SizedBox(width: 4),
                                  Text("TO RECEIVE",
                                      style: TextStyle(
                                          color: _assetColor,
                                          fontSize: 9,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 0.5)),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(_currency.format(pendingReceivables),
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                    if (pendingReceivables > 0 && pendingPayables > 0)
                      const SizedBox(width: 12),
                    if (pendingPayables > 0)
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 12),
                          decoration: BoxDecoration(
                              color: _liabilityColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: _liabilityColor.withOpacity(0.2))),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.call_made_rounded,
                                      color: _liabilityColor, size: 12),
                                  const SizedBox(width: 4),
                                  Text("TO PAY",
                                      style: TextStyle(
                                          color: _liabilityColor,
                                          fontSize: 9,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 0.5)),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(_currency.format(pendingPayables),
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                  ],
                )
              ]
            ],
          ),
        );
      },
    );
  }

  Widget _buildPremiumTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 40,
      decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.03),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withOpacity(0.05))),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
            color: _surfaceColor,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4))
            ],
            border: Border.all(color: Colors.white.withOpacity(0.05))),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: _tabController.index == 0 ? _assetColor : _liabilityColor,
        unselectedLabelColor: Colors.white54,
        labelStyle: const TextStyle(
            fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1),
        tabs: const [Tab(text: "ASSETS"), Tab(text: "LIABILITIES")],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Cash':
        return Icons.payments_rounded;
      case 'Bank Accounts':
        return Icons.account_balance_rounded;
      case 'Emergency Fund':
        return Icons.health_and_safety_rounded;
      case 'Money Lent':
        return Icons.front_hand_rounded;
      case 'Asset Lent':
        return Icons.inventory_2_rounded;
      case 'Receivables':
        return Icons.call_received_rounded;
      case 'Stocks & Mutual Funds':
        return Icons.candlestick_chart_rounded;
      case 'Bonds & FDs':
        return Icons.receipt_long_rounded;
      case 'PF / Gratuity':
        return Icons.savings_rounded;
      case 'Crypto':
        return Icons.currency_bitcoin_rounded;
      case 'Real Estate':
        return Icons.real_estate_agent_rounded;
      case 'Vehicles':
        return Icons.directions_car_rounded;
      case 'Jewelry & Gold':
        return Icons.diamond_rounded;
      case 'Investments':
        return Icons.trending_up_rounded;
      case 'Security Deposits':
        return Icons.lock_clock_rounded;
      case 'Life Insurance':
        return Icons.shield_rounded;
      case 'Business Assets':
        return Icons.storefront_rounded;
      case 'Credit Cards':
        return Icons.credit_card_rounded;
      case 'Buy Now Pay Later':
        return Icons.shopping_cart_checkout_rounded;
      case 'Money Borrowed':
        return Icons.request_quote_rounded;
      case 'Asset Borrowed':
        return Icons.inventory_rounded;
      case 'Personal Loans':
        return Icons.handshake_rounded;
      case 'EMI / Consumer Loans':
        return Icons.shopping_bag_rounded;
      case 'Mortgages':
        return Icons.home_work_rounded;
      case 'Business Loans':
        return Icons.storefront_rounded;
      case 'Overdrafts':
        return Icons.account_balance_wallet_rounded;
      case 'Student Loans':
        return Icons.school_rounded;
      case 'Unpaid Bills':
        return Icons.receipt_rounded;
      case 'Payables':
        return Icons.call_made_rounded;
      case 'Taxes Owed':
        return Icons.account_balance_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  Widget _buildLedgerList(
      Stream<List<BalanceSheetModel>> stream, Color themeColor, bool isAsset) {
    return StreamBuilder<List<BalanceSheetModel>>(
      stream: stream,
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());

        List<BalanceSheetModel> allEntries = snapshot.data!;

        var filtered = allEntries.where((e) {
          bool matchesSearch = _searchQuery.isEmpty ||
              e.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              (e.contactName
                      ?.toLowerCase()
                      .contains(_searchQuery.toLowerCase()) ??
                  false);
          bool matchesFilter = true;
          if (_currentFilter == 'Pending') matchesFilter = !e.isSettled;
          if (_currentFilter == 'Settled') matchesFilter = e.isSettled;
          if (_currentFilter == 'Overdue')
            matchesFilter = e.dueDate != null &&
                e.dueDate!.isBefore(DateTime.now()) &&
                !e.isSettled;
          return matchesSearch && matchesFilter;
        }).toList();

        if (filtered.isEmpty) {
          return Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off_rounded,
                      size: 64, color: Colors.white.withOpacity(0.05)),
                  const SizedBox(height: 16),
                  const Text("No records match your filters.",
                      style: TextStyle(color: Colors.white38, fontSize: 13)),
                ],
              ),
            ),
          );
        }

        int limit = isAsset ? _assetLimit : _liabilityLimit;
        final displayedLogs = filtered.take(limit).toList();
        bool hasMore = filtered.length > limit;

        return Column(
          children: [
            Expanded(
              child: SlidableAutoCloseBehavior(
                child: ListView.builder(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.only(
                      left: 20, right: 20, top: 8, bottom: 80),
                  itemCount: displayedLogs.length + (hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == displayedLogs.length) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: TextButton.icon(
                          onPressed: () => setState(() {
                            if (isAsset)
                              _assetLimit += 10;
                            else
                              _liabilityLimit += 10;
                          }),
                          icon: Icon(Icons.keyboard_arrow_down_rounded,
                              color: themeColor),
                          label: Text("Load More Older Records",
                              style: TextStyle(
                                  color: themeColor,
                                  fontWeight: FontWeight.bold)),
                          style: TextButton.styleFrom(
                              backgroundColor: themeColor.withOpacity(0.1),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12))),
                        ),
                      );
                    }

                    final entry = displayedLogs[index];
                    final iconData = _getCategoryIcon(entry.category);
                    bool isTrackable = entry.contactName != null ||
                        entry.dueDate != null ||
                        [
                          'Receivables',
                          'Payables',
                          'Personal Loans',
                          'Money Lent',
                          'Money Borrowed'
                        ].contains(entry.category);

                    int daysOverdue = 0;
                    bool isOverdue = false;
                    if (entry.dueDate != null && !entry.isSettled) {
                      daysOverdue =
                          DateTime.now().difference(entry.dueDate!).inDays;
                      isOverdue = daysOverdue > 0;
                    }

                    double remaining = entry.amount - entry.settledAmount;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Slidable(
                        key: ValueKey(entry.id),
                        startActionPane: ActionPane(
                          motion: const ScrollMotion(),
                          extentRatio: isTrackable ? 0.5 : 0.25,
                          children: [
                            SlidableAction(
                              onPressed: (_) => _showEditSheet(context, entry),
                              backgroundColor: BudgetrColors.accent,
                              foregroundColor: Colors.white,
                              icon: Icons.edit_rounded,
                              label: 'Edit',
                              borderRadius: isTrackable
                                  ? const BorderRadius.horizontal(
                                      left: Radius.circular(8))
                                  : BorderRadius.circular(8),
                            ),
                            if (isTrackable)
                              SlidableAction(
                                onPressed: (_) async {
                                  _searchFocusNode.unfocus();
                                  HapticFeedback.mediumImpact();
                                  if (entry.isSettled) {
                                    await _service.updateSettlement(
                                        entry.id, 0.0, false);
                                  } else {
                                    _showPartialSettleDialog(context, entry);
                                  }
                                },
                                backgroundColor: BudgetrColors.success,
                                foregroundColor: Colors.black,
                                icon: entry.isSettled
                                    ? Icons.undo_rounded
                                    : Icons.check_circle_rounded,
                                label: entry.isSettled ? 'Undo' : 'Settle',
                                borderRadius: const BorderRadius.horizontal(
                                    right: Radius.circular(8)),
                              ),
                          ],
                        ),
                        endActionPane: ActionPane(
                          motion: const ScrollMotion(),
                          extentRatio: 0.30,
                          children: [
                            SlidableAction(
                              onPressed: (_) =>
                                  _showDeleteSheet(context, entry.id),
                              backgroundColor: BudgetrColors.error,
                              foregroundColor: Colors.white,
                              label: 'Delete',
                              icon: Icons.delete_rounded,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ],
                        ),
                        child: Opacity(
                          opacity: entry.isSettled ? 0.4 : 1.0,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                                color: entry.isSettled
                                    ? Colors.white.withOpacity(0.01)
                                    : Colors.white.withOpacity(0.02),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: entry.isSettled
                                        ? Colors.transparent
                                        : Colors.white.withOpacity(0.03))),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.05),
                                      borderRadius: BorderRadius.circular(8)),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 6, horizontal: 4),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(DateFormat('dd').format(entry.date),
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14)),
                                      Text(
                                          DateFormat('MMM')
                                              .format(entry.date)
                                              .toUpperCase(),
                                          style: const TextStyle(
                                              color: Colors.white54,
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold)),
                                      Text(
                                          DateFormat('yyyy').format(entry.date),
                                          style: const TextStyle(
                                              color: Colors.white54,
                                              fontSize: 8,
                                              fontWeight: FontWeight.normal)),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(entry.title,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 15,
                                              decoration: entry.isSettled
                                                  ? TextDecoration.lineThrough
                                                  : null)),
                                      const SizedBox(height: 4),

                                      if (entry.contactName != null &&
                                          entry.contactName!.isNotEmpty) ...[
                                        InkWell(
                                          onTap: () {
                                            _searchFocusNode.unfocus();
                                            HapticFeedback.selectionClick();
                                            showModalBottomSheet(
                                              context: context,
                                              isScrollControlled: true,
                                              backgroundColor:
                                                  Colors.transparent,
                                              builder: (_) =>
                                                  ContactLedgerSheet(
                                                      contactName:
                                                          entry.contactName!),
                                            );
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                                color: Colors.white
                                                    .withOpacity(0.05),
                                                borderRadius:
                                                    BorderRadius.circular(4)),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(Icons.person_rounded,
                                                    color: themeColor
                                                        .withOpacity(0.8),
                                                    size: 10),
                                                const SizedBox(width: 4),
                                                Text(entry.contactName!,
                                                    style: const TextStyle(
                                                        color: Colors.white70,
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.w600)),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ] else ...[
                                        Row(
                                          children: [
                                            Icon(iconData,
                                                color:
                                                    themeColor.withOpacity(0.8),
                                                size: 12),
                                            const SizedBox(width: 4),
                                            Text(entry.category,
                                                style: const TextStyle(
                                                    color: Colors.white54,
                                                    fontSize: 12)),
                                          ],
                                        )
                                      ],

                                      // --- [UX FIX] INLINE DUE DATE & NOTES ---
                                      if ((entry.dueDate != null &&
                                              !entry.isSettled) ||
                                          (entry.notes != null &&
                                              entry.notes!
                                                  .trim()
                                                  .isNotEmpty)) ...[
                                        const SizedBox(height: 4),
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            // 1. Due Date Badge
                                            if (entry.dueDate != null &&
                                                !entry.isSettled) ...[
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 6,
                                                        vertical: 2),
                                                decoration: BoxDecoration(
                                                    color: isOverdue
                                                        ? BudgetrColors.error
                                                            .withOpacity(0.2)
                                                        : Colors.orangeAccent
                                                            .withOpacity(0.2),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            4)),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                        isOverdue
                                                            ? Icons
                                                                .warning_rounded
                                                            : Icons
                                                                .schedule_rounded,
                                                        color: isOverdue
                                                            ? BudgetrColors
                                                                .error
                                                            : Colors
                                                                .orangeAccent,
                                                        size: 10),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                        isOverdue
                                                            ? "$daysOverdue Days Overdue"
                                                            : "Due ${DateFormat('MMM dd, yyyy').format(entry.dueDate!)}",
                                                        style: TextStyle(
                                                            color: isOverdue
                                                                ? BudgetrColors
                                                                    .error
                                                                : Colors
                                                                    .orangeAccent,
                                                            fontSize: 9,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold)),
                                                  ],
                                                ),
                                              ),
                                              if (entry.notes != null &&
                                                  entry.notes!
                                                      .trim()
                                                      .isNotEmpty)
                                                const SizedBox(width: 8),
                                            ],

                                            // 2. Notes (Inline)
                                            if (entry.notes != null &&
                                                entry.notes!.trim().isNotEmpty)
                                              Expanded(
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    const Icon(
                                                        Icons
                                                            .sticky_note_2_rounded,
                                                        color: Colors.white24,
                                                        size: 10),
                                                    const SizedBox(width: 4),
                                                    Expanded(
                                                      child: Text(
                                                        entry.notes!.trim(),
                                                        style: const TextStyle(
                                                            color:
                                                                Colors.white38,
                                                            fontSize: 11),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                          ],
                                        ),
                                      ]
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      _currency.format(entry.isSettled
                                          ? entry.amount
                                          : remaining),
                                      style: TextStyle(
                                          color: entry.isSettled
                                              ? Colors.white54
                                              : Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15),
                                    ),
                                    if (!entry.isSettled &&
                                        entry.settledAmount > 0)
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 2.0),
                                        child: Text(
                                            "of ${_currency.format(entry.amount)}",
                                            style: const TextStyle(
                                                color: Colors.white38,
                                                fontSize: 10)),
                                      ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                          color: entry.isSettled
                                              ? Colors.white10
                                              : themeColor.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(4)),
                                      child: Text(
                                          entry.isSettled
                                              ? "CLEARED"
                                              : (isAsset ? "DR" : "CR"),
                                          style: TextStyle(
                                              color: entry.isSettled
                                                  ? Colors.white54
                                                  : themeColor,
                                              fontSize: 9,
                                              fontWeight: FontWeight.w900,
                                              letterSpacing: 1)),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFloatingActionButtons(BuildContext context) {
    return Positioned(
      bottom: 24,
      left: 20,
      right: 20,
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: _surfaceColor.withOpacity(0.9),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10))
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () {
                  _searchFocusNode.unfocus();
                  showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (ctx) =>
                          const AddBalanceEntrySheet(entryType: 'ASSET'));
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                            color: _assetColor.withOpacity(0.2),
                            shape: BoxShape.circle),
                        child: Icon(Icons.add_rounded,
                            color: _assetColor, size: 16)),
                    const SizedBox(width: 8),
                    const Text("ADD ASSET",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            letterSpacing: 1)),
                  ],
                ),
              ),
            ),
            Container(
                width: 1, height: 30, color: Colors.white.withOpacity(0.1)),
            Expanded(
              child: InkWell(
                onTap: () {
                  _searchFocusNode.unfocus();
                  showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (ctx) =>
                          const AddBalanceEntrySheet(entryType: 'LIABILITY'));
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                            color: _liabilityColor.withOpacity(0.2),
                            shape: BoxShape.circle),
                        child: Icon(Icons.remove_rounded,
                            color: _liabilityColor, size: 16)),
                    const SizedBox(width: 8),
                    const Text("ADD LIABILITY",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            letterSpacing: 1)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditSheet(BuildContext context, BalanceSheetModel entry) {
    _searchFocusNode.unfocus();
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => AddBalanceEntrySheet(
            entryType: entry.entryType, entryToEdit: entry));
  }

  void _showDeleteSheet(BuildContext context, String entryId) {
    _searchFocusNode.unfocus();
    showStatusSheet(
      context: context,
      title: "Delete Entry?",
      message:
          "This will permanently remove this entry and recalculate your balance.",
      icon: Icons.delete_forever_rounded,
      color: Colors.redAccent,
      buttonText: "Delete",
      cancelButtonText: "Cancel",
      onCancel: () {},
      onDismiss: () async {
        await _service.deleteEntry(entryId);
      },
    );
  }

  void _showPartialSettleDialog(BuildContext context, BalanceSheetModel entry) {
    _searchFocusNode.unfocus();
    double remaining = entry.amount - entry.settledAmount;
    final ctrl = TextEditingController(
        text: remaining.toString().replaceAll(RegExp(r"([.]*0+)(?!.*\d)"), ""));
    final formKey = GlobalKey<FormState>();

    showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              backgroundColor: BudgetrColors.cardSurface,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              title: const Text("Settle Entry",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              content: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Remaining balance: ${_currency.format(remaining)}",
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 13)),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8)),
                      child: TextFormField(
                        controller: ctrl,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold),
                        decoration: const InputDecoration(
                            prefixText: "₹ ",
                            prefixStyle:
                                TextStyle(color: Colors.white54, fontSize: 24),
                            border: InputBorder.none),
                        validator: (val) {
                          if (val == null || val.isEmpty) return "Enter amount";
                          double? parsed = double.tryParse(val);
                          if (parsed == null || parsed <= 0)
                            return "Invalid amount";
                          if (parsed > remaining)
                            return "Cannot exceed remaining";
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text("CANCEL",
                        style: TextStyle(color: Colors.white54))),
                ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      double addedSettle = double.parse(ctrl.text);
                      double totalSettled = entry.settledAmount + addedSettle;
                      bool isNowSettled = totalSettled >= entry.amount;

                      await _service.updateSettlement(
                          entry.id, totalSettled, isNowSettled);
                      if (ctx.mounted) Navigator.pop(ctx);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: BudgetrColors.success,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8))),
                  child: const Text("CONFIRM",
                      style: TextStyle(
                          color: Colors.black, fontWeight: FontWeight.bold)),
                )
              ],
            ));
  }
}
