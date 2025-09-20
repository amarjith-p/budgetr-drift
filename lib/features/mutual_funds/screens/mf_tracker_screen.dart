import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../core/models/mf_portfolio_snapshot_model.dart';
import '../../../core/models/mf_transaction_model.dart';
import '../../../core/services/firestore_service.dart';

class MfTrackerScreen extends StatefulWidget {
  const MfTrackerScreen({super.key});

  @override
  State<MfTrackerScreen> createState() => _MfTrackerScreenState();
}

class _MfTrackerScreenState extends State<MfTrackerScreen> {
  final firestoreService = FirestoreService();
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddTransactionSheet({MfTransaction? transaction}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _AddMfTransactionSheet(transaction: transaction),
    );
  }

  void _showAddSnapshotSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _AddMfSnapshotSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
    final isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      appBar: AppBar(title: const Text('Mutual Fund Tracker')),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isKeyboardVisible)
            Column(
              children: [
                StreamBuilder<List<MfPortfolioSnapshot>>(
                  stream: firestoreService.getMfPortfolioSnapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const SizedBox(
                        height: 250,
                        child: Center(
                          child: Text(
                            'Add portfolio snapshots to see the chart.',
                          ),
                        ),
                      );
                    }
                    return _PortfolioLineChart(snapshots: snapshot.data!);
                  },
                ),
                const Divider(height: 1, color: Colors.white12),
              ],
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Transactions',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by fund name...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Theme.of(
                  context,
                ).colorScheme.surfaceVariant.withOpacity(0.5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.zero,
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => _searchController.clear(),
                      )
                    : null,
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<MfTransaction>>(
              stream: firestoreService.getMfTransactions(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text('No transactions added yet.'),
                  );
                }

                final allTransactions = snapshot.data!;
                final filteredTransactions = allTransactions.where((
                  transaction,
                ) {
                  return transaction.fundName.toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  );
                }).toList();

                if (filteredTransactions.isEmpty) {
                  return const Center(
                    child: Text('No transactions match your search.'),
                  );
                }

                final totalPurchaseValue = filteredTransactions.fold<double>(
                  0,
                  (sum, item) => sum + item.amount,
                );

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Purchases (Filtered)',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          Text(
                            currencyFormat.format(totalPurchaseValue),
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    const Divider(
                      indent: 16,
                      endIndent: 16,
                      height: 16,
                      color: Colors.white12,
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                        itemCount: filteredTransactions.length,
                        itemBuilder: (context, index) {
                          final transaction = filteredTransactions[index];
                          return Dismissible(
                            key: Key(transaction.id),
                            background: Container(
                              color: Colors.blue.shade700,
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20.0,
                              ),
                              child: const Icon(
                                Icons.edit,
                                color: Colors.white,
                              ),
                            ),
                            secondaryBackground: Container(
                              color: Colors.red.shade700,
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20.0,
                              ),
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            ),
                            confirmDismiss: (direction) async {
                              if (direction == DismissDirection.endToStart) {
                                // Delete
                                return await showDialog(
                                  context: context,
                                  builder: (BuildContext context) => AlertDialog(
                                    title: const Text("Confirm Delete"),
                                    content: const Text(
                                      "Are you sure you want to delete this transaction?",
                                    ),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(context).pop(false),
                                        child: const Text("Cancel"),
                                      ),
                                      FilledButton(
                                        style: FilledButton.styleFrom(
                                          backgroundColor: Colors.red,
                                        ),
                                        onPressed: () {
                                          firestoreService.deleteMfTransaction(
                                            transaction.id,
                                          );
                                          Navigator.of(context).pop(true);
                                        },
                                        child: const Text("Delete"),
                                      ),
                                    ],
                                  ),
                                );
                              } else {
                                _showAddTransactionSheet(
                                  transaction: transaction,
                                );
                                return false;
                              }
                            },
                            child: _TransactionCard(transaction: transaction),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'add_transaction_fab',
            onPressed: () => _showAddTransactionSheet(),
            tooltip: 'Add Transaction',
            child: const Icon(Icons.add_shopping_cart),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'add_snapshot_fab',
            onPressed: _showAddSnapshotSheet,
            tooltip: 'Update Portfolio Value',
            child: const Icon(Icons.show_chart),
          ),
        ],
      ),
    );
  }
}

