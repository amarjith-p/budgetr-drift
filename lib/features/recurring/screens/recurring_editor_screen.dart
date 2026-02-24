import 'package:budget/core/services/category_service.dart';
import 'package:budget/core/widgets/glass_card.dart';
import 'package:budget/core/widgets/modern_app_bar.dart';
import 'package:budget/core/widgets/modern_dropdown.dart';
import 'package:budget/core/widgets/status_bottom_sheet.dart';
import 'package:budget/features/credit_tracker/models/credit_models.dart';
import 'package:budget/features/credit_tracker/services/credit_service.dart';
import 'package:budget/features/daily_expense/models/expense_models.dart';
import 'package:budget/features/daily_expense/services/expense_service.dart';
import 'package:budget/features/recurring/models/recurring_models.dart';
import 'package:budget/features/recurring/services/recurring_service.dart';
import 'package:budget/core/models/transaction_category_model.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import 'package:budget/features/settings/services/settings_service.dart';
import 'package:budget/features/dashboard/services/dashboard_service.dart';
import 'package:budget/features/settlement/services/settlement_service.dart';

class RecurringEditorScreen extends StatefulWidget {
  final RecurringPatternModel? pattern;
  const RecurringEditorScreen({super.key, this.pattern});

  @override
  State<RecurringEditorScreen> createState() => _RecurringEditorScreenState();
}

