import 'package:flutter/material.dart';
import '../models/expense_models.dart';

enum SortOption { newest, oldest, highestAmount, lowestAmount }

class FilterCriteria {
  DateTimeRange? dateRange;
  List<String> transactionTypes;
  RangeValues? amountRange;
  List<String> selectedCategories;
  List<String> selectedBuckets;
  SortOption sortOption;

  // [NEW SEARCH LOGIC]
  String? searchQuery;

  FilterCriteria({
    this.dateRange,
    List<String>? transactionTypes,
    this.amountRange,
    List<String>? selectedCategories,
    List<String>? selectedBuckets,
    this.sortOption = SortOption.newest,
    this.searchQuery, // [NEW SEARCH LOGIC]
  })  : transactionTypes = transactionTypes ?? [],
        selectedCategories = selectedCategories ?? [],
        selectedBuckets = selectedBuckets ?? [];

  // Getters
  DateTime? get startDate => dateRange?.start;

  // --- [NEW END DATE LOGIC] ---
  // Automatically pushes the end date to 11:59:59.999 PM
  // so all transactions on the selected "To Date" are included.
  DateTime? get endDate {
    if (dateRange?.end == null) return null;
    final d = dateRange!.end;
    return DateTime(d.year, d.month, d.day, 23, 59, 59, 999);
  }
  // --- [END NEW END DATE LOGIC] ---

  bool get hasFilters {
    return dateRange != null ||
        transactionTypes.isNotEmpty ||
        amountRange != null ||
        selectedCategories.isNotEmpty ||
        selectedBuckets.isNotEmpty ||
        sortOption != SortOption.newest ||
        (searchQuery != null && searchQuery!.isNotEmpty); // [NEW SEARCH LOGIC]
  }

  FilterCriteria copyWith({
    DateTimeRange? dateRange,
    List<String>? transactionTypes,
    RangeValues? amountRange,
    List<String>? selectedCategories,
    List<String>? selectedBuckets,
    SortOption? sortOption,
  }) {
    return FilterCriteria(
      dateRange: dateRange ?? this.dateRange,
      transactionTypes: transactionTypes ?? List.from(this.transactionTypes),
      amountRange: amountRange ?? this.amountRange,
      selectedCategories:
          selectedCategories ?? List.from(this.selectedCategories),
      selectedBuckets: selectedBuckets ?? List.from(this.selectedBuckets),
      sortOption: sortOption ?? this.sortOption,
      searchQuery:
          this.searchQuery, // Preserve search when other filters change
    );
  }

  // [NEW SEARCH LOGIC] - Dedicated copy method to easily overwrite search query
  FilterCriteria copyWithSearch(String? search) {
    return FilterCriteria(
      dateRange: this.dateRange,
      transactionTypes: List.from(this.transactionTypes),
      amountRange: this.amountRange,
      selectedCategories: List.from(this.selectedCategories),
      selectedBuckets: List.from(this.selectedBuckets),
      sortOption: this.sortOption,
      searchQuery: search,
    );
  }

  bool matches(ExpenseTransactionModel txn) {
    // 1. Date Check (Now strictly respects the new 23:59:59 boundary)
    if (startDate != null && endDate != null) {
      if (txn.date.isBefore(startDate!) || txn.date.isAfter(endDate!)) {
        return false;
      }
    }

    // 2. Type Check
    if (transactionTypes.isNotEmpty) {
      if (!transactionTypes.contains(txn.type)) return false;
    }

    // 3. Amount Check
    if (amountRange != null) {
      if (txn.amount < amountRange!.start || txn.amount > amountRange!.end) {
        return false;
      }
    }

    // 4. Category Check
    if (selectedCategories.isNotEmpty) {
      if (!selectedCategories.contains(txn.category)) return false;
    }

    // 5. Bucket Check
    if (selectedBuckets.isNotEmpty) {
      // Only apply bucket filter to Expenses
      if (txn.type == 'Expense' && !selectedBuckets.contains(txn.bucket)) {
        return false;
      }
    }

    // 6. Search Check [NEW SEARCH LOGIC]
    if (searchQuery != null && searchQuery!.isNotEmpty) {
      final q = searchQuery!.toLowerCase();
      if (!txn.notes.toLowerCase().contains(q) &&
          !txn.category.toLowerCase().contains(q) &&
          !txn.subCategory.toLowerCase().contains(q) &&
          !txn.amount.toString().contains(q)) {
        return false;
      }
    }

    return true;
  }
}
