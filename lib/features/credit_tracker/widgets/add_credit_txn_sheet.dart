import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/widgets/modern_loader.dart';
import '../../../core/widgets/calculator_keyboard.dart';
import '../../../core/models/transaction_category_model.dart';
import '../../../core/services/category_service.dart';
import '../../settings/services/settings_service.dart';
import '../../dashboard/services/dashboard_service.dart';
import '../../settlement/services/settlement_service.dart';
import '../models/credit_models.dart';
import '../services/credit_service.dart';

class AddCreditTransactionSheet extends StatefulWidget {
  final CreditTransactionModel? transactionToEdit;

  const AddCreditTransactionSheet({super.key, this.transactionToEdit});

  @override
  State<AddCreditTransactionSheet> createState() =>
      _AddCreditTransactionSheetState();
}

class _AddCreditTransactionSheetState extends State<AddCreditTransactionSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  final FocusNode _amountNode = FocusNode();
  final FocusNode _notesNode = FocusNode();
  final GlobalKey _amountFieldKey = GlobalKey();
  final GlobalKey _notesFieldKey = GlobalKey();

  List<CreditCardModel> _cards = [];
  CreditCardModel? _selectedCard;

  DateTime _date = DateTime.now();
  String _type = 'Expense';
  String? _selectedBucket;
  String? _category;
  String? _subCategory;

  bool _isLoading = false;
  bool _showCustomKeyboard = false;
  bool _systemKeyboardActive = false;

  List<String> _buckets = [];
  List<TransactionCategoryModel> _allCategories = [];

  // LOCK FLAG for Synced Transactions
  bool _isLinked = false;

  @override
  void initState() {
    super.initState();
    _loadData();

    _amountNode.addListener(() {
      if (_amountNode.hasFocus) {
        if (!_systemKeyboardActive) {
          setState(() => _showCustomKeyboard = true);
        }
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

  void _scrollToField(GlobalKey key) {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (key.currentContext != null) {
        Scrollable.ensureVisible(
          key.currentContext!,
          alignment: 0.5,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
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

  Future<void> _loadData() async {
    final cardsFuture = CreditService().getCreditCards().first;
    final catsFuture = CategoryService().getCategories().first;
    final configFuture = SettingsService().getPercentageConfig();

    final results = await Future.wait([
      cardsFuture,
      catsFuture,
      configFuture,
    ]);

    if (mounted) {
      final config = results[2] as dynamic;
      final cats =
          (config.categories as List).map((e) => e.name as String).toList();
      cats.add('Out of Bucket');

      setState(() {
        _cards = results[0] as List<CreditCardModel>;
        _allCategories = results[1] as List<TransactionCategoryModel>;
        _buckets = cats;

        if (widget.transactionToEdit != null) {
          final t = widget.transactionToEdit!;
          _amountCtrl.text =
              t.amount.toString().replaceAll(RegExp(r"([.]*0)(?!.*\d)"), "");
          _notesCtrl.text = t.notes;
          _date = t.date;
          _type = t.type;
          _selectedBucket = t.bucket;
          _category = t.category;
          _subCategory = t.subCategory;

          try {
            _selectedCard = _cards.firstWhere((c) => c.id == t.cardId);
          } catch (e) {
            _selectedCard = null;
          }

          if (t.linkedExpenseId != null && t.linkedExpenseId!.isNotEmpty) {
            _isLinked = true;
          }
        }
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCard == null) return;

    setState(() => _isLoading = true);

    try {
      final amount = double.parse(_amountCtrl.text);

      final txn = CreditTransactionModel(
        id: widget.transactionToEdit?.id ?? '',
        cardId: _selectedCard!.id,
        amount: amount,
        date: DateTime.timestamp(),
        bucket: _type == 'Expense'
            ? (_selectedBucket ?? 'Unallocated')
            : 'Unallocated',
        type: _type,
        category: _category ?? 'General',
        subCategory: _subCategory ?? 'General',
        notes: _notesCtrl.text,
        linkedExpenseId: widget.transactionToEdit?.linkedExpenseId,
      );

      if (widget.transactionToEdit == null) {
        // Add Transaction
        await CreditService().addTransaction(txn);

        if (mounted) {
          // await BudgetNotificationService()
          //     .checkAndTriggerCreditNotification(txn);
        }
      } else {
        // Update Transaction
        // await CreditService().updateTransaction(txn);

        // --- NEW: Trigger Check on Update ---
        if (mounted) {
          // await BudgetNotificationService()
          //     .checkAndTriggerCreditNotification(txn);
        }
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickDate() async {
    _amountNode.unfocus();
    _notesNode.unfocus();
    setState(() => _showCustomKeyboard = false);

    final d = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(data: ThemeData.dark(), child: child!);
      },
    );

    if (d != null) {
      final t = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_date),
        builder: (context, child) {
          return Theme(data: ThemeData.dark(), child: child!);
        },
      );

      if (t != null) {
        setState(() {
          _date = DateTime(d.year, d.month, d.day, t.hour, t.minute);
        });
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
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF00B4D8), width: 1.5),
      ),
      errorStyle: const TextStyle(color: Colors.redAccent),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    final categoryList = _allCategories.where((c) => c.type == _type).toList();
    final categoryNames = categoryList.map((e) => e.name).toList();

    List<String> subCategories = [];
    if (_category != null) {
      final hasCat = categoryList.any((e) => e.name == _category);
      if (hasCat) {
        final catModel = categoryList.firstWhere((e) => e.name == _category);
        subCategories = catModel.subCategories;
      }
    }

    return Container(
      padding: EdgeInsets.only(
        bottom: _showCustomKeyboard ? 0 : bottomPadding,
      ),
      decoration: const BoxDecoration(
        color: Color(0xff0D1B2A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    if (_isLinked)
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blueAccent.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.link,
                                color: Colors.blueAccent, size: 20),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                "Synced Transaction: Type and Card are locked.",
                                style: TextStyle(
                                    color: Colors.blueAccent, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),

                    Text(
                      widget.transactionToEdit != null
                          ? "Edit Transaction"
                          : "New Transaction",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Type Row
                    Row(
                      children: [
                        Expanded(
                          child: _typeButton(
                              'Expense', Colors.redAccent, _type == 'Expense'),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _typeButton(
                              'Income', Colors.greenAccent, _type == 'Income'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Card Dropdown
                    Opacity(
                      opacity: _isLinked ? 0.5 : 1.0,
                      child: IgnorePointer(
                        ignoring: _isLinked,
                        child: _buildSelectField<CreditCardModel>(
                          label: "Credit Card",
                          value: _selectedCard,
                          items: _cards,
                          labelBuilder: (c) => "${c.bankName} - ${c.name}",
                          onSelect: (val) {
                            setState(() => _selectedCard = val);
                          },
                          validator: (val) =>
                              val == null ? 'Please select a card' : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Date
                    InkWell(
                      onTap: _pickDate,
                      borderRadius: BorderRadius.circular(12),
                      child: InputDecorator(
                        decoration: _inputDeco("Date").copyWith(
                          suffixIcon: const Icon(
                            Icons.calendar_today,
                            color: Colors.white54,
                            size: 18,
                          ),
                        ),
                        child: Text(
                          DateFormat('dd MMM, hh:mm a').format(_date),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Amount
                    Container(
                      key: _amountFieldKey,
                      child: TextFormField(
                        controller: _amountCtrl,
                        focusNode: _amountNode,
                        readOnly: !_systemKeyboardActive,
                        showCursor: _systemKeyboardActive,
                        onTap: () {
                          if (!_amountNode.hasFocus) {
                            FocusScope.of(context).requestFocus(_amountNode);
                          }
                          setState(() {
                            _showCustomKeyboard = true;
                            _systemKeyboardActive = false;
                          });
                        },
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: _inputDeco("Amount").copyWith(
                          prefixText: '₹ ',
                        ),
                        validator: (val) {
                          if (val == null || val.isEmpty)
                            return 'Amount required';
                          if (double.tryParse(val) == null)
                            return 'Invalid amount';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Bucket
                    if (_type == 'Expense') ...[
                      _buildSelectField<String>(
                        label: "Bucket",
                        value: _selectedBucket,
                        items: _buckets,
                        labelBuilder: (s) => s,
                        onSelect: (val) {
                          setState(() => _selectedBucket = val);
                        },
                        validator: (val) =>
                            val == null ? 'Bucket required' : null,
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Category
                    Row(
                      children: [
                        Expanded(
                          child: _buildSelectField<String>(
                            label: "Category",
                            value: _category,
                            items: categoryNames,
                            labelBuilder: (s) => s,
                            onSelect: (val) {
                              setState(() {
                                _category = val;
                                _subCategory = null;
                              });
                            },
                            validator: (val) =>
                                val == null ? 'Category required' : null,
                          ),
                        ),
                        if (subCategories.isNotEmpty) ...[
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildSelectField<String>(
                              label: "Sub-Category",
                              value: _subCategory,
                              items: subCategories,
                              labelBuilder: (s) => s,
                              onSelect: (val) {
                                setState(() => _subCategory = val);
                              },
                              validator: null,
                            ),
                          ),
                        ]
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Notes
                    Container(
                      key: _notesFieldKey,
                      child: TextFormField(
                        controller: _notesCtrl,
                        focusNode: _notesNode,
                        style: const TextStyle(color: Colors.white),
                        decoration: _inputDeco("Notes (Optional)"),
                        onFieldSubmitted: (_) => _save(),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _save,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00B4D8),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: ModernLoader(size: 24),
                              )
                            : Text(
                                widget.transactionToEdit != null
                                    ? "Update"
                                    : "Save",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_showCustomKeyboard)
            CalculatorKeyboard(
              onKeyPress: (val) {
                CalculatorKeyboard.handleKeyPress(_amountCtrl, val);
              },
              onBackspace: () {
                CalculatorKeyboard.handleBackspace(_amountCtrl);
              },
              onEquals: () {
                CalculatorKeyboard.handleEquals(_amountCtrl);
              },
              onClear: () {
                _amountCtrl.clear();
              },
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
            ),
        ],
      ),
    );
  }

  Widget _buildSelectField<T>({
    required String label,
    required T? value,
    required List<T> items,
    required String Function(T) labelBuilder,
    required Function(T) onSelect,
    String? Function(T?)? validator,
  }) {
    return FormField<T>(
      initialValue: value,
      validator: validator,
      builder: (FormFieldState<T> state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () {
                _amountNode.unfocus();
                _notesNode.unfocus();
                setState(() => _showCustomKeyboard = false);
                showSelectionSheet<T>(
                  context: context,
                  title: label,
                  items: items,
                  selectedItem: value,
                  labelBuilder: labelBuilder,
                  onSelect: (v) {
                    if (v != null) {
                      onSelect(v);
                      state.didChange(v);
                    }
                  },
                );
              },
              borderRadius: BorderRadius.circular(12),
              child: InputDecorator(
                decoration: _inputDeco(label).copyWith(
                  errorText: state.errorText,
                  suffixIcon: const Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.white54,
                  ),
                ),
                isEmpty: value == null,
                child: Text(
                  value != null ? labelBuilder(value) : '',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void showSelectionSheet<T>({
    required BuildContext context,
    required String title,
    required List<T> items,
    T? selectedItem,
    required String Function(T) labelBuilder,
    required Function(T) onSelect,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          decoration: const BoxDecoration(
            color: Color(0xff1B263B),
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
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
                        borderRadius: BorderRadius.circular(12),
                      ),
                      tileColor: isSelected
                          ? const Color(0xFF00B4D8).withOpacity(0.2)
                          : Colors.transparent,
                      title: Text(
                        labelBuilder(item),
                        style: TextStyle(
                          color: isSelected
                              ? const Color(0xFF00B4D8)
                              : Colors.white70,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check, color: Color(0xFF00B4D8))
                          : null,
                    );
                  },
                ),
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
            ],
          ),
        );
      },
    );
  }

  Widget _typeButton(String label, Color color, bool isSelected) {
    return Opacity(
      opacity: _isLinked ? 0.5 : 1.0,
      child: GestureDetector(
        onTap: _isLinked
            ? null
            : () => setState(() {
                  _type = label == 'Expense' ? 'Expense' : 'Income';
                  _category = null;
                  _subCategory = null;
                  if (_type == 'Income') {
                    _selectedBucket = null;
                  }
                }),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isSelected ? color : Colors.white12),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? color : Colors.white54,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