class _RecurringEditorScreenState extends State<RecurringEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  late TextEditingController _nameCtrl;
  late TextEditingController _amountCtrl;
  late TextEditingController _notesCtrl;
  late TextEditingController _websiteCtrl;

  // Config
  String _txnType = 'Expense';
  String _sourceType = 'Bank';
  String _sourceId = '';
  String _destId = '';

  // Variables (No default selection initially)
  String _bucket = '';
  String _category = '';
  String _subCategory = '';

  // Schedule
  String _frequency = 'Monthly';
  int _interval = 1;
  DateTime _startDate = DateTime.now();
  TimeOfDay _time = const TimeOfDay(hour: 9, minute: 0);
  bool _autoExecute = true;
  String _scheduleType = 'Fixed';
  int _smartWeek = 1;
  int _smartDay = 1;

  // Smart Configs
  bool _isVariable = false;
  bool _hasEndDate = false;
  DateTime? _endDate;
  bool _notifyBefore = true;

  // --- STATE VARIABLES ---
  List<String> _globalFallbackBuckets = [];
  bool _isMonthSettled = false;

  List<ExpenseAccountModel> _bankAccounts = [];
  List<CreditCardModel> _creditCards = [];
  List<TransactionCategoryModel> _categories = [];
  List<String> _subCategories = [];
  List<String> _realBuckets = [];

  final Map<int, String> _weekRanks = {
    1: 'First',
    2: 'Second',
    3: 'Third',
    4: 'Fourth',
    -1: 'Last'
  };
  final Map<int, String> _weekDays = {
    1: 'Monday',
    2: 'Tuesday',
    3: 'Wednesday',
    4: 'Thursday',
    5: 'Friday',
    6: 'Saturday',
    7: 'Sunday'
  };

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.pattern?.name ?? '');
    _amountCtrl =
        TextEditingController(text: widget.pattern?.amount.toString() ?? '');
    _notesCtrl = TextEditingController(text: widget.pattern?.notes ?? '');
    _websiteCtrl = TextEditingController(text: widget.pattern?.website ?? '');

    if (widget.pattern != null) {
      _loadExistingPattern(widget.pattern!);
    }
    _loadData();
  }

  void _loadExistingPattern(RecurringPatternModel p) {
    _txnType = p.type;
    _bucket = p.bucket;
    _category = p.category;
    _subCategory = p.subCategory;
    _frequency = p.frequency;
    _interval = p.interval;
    _startDate = p.startDate;
    _time = p.executionTime;
    _autoExecute = p.autoExecute;
    _scheduleType = p.scheduleType;
    _smartWeek = p.weekParam ?? 1;
    _smartDay = p.dayParam ?? 1;

    _isVariable = p.isVariable;
    _endDate = p.endDate;
    _hasEndDate = p.endDate != null;
    _notifyBefore = p.notifyBefore;

    if (p.website != null) {
      _websiteCtrl.text = p.website!;
    }

    if (p.sourceCardId != null) {
      _sourceType = 'Credit';
      _sourceId = p.sourceCardId!;
    } else {
      _sourceType = 'Bank';
      _sourceId = p.sourceAccountId ?? '';
    }
    _destId = p.destinationAccountId ?? '';
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    final banksFuture = GetIt.I<ExpenseService>().getAccounts().first;
    final cardsFuture = GetIt.I<CreditService>().getCreditCards().first;
    final catsFuture = GetIt.I<CategoryService>().getCategories().first;
    final configFuture = GetIt.I<SettingsService>().getPercentageConfig();

    final results =
        await Future.wait([banksFuture, cardsFuture, catsFuture, configFuture]);

    if (mounted) {
      final config = results[3] as dynamic;
      _globalFallbackBuckets =
          (config.categories as List).map((e) => e.name as String).toList();
      _globalFallbackBuckets.add('Out of Bucket');

      setState(() {
        _bankAccounts = results[0] as List<ExpenseAccountModel>;
        _creditCards = results[1] as List<CreditCardModel>;
        _categories = (results[2] as List<TransactionCategoryModel>)
            .where((c) =>
                c.type == (_txnType == 'Transfer' ? 'Expense' : _txnType))
            .toList();

        if (_sourceId.isEmpty) {
          if (_sourceType == 'Bank' && _bankAccounts.isNotEmpty)
            _sourceId = _bankAccounts.first.id;
          if (_sourceType == 'Credit' && _creditCards.isNotEmpty)
            _sourceId = _creditCards.first.id;
        }

        if (_category.isNotEmpty) {
          final match =
              _categories.where((c) => c.name == _category).firstOrNull;
          if (match != null) _subCategories = match.subCategories;
        }
      });

      await _updateBucketsForDate(_startDate);

      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateBucketsForDate(DateTime date) async {
    try {
      final isSettled = await GetIt.I<SettlementService>()
          .isMonthSettled(date.year, date.month);

      if (isSettled) {
        setState(() {
          _isMonthSettled = true;
          _realBuckets = ['Out of Bucket'];
          _bucket = 'Out of Bucket';
        });
        return;
      }

      final record = await GetIt.I<DashboardService>()
          .getRecordForMonth(date.year, date.month);

      List<String> newBuckets = [];
      if (record != null && record.bucketOrder.isNotEmpty) {
        newBuckets = List.from(record.bucketOrder);
        for (var key in record.allocations.keys) {
          if (!newBuckets.contains(key)) newBuckets.add(key);
        }
      } else if (record != null) {
        final sorted = record.allocations.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));
        newBuckets = sorted.map((e) => e.key).toList();
      } else {
        newBuckets = List.from(_globalFallbackBuckets);
      }

      if (!newBuckets.contains('Out of Bucket'))
        newBuckets.add('Out of Bucket');

      setState(() {
        _isMonthSettled = false;
        _realBuckets = newBuckets;

        if (_bucket.isNotEmpty && !_realBuckets.contains(_bucket)) {
          _bucket = '';
        }
      });
    } catch (e) {
      setState(() => _realBuckets = List.from(_globalFallbackBuckets));
    }
  }

  void _updateCategoriesForType(String type) {
    setState(() {
      _txnType = type;
      _category = '';
      _subCategory = '';
      _loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0D1B2A),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  ModernAppBar(
                    title: widget.pattern == null ? "Create Plan" : "Edit Plan",
                    subtitle: "AUTOMATION",
                    trailingIcon:
                        widget.pattern != null ? Icons.delete_outline : null,
                    onTrailingPressed: widget.pattern != null ? _delete : null,
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildHeaderInput(),
                            const SizedBox(height: 20),
                            _sectionHeader("CONFIGURATION"),
                            _buildTypeSelector(),
                            const SizedBox(height: 16),
                            _buildAccountSelectors(),
                            const SizedBox(height: 24),
                            if (_txnType != 'Transfer') ...[
                              _sectionHeader("DETAILS"),
                              _buildCategoryBuckets(),
                              const SizedBox(height: 24),
                            ],
                            _sectionHeader("SCHEDULE"),
                            _buildFeatureRichSchedule(),
                            const SizedBox(height: 24),
                            _sectionHeader("ADVANCED"),
                            _buildAdvancedSettings(),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  ),
                  _buildSaveButton(),
                ],
              ),
      ),
    );
  }

  Widget _labeledDropdown({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    final isValid = items.contains(value);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: Colors.white38,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.black26,
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: isValid ? value : null,
              dropdownColor: const Color(0xff1B263B),
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down, color: Colors.white54),
              hint: const Text(
                "Select...",
                style: TextStyle(color: Colors.white30),
              ),
              items: items.map((i) {
                return DropdownMenuItem<String>(
                  value: i,
                  child: Text(
                    i,
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAdvancedSettings() {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        TextFormField(
          controller: _websiteCtrl,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
              labelText: "Service Website (Optional)",
              labelStyle: TextStyle(color: Colors.white54),
              hintText: "netflix.com",
              hintStyle: TextStyle(color: Colors.white24),
              prefixIcon: Icon(Icons.public, color: Colors.white54),
              enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white10))),
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          title: const Text("Pre-Payment Notification",
              style: TextStyle(color: Colors.white)),
          subtitle: const Text("Remind me before executing",
              style: TextStyle(color: Colors.white38, fontSize: 12)),
          value: _notifyBefore,
          onChanged: (v) => setState(() => _notifyBefore = v),
          activeColor: const Color(0xFF00B4D8),
          contentPadding: EdgeInsets.zero,
        ),
        SwitchListTile(
          title: const Text("Auto-Stop Date",
              style: TextStyle(color: Colors.white)),
          subtitle: Text(
              _hasEndDate
                  ? "Stops on ${DateFormat('d MMM yyyy').format(_endDate ?? DateTime.now())}"
                  : "Runs indefinitely",
              style: const TextStyle(color: Colors.white38, fontSize: 12)),
          value: _hasEndDate,
          onChanged: (v) {
            setState(() => _hasEndDate = v);
            if (v && _endDate == null)
              _endDate = DateTime.now().add(const Duration(days: 365));
          },
          activeColor: Colors.redAccent,
          contentPadding: EdgeInsets.zero,
        ),
        if (_hasEndDate)
          InkWell(
              onTap: () async {
                final d = await showDatePicker(
                    context: context,
                    initialDate: _endDate ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2040),
                    builder: (context, child) =>
                        Theme(data: ThemeData.dark(), child: child!));
                if (d != null) setState(() => _endDate = d);
              },
              child: Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8)),
                  child: Row(children: [
                    const Icon(Icons.calendar_today,
                        size: 16, color: Colors.redAccent),
                    const SizedBox(width: 8),
                    Text(DateFormat('d MMMM yyyy').format(_endDate!),
                        style: const TextStyle(color: Colors.white))
                  ])))
      ]),
    );
  }

  Widget _buildAccountSelectors() {
    List<dynamic> destinationOptions = [];
    if (_txnType == 'Transfer') {
      destinationOptions = [..._bankAccounts, ..._creditCards];
      destinationOptions
          .removeWhere((item) => (item as dynamic).id == _sourceId);
    }

    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
              _txnType == 'Income'
                  ? "DEPOSIT TO"
                  : (_txnType == 'Transfer' ? "FROM ACCOUNT" : "PAY FROM"),
              style: const TextStyle(
                  color: Colors.white38,
                  fontSize: 10,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(children: [
            _miniTab(
                "Bank",
                _sourceType == 'Bank',
                () => setState(() {
                      _sourceType = 'Bank';
                      _sourceId = _bankAccounts.isNotEmpty
                          ? _bankAccounts.first.id
                          : '';
                    })),
            const SizedBox(width: 10),
            _miniTab(
                "Credit",
                _sourceType == 'Credit',
                () => setState(() {
                      _sourceType = 'Credit';
                      _sourceId =
                          _creditCards.isNotEmpty ? _creditCards.first.id : '';
                    })),
          ]),
          const SizedBox(height: 10),
          _dropdown(
              dataItems: _sourceType == 'Bank' ? _bankAccounts : _creditCards,
              value: _sourceId,
              onChanged: (v) => setState(() => _sourceId = v!)),
          if (_txnType == 'Transfer') ...[
            const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Icon(Icons.arrow_downward, color: Colors.white24)),
            const Text("TRANSFER TO",
                style: TextStyle(
                    color: Colors.white38,
                    fontSize: 10,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Builder(builder: (context) {
              List<DropdownMenuItem<String>> items = [];
              final banks =
                  _bankAccounts.where((a) => a.id != _sourceId).toList();
              if (banks.isNotEmpty) {
                items.add(const DropdownMenuItem(
                    enabled: false,
                    value: 'header_bank',
                    child: Text("BANK ACCOUNTS",
                        style: TextStyle(
                            color: Colors.white38,
                            fontSize: 10,
                            fontWeight: FontWeight.w900))));
                for (var b in banks) {
                  items.add(DropdownMenuItem(
                      value: b.id,
                      child: Row(children: [
                        const Icon(Icons.account_balance_rounded,
                            color: Color(0xFF4CC9F0), size: 16),
                        const SizedBox(width: 10),
                        Text(b.name,
                            style: const TextStyle(color: Colors.white))
                      ])));
                }
              }
              final cards =
                  _creditCards.where((c) => c.id != _sourceId).toList();
              if (cards.isNotEmpty) {
                items.add(const DropdownMenuItem(
                    enabled: false,
                    value: 'header_card',
                    child: Text("CREDIT CARDS",
                        style: TextStyle(
                            color: Colors.white38,
                            fontSize: 10,
                            fontWeight: FontWeight.w900))));
                for (var c in cards) {
                  items.add(DropdownMenuItem(
                      value: c.id,
                      child: Row(children: [
                        const Icon(Icons.credit_card_rounded,
                            color: Color(0xFFF72585), size: 16),
                        const SizedBox(width: 10),
                        Text(c.name,
                            style: const TextStyle(color: Colors.white))
                      ])));
                }
              }
              return _dropdown(
                  customItems: items,
                  value: _destId,
                  onChanged: (v) => setState(() => _destId = v!));
            }),
          ]
        ],
      ),
    );
  }

  Widget _dropdown(
      {List<dynamic>? dataItems,
      List<DropdownMenuItem<String>>? customItems,
      required String value,
      required Function(String?) onChanged}) {
    final List<DropdownMenuItem<String>> menuItems = customItems ??
        (dataItems ?? [])
            .map((dynamic i) => DropdownMenuItem<String>(
                value: i.id as String,
                child: Text(i.name as String,
                    style: const TextStyle(color: Colors.white))))
            .toList();
    final isValid = menuItems.any((item) => item.value == value);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
          color: Colors.black26, borderRadius: BorderRadius.circular(8)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: isValid ? value : null,
          dropdownColor: const Color(0xff1B263B),
          isExpanded: true, // Forces stretch
          hint: const Text("Select Account",
              style: TextStyle(color: Colors.white30)),
          items: menuItems,
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _miniTab(String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
            color: isActive ? Colors.white24 : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border:
                Border.all(color: isActive ? Colors.white : Colors.white12)),
        child: Text(label,
            style: TextStyle(
                color: isActive ? Colors.white : Colors.white54, fontSize: 12)),
      ),
    );
  }

  Widget _buildCategoryBuckets() {
    bool isExpense = _txnType == 'Expense';
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (isExpense) ...[
            if (_isMonthSettled)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                    color: Colors.orangeAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: Colors.orangeAccent.withOpacity(0.3))),
                child: Row(
                  children: [
                    const Icon(Icons.lock_clock,
                        color: Colors.orangeAccent, size: 16),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        "Month Settled: Buckets restricted.",
                        style:
                            TextStyle(color: Colors.orangeAccent, fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ),
            _labeledDropdown(
                label: "Budget Bucket",
                value: _bucket,
                items: _realBuckets,
                onChanged: (val) => setState(() => _bucket = val!)),
            const SizedBox(height: 16),
          ],
          _labeledDropdown(
              label: "Category",
              value: _category,
              items: _categories.map((c) => c.name).toList(),
              onChanged: (val) {
                setState(() {
                  _category = val!;
                  final cat = _categories.firstWhere((c) => c.name == val);
                  _subCategories = cat.subCategories;
                  _subCategory = '';
                });
              }),
          const SizedBox(height: 16),
          _labeledDropdown(
              label: "Sub-Category",
              value: _subCategory,
              items: _subCategories,
              onChanged: (val) => setState(() => _subCategory = val!)),
        ],
      ),
    );
  }

  Widget _buildFeatureRichSchedule() {
    final nextDates = GetIt.I<RecurringService>().getNext3Dates(_startDate,
        _frequency, _interval, _scheduleType, _smartWeek, _smartDay, _time);
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: ['Daily', 'Weekly', 'Monthly', 'Yearly'].map((f) {
              final isSelected = _frequency == f;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: f != 'Yearly' ? 8.0 : 0.0),
                  child: ChoiceChip(
                    label: Container(
                      alignment: Alignment.center,
                      child: Text(f),
                    ),
                    selected: isSelected,
                    selectedColor: const Color(0xFF00B4D8),
                    disabledColor: Colors.white10,
                    labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.white60,
                        fontWeight: FontWeight.bold),
                    onSelected: (val) {
                      if (val) setState(() => _frequency = f);
                    },
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    const Text("REPEAT EVERY",
                        style: TextStyle(
                            color: Colors.white38,
                            fontSize: 10,
                            fontWeight: FontWeight.bold)),
                    Row(children: [
                      IconButton(
                          icon: const Icon(Icons.remove_circle_outline,
                              color: Colors.white54),
                          onPressed: () => setState(() {
                                if (_interval > 1) _interval--;
                              })),
                      Text("$_interval",
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                      IconButton(
                          icon: const Icon(Icons.add_circle_outline,
                              color: Colors.white54),
                          onPressed: () => setState(() => _interval++))
                    ])
                  ])),
              Container(width: 1, height: 40, color: Colors.white10),
              const SizedBox(width: 16),
              Expanded(
                  child: InkWell(
                      onTap: () async {
                        final t = await showTimePicker(
                            context: context,
                            initialTime: _time,
                            builder: (context, child) =>
                                Theme(data: ThemeData.dark(), child: child!));
                        if (t != null) setState(() => _time = t);
                      },
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text("AT TIME",
                                style: TextStyle(
                                    color: Colors.white38,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(_time.format(context),
                                style: const TextStyle(
                                    color: Color(0xFF00B4D8),
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold))
                          ]))),
            ],
          ),
          const Divider(color: Colors.white10, height: 24),
          if (_frequency == 'Monthly' || _frequency == 'Yearly') ...[
            Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(8)),
                child: Row(children: [
                  _scheduleToggle('On Date', 'Fixed'),
                  _scheduleToggle('On Day', 'Smart')
                ])),
            const SizedBox(height: 16),
            if (_scheduleType == 'Fixed')
              InkWell(
                  onTap: () async {
                    final d = await showDatePicker(
                        context: context,
                        initialDate: _startDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                        builder: (context, child) =>
                            Theme(data: ThemeData.dark(), child: child!));
                    if (d != null) {
                      setState(() => _startDate = d);
                      await _updateBucketsForDate(d);
                    }
                  },
                  child: Row(children: [
                    const Icon(Icons.calendar_month, color: Colors.white54),
                    const SizedBox(width: 12),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("START DATE",
                              style: TextStyle(
                                  color: Colors.white38, fontSize: 10)),
                          Text(DateFormat('d MMMM yyyy').format(_startDate),
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 16))
                        ])
                  ]))
            else
              Row(children: [
                Expanded(
                    child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                            value: _smartWeek,
                            dropdownColor: const Color(0xff1B263B),
                            icon: const Icon(Icons.keyboard_arrow_down,
                                color: Colors.white54),
                            items: _weekRanks.entries
                                .map((e) => DropdownMenuItem(
                                    value: e.key,
                                    child: Text(e.value,
                                        style: const TextStyle(
                                            color: Colors.white))))
                                .toList(),
                            onChanged: (v) =>
                                setState(() => _smartWeek = v!)))),
                const SizedBox(width: 12),
                Expanded(
                    child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                            value: _smartDay,
                            dropdownColor: const Color(0xff1B263B),
                            icon: const Icon(Icons.keyboard_arrow_down,
                                color: Colors.white54),
                            items: _weekDays.entries
                                .map((e) => DropdownMenuItem(
                                    value: e.key,
                                    child: Text(e.value,
                                        style: const TextStyle(
                                            color: Colors.white))))
                                .toList(),
                            onChanged: (v) => setState(() => _smartDay = v!))))
              ]),
            const SizedBox(height: 20),
          ] else ...[
            InkWell(
                onTap: () async {
                  final d = await showDatePicker(
                      context: context,
                      initialDate: _startDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                      builder: (context, child) =>
                          Theme(data: ThemeData.dark(), child: child!));
                  if (d != null) {
                    setState(() => _startDate = d);
                    await _updateBucketsForDate(d);
                  }
                },
                child: Row(children: [
                  const Icon(Icons.calendar_month, color: Colors.white54),
                  const SizedBox(width: 12),
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("START DATE",
                            style:
                                TextStyle(color: Colors.white38, fontSize: 10)),
                        Text(DateFormat('d MMMM yyyy').format(_startDate),
                            style: const TextStyle(
                                color: Colors.white, fontSize: 16))
                      ])
                ])),
            const SizedBox(height: 20),
          ],
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white10)),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Row(children: [
                Icon(Icons.update, color: Color(0xFF00B4D8), size: 14),
                SizedBox(width: 6),
                Text("PROJECTED SCHEDULE",
                    style: TextStyle(
                        color: Color(0xFF00B4D8),
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1))
              ]),
              const SizedBox(height: 12),
              ...nextDates.asMap().entries.map((e) {
                final idx = e.key;
                final date = e.value;
                return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(children: [
                      Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                              color: idx == 0 ? Colors.white : Colors.white24,
                              shape: BoxShape.circle)),
                      const SizedBox(width: 12),
                      Text(DateFormat('EEE, d MMM yyyy').format(date),
                          style: TextStyle(
                              color: idx == 0 ? Colors.white : Colors.white60,
                              fontWeight: idx == 0
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              fontSize: 13)),
                      if (idx == 0) ...[
                        const SizedBox(width: 8),
                        Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                                color: Colors.white10,
                                borderRadius: BorderRadius.circular(4)),
                            child: const Text("Next Due",
                                style: TextStyle(
                                    fontSize: 8, color: Colors.white70)))
                      ]
                    ]));
              }).toList()
            ]),
          ),
          const SizedBox(height: 20),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text("Automatic Execution",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
              Text(
                  _isVariable
                      ? "Disabled (Variable Amount)"
                      : "Create transaction without asking",
                  style: TextStyle(
                      color: _isVariable ? Colors.orange : Colors.white38,
                      fontSize: 10))
            ]),
            Switch(
                value: _autoExecute && !_isVariable,
                activeColor: const Color(0xFF00B4D8),
                onChanged: _isVariable
                    ? null
                    : (v) => setState(() => _autoExecute = v))
          ]),
        ],
      ),
    );
  }

  Widget _scheduleToggle(String title, String value) {
    final isSelected = _scheduleType == value;
    return Expanded(
        child: GestureDetector(
            onTap: () => setState(() => _scheduleType = value),
            child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF00B4D8).withOpacity(0.2)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(6)),
                child: Text(title,
                    style: TextStyle(
                        color: isSelected
                            ? const Color(0xFF00B4D8)
                            : Colors.white54,
                        fontWeight: FontWeight.bold,
                        fontSize: 12)))));
  }

  Widget _sectionHeader(String title) => Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(title,
          style: const TextStyle(
              color: Colors.white38,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2)));

  Widget _buildHeaderInput() {
    return GlassCard(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          TextFormField(
              controller: _nameCtrl,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
              decoration: const InputDecoration(
                  hintText: "Plan Name (e.g. Rent)",
                  hintStyle: TextStyle(color: Colors.white24),
                  border: InputBorder.none),
              validator: (v) => v!.isEmpty ? "Required" : null),
          const Divider(color: Colors.white10),
          Row(children: [
            Expanded(
              child: _isVariable
                  ? const Text("VARIABLE AMOUNT",
                      style: TextStyle(
                          color: Colors.orange,
                          fontSize: 20,
                          fontWeight: FontWeight.bold))
                  : TextFormField(
                      controller: _amountCtrl,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(
                          color: Color(0xFF00B4D8),
                          fontSize: 28,
                          fontWeight: FontWeight.bold),
                      decoration: const InputDecoration(
                          prefixText: "₹ ",
                          hintText: "0.00",
                          border: InputBorder.none),
                      validator: (v) =>
                          !_isVariable && v!.isEmpty ? "Required" : null),
            ),
            Container(width: 1, height: 30, color: Colors.white10),
            const SizedBox(width: 10),
            Column(children: [
              const Text("VARIABLE",
                  style: TextStyle(fontSize: 8, color: Colors.white54)),
              Switch(
                  value: _isVariable,
                  activeColor: Colors.orange,
                  onChanged: (v) => setState(() {
                        _isVariable = v;
                        if (v) _amountCtrl.text = "0.00";
                      }))
            ])
          ])
        ]));
  }

  Widget _buildTypeSelector() {
    return Container(
        decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.05),
            borderRadius: BorderRadius.circular(8)),
        child: Row(
            children: ['Expense', 'Income', 'Transfer'].map((type) {
          final isSelected = _txnType == type;
          Color color = type == 'Expense'
              ? Colors.redAccent
              : (type == 'Income' ? Colors.greenAccent : Colors.orangeAccent);
          return Expanded(
              child: GestureDetector(
                  onTap: () => _updateCategoriesForType(type),
                  child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                          color: isSelected
                              ? color.withOpacity(0.2)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                          border: isSelected ? Border.all(color: color) : null),
                      alignment: Alignment.center,
                      child: Text(type.toUpperCase(),
                          style: TextStyle(
                              color: isSelected ? color : Colors.white54,
                              fontWeight: FontWeight.bold,
                              fontSize: 12)))));
        }).toList()));
  }

  Widget _buildSaveButton() {
    return Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
            color: Color(0xff0D1B2A),
            border: Border(top: BorderSide(color: Colors.white10))),
        child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00B4D8),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8))),
                onPressed: _save,
                child: const Text("SAVE PLAN",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)))));
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_sourceId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select an account")));
      return;
    }

    // [VALIDATION] Enforce fields based on transaction type
    if (_txnType == 'Expense') {
      if (_bucket.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Please select a Budget Bucket")));
        return;
      }
      if (_category.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Please select a Category")));
        return;
      }
    } else if (_txnType == 'Income') {
      if (_category.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Please select a Category")));
        return;
      }
    }

    final pattern = RecurringPatternModel(
      id: widget.pattern?.id ?? const Uuid().v4(),
      name: _nameCtrl.text,
      amount: double.tryParse(_amountCtrl.text) ?? 0.0,
      type: _txnType,
      category: _category,
      subCategory: _subCategory,
      bucket: _txnType == 'Expense' ? _bucket : '',
      notes: _notesCtrl.text,
      sourceAccountId: _sourceType == 'Bank' ? _sourceId : null,
      sourceCardId: _sourceType == 'Credit' ? _sourceId : null,
      destinationAccountId: _txnType == 'Transfer' ? _destId : null,
      frequency: _frequency,
      interval: _interval,
      startDate: _startDate,
      executionTime: _time,
      scheduleType: _scheduleType,
      weekParam: _smartWeek,
      dayParam: _smartDay,
      nextRunAt: widget.pattern?.nextRunAt ?? DateTime.now(),
      isActive: true,
      autoExecute: _autoExecute,
      isVariable: _isVariable,
      endDate: _hasEndDate ? _endDate : null,
      website: _websiteCtrl.text,
      notifyBefore: _notifyBefore,
    );

    try {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => const Center(child: CircularProgressIndicator()));
      await GetIt.I<RecurringService>().savePattern(pattern);
      if (mounted) {
        Navigator.pop(context);
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red));
    }
  }

  Future<void> _delete() async {
    showStatusSheet(
      context: context,
      title: "Delete Plan?",
      message:
          "This will stop future transactions. Past records created by this plan will remain.",
      icon: Icons.delete_sweep_sharp,
      color: Colors.redAccent,
      cancelButtonText: "Cancel",
      onCancel: () {},
      buttonText: "Delete",
      onDismiss: () async {
        await GetIt.I<RecurringService>().deletePattern(widget.pattern!.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Plan deleted successfully."),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      },
    );
  }
}
