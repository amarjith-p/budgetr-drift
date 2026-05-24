import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:math_expressions/math_expressions.dart';

// --- CORE IMPORTS ---
import '../../../core/widgets/modern_loader.dart';
import '../../../core/models/transaction_category_model.dart';
import '../../../core/services/category_service.dart';
import '../../../core/widgets/status_bottom_sheet.dart';
import '../../../core/design/budgetr_colors.dart';
import '../../../core/design/budgetr_styles.dart';

// --- FEATURE IMPORTS ---
import '../../settings/services/settings_service.dart';
import '../../dashboard/services/dashboard_service.dart';
import '../../settlement/services/settlement_service.dart';
import '../models/credit_models.dart';
import '../services/credit_service.dart';

class NewCreditTransactionScreen extends StatefulWidget {
  final CreditTransactionModel? transactionToEdit;
  final CreditCardModel? preSelectedCard;
  final bool isDuplicate; // [NEW] Added for duplicate logic

  const NewCreditTransactionScreen({
    super.key,
    this.transactionToEdit,
    this.preSelectedCard,
    this.isDuplicate = false, // [NEW] Default to false
  });

  @override
  State<NewCreditTransactionScreen> createState() =>
      _NewCreditTransactionScreenState();
}

class _NewCreditTransactionScreenState
    extends State<NewCreditTransactionScreen> {
  // --- CONTROLLERS & NODES ---
  final _amountCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  final FocusNode _amountNode = FocusNode();
  final FocusNode _notesNode = FocusNode();
  final LayerLink _layerLink = LayerLink();

  // --- LOGIC STATE ---
  bool _isLinked = false; // Locks Type & Card if true
  bool _attemptedSave = false;
  bool _isMonthSettled = false; // Closed Budget Check
  bool _isLoading = false;

  // KEYBOARD STATE
  bool _showCalculator = true;

  // SELECTIONS
  CreditCardModel? _selectedCard;

  // DATA
  List<CreditCardModel> _cards = [];
  List<String> _buckets = [];
  List<String> _globalFallbackBuckets = [];
  List<TransactionCategoryModel> _allCategories = [];

  // SUGGESTIONS
  List<String> _allNotes = [];
  List<String> _filteredNotes = [];

  // FIELDS
  DateTime _date = DateTime.now();
  String _type = 'Expense'; // 'Expense' or 'Income'
  String? _selectedBucket;
  String? _category;
  String? _subCategory;

  @override
  void initState() {
    super.initState();
    _loadData();

    // Keyboard Logic
    _notesNode.addListener(() {
      if (_notesNode.hasFocus) {
        setState(() => _showCalculator = false);
      }
    });

    _amountNode.addListener(() {
      if (_amountNode.hasFocus) {
        SystemChannels.textInput.invokeMethod('TextInput.hide');
        setState(() => _showCalculator = true);
      }
    });

    // Notes Filtering
    _notesCtrl.addListener(_onNoteChanged);

    // Auto-focus amount
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _switchToCalculator();
    });
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _notesCtrl.removeListener(_onNoteChanged);
    _notesCtrl.dispose();
    _amountNode.dispose();
    _notesNode.dispose();
    super.dispose();
  }

  void _onNoteChanged() {
    final text = _notesCtrl.text.toLowerCase();
    if (text.isEmpty) {
      setState(() => _filteredNotes = []);
      return;
    }
    setState(() {
      _filteredNotes = _allNotes
          .where((note) => note.toLowerCase().contains(text))
          .take(3)
          .toList();
    });
  }

  void _switchToCalculator() {
    _notesNode.unfocus();
    FocusScope.of(context).requestFocus(_amountNode);
    setState(() => _showCalculator = true);
  }

  // ===========================================================================
  // 1. DATA & LOGIC
  // ===========================================================================

  Future<void> _loadData() async {
    final cardsFuture = GetIt.I<CreditService>().getCreditCards().first;
    final catsFuture = GetIt.I<CategoryService>().getCategories().first;
    final configFuture = GetIt.I<SettingsService>().getPercentageConfig();
    final notesFuture = GetIt.I<CreditService>().getDistinctNotes();

    final results =
        await Future.wait([cardsFuture, catsFuture, configFuture, notesFuture]);

    if (mounted) {
      final config = results[2] as dynamic;
      _globalFallbackBuckets =
          (config.categories as List).map((e) => e.name as String).toList();
      _globalFallbackBuckets.add('Out of Bucket');

      setState(() {
        _cards = results[0] as List<CreditCardModel>;
        _allCategories = results[1] as List<TransactionCategoryModel>;
        _allNotes = results[3] as List<String>;

        if (widget.transactionToEdit != null) {
          final t = widget.transactionToEdit!;
          _amountCtrl.text =
              t.amount.toString().replaceAll(RegExp(r"([.]*0)(?!.*\d)"), "");
          _notesCtrl.text = t.notes;

          // [UPDATED] Clone logic for date
          if (widget.isDuplicate) {
            _date = DateTime.now();
          } else {
            _date = t.date;
          }

          _type = t.type;
          _selectedBucket = t.bucket;
          _category = t.category;
          _subCategory = t.subCategory;

          try {
            _selectedCard = _cards.firstWhere((c) => c.id == t.cardId);
          } catch (_) {
            _selectedCard = null;
          }

          if (t.linkedExpenseId != null && t.linkedExpenseId!.isNotEmpty) {
            _isLinked = !widget.isDuplicate; // [UPDATED] Free up if duplicating
          }
        } else {
          if (widget.preSelectedCard != null) {
            try {
              _selectedCard =
                  _cards.firstWhere((c) => c.id == widget.preSelectedCard!.id);
            } catch (_) {}
          }
        }
      });

      await _updateBucketsForDate(_date);
    }
  }

  Future<void> _updateBucketsForDate(DateTime date) async {
    try {
      final isSettled = await GetIt.I<SettlementService>()
          .isMonthSettled(date.year, date.month);

      if (isSettled) {
        setState(() {
          _isMonthSettled = true;
          _buckets = ['Out of Bucket'];
          _selectedBucket = 'Out of Bucket';
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

      if (!newBuckets.contains('Out of Bucket')) {
        newBuckets.add('Out of Bucket');
      }

      setState(() {
        _isMonthSettled = false;
        _buckets = newBuckets;
        if (_selectedBucket != null && !_buckets.contains(_selectedBucket)) {
          _selectedBucket = null;
        }
      });
    } catch (e) {
      setState(() => _buckets = List.from(_globalFallbackBuckets));
    }
  }

  Future<void> _save() async {
    setState(() => _attemptedSave = true);

    final double amount = double.tryParse(_amountCtrl.text) ?? 0.0;
    if (amount <= 0) {
      _showError("Amount must be greater than 0");
      return;
    }

    if (_selectedCard == null) {
      _showError("Please select a Credit Card");
      return;
    }

    if (_type == 'Expense' && _selectedBucket == null) {
      _showError("Please select a Bucket");
      return;
    }

    if (_category == null) {
      _showError("Please select a Category");
      return;
    }

    setState(() => _isLoading = true);

    try {
      // [UPDATED] Insert as new if it's a clone
      final bool isEditing =
          widget.transactionToEdit != null && !widget.isDuplicate;
      final String txnId = isEditing ? widget.transactionToEdit!.id : '';

      final txn = CreditTransactionModel(
        id: txnId,
        cardId: _selectedCard!.id,
        amount: amount,
        date: _date,
        bucket: _type == 'Expense'
            ? (_selectedBucket ?? 'Unallocated')
            : 'Unallocated',
        type: _type,
        category: _category!,
        subCategory: _subCategory ?? 'General',
        notes: _notesCtrl.text,
        linkedExpenseId: widget.transactionToEdit?.linkedExpenseId,
      );

      if (!isEditing) {
        await GetIt.I<CreditService>().addTransaction(txn);
      } else {
        await GetIt.I<CreditService>().updateTransaction(txn);
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) _showError(e.toString());
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: BudgetrColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
        context: context,
        initialDate: _date,
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
        builder: (c, child) => Theme(data: ThemeData.dark(), child: child!));

    if (d != null) {
      if (!mounted) return;
      final t = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(_date),
          builder: (c, child) => Theme(data: ThemeData.dark(), child: child!));

      if (t != null) {
        final newDate = DateTime(d.year, d.month, d.day, t.hour, t.minute);
        setState(() => _date = newDate);
        await _updateBucketsForDate(newDate);
      }
    }
  }

  // ===========================================================================
  // 2. UI BUILD
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    Color typeColor =
        _type == 'Expense' ? BudgetrColors.error : BudgetrColors.success;

    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: BudgetrColors.background,
      resizeToAvoidBottomInset: !_showCalculator,
      body: Column(
        children: [
          // 1. MANUALLY SPACED HEADER
          Container(
            padding: EdgeInsets.only(
                top: statusBarHeight + 40, left: 16, right: 16, bottom: 12),
            color: Colors.transparent,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.white54),
                ),
                Text(
                  // [UPDATED] Dynamic Title
                  (widget.transactionToEdit != null && !widget.isDuplicate)
                      ? "Edit Transaction"
                      : (widget.isDuplicate ? "Duplicate Entry" : "New Entry"),
                  style: BudgetrStyles.h3.copyWith(color: Colors.white70),
                ),
                _isLoading
                    ? const ModernLoader(size: 20)
                    : IconButton(
                        onPressed: _save,
                        icon: Icon(Icons.check, color: typeColor, size: 28),
                      ),
              ],
            ),
          ),

          // 2. MAIN CONTENT
          Expanded(
            child: GestureDetector(
              onTap: _switchToCalculator,
              child: Container(
                color: Colors.transparent,
                child: Column(
                  children: [
                    // Segment Control
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 8),
                      child: _buildSegmentControl(typeColor),
                    ),

                    // Hero Amount
                    _buildHeroAmount(typeColor),
                    const SizedBox(height: 12),

                    // Warnings
                    if (_isLinked)
                      _buildWarningBanner(
                          "Synced Transaction: Type and Card are locked.",
                          Icons.link,
                          Colors.blueAccent),
                    if (_isMonthSettled && _type == 'Expense')
                      _buildWarningBanner(
                          "Budget Closed: Expenses forced to 'Out of Bucket'.",
                          Icons.lock_clock,
                          Colors.orangeAccent),

                    // Scrollable Inputs
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            _buildMainInputCard(),
                            const SizedBox(height: 16),

                            // INLINE AUTOCOMPLETE SUGGESTIONS
                            if (_filteredNotes.isNotEmpty &&
                                _notesNode.hasFocus)
                              Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4),
                                decoration: BoxDecoration(
                                  color: BudgetrColors.cardSurface,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.white10),
                                ),
                                child: Column(
                                  children: _filteredNotes.map((note) {
                                    return InkWell(
                                      onTap: () {
                                        _notesCtrl.text = note;
                                        _filteredNotes.clear();
                                        _switchToCalculator();
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 12),
                                        child: Row(
                                          children: [
                                            const Icon(Icons.history,
                                                size: 16,
                                                color: Colors.white38),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Text(
                                                note,
                                                style: const TextStyle(
                                                    color: Colors.white70),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),

                            // Note Field
                            TextField(
                              controller: _notesCtrl,
                              focusNode: _notesNode,
                              style: BudgetrStyles.body
                                  .copyWith(color: Colors.white),
                              textCapitalization: TextCapitalization.sentences,
                              decoration: InputDecoration(
                                hintText: "Add a note...",
                                hintStyle: TextStyle(
                                    color: Colors.white.withOpacity(0.3)),
                                prefixIcon: Icon(Icons.edit_note,
                                    color: Colors.white.withOpacity(0.5)),
                                filled: true,
                                fillColor: BudgetrColors.cardSurface,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    borderSide: BorderSide.none),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 14),
                              ),
                              onSubmitted: (_) => _switchToCalculator(),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 3. KEYBOARD AREA
          if (_showCalculator)
            Container(
              decoration: BoxDecoration(
                color: const Color(0xff121212),
                border: Border(
                    top: BorderSide(color: Colors.white.withOpacity(0.05))),
              ),
              child: SafeArea(
                top: false,
                child: _EmbeddedCalculator(
                  controller: _amountCtrl,
                  typeColor: typeColor,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // --- WIDGET BUILDERS ---

  Widget _buildWarningBanner(String msg, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3))),
        child: Row(children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Expanded(
              child: Text(msg,
                  style: BudgetrStyles.caption
                      .copyWith(color: color, fontSize: 11))),
        ]),
      ),
    );
  }

  Widget _buildSegmentControl(Color activeColor) {
    return Container(
      height: 40,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
          color: BudgetrColors.cardSurface,
          borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          _buildSegment("Expense", Colors.redAccent, activeColor),
          _buildSegment("Income", Colors.greenAccent, activeColor,
              label: "Payment/Income"),
        ],
      ),
    );
  }

  Widget _buildSegment(String value, Color color, Color activeColor,
      {String? label}) {
    bool isSelected = _type == value;
    bool isDisabled = _isLinked;

    return Expanded(
      child: GestureDetector(
        onTap: isDisabled
            ? null
            : () => setState(() {
                  _type = value;
                  _category = null;
                  _subCategory = null;
                  if (_type == 'Income') _selectedBucket = null;
                }),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(label ?? value,
              style: TextStyle(
                  color: isDisabled
                      ? Colors.white24
                      : (isSelected ? color : Colors.white38),
                  fontWeight: FontWeight.bold,
                  fontSize: 13)),
        ),
      ),
    );
  }

  Widget _buildHeroAmount(Color typeColor) {
    bool hasError =
        _attemptedSave && (double.tryParse(_amountCtrl.text) ?? 0) <= 0;
    return GestureDetector(
      onTap: _switchToCalculator,
      child: Container(
        height: 85,
        color: Colors.transparent,
        // 1. ADDED HORIZONTAL PADDING: Keeps text from hitting the screen edges
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 32),
        alignment: Alignment.center,
        // 2. ADDED FITTEDBOX: Automatically scales down the content if it exceeds the container's width
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.center,
          child: IntrinsicWidth(
            child: IgnorePointer(
              ignoring: true,
              child: TextField(
                controller: _amountCtrl,
                focusNode: _amountNode,
                readOnly: true,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.w700,
                  color: hasError ? Colors.redAccent : typeColor,
                  height: 1.1,
                ),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: "0",
                  hintStyle: const TextStyle(color: Colors.white12),
                  prefixText: "₹ ",
                  prefixStyle: TextStyle(
                      fontSize: 48,
                      color: hasError ? Colors.redAccent : Colors.white24,
                      fontWeight: FontWeight.w300),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainInputCard() {
    // 1. Row: Date & Card
    bool cardError = _attemptedSave && _selectedCard == null;
    Widget row1 = Row(
      children: [
        Expanded(
          child: _buildInputTile(
            icon: Icons.calendar_today,
            label: "DATE",
            value: DateFormat('MMM dd, hh:mm a').format(_date),
            onTap: _pickDate,
          ),
        ),
        Container(width: 1, height: 40, color: Colors.white10),
        Expanded(
          child: _buildInputTile(
            icon: Icons.credit_card,
            label: "CARD",
            value: _selectedCard?.name ?? "Select Card",
            isActive: !_isLinked,
            valueColor: cardError ? BudgetrColors.error : null,
            onTap: () {
              if (_isLinked) return;
              _showSelectionSheet<CreditCardModel>(
                  "Select Card",
                  _cards,
                  _selectedCard,
                  (c) => "${c.bankName} - ${c.name}",
                  (v) => setState(() => _selectedCard = v));
            },
          ),
        ),
      ],
    );

    // 2. Row: Category
    bool catError = _attemptedSave && _category == null;
    Widget row2 = Row(
      children: [
        Expanded(
          child: _buildInputTile(
            icon: Icons.category_outlined,
            label: "CATEGORY",
            value: _category ?? "Select",
            valueColor: catError ? BudgetrColors.error : null,
            onTap: () {
              final relevantCats =
                  _allCategories.where((c) => c.type == _type).toList();
              _showSelectionSheet<TransactionCategoryModel>(
                  "Category",
                  relevantCats,
                  null,
                  (c) => c.name,
                  (v) => setState(() {
                        _category = v.name;
                        _subCategory = null;
                      }));
            },
          ),
        ),
        Expanded(child: Container()), // Spacer to match layout
      ],
    );

    // 3. Row: Bucket & SubCategory (Expense Only)
    Widget? row3;
    if (_type == 'Expense') {
      // SubCategory Logic
      String subVal = "---";
      bool subActive = _category != null;
      if (subActive) {
        try {
          final cat = _allCategories.firstWhere((c) => c.name == _category);
          if (cat.subCategories.isNotEmpty) {
            subVal = _subCategory ?? "Select";
          } else {
            subActive = false;
          }
        } catch (_) {
          subActive = false;
        }
      }

      bool bucketError = _attemptedSave && _selectedBucket == null;

      row3 = Row(
        children: [
          Expanded(
            child: _buildInputTile(
              icon: Icons.pie_chart_outline,
              label: "BUCKET",
              value: _selectedBucket ?? "Select",
              valueColor: bucketError ? BudgetrColors.error : null,
              onTap: () => _showSelectionSheet<String>(
                  "Bucket",
                  _buckets,
                  _selectedBucket,
                  (s) => s,
                  (v) => setState(() => _selectedBucket = v)),
            ),
          ),
          Container(width: 1, height: 40, color: Colors.white10),
          Expanded(
            child: _buildInputTile(
              icon: Icons.subdirectory_arrow_right,
              label: "SUB-CAT",
              value: subVal,
              isActive: subActive,
              onTap: () {
                final cat =
                    _allCategories.firstWhere((c) => c.name == _category);
                _showSelectionSheet<String>(
                    "Sub Category",
                    cat.subCategories,
                    _subCategory,
                    (s) => s,
                    (v) => setState(() => _subCategory = v));
              },
            ),
          ),
        ],
      );
    } else if (_category != null && _type == 'Income') {
      // Payment Subcategory Logic
      String subVal = "---";
      bool subActive = true;
      try {
        final cat = _allCategories.firstWhere((c) => c.name == _category);
        if (cat.subCategories.isNotEmpty) {
          subVal = _subCategory ?? "Select";
        } else {
          subActive = false;
        }
      } catch (_) {
        subActive = false;
      }

      if (subActive) {
        row3 = Row(
          children: [
            Expanded(
              child: _buildInputTile(
                icon: Icons.subdirectory_arrow_right,
                label: "SUB-CAT",
                value: subVal,
                onTap: () {
                  final cat =
                      _allCategories.firstWhere((c) => c.name == _category);
                  _showSelectionSheet<String>(
                      "Sub Category",
                      cat.subCategories,
                      _subCategory,
                      (s) => s,
                      (v) => setState(() => _subCategory = v));
                },
              ),
            ),
            Expanded(child: Container()),
          ],
        );
      }
    }

    return Container(
      decoration: BoxDecoration(
          color: BudgetrColors.cardSurface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ]),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        children: [
          row1,
          const Divider(height: 1, color: Colors.white10),
          row2,
          if (row3 != null) ...[
            const Divider(height: 1, color: Colors.white10),
            row3,
          ]
        ],
      ),
    );
  }

  Widget _buildInputTile({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
    bool isActive = true,
    Color? valueColor,
  }) {
    return InkWell(
      onTap: isActive ? onTap : null,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(children: [
              Icon(icon, size: 12, color: Colors.white38),
              const SizedBox(width: 4),
              Text(label,
                  style: const TextStyle(
                      color: Colors.white38,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5)),
            ]),
            const SizedBox(height: 4),
            Text(value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: isActive
                        ? (valueColor ?? Colors.white)
                        : Colors.white24,
                    fontWeight: FontWeight.w600,
                    fontSize: 14)),
          ],
        ),
      ),
    );
  }

  void _showSelectionSheet<T>(String title, List<T> items, T? selected,
      String Function(T) labelGen, Function(T) onSel) {
    _notesNode.unfocus();
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) => Container(
              height: MediaQuery.of(context).size.height * 0.7,
              decoration: const BoxDecoration(
                  color: BudgetrColors.cardSurface,
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(24))),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(2))),
                  Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(title, style: BudgetrStyles.h2)),
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (ctx, i) {
                        final item = items[i];
                        bool isSelected = false;
                        if (selected != null) {
                          if (item is CreditCardModel &&
                              selected is CreditCardModel)
                            isSelected = item.id == selected.id;
                          else
                            isSelected = item == selected;
                        }
                        return ListTile(
                          onTap: () {
                            onSel(item);
                            Navigator.pop(ctx);
                          },
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          tileColor: isSelected
                              ? BudgetrColors.accent.withOpacity(0.1)
                              : Colors.white.withOpacity(0.03),
                          leading: isSelected
                              ? const Icon(Icons.check_circle,
                                  color: BudgetrColors.accent)
                              : const Icon(Icons.circle_outlined,
                                  color: Colors.white24),
                          title: Text(labelGen(item),
                              style: TextStyle(
                                  color: isSelected
                                      ? BudgetrColors.accent
                                      : Colors.white70,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.w500)),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ));
  }
}

