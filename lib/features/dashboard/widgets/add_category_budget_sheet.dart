// lib/features/dashboard/widgets/add_category_budget_sheet.dart
import 'package:budget/core/constants/icon_constants.dart';
import 'package:budget/core/database/app_database.dart';
import 'package:budget/core/design/budgetr_colors.dart';
import 'package:budget/core/design/budgetr_styles.dart';
import 'package:budget/core/models/transaction_category_model.dart';
import 'package:budget/core/services/category_service.dart';
import 'package:budget/features/dashboard/services/category_budget_service.dart';
import 'package:budget/features/dashboard/services/dashboard_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class AddCategoryBudgetSheet extends StatefulWidget {
  final CategoryBudget? existingBudget;

  const AddCategoryBudgetSheet({super.key, this.existingBudget});

  @override
  State<AddCategoryBudgetSheet> createState() => _AddCategoryBudgetSheetState();
}

class _AddCategoryBudgetSheetState extends State<AddCategoryBudgetSheet> {
  final _service = GetIt.I<CategoryBudgetService>();
  final _catService = GetIt.I<CategoryService>();
  final _dashboardService = GetIt.I<DashboardService>();

  List<String> _selectedCategories = [];
  List<String> _selectedSubCategories = []; // Subcategory State
  List<String> _selectedBuckets = [];
  String _selectedPeriod = 'MONTHLY';
  late TextEditingController _amountController;
  String? _amountError;

  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();

  List<TransactionCategoryModel> _categories = [];
  List<String> _availableBuckets = [];
  final List<String> _periodTypes = [
    'DAILY',
    'WEEKLY',
    'MONTHLY',
    'YEARLY',
    'CUSTOM'
  ];

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
        text: widget.existingBudget?.amount.toString() ?? '');

    if (widget.existingBudget != null) {
      _selectedCategories =
          List<String>.from(jsonDecode(widget.existingBudget!.categories));
      _selectedBuckets =
          List<String>.from(jsonDecode(widget.existingBudget!.buckets));
      _selectedSubCategories =
          List<String>.from(jsonDecode(widget.existingBudget!.subCategories));

      _selectedPeriod = widget.existingBudget!.periodType;
      _startDate = widget.existingBudget!.startDate;
      _endDate = widget.existingBudget!.endDate;
    } else {
      _calculateDatesForPeriod();
    }

    _loadData();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _loadData() async {
    _catService.getCategories().listen((cats) {
      final expenseCats = cats.where((c) => c.type == 'Expense').toList();
      if (mounted) setState(() => _categories = expenseCats);
    });

    _dashboardService.getFinancialRecords().listen((records) {
      if (!mounted) return;
      Set<String> orderedUniqueBuckets = {};

      for (var record in records) {
        if (record.bucketOrder.isNotEmpty) {
          orderedUniqueBuckets.addAll(
            record.bucketOrder.where((b) =>
                b.toLowerCase() != 'unallocated' &&
                b.toLowerCase() != 'income'),
          );
        }
        if (record.allocations.isNotEmpty) {
          orderedUniqueBuckets.addAll(
            record.allocations.keys.where((b) =>
                b.toLowerCase() != 'unallocated' &&
                b.toLowerCase() != 'income'),
          );
        }
      }
      orderedUniqueBuckets.add('Out of Bucket');
      setState(() {
        _availableBuckets = orderedUniqueBuckets.toList();
      });
    });
  }

  void _calculateDatesForPeriod() {
    final now = DateTime.now();
    switch (_selectedPeriod) {
      case 'DAILY':
        _startDate = DateTime(now.year, now.month, now.day);
        _endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
        break;
      case 'WEEKLY':
        _startDate = now.subtract(Duration(days: now.weekday - 1));
        _endDate =
            _startDate.add(const Duration(days: 6, hours: 23, minutes: 59));
        break;
      case 'MONTHLY':
        _startDate = DateTime(now.year, now.month, 1);
        _endDate = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
        break;
      case 'YEARLY':
        _startDate = DateTime(now.year, 1, 1);
        _endDate = DateTime(now.year, 12, 31, 23, 59, 59);
        break;
    }
  }

  Future<void> _pickDateRange() async {
    HapticFeedback.lightImpact();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(
            primary: BudgetrColors.accent,
            onPrimary: Colors.white,
            surface: Color(0xFF1E293B),
            onSurface: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = DateTime(
            picked.end.year, picked.end.month, picked.end.day, 23, 59, 59);
      });
    }
  }

  // [NEW] Dynamically compute available subcategories