class _PortfolioLineChart extends StatelessWidget {
  final List<MfPortfolioSnapshot> snapshots;
  const _PortfolioLineChart({required this.snapshots});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.compactCurrency(
      locale: 'en_IN',
      symbol: '₹',
    );

    LinearGradient _createCurrentValueGradient() {
      if (snapshots.length < 2) {
        return const LinearGradient(
          colors: [Colors.greenAccent, Colors.greenAccent],
        );
      }
      final colors = <Color>[];
      final stops = <double>[];
      final totalXRange =
          snapshots.last.date.millisecondsSinceEpoch -
          snapshots.first.date.millisecondsSinceEpoch;
      if (totalXRange == 0) {
        final isGain = snapshots[0].currentValue >= snapshots[0].investedValue;
        return LinearGradient(
          colors: [
            isGain ? Colors.greenAccent : Colors.redAccent,
            isGain ? Colors.greenAccent : Colors.redAccent,
          ],
        );
      }

      for (int i = 0; i < snapshots.length - 1; i++) {
        final p1 = snapshots[i];
        final p2 = snapshots[i + 1];
        final isGain =
            (p1.currentValue + p2.currentValue) / 2 >=
            (p1.investedValue + p2.investedValue) / 2;
        final segmentColor = isGain ? Colors.greenAccent : Colors.redAccent;
        final p1Stop =
            (p1.date.millisecondsSinceEpoch -
                snapshots.first.date.millisecondsSinceEpoch) /
            totalXRange;
        colors.add(segmentColor);
        stops.add(p1Stop);
        final p2Stop =
            (p2.date.millisecondsSinceEpoch -
                snapshots.first.date.millisecondsSinceEpoch) /
            totalXRange;
        colors.add(segmentColor);
        stops.add(p2Stop);
      }

      return LinearGradient(colors: colors, stops: stops);
    }

    return AspectRatio(
      aspectRatio: 1.7,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
        child: LineChart(
          LineChartData(
            lineBarsData: [
              LineChartBarData(
                spots: snapshots
                    .map(
                      (s) => FlSpot(
                        s.date.millisecondsSinceEpoch.toDouble(),
                        s.investedValue,
                      ),
                    )
                    .toList(),
                isCurved: true,
                color: Colors.blueAccent,
                barWidth: 3,
                isStrokeCapRound: true,
                dotData: const FlDotData(show: false),
              ),
              LineChartBarData(
                spots: snapshots
                    .map(
                      (s) => FlSpot(
                        s.date.millisecondsSinceEpoch.toDouble(),
                        s.currentValue,
                      ),
                    )
                    .toList(),
                isCurved: true,
                gradient: _createCurrentValueGradient(),
                barWidth: 3,
                isStrokeCapRound: true,
                dotData: const FlDotData(show: false),
              ),
            ],
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 70,
                  getTitlesWidget: (value, meta) => Text(
                    currencyFormat.format(value),
                    style: const TextStyle(fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  interval: snapshots.length > 1
                      ? (snapshots.last.date.millisecondsSinceEpoch -
                                snapshots.first.date.millisecondsSinceEpoch) /
                            3
                      : null,
                  getTitlesWidget: (value, meta) {
                    final text = DateFormat('dd MMM').format(
                      DateTime.fromMillisecondsSinceEpoch(value.toInt()),
                    );
                    return SideTitleWidget(
                      axisSide: meta.axisSide,
                      angle: -0.7,
                      space: 8,
                      child: Text(text, style: const TextStyle(fontSize: 12)),
                    );
                  },
                ),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              getDrawingHorizontalLine: (value) =>
                  const FlLine(color: Colors.white10, strokeWidth: 1),
            ),
            borderData: FlBorderData(
              show: true,
              border: Border.all(color: Colors.white10),
            ),
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                fitInsideVertically: true,
                getTooltipItems: (touchedSpots) {
                  return touchedSpots.map((spot) {
                    final isInvestedLine = spot.barIndex == 0;
                    final valueText = currencyFormat.format(spot.y);
                    final date = DateTime.fromMillisecondsSinceEpoch(
                      spot.x.toInt(),
                    );
                    final dateText = DateFormat('dd MMM yyyy').format(date);

                    final String lineLabel = isInvestedLine
                        ? 'Invested'
                        : 'Current';

                    return LineTooltipItem(
                      '$lineLabel: $valueText\n',
                      TextStyle(
                        color:
                            spot.bar.gradient?.colors.first ??
                            spot.bar.color ??
                            Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      children: [
                        TextSpan(
                          text: dateText,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontWeight: FontWeight.normal,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    );
                  }).toList();
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TransactionCard extends StatefulWidget {
  final MfTransaction transaction;
  const _TransactionCard({required this.transaction});

  @override
  State<_TransactionCard> createState() => _TransactionCardState();
}

class _TransactionCardState extends State<_TransactionCard> {
  bool _isExpanded = false;

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.white.withOpacity(0.7))),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
    final dateFormat = DateFormat('dd MMM yyyy');
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => setState(() => _isExpanded = !_isExpanded),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      widget.transaction.fundName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    currencyFormat.format(widget.transaction.amount),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    dateFormat.format(widget.transaction.date.toDate()),
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.white70),
                  ),
                  Text(
                    'Charges: ${currencyFormat.format(widget.transaction.charges)}',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.white70),
                  ),
                ],
              ),
              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: Column(
                  children: [
                    const Divider(height: 24, color: Colors.white12),
                    _buildDetailRow(
                      'Amount after Charges:',
                      currencyFormat.format(
                        widget.transaction.amountAfterCharges,
                      ),
                    ),
                    _buildDetailRow('NAV:', widget.transaction.nav.toString()),
                    _buildDetailRow(
                      'Units Allocated:',
                      widget.transaction.unitsAllocated.toStringAsFixed(4),
                    ),
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
      ),
    );
  }
}

