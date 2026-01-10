import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
import '../../credit_tracker/models/credit_models.dart';
import '../../credit_tracker/services/credit_service.dart';
import '../../notifications/services/budget_notification_service.dart';
import '../models/expense_models.dart';
import '../services/expense_service.dart';

class ModernExpenseSheet extends StatefulWidget {
  final ExpenseTransactionModel? txnToEdit;
  final ExpenseAccountModel? preSelectedAccount;
  const ModernExpenseSheet({
    super.key,
    this.txnToEdit,
    this.preSelectedAccount,
  });

  @override
  State<ModernExpenseSheet> createState() => _ModernExpenseSheetState();
}

class _ModernExpenseSheetState extends State<ModernExpenseSheet> {
  final _formKey = GlobalKey<FormState>();

  // --- CONTROLLERS ---
  final _amountCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final FocusNode _amountNode = FocusNode();
  final FocusNode _notesNode = FocusNode();

  // --- LOGIC STATE ---
  bool _isCreditEntry = false;
  bool _isLinkedTransaction = false;
  bool _attemptedSave = false;

  // Selections
  ExpenseAccountModel? _selectedAccount;
  ExpenseAccountModel? _toAccount;
  CreditCardModel? _selectedCreditCard;

  // Data
  List<ExpenseAccountModel> _accounts = [];
  List<CreditCardModel> _creditCards = [];
  List<String> _buckets = [];
  List<String> _globalFallbackBuckets = [];
  List<TransactionCategoryModel> _allCategories = [];

  // Fields
  DateTime _date = DateTime.now();
  String? _selectedBucket;
  String _type = 'Expense';
  String? _category;
  String? _subCategory;

  bool _isLoading = false;
  bool _isMonthSettled = false;
  bool _showCalculator = true;

  // External Account Constant
  final ExpenseAccountModel _externalAccount = ExpenseAccountModel(
    id: 'EXTERNAL_OPT',
    name: 'External Account',
    bankName: 'External',
    type: 'External',
    accountType: 'External',
    currentBalance: 0,
    createdAt: Timestamp.now(),
    dashboardOrder: 9999,
  );

  @override
  void initState() {
    super.initState();
    _loadData();

    _notesNode.addListener(() {
      setState(() => _showCalculator = !_notesNode.hasFocus);
    });
    _amountNode.addListener(() {
      if (_amountNode.hasFocus) setState(() => _showCalculator = true);
    });
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _notesCtrl.dispose();
    _amountNode.dispose();
    _notesNode.dispose();
    super.dispose();
  }

  // ===========================================================================
  // 1. DATA & LOGIC
  // ===========================================================================

  Future<void> _loadData() async {
    final accsFuture = ExpenseService().getAccounts().first;
    final creditFuture = CreditService().getCreditCards().first;
    final catsFuture = CategoryService().getCategories().first;
    final configFuture = SettingsService().getPercentageConfig();

    final results =
        await Future.wait([accsFuture, creditFuture, catsFuture, configFuture]);

    if (mounted) {
      final config = results[3] as dynamic;
      _globalFallbackBuckets =
          (config.categories as List).map((e) => e.name as String).toList();
      _globalFallbackBuckets.add('Out of Bucket');

      setState(() {
        _accounts = results[0] as List<ExpenseAccountModel>;
        // NOTE: We do not add _externalAccount here to avoid it showing up everywhere.
        // It is injected in the helper function `_getDisplayAccounts()`

        _creditCards = results[1] as List<CreditCardModel>;
        _allCategories = results[2] as List<TransactionCategoryModel>;

        if (widget.txnToEdit != null) {
          final t = widget.txnToEdit!;
          _amountCtrl.text =
              t.amount.toString().replaceAll(RegExp(r"([.]*0)(?!.*\d)"), "");
          _notesCtrl.text = t.notes;
          _date = t.date.toDate();
          _selectedBucket = t.bucket;
          _category = t.category;
          _subCategory = t.subCategory;
          _type = t.type;

          // Linked Credit Card
          if (t.linkedCreditCardId != null &&
              t.linkedCreditCardId!.isNotEmpty) {
            _isCreditEntry = true;
            _isLinkedTransaction = true;
            _selectedCreditCard = _creditCards.firstWhere(
                (c) => c.id == t.linkedCreditCardId,
                orElse: () => _creditCards.first);
          }

          if (t.type == 'Transfer Out' || t.type == 'Transfer In') {
            _type = 'Transfer';

            if (t.type == 'Transfer Out') {
              _selectedAccount = _accounts.firstWhere(
                  (a) => a.id == t.accountId,
                  orElse: () => _accounts.first);
              if (t.transferAccountId == null) {
                // Was External
                _toAccount = _externalAccount;
              } else {
                _toAccount = _accounts.firstWhere(
                    (a) => a.id == t.transferAccountId,
                    orElse: () => _accounts.first);
              }
            } else {
              _toAccount = _accounts.firstWhere((a) => a.id == t.accountId,
                  orElse: () => _accounts.first);
              if (t.transferAccountId == null) {
                // Was External
                _selectedAccount = _externalAccount;
              } else {
                _selectedAccount = _accounts.firstWhere(
                    (a) => a.id == t.transferAccountId,
                    orElse: () => _accounts.first);
              }
            }
          } else {
            _selectedAccount = _accounts.firstWhere((a) => a.id == t.accountId,
                orElse: () => _accounts.first);
          }
        } else {
          if (widget.preSelectedAccount != null) {
            try {
              _selectedAccount = _accounts
                  .firstWhere((a) => a.id == widget.preSelectedAccount!.id);
            } catch (_) {}
          }
        }
      });

      await _updateBucketsForDate(_date);
    }
  }

