import 'package:budget/core/widgets/status_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../../core/widgets/modern_loader.dart';
import '../../../core/widgets/calculator_keyboard.dart';
import '../../../core/models/transaction_category_model.dart';
import '../../../core/services/category_service.dart';
import '../../settings/services/settings_service.dart';
import '../../dashboard/services/dashboard_service.dart';
import '../../settlement/services/settlement_service.dart';
import '../../credit_tracker/models/credit_models.dart';
import '../../credit_tracker/services/credit_service.dart';
import '../../notifications/services/budget_notification_service.dart';
import '../models/expense_models.dart';
import '../services/expense_service.dart';

class AddExpenseTransactionSheet extends StatefulWidget {
  final ExpenseTransactionModel? txnToEdit;
  const AddExpenseTransactionSheet({super.key, this.txnToEdit});

  @override
  State<AddExpenseTransactionSheet> createState() =>
      _AddExpenseTransactionSheetState();
}

class _AddExpenseTransactionSheetState
    extends State<AddExpenseTransactionSheet> {
  final _formKey = GlobalKey<FormState>();

  final _amountCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  final FocusNode _amountNode = FocusNode();
  final FocusNode _notesNode = FocusNode();
  final GlobalKey _amountFieldKey = GlobalKey();
  final GlobalKey _notesFieldKey = GlobalKey();

  // Mode Toggle
  bool _isCreditEntry = false;
  // If true, we lock critical fields to prevent breaking the sync link
  bool _isLinkedTransaction = false;

  // Selected Data
  ExpenseAccountModel? _selectedAccount;
  ExpenseAccountModel? _toAccount;

  // For Credit Card Mode
  CreditCardModel? _selectedCreditCard;

  // Data Sources
  List<ExpenseAccountModel> _accounts = [];
  List<CreditCardModel> _creditCards = [];
  List<String> _buckets = [];
  List<String> _globalFallbackBuckets = [];
  List<TransactionCategoryModel> _allCategories = [];

  DateTime _date = DateTime.now();
  String? _selectedBucket;
  String _type = 'Expense';
  String? _category;
  String? _subCategory;

  bool _isLoading = false;
  bool _showCustomKeyboard = false;
  bool _systemKeyboardActive = false;
  bool _isMonthSettled = false;

  @override
  void initState() {
    super.initState();
    _loadData();
    _amountNode.addListener(() {
      if (_amountNode.hasFocus) {
        if (!_systemKeyboardActive) setState(() => _showCustomKeyboard = true);
        _scrollToField(_amountFieldKey);
      }
    });
    _notesNode.addListener(() {
      if (_notesNode.hasFocus) {
        setState(() => _showCustomKeyboard = false);
        _scrollToField(_notesFieldKey);
      }
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

  void _scrollToField(GlobalKey key) {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (key.currentContext != null) {
        Scrollable.ensureVisible(key.currentContext!,
            alignment: 0.5,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut);
      }
    });
  }

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

          // Detect Linked Transaction (Credit Entry or Synced Transfer)
          if (t.linkedCreditCardId != null &&
              t.linkedCreditCardId!.isNotEmpty) {
            _isCreditEntry = true;
            _isLinkedTransaction = true; // Lock Editing
            _selectedCreditCard = _creditCards.firstWhere(
                (c) => c.id == t.linkedCreditCardId,
                orElse: () => _creditCards.first);
          } else {
            _selectedAccount = _accounts.firstWhere((a) => a.id == t.accountId,
                orElse: () => _accounts.first);
          }

          if (t.type == 'Transfer Out' || t.type == 'Transfer In') {
            _type = 'Transfer';
            if (_isCreditEntry) {
              _selectedAccount = _accounts.firstWhere(
                  (a) => a.id == t.accountId,
                  orElse: () => _accounts.first);
            } else {
              _toAccount = _accounts.firstWhere(
                  (a) => a.id == t.transferAccountId,
                  orElse: () => _accounts.first);
            }
          } else {
            _type = t.type;
          }
        }
      });
      await _updateBucketsForDate(_date);
    }
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

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    ExpenseAccountModel? targetPoolAccount;
    if (_isCreditEntry ||
        (_type == 'Transfer' && _selectedCreditCard != null)) {
      try {
        targetPoolAccount = _accounts.firstWhere((a) =>
            a.bankName == 'Credit Card Pool Account' ||
            a.accountType == 'Credit Card');
      } catch (e) {
        showStatusSheet(
          context: context,
          title: "Credit Pool Account Not Found",
          message:
              "Please create a Credit Card Pool Account Through Accounts Page",
          icon: Icons.warning_amber_rounded,
          color: Colors.orangeAccent,
        );
        // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        //     content: Text(
        //         "Error: No 'Credit Card Pool Account' found. Please create one.")));
        return;
      }
    }

    if (!_isCreditEntry && _selectedAccount == null) return;
    if (_isCreditEntry && _selectedCreditCard == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select a Credit Card")));
      return;
    }

    if (_type == 'Transfer') {
      if (_selectedAccount == null) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Select From Account")));
        return;
      }
      if (_isCreditEntry && _selectedCreditCard == null) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Select Credit Card to pay")));
        return;
      }
      if (!_isCreditEntry && _toAccount == null) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Select Destination Account")));
        return;
      }
    }

    setState(() => _isLoading = true);
    try {
      final double amount = double.tryParse(_amountCtrl.text) ?? 0.0;
      bool isEditing = widget.txnToEdit != null;

      if (isEditing) {
        final newTxn = ExpenseTransactionModel(
          id: widget.txnToEdit!.id,
          accountId: _selectedAccount!.id, // Allows account switching
          amount: amount,
          date: Timestamp.fromDate(_date),
          bucket: _selectedBucket ?? 'Unallocated', // Allow bucket update
          type: _type, // Locked in UI if editing, but passed here
          category: _category!,
          subCategory: _subCategory ?? 'General',
          notes: _notesCtrl.text,
          linkedCreditCardId: widget.txnToEdit!.linkedCreditCardId,
          transferAccountId: widget.txnToEdit!.transferAccountId,
          transferAccountName: widget.txnToEdit!.transferAccountName,
          transferAccountBankName: widget.txnToEdit!.transferAccountBankName,
        );
        await ExpenseService().updateTransaction(newTxn);
      } else {
        // Handle Add (Standard Logic)
        if (_type == 'Transfer') {
          if (_isCreditEntry) {
            // Credit Card Payment (Account -> Pool)
            // We ONLY create the "Transfer Out" side. The Service creates "Transfer In".
            final transferOut = ExpenseTransactionModel(
              id: '',
              accountId: _selectedAccount!.id,
              amount: amount,
              date: Timestamp.fromDate(_date),
              bucket: 'Unallocated',
              type: 'Transfer Out',
              category: 'Transfer',
              subCategory: 'Credit Card Bill',
              notes: _notesCtrl.text,
              transferAccountId: targetPoolAccount!.id,
              transferAccountName: _selectedCreditCard!.name,
              transferAccountBankName: _selectedCreditCard!.bankName,
              linkedCreditCardId: _selectedCreditCard!.id,
            );

            // [CHANGED] Only add the source transaction. Service handles partner creation.
            await ExpenseService().addTransaction(transferOut);
            BudgetNotificationService()
                .checkAndTriggerNotification(transferOut);
          } else {
            // Standard Transfer (Account -> Account)
            // We ONLY create the "Transfer Out" side.
            final transferOut = ExpenseTransactionModel(
              id: '',
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

            // [CHANGED] Only add the source transaction. Service handles partner creation.
            await ExpenseService().addTransaction(transferOut);
            BudgetNotificationService()
                .checkAndTriggerNotification(transferOut);
          }
        } else {
          final bucketValue =
              _type == 'Expense' ? (_selectedBucket!) : 'Income';
          final finalAccountId =
              _isCreditEntry ? targetPoolAccount!.id : _selectedAccount!.id;
          final ccId = _isCreditEntry ? _selectedCreditCard!.id : null;

          final txn = ExpenseTransactionModel(
            id: '',
            accountId: finalAccountId,
            amount: amount,
            date: Timestamp.fromDate(_date),
            bucket: bucketValue,
            type: _type,
            category: _category!,
            subCategory: _subCategory ?? 'General',
            notes: _notesCtrl.text,
            linkedCreditCardId: ccId,
          );
          await ExpenseService().addTransaction(txn);
          BudgetNotificationService().checkAndTriggerNotification(txn);
        }
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final relevantCategories =
        _allCategories.where((c) => c.type == _type).toList();
    final categoryKeys = relevantCategories.map((e) => e.name).toList();
    List<String> subCategories = [];
    if (_category != null && _type != 'Transfer') {
      final cat = relevantCategories.firstWhere((c) => c.name == _category,
          orElse: () => relevantCategories.first);
      subCategories = cat.subCategories;
    }
    final bottomPadding =
        _showCustomKeyboard ? 0.0 : MediaQuery.of(context).viewInsets.bottom;

    // Check if we are editing
    final bool isEditing = widget.txnToEdit != null;

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xff0D1B2A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Flexible(
          fit: FlexFit.loose,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
                key: _formKey,
                child: Column(children: [
                  Center(
                      child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(2)))),
                  const SizedBox(height: 16),

                  // HEADER
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(isEditing ? "Edit Transaction" : "Log Transaction",
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold)),
                      // Credit Card Toggle
                      Opacity(
                        // Dim if disabled (Linked OR Editing)
                        opacity:
                            (_isLinkedTransaction || isEditing) ? 0.5 : 1.0,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                              color: _isCreditEntry
                                  ? Colors.redAccent.withOpacity(0.2)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: _isCreditEntry
                                      ? Colors.redAccent
                                      : Colors.white24)),
                          child: Row(
                            children: [
                              Icon(Icons.credit_card,
                                  size: 16,
                                  color: _isCreditEntry
                                      ? Colors.redAccent
                                      : Colors.white54),
                              const SizedBox(width: 8),
                              Text("Credit Card",
                                  style: TextStyle(
                                      color: _isCreditEntry
                                          ? Colors.redAccent
                                          : Colors.white54,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold)),
                              Switch(
                                value: _isCreditEntry,
                                // DISABLED ON EDIT to prevent complex state changes
                                onChanged: (_isLinkedTransaction || isEditing)
                                    ? null
                                    : (val) {
                                        setState(() {
                                          _isCreditEntry = val;
                                          if (_type == 'Transfer' &&
                                              _isCreditEntry) {
                                            _toAccount = null;
                                          }
                                        });
                                      },
                                activeColor: Colors.redAccent,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              )
                            ],
                          ),
                        ),
                      )
                    ],
                  ),

                  const SizedBox(height: 20),
                  if (_isLinkedTransaction)
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          color: Colors.blueAccent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8)),
                      child: const Row(
                        children: [
                          Icon(Icons.link, color: Colors.blueAccent, size: 20),
                          SizedBox(width: 12),
                          Expanded(
                              child: Text(
                                  "Linked Transaction: Type and Accounts are locked to maintain sync.",
                                  style: TextStyle(color: Colors.blueAccent)))
                        ],
                      ),
                    ),

                  // Type Buttons (Locked if linked, Transfer Disabled if Editing)
                  Opacity(
                    opacity: _isLinkedTransaction ? 0.5 : 1.0,
                    child: Row(children: [
                      Expanded(
                          child: _typeBtn("Expense", Colors.redAccent,
                              _isLinkedTransaction)),
                      const SizedBox(width: 8),
                      Expanded(
                          child: _typeBtn("Income", Colors.greenAccent,
                              _isLinkedTransaction)),
                      const SizedBox(width: 8),
                      // DISABLE TRANSFER BUTTON IF EDITING
                      Expanded(
                          child: _typeBtn("Transfer", Colors.blueAccent,
                              _isLinkedTransaction || isEditing)),
                    ]),
                  ),

                  const SizedBox(height: 24),

                  // ACCOUNTS (Locked if linked)
                  if (_type == 'Transfer') ...[
                    _buildSelectField<ExpenseAccountModel>(
                        "From Account",
                        _selectedAccount,
                        _accounts,
                        (a) => "${a.bankName} - ${a.name}",
                        (v) => setState(() => _selectedAccount = v),
                        validator: (v) => v == null ? "Required" : null,
                        isEnabled: !_isLinkedTransaction),
                    const SizedBox(height: 16),
                    if (_isCreditEntry)
                      _buildSelectField<CreditCardModel>(
                          "To Credit Card",
                          _selectedCreditCard,
                          _creditCards,
                          (c) => "${c.bankName} - ${c.name}",
                          (v) => setState(() => _selectedCreditCard = v),
                          validator: (v) => v == null ? "Select Card" : null,
                          isEnabled: !_isLinkedTransaction)
                    else
                      _buildSelectField<ExpenseAccountModel>(
                          "To Account",
                          _toAccount,
                          _accounts
                              .where((a) => a.id != _selectedAccount?.id)
                              .toList(),
                          (a) => "${a.bankName} - ${a.name}",
                          (v) => setState(() => _toAccount = v),
                          validator: (v) =>
                              v == null ? "Select Destination" : null,
                          isEnabled: !_isLinkedTransaction),
                  ] else ...[
                    if (_isCreditEntry)
                      _buildSelectField<CreditCardModel>(
                          "Use Credit Card",
                          _selectedCreditCard,
                          _creditCards,
                          (c) => "${c.bankName} - ${c.name}",
                          (v) => setState(() => _selectedCreditCard = v),
                          validator: (v) => v == null ? "Select Card" : null,
                          isEnabled: !_isLinkedTransaction)
                    else
                      _buildSelectField<ExpenseAccountModel>(
                          "Account",
                          _selectedAccount,
                          _accounts,
                          (a) => "${a.bankName} - ${a.name}",
                          (v) => setState(() => _selectedAccount = v),
                          validator: (v) => v == null ? "Required" : null,
                          isEnabled: !_isLinkedTransaction),
                  ],

                  const SizedBox(height: 16),

                  // Date (Editable)
                  InkWell(
                    onTap: _pickDate,
                    borderRadius: BorderRadius.circular(12),
                    child: InputDecorator(
                      decoration: _inputDeco("Date").copyWith(
                          suffixIcon: const Icon(Icons.calendar_today,
                              color: Colors.white54, size: 18)),
                      child: Text(DateFormat('dd MMM, hh:mm a').format(_date),
                          style: const TextStyle(color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Amount (Editable)
                  Container(
                    key: _amountFieldKey,
                    child: TextFormField(
                      controller: _amountCtrl,
                      focusNode: _amountNode,
                      readOnly: !_systemKeyboardActive,
                      showCursor: _systemKeyboardActive,
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold),
                      decoration:
                          _inputDeco("Amount").copyWith(prefixText: '₹ '),
                      onTap: () {
                        if (!_amountNode.hasFocus)
                          FocusScope.of(context).requestFocus(_amountNode);
                        setState(() {
                          _showCustomKeyboard = true;
                          _systemKeyboardActive = false;
                        });
                      },
                      validator: (v) {
                        if (v == null || v.isEmpty) return "Required";
                        if ((double.tryParse(v) ?? 0) <= 0) return "Invalid";
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Buckets & Categories
                  if (_type == 'Expense') ...[
                    _buildSelectField<String>(
                        "Bucket",
                        _selectedBucket,
                        _buckets,
                        (s) => s,
                        (v) => setState(() => _selectedBucket = v),
                        validator: (v) => v == null ? "Select Bucket" : null),
                    const SizedBox(height: 16),
                  ],

                  if (_type != 'Transfer') ...[
                    Row(children: [
                      Expanded(
                          child: _buildSelectField<String>(
                              "Category",
                              _category,
                              categoryKeys,
                              (s) => s,
                              (v) => setState(() {
                                    _category = v;
                                    _subCategory = null;
                                  }),
                              validator: (v) => v == null ? "Required" : null)),
                      if (_category != null && subCategories.isNotEmpty) ...[
                        const SizedBox(width: 12),
                        Expanded(
                            child: _buildSelectField<String>(
                                "Sub-Cat",
                                _subCategory,
                                subCategories,
                                (s) => s,
                                (v) => setState(() => _subCategory = v))),
                      ]
                    ]),
                    const SizedBox(height: 16),
                  ],

                  // Notes (Editable)
                  Container(
                    key: _notesFieldKey,
                    child: TextFormField(
                      controller: _notesCtrl,
                      focusNode: _notesNode,
                      style: const TextStyle(color: Colors.white),
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _save(),
                      decoration: _inputDeco("Notes (Optional)"),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Save Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _type == 'Transfer'
                            ? Colors.blueAccent
                            : (_isCreditEntry
                                ? Colors.blueAccent
                                : const Color(0xFF00B4D8)),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: ModernLoader(size: 24))
                          : Text(widget.txnToEdit != null ? "Update" : "Save",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                ])),
          ),
        ),
        if (_showCustomKeyboard)
          CalculatorKeyboard(
            onKeyPress: (v) =>
                CalculatorKeyboard.handleKeyPress(_amountCtrl, v),
            onBackspace: () => CalculatorKeyboard.handleBackspace(_amountCtrl),
            onEquals: () => CalculatorKeyboard.handleEquals(_amountCtrl),
            onClear: () => _amountCtrl.clear(),
            onClose: () {
              setState(() => _showCustomKeyboard = false);
              _amountNode.unfocus();
            },
            onNext: () {
              setState(() => _showCustomKeyboard = false);
              FocusScope.of(context).requestFocus(_notesNode);
            },
            onSwitchToSystem: () {
              setState(() {
                _showCustomKeyboard = false;
                _systemKeyboardActive = true;
              });
              _amountNode.unfocus();
              Future.delayed(const Duration(milliseconds: 50), () {
                FocusScope.of(context).requestFocus(_amountNode);
              });
            },
            onPrevious: () {
              setState(() => _showCustomKeyboard = false);
              _amountNode.unfocus();
            },
          )
      ]),
    );
  }

  // --- Helpers ---
  Future<void> _pickDate() async {
    _amountNode.unfocus();
    _notesNode.unfocus();
    setState(() => _showCustomKeyboard = false);
    final d = await showDatePicker(
        context: context,
        initialDate: _date,
        firstDate: DateTime(2020),
        lastDate: DateTime(2030),
        builder: (c, child) => Theme(data: ThemeData.dark(), child: child!));
    if (d != null) {
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

  InputDecoration _inputDeco(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
      filled: true,
      fillColor: Colors.white.withOpacity(0.05),
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.1))),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF00B4D8), width: 1.5)),
      errorStyle: const TextStyle(color: Colors.redAccent),
    );
  }

  Widget _typeBtn(String label, Color col, bool disabled) {
    bool isSel = _type == label;
    return GestureDetector(
      onTap: disabled
          ? null
          : () => setState(() {
                _type = label;
                _category = null;
                _subCategory = null;
                if ((_type == 'Income' && !_isCreditEntry) ||
                    _type == 'Transfer') _selectedBucket = null;
              }),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
            color: isSel ? col.withOpacity(0.2) : Colors.transparent,
            border: Border.all(color: isSel ? col : Colors.white12),
            borderRadius: BorderRadius.circular(8)),
        child: Center(
            child: Text(label,
                style: TextStyle(
                    color: isSel ? col : Colors.white54,
                    fontWeight: FontWeight.bold))),
      ),
    );
  }

  Widget _buildSelectField<T>(String label, T? val, List<T> items,
      String Function(T) labelGen, Function(T) onSel,
      {String? Function(T?)? validator, bool isEnabled = true}) {
    return FormField<T>(
      validator: validator,
      initialValue: val,
      builder: (FormFieldState<T> state) {
        return Opacity(
          opacity: isEnabled ? 1.0 : 0.5,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            InkWell(
              onTap: isEnabled
                  ? () {
                      _amountNode.unfocus();
                      _notesNode.unfocus();
                      setState(() => _showCustomKeyboard = false);
                      showSelectionSheet<T>(
                          context: context,
                          title: label,
                          items: items,
                          selectedItem: val,
                          labelBuilder: labelGen,
                          onSelect: (v) {
                            if (v != null) {
                              onSel(v);
                              state.didChange(v);
                            }
                          });
                    }
                  : null,
              borderRadius: BorderRadius.circular(12),
              child: InputDecorator(
                  decoration: _inputDeco(label).copyWith(
                      errorText: state.errorText,
                      suffixIcon: const Icon(Icons.keyboard_arrow_down,
                          color: Colors.white54)),
                  isEmpty: val == null,
                  child: Text(val != null ? labelGen(val) : '',
                      style: const TextStyle(color: Colors.white))),
            ),
          ]),
        );
      },
    );
  }

  void showSelectionSheet<T>(
      {required BuildContext context,
      required String title,
      required List<T> items,
      T? selectedItem,
      required String Function(T) labelBuilder,
      required Function(T) onSelect}) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return Container(
              constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.85),
              decoration: const BoxDecoration(
                  color: Color(0xff1B263B),
                  borderRadius:
                      BorderRadius.vertical(top: Radius.circular(24))),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const SizedBox(height: 16),
                Center(
                    child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(2)))),
                Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(title,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold))),
                const Divider(color: Colors.white10, height: 1),
                Flexible(
                    child: ListView.separated(
                        shrinkWrap: true,
                        padding: const EdgeInsets.all(16),
                        itemCount: items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final item = items[index];
                          final isSelected = item == selectedItem;
                          return ListTile(
                              onTap: () {
                                onSelect(item);
                                Navigator.pop(context);
                              },
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              tileColor: isSelected
                                  ? const Color(0xFF00B4D8).withOpacity(0.2)
                                  : Colors.transparent,
                              title: Text(labelBuilder(item),
                                  style: TextStyle(
                                      color: isSelected
                                          ? const Color(0xFF00B4D8)
                                          : Colors.white70,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal)),
                              trailing: isSelected
                                  ? const Icon(Icons.check,
                                      color: Color(0xFF00B4D8))
                                  : null);
                        })),
                SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
              ]));
        });
  }
}