class _AddMfTransactionSheet extends StatefulWidget {
  final MfTransaction? transaction;
  const _AddMfTransactionSheet({super.key, this.transaction});

  @override
  State<_AddMfTransactionSheet> createState() => _AddMfTransactionSheetState();
}

class _AddMfTransactionSheetState extends State<_AddMfTransactionSheet> {
  final _formKey = GlobalKey<FormState>();
  final _firestoreService = FirestoreService();
  final _amountController = TextEditingController();
  final _amountAfterChargesController = TextEditingController();
  final _chargesController = TextEditingController();
  final _navController = TextEditingController();
  final _unitsController = TextEditingController();

  List<String> _fundNames = [
    'Parag Parikh Flexi Cap',
    'HDFC Mid Cap',
    'UTI Nifty 50 Index Fund',
  ];
  String? _selectedFundName;
  DateTime? _selectedDate;
  static const String _addNewFundKey = 'ADD_NEW_FUND';

  bool get _isEditing => widget.transaction != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _selectedFundName = widget.transaction!.fundName;
      _selectedDate = widget.transaction!.date.toDate();
      _amountController.text = widget.transaction!.amount.toString();
      _amountAfterChargesController.text = widget
          .transaction!
          .amountAfterCharges
          .toString();
      _navController.text = widget.transaction!.nav.toString();
      _unitsController.text = widget.transaction!.unitsAllocated.toString();
    } else {
      _selectedDate = DateTime.now();
    }
    _loadFundNames();
    _amountController.addListener(_calculateCharges);
    _amountAfterChargesController.addListener(_calculateCharges);
  }

  Future<void> _loadFundNames() async {
    final userFunds = await _firestoreService.getFundNames();
    setState(() {
      _fundNames = [
        ...{
          'Parag Parikh Flexi Cap',
          'HDFC Mid Cap',
          'UTI Nifty 50 Index Fund',
        },
        ...userFunds,
      ].toList();
    });
  }

  void _calculateCharges() {
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    final amountAfter =
        double.tryParse(_amountAfterChargesController.text) ?? 0.0;
    _chargesController.text = (amount - amountAfter).toStringAsFixed(2);
  }

  Future<void> _addNewFund() async {
    final newFundController = TextEditingController();
    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Fund Name'),
        content: TextField(
          controller: newFundController,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Enter fund name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(newFundController.text),
            child: const Text('Add'),
          ),
        ],
      ),
    );
    if (newName != null && newName.trim().isNotEmpty) {
      await _firestoreService.addFundName(newName.trim());
      await _loadFundNames();
      setState(() => _selectedFundName = newName.trim());
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _onRecord() async {
    if (_formKey.currentState!.validate() &&
        _selectedFundName != null &&
        _selectedDate != null) {
      final transactionData = MfTransaction(
        id: _isEditing ? widget.transaction!.id : '',
        fundName: _selectedFundName!,
        amount: double.parse(_amountController.text),
        amountAfterCharges: double.parse(_amountAfterChargesController.text),
        nav: double.parse(_navController.text),
        unitsAllocated: double.parse(_unitsController.text),
        date: Timestamp.fromDate(_selectedDate!),
      );
      if (_isEditing) {
        await _firestoreService.updateMfTransaction(
          widget.transaction!.id,
          transactionData,
        );
      } else {
        await _firestoreService.addMfTransaction(transactionData);
      }
      if (mounted) Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields, including Fund and Date.'),
        ),
      );
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _amountAfterChargesController.dispose();
    _chargesController.dispose();
    _navController.dispose();
    _unitsController.dispose();
    super.dispose();
  }

  InputDecoration _modernInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _isEditing ? 'Edit MF Transaction' : 'New MF Transaction',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 24),
              DropdownButtonFormField<String>(
                value: _selectedFundName,
                decoration: _modernInputDecoration('Fund Name'),
                items: [
                  ..._fundNames.map(
                    (name) => DropdownMenuItem(value: name, child: Text(name)),
                  ),
                  DropdownMenuItem(
                    value: _addNewFundKey,
                    child: Row(
                      children: [
                        Icon(
                          Icons.add,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        const Text('Add New Fund...'),
                      ],
                    ),
                  ),
                ],
                onChanged: (value) {
                  if (value == _addNewFundKey) {
                    setState(() => _selectedFundName = null);
                    _addNewFund();
                  } else {
                    setState(() => _selectedFundName = value);
                  }
                },
                validator: (value) =>
                    value == null ? 'Please select a fund' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _amountController,
                      decoration: _modernInputDecoration('Amount'),
                      keyboardType: TextInputType.number,
                      validator: (v) => v!.isEmpty ? 'Req.' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _amountAfterChargesController,
                      decoration: _modernInputDecoration('After Charges'),
                      keyboardType: TextInputType.number,
                      validator: (v) => v!.isEmpty ? 'Req.' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _chargesController,
                decoration: _modernInputDecoration('Charges (Auto)'),
                readOnly: true,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _navController,
                      decoration: _modernInputDecoration('NAV'),
                      keyboardType: TextInputType.number,
                      validator: (v) => v!.isEmpty ? 'Req.' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _unitsController,
                      decoration: _modernInputDecoration('Units Allocated'),
                      keyboardType: TextInputType.number,
                      validator: (v) => v!.isEmpty ? 'Req.' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.surfaceVariant.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  title: Text(
                    _selectedDate == null
                        ? 'Select Date'
                        : DateFormat('dd MMM yyyy').format(_selectedDate!),
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: _selectDate,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _onRecord,
                  child: Text(
                    _isEditing ? 'Update Transaction' : 'Record Transaction',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddMfSnapshotSheet extends StatefulWidget {
  const _AddMfSnapshotSheet();
  @override
  State<_AddMfSnapshotSheet> createState() => _AddMfSnapshotSheetState();
}

class _AddMfSnapshotSheetState extends State<_AddMfSnapshotSheet> {
  final _formKey = GlobalKey<FormState>();
  final _firestoreService = FirestoreService();
  final _investedController = TextEditingController();
  final _currentController = TextEditingController();
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _onRecord() async {
    if (_formKey.currentState!.validate() && _selectedDate != null) {
      final snapshot = MfPortfolioSnapshot(
        id: '',
        investedValue: double.parse(_investedController.text),
        currentValue: double.parse(_currentController.text),
        date: Timestamp.fromDate(_selectedDate!),
      );
      await _firestoreService.addMfPortfolioSnapshot(snapshot);
      if (mounted) Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fill all fields.')));
    }
  }

  @override
  void dispose() {
    _investedController.dispose();
    _currentController.dispose();
    super.dispose();
  }

  InputDecoration _modernInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'New Portfolio Snapshot',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Record the total value of your portfolio on a specific date for the chart.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _investedController,
              decoration: _modernInputDecoration('Total Invested Value'),
              keyboardType: TextInputType.number,
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _currentController,
              decoration: _modernInputDecoration('Total Current Value'),
              keyboardType: TextInputType.number,
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.surfaceVariant.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                title: Text(
                  _selectedDate == null
                      ? 'Select Date'
                      : DateFormat('dd MMM yyyy').format(_selectedDate!),
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: _selectDate,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _onRecord,
                child: const Text('Record Snapshot'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
