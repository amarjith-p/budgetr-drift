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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BudgetrColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                ModernAppBar(
                  title: "Balance Sheet",
                  subtitle: "PAYABLES & RECEIVABLES CUM",
                  // trailingIcon: Icons.account_balance_wallet_rounded,
                  // onTrailingPressed: () {},
                ),
                _buildCompactGlowingSummary(),
                _buildPremiumTabBar(),
                const SizedBox(height: 8),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildLedgerList(
                          _service.watchAssets(), _assetColor, true),
                      _buildLedgerList(
                          _service.watchLiabilities(), _liabilityColor, false),
                    ],
                  ),
                ),
              ],
            ),
            _buildFloatingActionButtons(context),
          ],
        ),
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
              .fold(0.0, (sum, e) => sum + e.amount);
          pendingPayables = liabilities
              .where((e) => !e.isSettled && isIOU(e))
              .fold(0.0, (sum, e) => sum + e.amount);
        }

        double netEquity = totalAssets - totalLiabilities;
        Color equityColor = netEquity >= 0 ? _assetColor : _liabilityColor;

        return Container(
          margin: const EdgeInsets.fromLTRB(20, 8, 20, 20),
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
                          child: Text(
                            _currency.format(netEquity),
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -1,
                                shadows: [
                                  Shadow(
                                      color: equityColor.withOpacity(0.6),
                                      blurRadius: 15)
                                ]),
                          ),
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
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
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
        tabs: const [
          Tab(text: "ASSETS"),
          Tab(text: "LIABILITIES"),
        ],
      ),
    );
  }

  // --- EXPANDED ICONS ---
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
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final entries = snapshot.data!;

        if (entries.isEmpty) {
          return Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(isAsset ? Icons.verified_user_rounded : Icons.gavel_rounded,
                  size: 64, color: Colors.white.withOpacity(0.05)),
              const SizedBox(height: 16),
              Text("No ${isAsset ? 'Assets' : 'Liabilities'} recorded.",
                  style: const TextStyle(color: Colors.white38, fontSize: 13)),
            ],
          ));
        }

        return SlidableAutoCloseBehavior(
          child: ListView.builder(
            padding: const EdgeInsets.only(
                left: 20, right: 20, top: 16, bottom: 120),
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index];
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
              bool isOverdue = entry.dueDate != null &&
                  entry.dueDate!.isBefore(DateTime.now()) &&
                  !entry.isSettled;

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
                            HapticFeedback.mediumImpact();
                            await _service.toggleSettlementStatus(
                                entry.id, entry.isSettled);
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
                        onPressed: (_) => _showDeleteSheet(context, entry.id),
                        backgroundColor: BudgetrColors.error,
                        foregroundColor: Colors.white,
                        icon: Icons.delete_rounded,
                        label: 'Delete',
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
                                : Colors.white.withOpacity(0.03)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                                vertical: 6, horizontal: 4),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  DateFormat('dd').format(entry.date),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  DateFormat('MMM')
                                      .format(entry.date)
                                      .toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white54,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  DateFormat('yyyy').format(entry.date),
                                  style: const TextStyle(
                                    color: Colors.white54,
                                    fontSize: 8,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(entry.title,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      decoration: entry.isSettled
                                          ? TextDecoration.lineThrough
                                          : null,
                                    )),
                                const SizedBox(height: 4),
                                if (entry.contactName != null &&
                                    entry.contactName!.isNotEmpty) ...[
                                  Row(
                                    children: [
                                      Icon(Icons.person_rounded,
                                          color: themeColor.withOpacity(0.8),
                                          size: 12),
                                      const SizedBox(width: 4),
                                      Text(entry.contactName!,
                                          style: const TextStyle(
                                              color: Colors.white54,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600)),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                ] else ...[
                                  Row(
                                    children: [
                                      Icon(iconData,
                                          color: themeColor.withOpacity(0.8),
                                          size: 12),
                                      const SizedBox(width: 4),
                                      Text(entry.category,
                                          style: const TextStyle(
                                              color: Colors.white54,
                                              fontSize: 12)),
                                    ],
                                  )
                                ],
                                if (entry.dueDate != null &&
                                    !entry.isSettled) ...[
                                  Container(
                                    margin: const EdgeInsets.only(top: 4),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                        color: isOverdue
                                            ? BudgetrColors.error
                                                .withOpacity(0.2)
                                            : Colors.orangeAccent
                                                .withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(4)),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                            isOverdue
                                                ? Icons.warning_rounded
                                                : Icons.schedule_rounded,
                                            color: isOverdue
                                                ? BudgetrColors.error
                                                : Colors.orangeAccent,
                                            size: 10),
                                        const SizedBox(width: 4),
                                        Text(
                                            isOverdue
                                                ? "Overdue"
                                                : "Due ${DateFormat('MMM dd, yyyy').format(entry.dueDate!)}",
                                            style: TextStyle(
                                                color: isOverdue
                                                    ? BudgetrColors.error
                                                    : Colors.orangeAccent,
                                                fontSize: 9,
                                                fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  )
                                ]
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                _currency.format(entry.amount),
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                    color: entry.isSettled
                                        ? Colors.white10
                                        : themeColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4)),
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
                onTap: () => showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (ctx) =>
                      const AddBalanceEntrySheet(entryType: 'ASSET'),
                ),
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
                onTap: () => showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (ctx) =>
                      const AddBalanceEntrySheet(entryType: 'LIABILITY'),
                ),
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          AddBalanceEntrySheet(entryType: entry.entryType, entryToEdit: entry),
    );
  }

  void _showDeleteSheet(BuildContext context, String entryId) {
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
}
