import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:math_expressions/math_expressions.dart';

// --- CORE IMPORTS ---
import '../../../core/widgets/modern_loader.dart';
import '../../../core/models/transaction_category_model.dart';
import '../../../core/services/category_service.dart';
import '../../../core/design/budgetr_colors.dart';
import '../../../core/design/budgetr_styles.dart';

// --- FEATURE IMPORTS ---
import '../../settings/services/settings_service.dart';
import '../../dashboard/services/dashboard_service.dart';
import '../../settlement/services/settlement_service.dart';
import '../../credit_tracker/models/credit_models.dart';
import '../../credit_tracker/services/credit_service.dart';
import '../../credit_tracker/utils/billing_cycle_utils.dart';
import '../models/expense_models.dart';
import '../services/expense_service.dart';

class NewExpenseScreen extends StatefulWidget {
  final ExpenseTransactionModel? txnToEdit;
  final ExpenseAccountModel? preSelectedAccount;
  final DateTime? initialDate;

  const NewExpenseScreen({
    super.key,
    this.txnToEdit,
    this.preSelectedAccount,
    this.initialDate,
  });

  @override
  State<NewExpenseScreen> createState() => _NewExpenseScreenState();
}

class _NewExpenseScreenState extends State<NewExpenseScreen> {
  // --- CONTROLLERS & NODES ---
  final _amountCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  final FocusNode _amountNode = FocusNode();
  final FocusNode _notesNode = FocusNode();
  final LayerLink _layerLink = LayerLink();

  // --- LOGIC STATE ---
  bool _isCreditEntry = false;
  bool _isLinkedTransaction = false;
  bool _attemptedSave = false;
  bool _isLoading = false;
  bool _isMonthSettled = false;

  // KEYBOARD STATE
  bool _showCalculator = true;

  // SELECTIONS
  ExpenseAccountModel? _selectedAccount;
  ExpenseAccountModel? _toAccount;
  CreditCardModel? _selectedCreditCard;

  // DATA
  List<ExpenseAccountModel> _accounts = [];
  List<CreditCardModel> _creditCards = [];
  List<String> _buckets = [];
  List<String> _globalFallbackBuckets = [];
  List<TransactionCategoryModel> _allCategories = [];

  // SUGGESTIONS LOGIC
  List<String> _allNotes = [];
  List<String> _filteredNotes = [];

  // FIELDS
  DateTime _date = DateTime.now();
  String? _selectedBucket;
  String _type = 'Expense';
  String? _category;
  String? _subCategory;

  // EXTERNAL ACCOUNT
  final ExpenseAccountModel _externalAccount = ExpenseAccountModel(
    id: 'EXTERNAL_OPT',
    name: 'External Account',
    bankName: 'External',
    type: 'External',
    accountType: 'External',
    currentBalance: 0,
    createdAt: DateTime.timestamp(),
    dashboardOrder: 9999,
  );