// [NEW] Dynamically compute available subcategories
  List<String> get _currentAvailableSubCategories {
    Set<String> subs = {};
    if (_selectedCategories.isEmpty) {
      for (var cat in _categories) {
        // FIXED: cat.subCategories is already a List<String> in the model
        subs.addAll(cat.subCategories);
      }
    } else {
      for (var cat
          in _categories.where((c) => _selectedCategories.contains(c.name))) {
        // FIXED: cat.subCategories is already a List<String> in the model
        subs.addAll(cat.subCategories);
      }
    }
    final sortedList = subs.toList()..sort();
    return sortedList;
  }

  void _showCategoryPicker() {
    HapticFeedback.lightImpact();
    List<String> tempSelected = List.from(_selectedCategories);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(builder: (context, setSheetState) {
        final bool isAllSelected =
            tempSelected.length == _categories.length && _categories.isNotEmpty;

        return Container(
          height: MediaQuery.of(context).size.height * 0.8,
          padding: const EdgeInsets.only(top: 24),
          decoration: const BoxDecoration(
            color: BudgetrColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
          ),
          child: Column(
            children: [
              Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Target Categories", style: BudgetrStyles.h3),
                        if (tempSelected.isNotEmpty)
                          Text("${tempSelected.length} Selected",
                              style: const TextStyle(
                                  color: BudgetrColors.accent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12)),
                      ],
                    ),
                    TextButton(
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        setSheetState(() => isAllSelected
                            ? tempSelected.clear()
                            : tempSelected =
                                _categories.map((c) => c.name).toList());
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: isAllSelected
                            ? Colors.white70
                            : BudgetrColors.accent,
                        backgroundColor: isAllSelected
                            ? Colors.white.withOpacity(0.05)
                            : BudgetrColors.accent.withOpacity(0.1),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text(isAllSelected ? "Deselect All" : "Select All",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _categories.length,
                  itemBuilder: (context, index) {
                    final cat = _categories[index];
                    final isSelected = tempSelected.contains(cat.name);
                    final icon = cat.iconCode != null
                        ? IconConstants.getIconByCode(cat.iconCode!)
                        : Icons.category_rounded;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? BudgetrColors.accent.withOpacity(0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: isSelected
                                ? BudgetrColors.accent.withOpacity(0.3)
                                : Colors.transparent),
                      ),
                      child: ListTile(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setSheetState(() => isSelected
                              ? tempSelected.remove(cat.name)
                              : tempSelected.add(cat.name));
                        },
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              shape: BoxShape.circle),
                          child: Icon(icon,
                              color: isSelected
                                  ? BudgetrColors.accent
                                  : Colors.white70,
                              size: 20),
                        ),
                        title: Text(cat.name,
                            style: TextStyle(
                                color: isSelected
                                    ? BudgetrColors.accent
                                    : Colors.white,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal)),
                        trailing: isSelected
                            ? const Icon(Icons.check_circle_rounded,
                                color: BudgetrColors.accent)
                            : const Icon(Icons.circle_outlined,
                                color: Colors.white24),
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(24),
                decoration:
                    BoxDecoration(color: BudgetrColors.background, boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 10,
                      offset: const Offset(0, -5))
                ]),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: BudgetrColors.accent,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8))),
                    onPressed: () {
                      setState(() {
                        _selectedCategories = tempSelected;
                        // Auto-clean subcategories if their parent category was removed
                        final availableSubs = _currentAvailableSubCategories;
                        _selectedSubCategories
                            .removeWhere((sub) => !availableSubs.contains(sub));
                      });
                      Navigator.pop(ctx);
                    },
                    child: const Text("Confirm Categories",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  // [NEW] Subcategory Picker Bottom Sheet
  void _showSubCategoryPicker() {
    HapticFeedback.lightImpact();
    List<String> tempSelected = List.from(_selectedSubCategories);
    final availableSubs = _currentAvailableSubCategories;

    if (availableSubs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text(
            "No subcategories available for the selected categories."),
        backgroundColor: Colors.orange.shade800,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(builder: (context, setSheetState) {
        final bool isAllSelected =
            tempSelected.length == availableSubs.length &&
                availableSubs.isNotEmpty;

        return Container(
          height: MediaQuery.of(context).size.height * 0.8,
          padding: const EdgeInsets.only(top: 24),
          decoration: const BoxDecoration(
            color: BudgetrColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
          ),
          child: Column(
            children: [
              Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Target Subcategories", style: BudgetrStyles.h3),
                        if (tempSelected.isNotEmpty)
                          Text("${tempSelected.length} Selected",
                              style: const TextStyle(
                                  color: BudgetrColors.accent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12)),
                      ],
                    ),
                    TextButton(
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        setSheetState(() => isAllSelected
                            ? tempSelected.clear()
                            : tempSelected = List.from(availableSubs));
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: isAllSelected
                            ? Colors.white70
                            : BudgetrColors.accent,
                        backgroundColor: isAllSelected
                            ? Colors.white.withOpacity(0.05)
                            : BudgetrColors.accent.withOpacity(0.1),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text(isAllSelected ? "Deselect All" : "Select All",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: availableSubs.length,
                  itemBuilder: (context, index) {
                    final subCat = availableSubs[index];
                    final isSelected = tempSelected.contains(subCat);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? BudgetrColors.accent.withOpacity(0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: isSelected
                                ? BudgetrColors.accent.withOpacity(0.3)
                                : Colors.transparent),
                      ),
                      child: ListTile(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setSheetState(() => isSelected
                              ? tempSelected.remove(subCat)
                              : tempSelected.add(subCat));
                        },
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              shape: BoxShape.circle),
                          child: Icon(Icons.subdirectory_arrow_right_rounded,
                              color: isSelected
                                  ? BudgetrColors.accent
                                  : Colors.white70,
                              size: 20),
                        ),
                        title: Text(subCat,
                            style: TextStyle(
                                color: isSelected
                                    ? BudgetrColors.accent
                                    : Colors.white,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal)),
                        trailing: isSelected
                            ? const Icon(Icons.check_circle_rounded,
                                color: BudgetrColors.accent)
                            : const Icon(Icons.circle_outlined,
                                color: Colors.white24),
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(24),
                decoration:
                    BoxDecoration(color: BudgetrColors.background, boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 10,
                      offset: const Offset(0, -5))
                ]),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: BudgetrColors.accent,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8))),
                    onPressed: () {
                      setState(() => _selectedSubCategories = tempSelected);
                      Navigator.pop(ctx);
                    },
                    child: const Text("Confirm Subcategories",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  void _showBucketPicker() {
    HapticFeedback.lightImpact();
    List<String> tempSelected = List.from(_selectedBuckets);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(builder: (context, setSheetState) {
        final bool isAllSelected =
            tempSelected.length == _availableBuckets.length &&
                _availableBuckets.isNotEmpty;

        return Container(
          height: MediaQuery.of(context).size.height * 0.6,
          padding: const EdgeInsets.only(top: 24),
          decoration: const BoxDecoration(
            color: BudgetrColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
          ),
          child: Column(
            children: [
              Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Target Buckets", style: BudgetrStyles.h3),
                        if (tempSelected.isNotEmpty)
                          Text("${tempSelected.length} Selected",
                              style: const TextStyle(
                                  color: BudgetrColors.accent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12)),
                      ],
                    ),
                    TextButton(
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        setSheetState(() => isAllSelected
                            ? tempSelected.clear()
                            : tempSelected = List.from(_availableBuckets));
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: isAllSelected
                            ? Colors.white70
                            : BudgetrColors.accent,
                        backgroundColor: isAllSelected
                            ? Colors.white.withOpacity(0.05)
                            : BudgetrColors.accent.withOpacity(0.1),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text(isAllSelected ? "Deselect All" : "Select All",
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 13)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _availableBuckets.length,
                  itemBuilder: (context, index) {
                    final bucket = _availableBuckets[index];
                    final isSelected = tempSelected.contains(bucket);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? BudgetrColors.accent.withOpacity(0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: isSelected
                                ? BudgetrColors.accent.withOpacity(0.3)
                                : Colors.transparent),
                      ),
                      child: ListTile(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setSheetState(() => isSelected
                              ? tempSelected.remove(bucket)
                              : tempSelected.add(bucket));
                        },
                        leading: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              shape: BoxShape.circle),
                          child: Icon(Icons.account_balance_wallet_rounded,
                              color: isSelected
                                  ? BudgetrColors.accent
                                  : Colors.white70,
                              size: 20),
                        ),
                        title: Text(bucket,
                            style: TextStyle(
                                color: isSelected
                                    ? BudgetrColors.accent
                                    : Colors.white,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal)),
                        trailing: isSelected
                            ? const Icon(Icons.check_circle_rounded,
                                color: BudgetrColors.accent)
                            : const Icon(Icons.circle_outlined,
                                color: Colors.white24),
                      ),
                    );
                  },
                ),
              ),
              Container(
                padding: const EdgeInsets.all(24),
                decoration:
                    BoxDecoration(color: BudgetrColors.background, boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 10,
                      offset: const Offset(0, -5))
                ]),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: BudgetrColors.accent,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8))),
                    onPressed: () {
                      setState(() => _selectedBuckets = tempSelected);
                      Navigator.pop(ctx);
                    },
                    child: const Text("Confirm Buckets",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  void _showPeriodPicker() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.only(top: 24, bottom: 32),
        decoration: const BoxDecoration(
          color: BudgetrColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
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
            Text("Select Timeframe", style: BudgetrStyles.h3),
            const SizedBox(height: 16),
            ..._periodTypes.map((period) {
              final isSelected = _selectedPeriod == period;
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                decoration: BoxDecoration(
                  color: isSelected
                      ? BudgetrColors.accent.withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListTile(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() {
                      _selectedPeriod = period;
                      if (_selectedPeriod != 'CUSTOM')
                        _calculateDatesForPeriod();
                    });
                    Navigator.pop(context);
                  },
                  title: Text(period,
                      style: TextStyle(
                          color:
                              isSelected ? BudgetrColors.accent : Colors.white,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.w500)),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle_rounded,
                          color: BudgetrColors.accent)
                      : null,
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  void _save() {
    setState(() {
      _amountError = null;
    });

    final amountText = _amountController.text.trim();

    if (amountText.isEmpty) {
      setState(() {
        _amountError = "Budget limit cannot be empty.";
      });
      HapticFeedback.heavyImpact();
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      setState(() {
        _amountError = "Please enter a valid limit greater than zero.";
      });
      HapticFeedback.heavyImpact();
      return;
    }

    if (widget.existingBudget != null) {
      _service.updateCategoryBudget(
        id: widget.existingBudget!.id,
        categories: _selectedCategories,
        buckets: _selectedBuckets,
        subCategories: _selectedSubCategories,
        amount: amount,
        periodType: _selectedPeriod,
        startDate: _startDate,
        endDate: _endDate,
      );
    } else {
      _service.addCategoryBudget(
        categories: _selectedCategories,
        buckets: _selectedBuckets,
        subCategories: _selectedSubCategories,
        amount: amount,
        periodType: _selectedPeriod,
        startDate: _startDate,
        endDate: _endDate,
      );
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingBudget != null;

    String categoryDisplayText = "Any Category";
    IconData catDisplayIcon = Icons.all_inclusive_rounded;
    if (_selectedCategories.isNotEmpty) {
      if (_selectedCategories.length == 1) {
        categoryDisplayText = _selectedCategories.first;
        try {
          final cat = _categories
              .firstWhere((c) => c.name == _selectedCategories.first);
          if (cat.iconCode != null)
            catDisplayIcon = IconConstants.getIconByCode(cat.iconCode!);
        } catch (_) {}
      } else {
        categoryDisplayText = "${_selectedCategories.length} Categories";
        catDisplayIcon = Icons.auto_awesome_mosaic_rounded;
      }
    }

    // [NEW] Subcategory display logic
    String subCategoryDisplayText = "Any Subcategory";
    if (_selectedSubCategories.isNotEmpty) {
      if (_selectedSubCategories.length == 1) {
        subCategoryDisplayText = _selectedSubCategories.first;
      } else {
        subCategoryDisplayText =
            "${_selectedSubCategories.length} Subcategories";
      }
    }

    String bucketDisplayText = "Any Bucket";
    if (_selectedBuckets.isNotEmpty) {
      if (_selectedBuckets.length == 1) {
        bucketDisplayText = _selectedBuckets.first;
      } else {
        bucketDisplayText = "${_selectedBuckets.length} Buckets";
      }
    }

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        left: 24,
        right: 24,
        top: 20,
      ),
      decoration: const BoxDecoration(
        color: BudgetrColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 48,
                height: 5,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8)),
              ),
            ),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: BudgetrColors.accent.withOpacity(0.1),
                      shape: BoxShape.circle),
                  child: Icon(
                      isEditing ? Icons.edit_note_rounded : Icons.tune_rounded,
                      color: BudgetrColors.accent,
                      size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(isEditing ? "Edit Allocation" : "New Allocation",
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5)),
                      const SizedBox(height: 2),
                      Text("Set custom limits using matrix filtering",
                          style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            GestureDetector(
              onTap: _showBucketPicker,
              behavior: HitTestBehavior.opaque,
              child: _buildUnifiedField(
                label: "Target Buckets",
                icon: Icons.account_balance_wallet_rounded,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        bucketDisplayText,
                        style: TextStyle(
                            color: _selectedBuckets.isNotEmpty
                                ? Colors.white
                                : Colors.white54,
                            fontSize: 16,
                            fontWeight: FontWeight.w500),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(Icons.keyboard_arrow_down_rounded,
                        color: Colors.white54),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: _showCategoryPicker,
              behavior: HitTestBehavior.opaque,
              child: _buildUnifiedField(
                label: "Target Categories",
                icon: Icons.grid_view_rounded,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(catDisplayIcon, color: Colors.white70, size: 18),
                          const SizedBox(width: 10),
                          Flexible(
                            child: Text(
                              categoryDisplayText,
                              style: TextStyle(
                                  color: _selectedCategories.isNotEmpty
                                      ? Colors.white
                                      : Colors.white54,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.keyboard_arrow_down_rounded,
                        color: Colors.white54),
                  ],
                ),
              ),
            ),
            // [NEW] Target Subcategories Field
            GestureDetector(
              onTap: _showSubCategoryPicker,
              behavior: HitTestBehavior.opaque,
              child: _buildUnifiedField(
                label: "Target Subcategories",
                icon: Icons.subdirectory_arrow_right_rounded,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        subCategoryDisplayText,
                        style: TextStyle(
                            color: _selectedSubCategories.isNotEmpty
                                ? Colors.white
                                : Colors.white54,
                            fontSize: 16,
                            fontWeight: FontWeight.w500),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(Icons.keyboard_arrow_down_rounded,
                        color: Colors.white54),
                  ],
                ),
              ),
            ),
            _buildUnifiedField(
              label: "Budget Limit",
              icon: Icons.currency_rupee_rounded,
              errorText: _amountError,
              child: TextField(
                controller: _amountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600),
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: '0.00',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                ),
                onChanged: (value) {
                  if (_amountError != null) {
                    setState(() {
                      _amountError = null;
                    });
                  }
                },
              ),
            ),
            GestureDetector(
              onTap: _showPeriodPicker,
              behavior: HitTestBehavior.opaque,
              child: _buildUnifiedField(
                label: "Timeframe",
                icon: Icons.update_rounded,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_selectedPeriod,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500)),
                    const Icon(Icons.keyboard_arrow_down_rounded,
                        color: Colors.white54),
                  ],
                ),
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOutCubic,
              child: _selectedPeriod == 'CUSTOM'
                  ? GestureDetector(
                      onTap: _pickDateRange,
                      behavior: HitTestBehavior.opaque,
                      child: _buildUnifiedField(
                        label: "Custom Date Range",
                        icon: Icons.calendar_month_rounded,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "${DateFormat('MMM d, yyyy').format(_startDate)} - ${DateFormat('MMM d, yyyy').format(_endDate)}",
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500),
                            ),
                            const Icon(Icons.edit_calendar_rounded,
                                color: Colors.white54, size: 18),
                          ],
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: BudgetrColors.accent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                onPressed: _save,
                child: const Text("Save Budget",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        letterSpacing: 0.5)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnifiedField({
    required String label,
    required IconData icon,
    required Widget child,
    String? errorText,
  }) {
    final bool hasError = errorText != null && errorText.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(label.toUpperCase(),
                style: TextStyle(
                    color: hasError
                        ? Colors.redAccent
                        : Colors.white.withOpacity(0.5),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2)),
          ),
          Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: hasError
                      ? Colors.redAccent
                      : Colors.white.withOpacity(0.1)),
            ),
            child: Row(
              children: [
                Icon(icon,
                    color: hasError ? Colors.redAccent : BudgetrColors.accent,
                    size: 20),
                const SizedBox(width: 14),
                Expanded(child: child),
              ],
            ),
          ),
          if (hasError)
            Padding(
              padding: const EdgeInsets.only(left: 4, top: 8),
              child: Text(
                errorText,
                style: const TextStyle(
                  color: Colors.redAccent,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