  /// Helper to get clean list of accounts for selection
  /// Filters out:
  /// 1. "Credit Card Pool Account" (Internal system account)
  /// 2. "External Account" (unless it's a Normal Transfer)
  List<ExpenseAccountModel> _getDisplayAccounts() {
    List<ExpenseAccountModel> filtered = _accounts.where((a) {
      // Filter out internal Credit Pool accounts
      return a.bankName != 'Credit Card Pool Account' &&
          a.accountType != 'Credit Card';
    }).toList();

    // Include External only for Normal Transfers
    if (_type == 'Transfer' && !_isCreditEntry) {
      filtered.add(_externalAccount);
    }

    return filtered;
  }

  Future<void> _updateBucketsForDate(DateTime date) async {
    try {
      final isSettled =
          await SettlementService().isMonthSettled(date.year, date.month);
      if (isSettled) {
        setState(() {
          _isMonthSettled = true;
          _buckets = ['Out of Bucket'];
          _selectedBucket = 'Out of Bucket';
        });
        return;
      }
      final record =
          await DashboardService().getRecordForMonth(date.year, date.month);
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
        _buckets = newBuckets;
        if (_selectedBucket != null && !_buckets.contains(_selectedBucket))
          _selectedBucket = null;
      });
    } catch (e) {
      setState(() => _buckets = List.from(_globalFallbackBuckets));
    }
  }

  // ===========================================================================
  // 2. VALIDATION & SAVE
  // ===========================================================================

  Future<void> _save() async {
    setState(() => _attemptedSave = true);

    // 1. Amount
    final double amount = double.tryParse(_amountCtrl.text) ?? 0.0;
    if (amount <= 0) {
      _showError("Amount must be greater than 0");
      return;
    }

    // 2. Source Selection Logic
    bool isCardExpense = _isCreditEntry && _type != 'Transfer';

    if (isCardExpense) {
      if (_selectedCreditCard == null) {
        _showError("Select a Credit Card");
        return;
      }
    } else {
      if (_selectedAccount == null) {
        _showError("Select a Source Account");
        return;
      }
    }

    // 3. Category
    if (_type != 'Transfer' && _category == null) {
      _showError("Select a Category");
      return;
    }

    // 4. Bucket
    if (_type == 'Expense' && _selectedBucket == null) {
      _showError("Select a Bucket");
      return;
    }

    // 5. Transfer Target
    if (_type == 'Transfer') {
      if (_isCreditEntry) {
        // Paying Bill: Target is Card
        if (_selectedCreditCard == null) {
          _showError("Select the Card to pay");
          return;
        }
      } else {
        // Normal Transfer: Target is Account
        if (_toAccount == null) {
          _showError("Select a Destination Account");
          return;
        }
        if (_toAccount!.id == _selectedAccount!.id) {
          _showError("Source and Destination cannot be the same");
          return;
        }
        if (_selectedAccount!.id == _externalAccount.id &&
            _toAccount!.id == _externalAccount.id) {
          _showError("Cannot transfer External to External");
          return;
        }
      }
    }

    ExpenseAccountModel? poolAccount;
    // Find pool account ID backend-only
    if (_isCreditEntry || (_type == 'Transfer' && _isCreditEntry)) {
      try {
        poolAccount = _accounts.firstWhere((a) =>
            a.bankName == 'Credit Card Pool Account' ||
            a.accountType == 'Credit Card');
      } catch (e) {
        /* ignore */
      }
    }

    setState(() => _isLoading = true);

    try {
      final bool isEditing = widget.txnToEdit != null;
      final String txnId = isEditing ? widget.txnToEdit!.id : '';

      ExpenseTransactionModel txn;

      if (_type == 'Transfer') {
        if (_isCreditEntry) {
          // paying credit card bill (Internal Bank -> Credit Pool)
          txn = ExpenseTransactionModel(
            id: txnId,
            accountId: _selectedAccount!.id, // Paying FROM Bank
            amount: amount,
            date: Timestamp.fromDate(_date),
            bucket: 'Unallocated',
            type: 'Transfer Out',
            category: 'Transfer',
            subCategory: 'Credit Card Bill',
            notes: _notesCtrl.text,
            transferAccountId: poolAccount?.id,
            transferAccountName: _selectedCreditCard!.name, // Name of the Card
            transferAccountBankName: _selectedCreditCard!.bankName,
            linkedCreditCardId: _selectedCreditCard!.id,
          );
        } else {
          // Account Transfer
          if (_toAccount!.id == _externalAccount.id) {
            txn = ExpenseTransactionModel(
              id: txnId,
              accountId: _selectedAccount!.id,
              amount: amount,
              date: Timestamp.fromDate(_date),
              bucket: 'Unallocated',
              type: 'Transfer Out',
              category: 'Transfer',
              subCategory: 'To External',
              notes: _notesCtrl.text,
              transferAccountId: null,
              transferAccountName: 'External Account',
              transferAccountBankName: 'External',
            );
          } else if (_selectedAccount!.id == _externalAccount.id) {
            txn = ExpenseTransactionModel(
              id: txnId,
              accountId: _toAccount!.id,
              amount: amount,
              date: Timestamp.fromDate(_date),
              bucket: 'Unallocated',
              type: 'Transfer In',
              category: 'Transfer',
              subCategory: 'From External',
              notes: _notesCtrl.text,
              transferAccountId: null,
              transferAccountName: 'External Account',
              transferAccountBankName: 'External',
            );
          } else {
            txn = ExpenseTransactionModel(
              id: txnId,
              accountId: _selectedAccount!.id,
              amount: amount,
              date: Timestamp.fromDate(_date),
              bucket: 'Unallocated',
              type: 'Transfer Out',
              category: 'Transfer',
              subCategory: 'General',
              notes: _notesCtrl.text,
              transferAccountId: _toAccount!.id,
              transferAccountName: _toAccount!.name,
              transferAccountBankName: _toAccount!.bankName,
            );
          }
        }
      } else {
        // Expense / Income
        final String finalAccountId =
            isCardExpense ? (poolAccount?.id ?? '') : _selectedAccount!.id;

        // Safety: ensure no external selection leaked into non-transfer
        if (_selectedAccount?.id == _externalAccount.id) {
          throw Exception(
              "External Account is only allowed for Transfers. Please change the Account.");
        }

        txn = ExpenseTransactionModel(
          id: txnId,
          accountId: finalAccountId,
          amount: amount,
          date: Timestamp.fromDate(_date),
          bucket: _type == 'Expense'
              ? (_selectedBucket ?? 'Unallocated')
              : 'Income',
          type: _type,
          category: _category!,
          subCategory: _subCategory ?? 'General',
          notes: _notesCtrl.text,
          linkedCreditCardId: _isCreditEntry ? _selectedCreditCard!.id : null,
        );
      }

      if (isEditing) {
        await ExpenseService().updateTransaction(txn);
      } else {
        await ExpenseService().addTransaction(txn);
      }

      if (mounted) {
        await BudgetNotificationService().checkAndTriggerNotification(txn);
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) _showError(e.toString());
    }
  }

  void _showError(String msg) {
    showStatusSheet(
      context: context,
      title: "Error",
      message: msg,
      icon: Icons.warning_amber_rounded,
      color: BudgetrColors.error,
    );
  }

  Future<void> _pickDate() async {
    _amountNode.unfocus();
    _notesNode.unfocus();
    final d = await showDatePicker(
        context: context,
        initialDate: _date,
        firstDate: DateTime(2020),
        lastDate: DateTime(2030),
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
  // 3. UI BUILD
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    Color typeColor = _type == 'Income'
        ? BudgetrColors.success
        : (_type == 'Transfer' ? BudgetrColors.accent : BudgetrColors.error);

    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final bool isEditing = widget.txnToEdit != null;

    return Padding(
      padding: EdgeInsets.only(bottom: keyboardHeight),
      child: Container(
        constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.95),
        decoration: const BoxDecoration(
          color: BudgetrColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 32,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2)),
              ),
            ),

            if (_isLinkedTransaction)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                    color: Colors.blueAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border:
                        Border.all(color: Colors.blueAccent.withOpacity(0.3))),
                child: Row(children: [
                  const Icon(Icons.link, color: Colors.blueAccent, size: 16),
                  const SizedBox(width: 8),
                  Text("Synced Transaction: Editing Partially restricted.",
                      style: BudgetrStyles.caption
                          .copyWith(color: Colors.blueAccent))
                ]),
              ),
            // [NEW] SETTLED WARNING
            if (_isMonthSettled && _type == 'Expense')
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                    color: Colors.orangeAccent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: Colors.orangeAccent.withOpacity(0.3))),
                child: Row(
                  children: [
                    const Icon(Icons.lock_clock,
                        color: Colors.orangeAccent, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Budget Closed: Expenses forced to 'Out of Bucket'.",
                        style: BudgetrStyles.caption
                            .copyWith(color: Colors.orangeAccent, fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ),

            // Segment Control
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                height: 36,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(10)),
                child: Row(
                  children: [
                    _buildSegment("Expense", Colors.redAccent, isEditing),
                    _buildSegment("Income", Colors.greenAccent, isEditing),
                    _buildSegment("Transfer", Colors.blueAccent, isEditing),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: _pickDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(20)),
                      child: Row(children: [
                        const Icon(Icons.calendar_today,
                            size: 14, color: Colors.white70),
                        const SizedBox(width: 6),
                        Text(DateFormat('MMM dd, hh:mm a').format(_date),
                            style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                                fontWeight: FontWeight.w600)),
                      ]),
                    ),
                  ),
                  if (!_isLinkedTransaction && widget.txnToEdit == null)
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isCreditEntry = !_isCreditEntry;
                          // When switching modes, validate external usage
                          if (_isCreditEntry) {
                            if (_type == 'Transfer') {
                              _toAccount = null; // Clear Target
                            }
                            // Clear Source/Target if they were External (Ext not allowed in Credit Mode)
                            if (_selectedAccount?.id == _externalAccount.id)
                              _selectedAccount = null;
                            if (_toAccount?.id == _externalAccount.id)
                              _toAccount = null;
                          }
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _isCreditEntry
                              ? Colors.redAccent.withOpacity(0.2)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: _isCreditEntry
                                  ? Colors.redAccent
                                  : Colors.white12),
                        ),
                        child: Row(children: [
                          Text("Credit Card",
                              style: TextStyle(
                                  color: _isCreditEntry
                                      ? Colors.redAccent
                                      : Colors.white38,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(width: 6),
                          Icon(
                              _isCreditEntry
                                  ? Icons.toggle_on
                                  : Icons.toggle_off,
                              color: _isCreditEntry
                                  ? Colors.redAccent
                                  : Colors.white38,
                              size: 20),
                        ]),
                      ),
                    ),
                ],
              ),
            ),

            _buildHeroAmount(typeColor),

            Flexible(
              fit: FlexFit.loose,
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      _buildMainGrid(),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _notesCtrl,
                        focusNode: _notesNode,
                        style: BudgetrStyles.body.copyWith(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: "Add a note...",
                          hintStyle:
                              TextStyle(color: Colors.white.withOpacity(0.3)),
                          prefixIcon: Icon(Icons.edit_note,
                              color: Colors.white.withOpacity(0.5)),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.05),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none),
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 16),
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            ),

            if (_showCalculator) ...[
              Container(color: Colors.white.withOpacity(0.05), height: 1),
              _EmbeddedCalculator(
                  controller: _amountCtrl, typeColor: typeColor),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: typeColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                      elevation: 4,
                    ),
                    child: _isLoading
                        ? const ModernLoader(size: 20)
                        : const Text("SAVE",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ),
            ] else
              Container(
                width: double.infinity,
                color: BudgetrColors.cardSurface,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                alignment: Alignment.centerRight,
                child: TextButton(
                    onPressed: () => FocusScope.of(context).unfocus(),
                    child: const Text("Done")),
              )
          ],
        ),
      ),
    );
  }

  // --- GRID ITEMS ---

  Widget _buildMainGrid() {
    List<Widget> items = [];

    // --- GRID ITEM 1: SOURCE ---
    bool isBillPayment = _type == 'Transfer' && _isCreditEntry;
    bool isCardExpense = _type != 'Transfer' && _isCreditEntry;

    // LABEL LOGIC
    String sourceLabel = "ACCOUNT";
    if (_type == 'Transfer') sourceLabel = "FROM";
    if (isBillPayment) sourceLabel = "PAY FROM";
    if (isCardExpense) sourceLabel = "PAY WITH";

    // VALUE LOGIC
    String sourceVal = "Select Account";
    if (isCardExpense) {
      sourceVal = _selectedCreditCard?.name ?? "Select Card";
    } else {
      sourceVal = _selectedAccount?.name ?? "Select Account";
    }

    // ICON LOGIC
    IconData sourceIcon =
        isCardExpense ? Icons.credit_card : Icons.account_balance;

    // ERROR LOGIC
    bool sourceError = _attemptedSave &&
        (isCardExpense
            ? _selectedCreditCard == null
            : _selectedAccount == null);

    items.add(_buildGridItem(
        label: sourceLabel,
        value: sourceVal,
        icon: sourceIcon,
        isActive: !_isLinkedTransaction,
        hasError: sourceError,
        onTap: () {
          if (_isLinkedTransaction) return;
          if (isCardExpense) {
            // Credit Expense -> Select Card
            _showSelectionSheet<CreditCardModel>(
                "Select Card",
                _creditCards,
                _selectedCreditCard,
                (c) => "${c.bankName} - ${c.name}",
                (v) => setState(() => _selectedCreditCard = v));
          } else {
            // Bank Account Selection
            // Use helper to filter out Pool account + optionally add External
            List<ExpenseAccountModel> options = _getDisplayAccounts();

            _showSelectionSheet<ExpenseAccountModel>(
                "Select Account",
                options,
                _selectedAccount,
                (a) => "${a.bankName} - ${a.name}",
                (v) => setState(() => _selectedAccount = v));
          }
        }));

    // --- GRID ITEM 2: TARGET / CATEGORY ---
    if (_type == 'Transfer') {
      String targetLabel = "TO";
      String targetVal = "Select Account";
      bool targetError = false;

      if (isBillPayment) {
        // Paying Bill -> Target is Card
        targetLabel = "TO CARD";
        targetVal = _selectedCreditCard?.name ?? "Select Card";
        targetError = _attemptedSave && _selectedCreditCard == null;
      } else {
        // Normal Transfer -> Target is Account
        targetVal = _toAccount?.name ?? "Select Account";
        targetError = _attemptedSave && _toAccount == null;
      }

      items.add(_buildGridItem(
          label: targetLabel,
          value: targetVal,
          icon: Icons.login,
          isActive: !_isLinkedTransaction,
          hasError: targetError,
          onTap: () {
            if (_isLinkedTransaction) return;
            if (isBillPayment) {
              // Target = Card
              _showSelectionSheet<CreditCardModel>(
                  "Select Card",
                  _creditCards,
                  _selectedCreditCard,
                  (c) => "${c.bankName} - ${c.name}",
                  (v) => setState(() => _selectedCreditCard = v));
            } else {
              // Target = Account
              final targets = _getDisplayAccounts()
                  .where((a) => a.id != _selectedAccount?.id)
                  .toList();

              // Remove External if Source is already External (No External -> External)
              if (_selectedAccount?.id == _externalAccount.id) {
                targets.removeWhere((e) => e.id == _externalAccount.id);
              }

              _showSelectionSheet<ExpenseAccountModel>(
                  "To Account",
                  targets,
                  _toAccount,
                  (a) => "${a.bankName} - ${a.name}",
                  (v) => setState(() => _toAccount = v));
            }
          }));
    } else {
      items.add(_buildGridItem(
          label: "CATEGORY",
          value: _category ?? "Select",
          icon: Icons.category_outlined,
          isActive: true,
          hasError: _attemptedSave && _category == null,
          onTap: () {
            final cats = _allCategories.where((c) => c.type == _type).toList();
            _showSelectionSheet<TransactionCategoryModel>(
                "Category",
                cats,
                null,
                (c) => c.name,
                (v) => setState(() {
                      _category = v.name;
                      _subCategory = null;
                    }));
          }));
    }

    // 3. Bucket
    bool bucketActive = _type == 'Expense';
    items.add(_buildGridItem(
        label: "BUCKET",
        value: bucketActive ? (_selectedBucket ?? "Select") : "---",
        icon: Icons.pie_chart_outline,
        isActive: bucketActive,
        hasError: _attemptedSave && bucketActive && _selectedBucket == null,
        onTap: () => _showSelectionSheet<String>(
            "Bucket",
            _buckets,
            _selectedBucket,
            (s) => s,
            (v) => setState(() => _selectedBucket = v))));

    // 4. SubCategory
    String subVal = "---";
    bool subActive = (_category != null && _type != 'Transfer');
    if (subActive) {
      try {
        final cat = _allCategories.firstWhere((c) => c.name == _category);
        if (cat.subCategories.isNotEmpty)
          subVal = _subCategory ?? "Select";
        else
          subActive = false;
      } catch (_) {
        subActive = false;
      }
    }

    items.add(_buildGridItem(
        label: "SUB-CATEGORY",
        value: subVal,
        icon: Icons.subdirectory_arrow_right,
        isActive: subActive,
        hasError: false,
        onTap: () {
          final cat = _allCategories.firstWhere((c) => c.name == _category);
          _showSelectionSheet<String>("Sub Category", cat.subCategories,
              _subCategory, (s) => s, (v) => setState(() => _subCategory = v));
        }));

    return LayoutBuilder(builder: (ctx, constr) {
      return Wrap(
        spacing: 12,
        runSpacing: 12,
        children: items
            .map((i) => SizedBox(width: (constr.maxWidth - 12) / 2, child: i))
            .toList(),
      );
    });
  }

  Widget _buildGridItem(
      {required String label,
      required String value,
      required IconData icon,
      required bool isActive,
      required bool hasError,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: isActive ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: isActive
              ? Colors.white.withOpacity(0.05)
              : Colors.white.withOpacity(0.02),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: hasError ? Colors.redAccent : Colors.transparent),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(icon,
                size: 14, color: isActive ? Colors.white38 : Colors.white12),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    fontSize: 10,
                    color: isActive ? Colors.white38 : Colors.white12,
                    fontWeight: FontWeight.bold))
          ]),
          const SizedBox(height: 6),
          Text(value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  color: isActive ? Colors.white : Colors.white24,
                  fontSize: 14,
                  fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }

  Widget _buildSegment(String label, Color color, bool isEditing) {
    bool isSelected = _type == label;

    bool wasOriginalTransfer = false;
    if (isEditing && widget.txnToEdit != null) {
      wasOriginalTransfer = widget.txnToEdit!.type.contains('Transfer');
    }

    bool isDisabled = _isLinkedTransaction ||
        (isEditing && label == 'Transfer' && !wasOriginalTransfer);

    return Expanded(
      child: GestureDetector(
        onTap: isDisabled
            ? null
            : () => setState(() {
                  _type = label;
                  _category = null;
                  _subCategory = null;
                  // IMPORTANT: Reset external logic when switching types
                  if (_type != 'Transfer') {
                    if (_selectedAccount?.id == _externalAccount.id)
                      _selectedAccount = null;
                    _toAccount = null;
                  }
                  if (_type != 'Expense') _selectedBucket = null;
                }),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border:
                isSelected ? Border.all(color: color.withOpacity(0.5)) : null,
          ),
          alignment: Alignment.center,
          child: Text(label,
              style: TextStyle(
                  color: isDisabled
                      ? Colors.white24
                      : (isSelected ? color : Colors.white38),
                  fontWeight: FontWeight.bold,
                  fontSize: 12)),
        ),
      ),
    );
  }

  Widget _buildHeroAmount(Color typeColor) {
    bool hasError =
        _attemptedSave && (double.tryParse(_amountCtrl.text) ?? 0) <= 0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: IntrinsicWidth(
        child: TextFormField(
          controller: _amountCtrl,
          focusNode: _amountNode,
          readOnly: true,
          showCursor: true,
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 44,
              fontWeight: FontWeight.bold,
              color: hasError ? Colors.redAccent : typeColor,
              height: 1.1),
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: "0",
            hintStyle: const TextStyle(color: Colors.white12),
            prefixText: "₹",
            prefixStyle: TextStyle(
                fontSize: 44,
                color: hasError ? Colors.redAccent : Colors.white24,
                fontWeight: FontWeight.w300),
            contentPadding: EdgeInsets.zero,
          ),
          onTap: () => FocusScope.of(context).requestFocus(_amountNode),
        ),
      ),
    );
  }

  void _showSelectionSheet<T>(String title, List<T> items, T? selected,
      String Function(T) labelGen, Function(T) onSel) {
    _amountNode.unfocus();
    _notesNode.unfocus();
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) => Container(
              height: MediaQuery.of(context).size.height * 0.65,
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
                      child: Text(title,
                          style:
                              BudgetrStyles.h2.copyWith(color: Colors.white))),
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (ctx, i) {
                        final item = items[i];
                        bool isSelected = false;
                        if (selected != null) {
                          if (item is ExpenseAccountModel &&
                              selected is ExpenseAccountModel)
                            isSelected = item.id == selected.id;
                          else if (item is CreditCardModel &&
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
                              borderRadius: BorderRadius.circular(16)),
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

class _EmbeddedCalculator extends StatelessWidget {
  final TextEditingController controller;
  final Color typeColor;
  const _EmbeddedCalculator(
      {required this.controller, required this.typeColor});

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
    } catch (e) {
      /* ignore */
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xff121212),
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(children: [
            _key('C', color: Colors.redAccent, onTap: controller.clear),
            _key('(', color: Colors.white54),
            _key(')', color: Colors.white54),
            _key('÷', color: Colors.blueAccent)
          ]),
          Row(children: [
            _key('7'),
            _key('8'),
            _key('9'),
            _key('×', color: Colors.blueAccent)
          ]),
          Row(children: [
            _key('4'),
            _key('5'),
            _key('6'),
            _key('-', color: Colors.blueAccent)
          ]),
          Row(children: [
            _key('1'),
            _key('2'),
            _key('3'),
            _key('+', color: Colors.blueAccent)
          ]),
          Row(children: [
            _key('.', color: Colors.white70),
            _key('0'),
            _backspaceKey(),
            _equalsKey(typeColor)
          ]),
        ],
      ),
    );
  }

  Widget _key(String label, {Color? color, VoidCallback? onTap}) {
    return Expanded(
        child: InkWell(
            onTap: onTap ?? () => _onKey(label),
            borderRadius: BorderRadius.circular(8),
            child: Container(
                height: 42,
                alignment: Alignment.center,
                margin: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8)),
                child: Text(label,
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        color: color ?? Colors.white)))));
  }

  Widget _backspaceKey() {
    return Expanded(
        child: InkWell(
            onTap: _onBackspace,
            borderRadius: BorderRadius.circular(8),
            child: Container(
                height: 42,
                margin: const EdgeInsets.all(2),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.backspace_outlined,
                    size: 18, color: Colors.white54))));
  }

  Widget _equalsKey(Color color) {
    return Expanded(
        child: InkWell(
            onTap: _onEquals,
            borderRadius: BorderRadius.circular(8),
            child: Container(
                height: 42,
                margin: const EdgeInsets.all(2),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8)),
                child: Text('=',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: color)))));
  }
}