  @override
  void initState() {
    super.initState();
    if (widget.initialDate != null) {
      _date = widget.initialDate!;
    }
    _loadData();

    // Listeners for Keyboard Toggle
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

    // Notes filtering listener
    _notesCtrl.addListener(_onNoteChanged);
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
          .take(3) // Limit to 3 suggestions to save space
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
    final accsFuture = GetIt.I<ExpenseService>().getAccounts().first;
    final creditFuture = GetIt.I<CreditService>().getCreditCards().first;
    final catsFuture = GetIt.I<CategoryService>().getCategories().first;
    final configFuture = GetIt.I<SettingsService>().getPercentageConfig();
    final notesFuture = GetIt.I<ExpenseService>().getDistinctNotes();

    final results = await Future.wait(
        [accsFuture, creditFuture, catsFuture, configFuture, notesFuture]);

    if (mounted) {
      final config = results[3] as dynamic;
      _globalFallbackBuckets =
          (config.categories as List).map((e) => e.name as String).toList();
      _globalFallbackBuckets.add('Out of Bucket');

      setState(() {
        _accounts = results[0] as List<ExpenseAccountModel>;
        _creditCards = results[1] as List<CreditCardModel>;
        _allCategories = results[2] as List<TransactionCategoryModel>;
        _allNotes = results[4] as List<String>;

        if (widget.txnToEdit != null) {
          final t = widget.txnToEdit!;
          _amountCtrl.text =
              t.amount.toString().replaceAll(RegExp(r"([.]*0)(?!.*\d)"), "");
          _notesCtrl.text = t.notes;
          _date = t.date;
          _selectedBucket = t.bucket;
          _category = t.category;
          _subCategory = t.subCategory;
          _type = t.type;

          if (t.linkedCreditCardId != null &&
              t.linkedCreditCardId!.isNotEmpty) {
            _isCreditEntry = true;
            _isLinkedTransaction = true;
            _selectedCreditCard = _creditCards.firstWhere(
                (c) => c.id == t.linkedCreditCardId,
                orElse: () => _creditCards.first);
            if (t.accountId.isNotEmpty) {
              try {
                _selectedAccount = _accounts.firstWhere(
                    (a) => a.id == t.accountId,
                    orElse: () => _accounts.first);
              } catch (_) {}
            }
          } else {
            if (t.accountId.isNotEmpty) {
              try {
                _selectedAccount = _accounts.firstWhere(
                    (a) => a.id == t.accountId,
                    orElse: () => _accounts.first);
              } catch (_) {}
            }
          }

          if (t.type == 'Transfer Out' || t.type == 'Transfer In') {
            _type = 'Transfer';
            if (t.type == 'Transfer Out') {
              if (!_isCreditEntry) {
                if (t.transferAccountId == null) {
                  _toAccount = _externalAccount;
                } else {
                  try {
                    _toAccount = _accounts.firstWhere(
                        (a) => a.id == t.transferAccountId,
                        orElse: () => _accounts.first);
                  } catch (_) {}
                }
              }
            } else {
              try {
                _toAccount = _accounts.firstWhere((a) => a.id == t.accountId,
                    orElse: () => _accounts.first);
              } catch (_) {}
              if (t.transferAccountId == null) {
                _selectedAccount = _externalAccount;
              } else {
                try {
                  _selectedAccount = _accounts.firstWhere(
                      (a) => a.id == t.transferAccountId,
                      orElse: () => _accounts.first);
                } catch (_) {}
              }
            }
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

  List<ExpenseAccountModel> _getDisplayAccounts() {
    List<ExpenseAccountModel> filtered = _accounts.where((a) {
      return a.bankName != 'Credit Card Pool Account' &&
          a.accountType != 'Credit Card';
    }).toList();
    if (_type == 'Transfer' && !_isCreditEntry) {
      filtered.add(_externalAccount);
    }
    return filtered;
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

    if (_type != 'Transfer' && _category == null) {
      _showError("Select a Category");
      return;
    }
    if (_type == 'Expense' && _selectedBucket == null) {
      _showError("Select a Bucket");
      return;
    }

    if (_type == 'Transfer') {
      if (_isCreditEntry) {
        if (_selectedCreditCard == null) {
          _showError("Select the Card to pay");
          return;
        }
      } else {
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

    setState(() => _isLoading = true);
    try {
      final bool isEditing = widget.txnToEdit != null;
      final String txnId = isEditing ? widget.txnToEdit!.id : '';

      ExpenseTransactionModel txn;
      String? finalCreditCategory;
      String? finalCreditSubCategory;

      if (_type == 'Transfer') {
        if (_isCreditEntry) {
          if (!isEditing && _selectedCreditCard != null) {
            final isRepaymentWindow =
                _checkIfRepaymentWindow(_date, _selectedCreditCard!);
            if (isRepaymentWindow) {
              setState(() => _isLoading = false);
              final bool isRepayment = await _askRepaymentConfirmation();
              if (isRepayment) {
                finalCreditCategory = 'Repayment';
                finalCreditSubCategory = 'Bill Payment';
              }
              setState(() => _isLoading = true);
            }
          }
          txn = ExpenseTransactionModel(
            id: txnId,
            accountId: _selectedAccount!.id,
            amount: amount,
            date: _date,
            bucket: 'Unallocated',
            type: 'Transfer Out',
            category: 'Transfer',
            subCategory: 'Credit Card Bill',
            notes: _notesCtrl.text,
            transferAccountId: _selectedCreditCard!.id,
            transferAccountName: _selectedCreditCard!.name,
            transferAccountBankName: _selectedCreditCard!.bankName,
            linkedCreditCardId: _selectedCreditCard!.id,
          );
        } else {
          if (_toAccount!.id == _externalAccount.id) {
            txn = ExpenseTransactionModel(
              id: txnId,
              accountId: _selectedAccount!.id,
              amount: amount,
              date: _date,
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
              date: _date,
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
              date: _date,
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
        final String finalAccountId = isCardExpense ? '' : _selectedAccount!.id;
        if (!isCardExpense && _selectedAccount?.id == _externalAccount.id) {
          throw Exception("External Account is only allowed for Transfers.");
        }
        txn = ExpenseTransactionModel(
          id: txnId,
          accountId: finalAccountId,
          amount: amount,
          date: _date,
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
        await GetIt.I<ExpenseService>().updateTransaction(txn);
      } else {
        await GetIt.I<ExpenseService>().addTransaction(txn,
            creditCategoryOverride: finalCreditCategory,
            creditSubCategoryOverride: finalCreditSubCategory);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) _showError(e.toString());
    }
  }

  bool _checkIfRepaymentWindow(DateTime date, CreditCardModel card) {
    final lastStatement =
        BillingCycleUtils.getLastBillDate(date, card.billDate);
    final dueDate =
        BillingCycleUtils.getDueDateForStatement(lastStatement, card.dueDate);
    return date.isAfter(lastStatement) &&
        !date.isAfter(dueDate.add(const Duration(seconds: 1)));
  }

  Future<bool> _askRepaymentConfirmation() async {
    return await showModalBottomSheet<bool>(
            context: context,
            backgroundColor: Colors.transparent,
            builder: (context) => Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: Color(0xff1B263B),
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(2))),
                      const SizedBox(height: 24),
                      const Icon(Icons.receipt_long_rounded,
                          size: 48, color: BudgetrColors.accent),
                      const SizedBox(height: 16),
                      const Text("Mark as Bill Repayment?",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      const Text(
                        "This transfer falls within the payment period for this card. Should this be treated as a Bill Repayment in the Credit Tracker?",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              style: TextButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                foregroundColor: Colors.white60,
                              ),
                              child: const Text("No, Just Transfer"),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => Navigator.pop(context, true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: BudgetrColors.accent,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Text("Yes, Repayment"),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: MediaQuery.of(context).padding.bottom),
                    ],
                  ),
                )) ??
        false;
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
  // 3. UI BUILD - RESTORED CARD DESIGN & FIXED AUTOCOMPLETE
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    Color typeColor = _type == 'Income'
        ? BudgetrColors.success
        : (_type == 'Transfer' ? BudgetrColors.accent : BudgetrColors.error);

    // Get exact status bar height
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
                  widget.txnToEdit != null ? "Edit Transaction" : "New Entry",
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

          // 2. MAIN CONTENT (EXPANDED)
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

                    // Scrollable Inputs
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            _buildMainInputCard(),
                            const SizedBox(height: 16),

                            // --- INLINE AUTOCOMPLETE SUGGESTIONS ---
                            // Display suggestions ABOVE the text field in the column
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
                                        _switchToCalculator(); // Close keyboard after selection
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 12),
                                        child: Row(
                                          children: [
                                            Icon(Icons.history,
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

  // --- WIDGETS ---

  Widget _buildSegmentControl(Color activeColor) {
    bool isEditing = widget.txnToEdit != null;
    return Container(
      height: 40,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
          color: BudgetrColors.cardSurface,
          borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          _buildSegment("Expense", Colors.redAccent, isEditing, activeColor),
          _buildSegment("Income", Colors.greenAccent, isEditing, activeColor),
          _buildSegment("Transfer", Colors.blueAccent, isEditing, activeColor),
        ],
      ),
    );
  }

  Widget _buildSegment(
      String label, Color color, bool isEditing, Color activeColor) {
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
            borderRadius: BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: Text(label,
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
        color: Colors.transparent,
        padding: const EdgeInsets.symmetric(vertical: 8),
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
    );
  }

  Widget _buildMainInputCard() {
    // --- ROW 1: Date & Type ---
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
            icon: _isCreditEntry
                ? Icons.credit_card
                : Icons.account_balance_wallet,
            label: "TYPE",
            value: _isCreditEntry ? "Credit" : "Cash/Bank",
            isActive: !_isLinkedTransaction && widget.txnToEdit == null,
            onTap: () => setState(() {
              _isCreditEntry = !_isCreditEntry;
              if (_isCreditEntry) {
                if (_type == 'Transfer') _toAccount = null;
                if (_selectedAccount?.id == _externalAccount.id)
                  _selectedAccount = null;
                if (_toAccount?.id == _externalAccount.id) _toAccount = null;
              }
            }),
            valueColor: _isCreditEntry ? Colors.redAccent : null,
          ),
        ),
      ],
    );

    // --- ROW 2: Source & Target ---
    bool isBillPayment = _type == 'Transfer' && _isCreditEntry;
    bool isCardExpense = _type != 'Transfer' && _isCreditEntry;
    String sourceLabel = _type == 'Transfer' ? "FROM" : "ACCOUNT";
    if (isBillPayment) sourceLabel = "PAY FROM";
    if (isCardExpense) sourceLabel = "PAY WITH";

    String sourceVal = isCardExpense
        ? (_selectedCreditCard?.name ?? "Select Card")
        : (_selectedAccount?.name ?? "Select Account");
    IconData sourceIcon =
        isCardExpense ? Icons.credit_card : Icons.account_balance;
    bool sourceError = _attemptedSave &&
        (isCardExpense
            ? _selectedCreditCard == null
            : _selectedAccount == null);

    // Target Logic
    Widget targetTile;
    if (_type == 'Transfer') {
      String targetLabel = "TO";
      String targetVal;
      bool targetError;
      if (isBillPayment) {
        targetLabel = "TO CARD";
        targetVal = _selectedCreditCard?.name ?? "Select Card";
        targetError = _attemptedSave && _selectedCreditCard == null;
      } else {
        targetVal = _toAccount?.name ?? "Select Account";
        targetError = _attemptedSave && _toAccount == null;
      }
      targetTile = _buildInputTile(
        icon: Icons.login,
        label: targetLabel,
        value: targetVal,
        isActive: !_isLinkedTransaction,
        valueColor: targetError ? BudgetrColors.error : null,
        onTap: () {
          if (_isLinkedTransaction) return;
          if (isBillPayment) {
            _showSelectionSheet<CreditCardModel>(
                "Select Card",
                _creditCards,
                _selectedCreditCard,
                (c) => "${c.bankName} - ${c.name}",
                (v) => setState(() => _selectedCreditCard = v));
          } else {
            final targets = _getDisplayAccounts()
                .where((a) => a.id != _selectedAccount?.id)
                .toList();
            if (_selectedAccount?.id == _externalAccount.id)
              targets.removeWhere((e) => e.id == _externalAccount.id);
            _showSelectionSheet<ExpenseAccountModel>(
                "To Account",
                targets,
                _toAccount,
                (a) => "${a.bankName} - ${a.name}",
                (v) => setState(() => _toAccount = v));
          }
        },
      );
    } else {
      // Category
      targetTile = _buildInputTile(
        icon: Icons.category_outlined,
        label: "CATEGORY",
        value: _category ?? "Select",
        valueColor:
            _attemptedSave && _category == null ? BudgetrColors.error : null,
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
        },
      );
    }

    Widget row2 = Row(
      children: [
        Expanded(
          child: _buildInputTile(
            icon: sourceIcon,
            label: sourceLabel,
            value: sourceVal,
            isActive: !_isLinkedTransaction,
            valueColor: sourceError ? BudgetrColors.error : null,
            onTap: () {
              if (_isLinkedTransaction) return;
              if (isCardExpense) {
                _showSelectionSheet<CreditCardModel>(
                    "Select Card",
                    _creditCards,
                    _selectedCreditCard,
                    (c) => "${c.bankName} - ${c.name}",
                    (v) => setState(() => _selectedCreditCard = v));
              } else {
                _showSelectionSheet<ExpenseAccountModel>(
                    "Select Account",
                    _getDisplayAccounts(),
                    _selectedAccount,
                    (a) => "${a.bankName} - ${a.name}",
                    (v) => setState(() => _selectedAccount = v));
              }
            },
          ),
        ),
        Container(width: 1, height: 40, color: Colors.white10),
        Expanded(child: targetTile),
      ],
    );

    // --- ROW 3: Bucket & SubCat (Conditional) ---
    Widget? row3;
    if (_type == 'Expense') {
      String subVal = "---";
      bool subActive = false;
      if (_category != null) {
        try {
          final cat = _allCategories.firstWhere((c) => c.name == _category);
          if (cat.subCategories.isNotEmpty) {
            subVal = _subCategory ?? "Select";
            subActive = true;
          }
        } catch (_) {}
      }

      row3 = Row(
        children: [
          Expanded(
            child: _buildInputTile(
              icon: Icons.pie_chart_outline,
              label: "BUCKET",
              value: _selectedBucket ?? "Select",
              valueColor: _attemptedSave && _selectedBucket == null
                  ? BudgetrColors.error
                  : null,
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
    } else if (_category != null && _type != 'Transfer') {
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
            Expanded(child: Container()) // Spacer
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
      borderRadius: BorderRadius.circular(8),
      child: Padding(
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
// INTERNAL CALCULATOR WIDGET
// =============================================================================
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
    } catch (e) {/* ignore */}
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 8, top: 12, bottom: 8),
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
            borderRadius: BorderRadius.circular(30),
            child: Container(
                height: 48,
                alignment: Alignment.center,
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.02),
                    shape: BoxShape.circle),
                child: Text(label,
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w400,
                        color: color ?? Colors.white)))));
  }

  Widget _backspaceKey() {
    return Expanded(
        child: InkWell(
            onTap: _onBackspace,
            borderRadius: BorderRadius.circular(30),
            child: Container(
                height: 48,
                margin: const EdgeInsets.all(4),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.02),
                    shape: BoxShape.circle),
                child: const Icon(Icons.backspace_outlined,
                    size: 20, color: Colors.white54))));
  }

  Widget _equalsKey(Color color) {
    return Expanded(
        child: InkWell(
            onTap: _onEquals,
            borderRadius: BorderRadius.circular(30),
            child: Container(
                height: 48,
                margin: const EdgeInsets.all(4),
                alignment: Alignment.center,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: const Text('=',
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)))));
  }
}
