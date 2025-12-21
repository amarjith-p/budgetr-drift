import 'package:budget/core/widgets/modern_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/widgets/calculator_keyboard.dart';
import '../../../core/widgets/modern_dropdown.dart';
import '../../../core/widgets/date_filter_row.dart';
import '../../../core/models/net_worth_model.dart';
import '../../../core/models/net_worth_split_model.dart';
import '../services/net_worth_service.dart';

class NetWorthScreen extends StatefulWidget {
  const NetWorthScreen({super.key});

  @override
  State<NetWorthScreen> createState() => _NetWorthScreenState();
}

class _NetWorthScreenState extends State<NetWorthScreen> {
  final Color _bgColor = const Color(0xff0D1B2A);
  final Color _accentColor = const Color(0xFF2EC4B6);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: _bgColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            'Net Worth & Analysis',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(70),
            child: Container(
              height: 50,
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              decoration: BoxDecoration(
                color: const Color(0xFF1B263B).withOpacity(0.8),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
              ),
              child: TabBar(
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white54,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
                indicator: BoxDecoration(
                  color: _accentColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: _accentColor.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(4),
                tabs: const [
                  Tab(text: "TOTAL NET WORTH"),
                  Tab(text: "SPLITS ANALYSIS"),
                ],
              ),
            ),
          ),
        ),
        body: const TabBarView(
          children: [_NetWorthTab(), _NetWorthSplitsTab()],
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// TAB 1: TOTAL NET WORTH DASHBOARD
// -----------------------------------------------------------------------------
class _NetWorthTab extends StatefulWidget {
  const _NetWorthTab();

  @override
  State<_NetWorthTab> createState() => _NetWorthTabState();
}

class _NetWorthTabState extends State<_NetWorthTab> {
  final _netWorthService = NetWorthService();
  final _currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
  final _shortCurrency = NumberFormat.compactCurrency(
    symbol: '₹',
    locale: 'en_IN',
  );
  final DateFormat _dateFormat = DateFormat('dd MMM yyyy');

  final Color _cardColor = const Color(0xFF1B263B).withOpacity(0.6);
  final Color _accentColor = const Color(0xFF2EC4B6);
  final Color _greenColor = const Color(0xFF00E676);
  final Color _redColor = const Color(0xFFFF5252);

  Future<void> _deleteRecord(String id) async {
    bool confirm =
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: const Color(0xFF0D1B2A),
            title: const Text(
              'Delete Record?',
              style: TextStyle(color: Colors.white),
            ),
            content: const Text(
              'This cannot be undone.',
              style: TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.redAccent),
                ),
              ),
            ],
          ),
        ) ??
        false;

    if (confirm) await _netWorthService.deleteNetWorthRecord(id);
  }

  void _showInputSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (context) => const _NetWorthInputSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<NetWorthRecord>>(
      stream: _netWorthService.getNetWorthRecords(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: ModernLoader());
        }

        final records = snapshot.data ?? [];
        final sortedRecords = List<NetWorthRecord>.from(records)
          ..sort((a, b) => a.date.compareTo(b.date));

        List<Map<String, dynamic>> tableData = [];
        for (int i = 0; i < sortedRecords.length; i++) {
          double diff = 0;
          if (i > 0) {
            diff = sortedRecords[i].amount - sortedRecords[i - 1].amount;
          }
          tableData.add({'record': sortedRecords[i], 'diff': diff});
        }
        tableData = tableData.reversed.toList();

        if (records.isEmpty) return _buildEmptyState();

        double current = sortedRecords.last.amount;
        double previous = sortedRecords.length > 1
            ? sortedRecords[sortedRecords.length - 2].amount
            : 0;
        double growth = current - previous;

        return Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 100),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    // Summary Card
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [_cardColor, _cardColor.withOpacity(0.8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.05),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            "CURRENT NET WORTH",
                            style: TextStyle(
                              color: _accentColor,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _currencyFormat.format(current),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (sortedRecords.length > 1)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: (growth >= 0 ? _greenColor : _redColor)
                                    .withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    growth >= 0
                                        ? Icons.trending_up
                                        : Icons.trending_down,
                                    color: growth >= 0
                                        ? _greenColor
                                        : _redColor,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    "${growth >= 0 ? '+' : ''}${_shortCurrency.format(growth)}",
                                    style: TextStyle(
                                      color: growth >= 0
                                          ? _greenColor
                                          : _redColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Chart
                    Container(
                      height: 320,
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                      decoration: BoxDecoration(
                        color: _cardColor,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.05),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 8.0,
                              bottom: 20,
                            ),
                            child: Text(
                              "Growth Trajectory",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Expanded(child: _buildChart(sortedRecords)),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Table
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "History Log",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    Container(
                      decoration: BoxDecoration(
                        color: _cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.05),
                        ),
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          headingRowColor: MaterialStateProperty.all(
                            Colors.white.withOpacity(0.05),
                          ),
                          columnSpacing: 24,
                          columns: [
                            DataColumn(
                              label: Text(
                                'DATE',
                                style: TextStyle(
                                  color: _accentColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'NET WORTH',
                                style: TextStyle(
                                  color: _accentColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                              numeric: true,
                            ),
                            DataColumn(
                              label: Text(
                                'DIFFERENCE',
                                style: TextStyle(
                                  color: _accentColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                              numeric: true,
                            ),
                            const DataColumn(label: Text('')),
                          ],
                          rows: tableData.map((data) {
                            final record = data['record'] as NetWorthRecord;
                            final diff = data['diff'] as double;

                            return DataRow(
                              cells: [
                                DataCell(
                                  Text(
                                    _dateFormat.format(record.date),
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    _currencyFormat.format(record.amount),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    diff == 0
                                        ? '-'
                                        : '${diff > 0 ? '+' : ''}${_currencyFormat.format(diff)}',
                                    style: TextStyle(
                                      color: diff > 0
                                          ? _greenColor
                                          : (diff < 0
                                                ? _redColor
                                                : Colors.white30),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                DataCell(
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      size: 18,
                                      color: Colors.white30,
                                    ),
                                    onPressed: () => _deleteRecord(record.id),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Floating Capsule
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    _showInputSheet();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [_accentColor, const Color(0xFF2563EB)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: _accentColor.withOpacity(0.4),
                          blurRadius: 20,
                          spreadRadius: -5,
                          offset: const Offset(0, 10),
                        ),
                      ],
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add_chart_rounded, color: Colors.white),
                        SizedBox(width: 12),
                        Text(
                          "Update Net Worth",
                          style: TextStyle(
                            color: Colors.white,
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
          ],
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: _accentColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.currency_rupee, size: 48, color: _accentColor),
          ),
          const SizedBox(height: 24),
          const Text(
            "Start Tracking Wealth",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Add your assets and liabilities\nto see your net worth grow.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white.withOpacity(0.5)),
          ),
          const SizedBox(height: 40),
          ElevatedButton.icon(
            onPressed: _showInputSheet,
            style: ElevatedButton.styleFrom(
              backgroundColor: _accentColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            icon: const Icon(Icons.add),
            label: const Text("Add First Entry"),
          ),
        ],
      ),
    );
  }

  Widget _buildChart(List<NetWorthRecord> sortedRecords) {
    List<FlSpot> spots = [];
    double sumX = 0, sumY = 0, sumXY = 0, sumXX = 0;
    int n = sortedRecords.length;

    for (int i = 0; i < n; i++) {
      double val = sortedRecords[i].amount;
      spots.add(FlSpot(i.toDouble(), val));
      sumX += i;
      sumY += val;
      sumXY += (i * val);
      sumXX += (i * i);
    }

    List<FlSpot> trendSpots = [];
    if (n > 1) {
      double slope = (n * sumXY - sumX * sumY) / (n * sumXX - sumX * sumX);
      double intercept = (sumY - slope * sumX) / n;
      trendSpots.add(FlSpot(0, intercept));
      trendSpots.add(FlSpot((n - 1).toDouble(), slope * (n - 1) + intercept));
    } else if (n == 1) {
      trendSpots.add(FlSpot(0, spots[0].y));
    }

    double interval = 1.0;
    if (n > 5) interval = (n / 5).ceilToDouble();

    return LineChart(
      LineChartData(
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipColor: (spot) =>
                const Color(0xFF0D1B2A).withOpacity(0.95),
            tooltipRoundedRadius: 8,
            getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
              return touchedBarSpots.map((barSpot) {
                if (barSpot.barIndex == 0) return null;
                final index = barSpot.x.toInt();
                if (index >= 0 && index < sortedRecords.length) {
                  final record = sortedRecords[index];
                  final dateStr = DateFormat('dd MMM yyyy').format(record.date);
                  return LineTooltipItem(
                    '$dateStr\n',
                    const TextStyle(
                      color: Colors.white70,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                    children: [
                      TextSpan(
                        text: _currencyFormat.format(barSpot.y),
                        style: TextStyle(
                          color: _accentColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  );
                }
                return null;
              }).toList();
            },
          ),
        ),
        gridData: const FlGridData(show: false),
        titlesData: FlTitlesData(
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: interval,
              getTitlesWidget: (value, meta) {
                int index = value.toInt();
                if (index >= 0 && index < sortedRecords.length) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      DateFormat('MMM yy').format(sortedRecords[index].date),
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.3),
                        fontSize: 10,
                      ),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: trendSpots,
            isCurved: false,
            color: Colors.white.withOpacity(0.3),
            barWidth: 1,
            dashArray: [5, 5],
            dotData: const FlDotData(show: false),
          ),
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: _accentColor,
            barWidth: 3,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) =>
                  FlDotCirclePainter(
                    radius: 4,
                    color: _accentColor,
                    strokeWidth: 2,
                    strokeColor: Colors.white,
                  ),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  _accentColor.withOpacity(0.3),
                  _accentColor.withOpacity(0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// TAB 2: SPLITS ANALYSIS
// -----------------------------------------------------------------------------
class _NetWorthSplitsTab extends StatefulWidget {
  const _NetWorthSplitsTab();

  @override
  State<_NetWorthSplitsTab> createState() => _NetWorthSplitsTabState();
}

class _NetWorthSplitsTabState extends State<_NetWorthSplitsTab> {
  final NetWorthService _netWorthService = NetWorthService();
  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
  );
  final DateFormat _dateFormat = DateFormat('dd MMM yyyy');
  final Color _cardColor = const Color(0xFF1B263B).withOpacity(0.6);

  final Color _greenColor = const Color(0xFF00E676);
  final Color _redColor = const Color(0xFFFF5252);
  final Color _accentColor = const Color(0xFF2EC4B6);

  int? _filterYear;
  int? _filterMonth;

  Future<void> _deleteSplit(String id) async {
    bool confirm =
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: const Color(0xFF0D1B2A),
            title: const Text(
              'Delete Record?',
              style: TextStyle(color: Colors.white),
            ),
            content: const Text(
              'This cannot be undone.',
              style: TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text(
                  'Cancel',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.redAccent),
                ),
              ),
            ],
          ),
        ) ??
        false;
    if (confirm) await _netWorthService.deleteNetWorthSplit(id);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<NetWorthSplit>>(
      stream: _netWorthService.getNetWorthSplits(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return const Center(child: ModernLoader());
        var records = snapshot.data ?? [];

        var filteredRecords = records.where((record) {
          bool matchesYear =
              _filterYear == null || record.date.year == _filterYear;
          bool matchesMonth =
              _filterMonth == null || record.date.month == _filterMonth;
          return matchesYear && matchesMonth;
        }).toList();

        filteredRecords.sort((a, b) => b.date.compareTo(a.date));

        return Stack(
          children: [
            Column(
              children: [
                _buildFilters(records),
                Expanded(
                  child: filteredRecords.isEmpty
                      ? Center(
                          child: Text(
                            'No split records found',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.only(
                            bottom: 100,
                            left: 16,
                            right: 16,
                          ),
                          itemCount: filteredRecords.length,
                          itemBuilder: (context, index) {
                            final split = filteredRecords[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: _cardColor,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.05),
                                ),
                              ),
                              child: Theme(
                                data: Theme.of(context).copyWith(
                                  dividerColor: Colors.transparent,
                                  iconTheme: const IconThemeData(
                                    color: Colors.white70,
                                  ),
                                ),
                                child: ExpansionTile(
                                  tilePadding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 8,
                                  ),
                                  title: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        _dateFormat.format(split.date),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        _currencyFormat.format(
                                          split.effectiveSavings,
                                        ),
                                        style: TextStyle(
                                          color: split.effectiveSavings >= 0
                                              ? _greenColor
                                              : _redColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                        20,
                                        0,
                                        20,
                                        20,
                                      ),
                                      child: Column(
                                        children: [
                                          const Divider(color: Colors.white10),
                                          _detailRow(
                                            'Income',
                                            split.effectiveIncome,
                                            _greenColor,
                                          ),
                                          _detailRow(
                                            'Expense',
                                            split.effectiveExpense,
                                            _redColor,
                                          ),
                                          const SizedBox(height: 12),
                                          _subRow(
                                            'Net Income',
                                            split.netIncome,
                                          ),
                                          _subRow(
                                            'Capital Gain',
                                            split.capitalGain,
                                          ),
                                          _subRow(
                                            'Non-Calc Income',
                                            split.nonCalcIncome,
                                          ),
                                          const SizedBox(height: 8),
                                          _subRow(
                                            'Net Expense',
                                            split.netExpense,
                                          ),
                                          _subRow(
                                            'Capital Loss',
                                            split.capitalLoss,
                                          ),
                                          _subRow(
                                            'Non-Calc Expense',
                                            split.nonCalcExpense,
                                          ),
                                          const SizedBox(height: 16),
                                          Align(
                                            alignment: Alignment.centerRight,
                                            child: OutlinedButton.icon(
                                              onPressed: () =>
                                                  _deleteSplit(split.id),
                                              icon: const Icon(
                                                Icons.delete_outline,
                                                size: 16,
                                                color: Colors.redAccent,
                                              ),
                                              label: const Text(
                                                "Delete",
                                                style: TextStyle(
                                                  color: Colors.redAccent,
                                                ),
                                              ),
                                              style: OutlinedButton.styleFrom(
                                                side: BorderSide(
                                                  color: Colors.redAccent
                                                      .withOpacity(0.3),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      useSafeArea: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => const _AddNetWorthSplitSheet(),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [_accentColor, const Color(0xFF2563EB)],
                      ),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: _accentColor.withOpacity(0.4),
                          blurRadius: 20,
                          spreadRadius: -5,
                          offset: const Offset(0, 10),
                        ),
                      ],
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.playlist_add_rounded, color: Colors.white),
                        SizedBox(width: 12),
                        Text(
                          "Add New Split",
                          style: TextStyle(
                            color: Colors.white,
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
          ],
        );
      },
    );
  }

  Widget _buildFilters(List<NetWorthSplit> allRecords) {
    final years = allRecords.map((e) => e.date.year).toSet().toList();
    years.sort((a, b) => b.compareTo(a));
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: DateFilterRow(
        selectedYear: _filterYear,
        selectedMonth: _filterMonth,
        availableYears: years,
        availableMonths: List.generate(12, (i) => i + 1),
        onYearSelected: (val) => setState(() {
          _filterYear = val;
          if (val == null) _filterMonth = null;
        }),
        onMonthSelected: (val) => setState(() => _filterMonth = val),
      ),
    );
  }

  Widget _detailRow(String label, double amount, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white)),
          Text(
            _currencyFormat.format(amount),
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _subRow(String label, double amount) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
          Text(
            _currencyFormat.format(amount),
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// STICKY INPUT SHEET (Total Net Worth)
// -----------------------------------------------------------------------------
class _NetWorthInputSheet extends StatefulWidget {
  const _NetWorthInputSheet();

  @override
  State<_NetWorthInputSheet> createState() => _NetWorthInputSheetState();
}

class _NetWorthInputSheetState extends State<_NetWorthInputSheet> {
  final _netWorthService = NetWorthService();
  final ScrollController _scrollController = ScrollController();

  final TextEditingController _assetsController = TextEditingController();
  final TextEditingController _liabilitiesController = TextEditingController();
  final FocusNode _assetsFocus = FocusNode();
  final FocusNode _liabilitiesFocus = FocusNode();

  DateTime _selectedDate = DateTime.now();
  double _currentNetWorth = 0.0;

  TextEditingController? _activeController;
  bool _isKeyboardVisible = false;
  bool _useSystemKeyboard = false;

  @override
  void initState() {
    super.initState();
    _assetsController.addListener(_calculate);
    _liabilitiesController.addListener(_calculate);
  }

  @override
  void dispose() {
    _assetsController.dispose();
    _liabilitiesController.dispose();
    _assetsFocus.dispose();
    _liabilitiesFocus.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _calculate() {
    final assets = double.tryParse(_assetsController.text) ?? 0.0;
    final liabilities = double.tryParse(_liabilitiesController.text) ?? 0.0;
    setState(() => _currentNetWorth = assets - liabilities);
  }

  void _scrollToInput(FocusNode node) {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (node.context != null && mounted) {
        Scrollable.ensureVisible(
          node.context!,
          alignment: 0.5,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _setActive(TextEditingController ctrl, FocusNode node) {
    setState(() {
      _activeController = ctrl;
      if (!_useSystemKeyboard) {
        _isKeyboardVisible = true;
        FocusScope.of(context).requestFocus(node);
      } else {
        _isKeyboardVisible = false;
      }
    });
    _scrollToInput(node);
  }

  void _closeKeyboard() {
    setState(() => _isKeyboardVisible = false);
    FocusScope.of(context).unfocus();
  }

  void _switchToSystemKeyboard() {
    setState(() {
      _useSystemKeyboard = true;
      _isKeyboardVisible = false;
    });
    FocusScope.of(context).unfocus();
  }

  void _handleNext() {
    if (_activeController == _assetsController) {
      _setActive(_liabilitiesController, _liabilitiesFocus);
    } else {
      _closeKeyboard();
    }
  }

  Future<void> _save() async {
    _closeKeyboard();
    final assets = double.tryParse(_assetsController.text) ?? 0.0;
    final liabilities = double.tryParse(_liabilitiesController.text) ?? 0.0;

    final record = NetWorthRecord(
      id: '',
      date: _selectedDate,
      amount: assets - liabilities,
    );

    await _netWorthService.addNetWorthRecord(record);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _currentNetWorth >= 0
        ? const Color(0xFF00E676)
        : const Color(0xFFFF5252);

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      color: const Color(0xff0D1B2A),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Column(
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Update Net Worth",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          final d = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime.now(),
                            builder: (context, child) => Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: const ColorScheme.dark(
                                  primary: Color(0xFF2EC4B6),
                                  surface: Color(0xFF1B263B),
                                ),
                              ),
                              child: child!,
                            ),
                          );
                          if (d != null) setState(() => _selectedDate = d);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.1),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.calendar_today,
                                size: 14,
                                color: Colors.white70,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                DateFormat('dd MMM yyyy').format(_selectedDate),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  _buildInput(
                    "Total Assets",
                    _assetsController,
                    _assetsFocus,
                    const Color(0xFF00E676),
                  ),
                  const SizedBox(height: 16),
                  _buildInput(
                    "Total Liabilities",
                    _liabilitiesController,
                    _liabilitiesFocus,
                    const Color(0xFFFF5252),
                  ),
                ],
              ),
            ),
          ),

          // --- STICKY BOTTOM BAR ---
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xff0D1B2A),
              border: Border(
                top: BorderSide(color: Colors.white.withOpacity(0.1)),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Calculated Net Worth:",
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    Text(
                      NumberFormat.currency(
                        locale: 'en_IN',
                        symbol: '₹',
                      ).format(_currentNetWorth),
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: BorderSide(
                            color: Colors.white.withOpacity(0.2),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          "Cancel",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _save,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: const Color(0xFF2EC4B6),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          "Save Record",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // --- KEYBOARD ---
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            child: _isKeyboardVisible
                ? CalculatorKeyboard(
                    onKeyPress: (v) => CalculatorKeyboard.handleKeyPress(
                      _activeController!,
                      v,
                    ),
                    onBackspace: () =>
                        CalculatorKeyboard.handleBackspace(_activeController!),
                    onClear: () => _activeController!.clear(),
                    onEquals: () =>
                        CalculatorKeyboard.handleEquals(_activeController!),
                    onClose: _closeKeyboard,
                    onSwitchToSystem: _switchToSystemKeyboard,
                    onNext: _handleNext,
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildInput(
    String label,
    TextEditingController ctrl,
    FocusNode node,
    Color accent,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: accent,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: ctrl,
          focusNode: node,
          readOnly: !_useSystemKeyboard,
          showCursor: true,
          keyboardType: TextInputType.number,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          decoration: InputDecoration(
            prefixText: '₹ ',
            prefixStyle: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 20,
            ),
            hintText: '0',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.1)),
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
            isDense: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          onTap: () => _setActive(ctrl, node),
        ),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// HELPER: MODERN SPLIT INPUT SHEET
// -----------------------------------------------------------------------------
class _AddNetWorthSplitSheet extends StatefulWidget {
  const _AddNetWorthSplitSheet();

  @override
  State<_AddNetWorthSplitSheet> createState() => _AddNetWorthSplitSheetState();
}

class _AddNetWorthSplitSheetState extends State<_AddNetWorthSplitSheet> {
  final _netWorthService = NetWorthService();
  final ScrollController _scrollController = ScrollController();

  // Controllers
  final _netIncomeCtrl = TextEditingController();
  final _netExpenseCtrl = TextEditingController();
  final _capGainCtrl = TextEditingController();
  final _capLossCtrl = TextEditingController();
  final _nonCalcIncomeCtrl = TextEditingController();
  final _nonCalcExpenseCtrl = TextEditingController();

  // Focus Nodes
  final _netIncomeFocus = FocusNode();
  final _netExpenseFocus = FocusNode();
  final _capGainFocus = FocusNode();
  final _capLossFocus = FocusNode();
  final _nonCalcIncomeFocus = FocusNode();
  final _nonCalcExpenseFocus = FocusNode();

  DateTime _selectedDate = DateTime.now();

  // Keyboard State
  TextEditingController? _activeController;
  bool _isKeyboardVisible = false;
  bool _useSystemKeyboard = false;

  @override
  void dispose() {
    _netIncomeCtrl.dispose();
    _netExpenseCtrl.dispose();
    _capGainCtrl.dispose();
    _capLossCtrl.dispose();
    _nonCalcIncomeCtrl.dispose();
    _nonCalcExpenseCtrl.dispose();

    _netIncomeFocus.dispose();
    _netExpenseFocus.dispose();
    _capGainFocus.dispose();
    _capLossFocus.dispose();
    _nonCalcIncomeFocus.dispose();
    _nonCalcExpenseFocus.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // --- Keyboard Handling ---
  void _scrollToInput(FocusNode node) {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (node.context != null && mounted) {
        Scrollable.ensureVisible(
          node.context!,
          alignment: 0.5,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _setActive(TextEditingController ctrl, FocusNode node) {
    setState(() {
      _activeController = ctrl;
      if (!_useSystemKeyboard) {
        _isKeyboardVisible = true;
        FocusScope.of(context).requestFocus(node);
      } else {
        _isKeyboardVisible = false;
      }
    });
    _scrollToInput(node);
  }

  void _closeKeyboard() {
    setState(() => _isKeyboardVisible = false);
    FocusScope.of(context).unfocus();
  }

  void _switchToSystemKeyboard() {
    setState(() {
      _useSystemKeyboard = true;
      _isKeyboardVisible = false;
    });
    FocusScope.of(context).unfocus();
  }

  void _handleNext() {
    if (_activeController == _netIncomeCtrl)
      _setActive(_netExpenseCtrl, _netExpenseFocus);
    else if (_activeController == _netExpenseCtrl)
      _setActive(_capGainCtrl, _capGainFocus);
    else if (_activeController == _capGainCtrl)
      _setActive(_capLossCtrl, _capLossFocus);
    else if (_activeController == _capLossCtrl)
      _setActive(_nonCalcIncomeCtrl, _nonCalcIncomeFocus);
    else if (_activeController == _nonCalcIncomeCtrl)
      _setActive(_nonCalcExpenseCtrl, _nonCalcExpenseFocus);
    else
      _closeKeyboard();
  }

  Future<void> _save() async {
    _closeKeyboard();

    final split = NetWorthSplit(
      id: '',
      date: _selectedDate,
      netIncome: double.tryParse(_netIncomeCtrl.text) ?? 0,
      netExpense: double.tryParse(_netExpenseCtrl.text) ?? 0,
      capitalGain: double.tryParse(_capGainCtrl.text) ?? 0,
      capitalLoss: double.tryParse(_capLossCtrl.text) ?? 0,
      nonCalcIncome: double.tryParse(_nonCalcIncomeCtrl.text) ?? 0,
      nonCalcExpense: double.tryParse(_nonCalcExpenseCtrl.text) ?? 0,
    );

    await _netWorthService.addNetWorthSplit(split);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      color: const Color(0xff0D1B2A),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          // Content
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Header with Date Picker
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Add Split Analysis",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          final d = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime.now(),
                            builder: (context, child) => Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: const ColorScheme.dark(
                                  primary: Color(0xFF2EC4B6),
                                  surface: Color(0xFF1B263B),
                                ),
                              ),
                              child: child!,
                            ),
                          );
                          if (d != null) setState(() => _selectedDate = d);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.1),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.calendar_today,
                                size: 14,
                                color: Colors.white70,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                DateFormat('dd MMM').format(_selectedDate),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // --- Input Fields Grid (Strict Colors) ---
                  Row(
                    children: [
                      // Net Income (Green)
                      Expanded(
                        child: _buildSplitInput(
                          "Net Income",
                          _netIncomeCtrl,
                          _netIncomeFocus,
                          const Color(0xFF00E676),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Net Expense (Red)
                      Expanded(
                        child: _buildSplitInput(
                          "Net Expense",
                          _netExpenseCtrl,
                          _netExpenseFocus,
                          const Color(0xFFFF5252),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      // Capital Gain (Green)
                      Expanded(
                        child: _buildSplitInput(
                          "Capital Gain",
                          _capGainCtrl,
                          _capGainFocus,
                          const Color(0xFF00E676),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Capital Loss (Red)
                      Expanded(
                        child: _buildSplitInput(
                          "Capital Loss",
                          _capLossCtrl,
                          _capLossFocus,
                          const Color(0xFFFF5252),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      // Other Income (Green)
                      Expanded(
                        child: _buildSplitInput(
                          "Other Income",
                          _nonCalcIncomeCtrl,
                          _nonCalcIncomeFocus,
                          const Color(0xFF00E676),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Other Expense (Red)
                      Expanded(
                        child: _buildSplitInput(
                          "Other Expense",
                          _nonCalcExpenseCtrl,
                          _nonCalcExpenseFocus,
                          const Color(0xFFFF5252),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),

          // --- Sticky Action Bar ---
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xff0D1B2A),
              border: Border(
                top: BorderSide(color: Colors.white.withOpacity(0.1)),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.4),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: Colors.white.withOpacity(0.2)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      "Cancel",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: const Color(0xFF2EC4B6),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      "Save Split",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // --- Keyboard ---
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            child: _isKeyboardVisible
                ? CalculatorKeyboard(
                    onKeyPress: (v) => CalculatorKeyboard.handleKeyPress(
                      _activeController!,
                      v,
                    ),
                    onBackspace: () =>
                        CalculatorKeyboard.handleBackspace(_activeController!),
                    onClear: () => _activeController!.clear(),
                    onEquals: () =>
                        CalculatorKeyboard.handleEquals(_activeController!),
                    onClose: _closeKeyboard,
                    onSwitchToSystem: _switchToSystemKeyboard,
                    onNext: _handleNext,
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildSplitInput(
    String label,
    TextEditingController ctrl,
    FocusNode node,
    Color accent,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: accent.withOpacity(0.9),
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: ctrl,
          focusNode: node,
          readOnly: !_useSystemKeyboard,
          showCursor: true,
          keyboardType: TextInputType.number,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          decoration: InputDecoration(
            prefixText: '₹ ',
            prefixStyle: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 16,
            ),
            hintText: '0',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.1)),
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
            isDense: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          onTap: () => _setActive(ctrl, node),
        ),
      ],
    );
  }
}
