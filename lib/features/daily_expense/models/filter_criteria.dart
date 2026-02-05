import 'package:flutter/material.dart';
import '../models/expense_models.dart';

enum SortOption { newest, oldest, highestAmount, lowestAmount }

class FilterCriteria {
  DateTimeRange? dateRange;
  List<String> transactionTypes;
  RangeValues? amountRange;
  List<String> selectedCategories;
  List<String> selectedBuckets; // [NEW]
  SortOption sortOption;

  FilterCriteria({
    this.dateRange,
    List<String>? transactionTypes,
    this.amountRange,
    List<String>? selectedCategories,
    List<String>? selectedBuckets, // [NEW]
    this.sortOption = SortOption.newest,
  })  : transactionTypes = transactionTypes ?? [],
        selectedCategories = selectedCategories ?? [],
        selectedBuckets = selectedBuckets ?? []; // [NEW]

  // Getters
  DateTime? get startDate => dateRange?.start;
  DateTime? get endDate => dateRange?.end;

  bool get hasFilters {
    return dateRange != null ||
        transactionTypes.isNotEmpty ||
        amountRange != null ||
        selectedCategories.isNotEmpty ||
        selectedBuckets.isNotEmpty || // [NEW]
        sortOption != SortOption.newest;
  }

  FilterCriteria copyWith({
    DateTimeRange? dateRange,
    List<String>? transactionTypes,
    RangeValues? amountRange,
    List<String>? selectedCategories,
    List<String>? selectedBuckets, // [NEW]
    SortOption? sortOption,
  }) {
    return FilterCriteria(
      dateRange: dateRange ?? this.dateRange,
      transactionTypes: transactionTypes ?? List.from(this.transactionTypes),
      amountRange: amountRange ?? this.amountRange,
      selectedCategories:
          selectedCategories ?? List.from(this.selectedCategories),
      selectedBuckets:
          selectedBuckets ?? List.from(this.selectedBuckets), // [NEW]
      sortOption: sortOption ?? this.sortOption,
    );
  }

  bool matches(ExpenseTransactionModel txn) {
    // 1. Date Check
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

    // 5. Bucket Check [NEW]
    if (selectedBuckets.isNotEmpty) {
      // Only apply bucket filter to Expenses (Income usually doesn't have buckets or is 'Unallocated')
      if (txn.type == 'Expense' && !selectedBuckets.contains(txn.bucket)) {
        return false;
      }
    }

    return true;
  }
}
