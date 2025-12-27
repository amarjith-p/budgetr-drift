import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../../core/widgets/modern_dropdown.dart'; // Contains showSelectionSheet
import '../../../core/models/percentage_config_model.dart';
import '../../settings/services/settings_service.dart';
import '../models/credit_models.dart';
import '../services/credit_service.dart';

class AddCreditTransactionSheet extends StatefulWidget {
  const AddCreditTransactionSheet({super.key});

  @override
  State<AddCreditTransactionSheet> createState() =>
      _AddCreditTransactionSheetState();
}

class _AddCreditTransactionSheetState extends State<AddCreditTransactionSheet> {
  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  // Data
  CreditCardModel? _selectedCard;
  List<CreditCardModel> _cards = [];
  List<String> _buckets = [];

  // Selections
  DateTime _date = DateTime.now();
  String? _selectedBucket;
  String _type = 'Expense'; // 'Expense' or 'Income'
  String? _category;
  String? _subCategory;

  bool _isLoading = false;

  // Categories Map
  final Map<String, List<String>> _expenseCategories = {
    'Shopping': ['Clothing', 'Electronics', 'Groceries', 'Home'],
    'Food': ['Dining Out', 'Delivery', 'Drinks'],
    'Travel': ['Flight', 'Cab', 'Hotel', 'Fuel'],
    'Utilities': ['Phone', 'Internet', 'Electricity'],
    'Entertainment': ['Movies', 'Subscription', 'Events'],
    'Medical': ['Pharmacy', 'Doctor', 'Insurance'],
    'Other': ['Miscellaneous'],
  };

  final Map<String, List<String>> _incomeCategories = {
    'Repayment': ['Bill Payment', 'Refund'],
    'Rewards': ['Cashback', 'Points Redemption'],
  };

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // Load Cards
    final cardStream = CreditService().getCreditCards().first;
    final configFuture = SettingsService().getPercentageConfig();

    final results = await Future.wait([cardStream, configFuture]);

    if (mounted) {
      setState(() {
        _cards = results[0] as List<CreditCardModel>;
        final config = results[1] as PercentageConfig;
        _buckets = config.categories.map((e) => e.name).toList();

        // NO DEFAULT SELECTION
        _selectedCard = null;
        _selectedBucket = null;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      // Determine bucket: User selected if Expense, else 'Repayment'
      final bucketValue = _type == 'Expense' ? (_selectedBucket!) : 'Repayment';

      final txn = CreditTransactionModel(
        id: '',
        cardId: _selectedCard!.id,
        amount: double.parse(_amountCtrl.text),
        date: Timestamp.fromDate(_date),
        bucket: bucketValue,
        type: _type,
        category: _category!,
        subCategory: _subCategory ?? 'General',
        notes: _notesCtrl.text,
      );

      await CreditService().addTransaction(txn);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = _type == 'Expense'
        ? _expenseCategories
        : _incomeCategories;
    final categoryKeys = categories.keys.toList();
    final subCategories =
        (_category != null && categories.containsKey(_category))
        ? categories[_category]!
        : <String>[];

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Color(0xff0D1B2A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
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
              const Text(
                "Add Transaction",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),

              // Card Selection (Mandatory)
              _buildSelectField<CreditCardModel>(
                label: "Credit Card",
                value: _selectedCard,
                items: _cards,
                labelBuilder: (c) => "${c.bankName} - ${c.name}",
                onSelect: (v) => setState(() => _selectedCard = v),
                validator: (v) => v == null ? 'Please select a card' : null,
              ),
              const SizedBox(height: 16),

              // Type (Income/Expense)
              Row(
                children: [
                  Expanded(
                    child: _typeButton(
                      "Expense",
                      Colors.redAccent,
                      _type == 'Expense',
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _typeButton(
                      "Payment/Income",
                      Colors.greenAccent,
                      _type == 'Income',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Date & Time Picker
              InkWell(
                onTap: () async {
                  // 1. Pick Date
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _date,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                    builder: (context, child) =>
                        Theme(data: ThemeData.dark(), child: child!),
                  );

                  if (pickedDate != null) {
                    if (!mounted) return;
                    // 2. Pick Time
                    final pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(_date),
                      builder: (context, child) =>
                          Theme(data: ThemeData.dark(), child: child!),
                    );

                    if (pickedTime != null) {
                      // 3. Combine
                      setState(() {
                        _date = DateTime(
                          pickedDate.year,
                          pickedDate.month,
                          pickedDate.day,
                          pickedTime.hour,
                          pickedTime.minute,
                        );
                      });
                    }
                  }
                },
                borderRadius: BorderRadius.circular(12),
                child: InputDecorator(
                  decoration: _inputDeco('Date & Time').copyWith(
                    suffixIcon: const Icon(
                      Icons.calendar_today,
                      color: Colors.white54,
                      size: 18,
                    ),
                  ),
                  child: Text(
                    DateFormat('dd MMM yyyy, hh:mm a').format(_date),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Amount
              TextFormField(
                controller: _amountCtrl,
                keyboardType: TextInputType.number,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                decoration: _inputDeco('Amount').copyWith(prefixText: '₹ '),
                validator: (v) => v!.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              // Bucket Selection (ONLY VISIBLE FOR EXPENSE)
              if (_type == 'Expense') ...[
                _buildSelectField<String>(
                  label: "Budget Bucket",
                  value: _selectedBucket,
                  items: _buckets,
                  labelBuilder: (v) => v,
                  onSelect: (v) => setState(() => _selectedBucket = v),
                  validator: (v) => v == null ? 'Required' : null,
                ),
                const SizedBox(height: 16),
              ],

              // Category & SubCategory (Dynamic Layout)
              Row(
                children: [
                  Expanded(
                    child: _buildSelectField<String>(
                      label: "Category",
                      value: _category,
                      items: categoryKeys,
                      labelBuilder: (v) => v,
                      onSelect: (v) => setState(() {
                        _category = v;
                        _subCategory = null; // Reset sub
                      }),
                      validator: (v) => v == null ? 'Required' : null,
                    ),
                  ),
                  // Only show Sub-Category if Category is selected
                  if (_category != null) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSelectField<String>(
                        label: "Sub-Category",
                        value: _subCategory,
                        items: subCategories,
                        labelBuilder: (v) => v,
                        onSelect: (v) => setState(() => _subCategory = v),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 16),

              // Notes
              TextFormField(
                controller: _notesCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDeco('Notes (Optional)'),
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3A86FF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Add Transaction",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
    );
  }

  /// Improved Select Field using FormField
  Widget _buildSelectField<T>({
    required String label,
    required T? value,
    required List<T> items,
    required String Function(T) labelBuilder,
    required Function(T) onSelect,
    String? Function(T?)? validator,
  }) {
    return FormField<T>(
      validator: validator,
      initialValue: value,
      builder: (FormFieldState<T> state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () => showSelectionSheet<T>(
                context: context,
                title: "Select $label",
                items: items,
                selectedItem: value,
                labelBuilder: labelBuilder,
                onSelect: (v) {
                  if (v != null) {
                    onSelect(v);
                    state.didChange(v);
                  }
                },
              ),
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

  Widget _typeButton(String label, Color color, bool isSelected) {
    return GestureDetector(
      onTap: () => setState(() {
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
    );
  }
}