// =============================================================================
// INTERNAL CALCULATOR WIDGET (Compact Squircle Design)
// =============================================================================
class _EmbeddedCalculator extends StatelessWidget {
  final TextEditingController controller;
  final Color typeColor;

  const _EmbeddedCalculator({
    required this.controller,
    required this.typeColor,
  });

  void _onKey(String value) {
    final text = controller.text;
    final selection = controller.selection;
    int start = selection.start >= 0 ? selection.start : text.length;
    int end = selection.end >= 0 ? selection.end : text.length;
    final newText = text.replaceRange(start, end, value);
    controller.value = TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: start + value.length));
  }

  void _onBackspace() {
    final text = controller.text;
    final selection = controller.selection;
    int start = selection.start >= 0 ? selection.start : text.length;
    if (start > 0) {
      final newText = text.replaceRange(start - 1, start, '');
      controller.value = TextEditingValue(
          text: newText, selection: TextSelection.collapsed(offset: start - 1));
    }
  }

  void _onEquals() {
    String expression =
        controller.text.replaceAll('×', '*').replaceAll('÷', '/');
    try {
      Parser p = Parser();
      Expression exp = p.parse(expression);
      ContextModel cm = ContextModel();
      double result = exp.evaluate(EvaluationType.REAL, cm);
      controller.text =
          result.toStringAsFixed(2).replaceAll(RegExp(r"([.]*0)(?!.*\d)"), "");
      controller.selection = TextSelection.fromPosition(
          TextPosition(offset: controller.text.length));
    } catch (e) {/* ignore */}
  }

  @override
  Widget build(BuildContext context) {
    final operatorBgColor = typeColor.withOpacity(0.1);

    return Padding(
      padding: const EdgeInsets.only(left: 12, right: 12, top: 8, bottom: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(children: [
            _buildKey('C',
                textColor: Colors.redAccent,
                bgColor: Colors.redAccent.withOpacity(0.1),
                onTap: controller.clear),
            _buildKey('(', textColor: typeColor, bgColor: operatorBgColor),
            _buildKey(')', textColor: typeColor, bgColor: operatorBgColor),
            _buildKey('÷', textColor: typeColor, bgColor: operatorBgColor),
          ]),
          const SizedBox(height: 6),
          Row(children: [
            _buildKey('7'),
            _buildKey('8'),
            _buildKey('9'),
            _buildKey('×', textColor: typeColor, bgColor: operatorBgColor),
          ]),
          const SizedBox(height: 6),
          Row(children: [
            _buildKey('4'),
            _buildKey('5'),
            _buildKey('6'),
            _buildKey('-', textColor: typeColor, bgColor: operatorBgColor),
          ]),
          const SizedBox(height: 6),
          Row(children: [
            _buildKey('1'),
            _buildKey('2'),
            _buildKey('3'),
            _buildKey('+', textColor: typeColor, bgColor: operatorBgColor),
          ]),
          const SizedBox(height: 6),
          Row(children: [
            _buildKey('.', textColor: Colors.white54),
            _buildKey('0'),
            _buildBackspaceKey(),
            _buildEqualsKey(),
          ]),
        ],
      ),
    );
  }

  Widget _buildKey(String label,
      {Color? textColor, Color? bgColor, VoidCallback? onTap}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: Material(
          color: bgColor ?? Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: onTap ?? () => _onKey(label),
            borderRadius: BorderRadius.circular(12),
            splashColor: (textColor ?? Colors.white).withOpacity(0.1),
            highlightColor: Colors.transparent,
            child: Container(
              height: 48,
              alignment: Alignment.center,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: textColor ?? Colors.white.withOpacity(0.9),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackspaceKey() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: Material(
          color: Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: _onBackspace,
            borderRadius: BorderRadius.circular(12),
            splashColor: Colors.white.withOpacity(0.1),
            child: Container(
              height: 48,
              alignment: Alignment.center,
              child: const Icon(Icons.backspace_rounded,
                  size: 20, color: Colors.white54),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEqualsKey() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: Material(
          color: typeColor,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: _onEquals,
            borderRadius: BorderRadius.circular(12),
            splashColor: Colors.black.withOpacity(0.1),
            child: Container(
              height: 48,
              alignment: Alignment.center,
              child: const Text(
                '=',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
