class Settlement {
  final String id;
  final int year;
  final int month;

  final Map<String, double> allocations;
  final Map<String, double> expenses;
  // Balances are derived (Allocation - Expense)

  final double totalIncome;
  final double totalExpense;
  final double totalBalance;
  final DateTime settledAt;

  // NEW: Persisted order to match Dashboard/FinancialRecord
  final List<String> bucketOrder;

  Settlement({
    required this.id,
    required this.year,
    required this.month,
    required this.allocations,
    required this.expenses,
    required this.totalIncome,
    required this.totalExpense,
    required this.settledAt,
    required this.bucketOrder, // Required field
  }) : totalBalance = totalIncome - totalExpense;

  double getBalanceFor(String category) {
    return (allocations[category] ?? 0.0) - (expenses[category] ?? 0.0);
  }

  // factory Settlement.fromFirestore(DocumentSnapshot doc) {
  //   Map data = doc.data() as Map<String, dynamic>;

  //   Map<String, double> allocations = {};
  //   Map<String, double> expenses = {};

  //   if (data.containsKey('allocations') && data.containsKey('expenses')) {
  //     allocations = Map<String, double>.from(
  //       data['allocations'].map((k, v) => MapEntry(k, (v as num).toDouble())),
  //     );
  //     expenses = Map<String, double>.from(
  //       data['expenses'].map((k, v) => MapEntry(k, (v as num).toDouble())),
  //     );
  //   } else {
  //     // Legacy Support
  //     allocations = {
  //       'Necessities': (data['necessitiesAllocation'] ?? 0.0).toDouble(),
  //       'Lifestyle': (data['lifestyleAllocation'] ?? 0.0).toDouble(),
  //       'Investment': (data['investmentAllocation'] ?? 0.0).toDouble(),
  //       'Emergency': (data['emergencyAllocation'] ?? 0.0).toDouble(),
  //       'Buffer': (data['bufferAllocation'] ?? 0.0).toDouble(),
  //     };
  //     expenses = {
  //       'Necessities': (data['necessitiesExpense'] ?? 0.0).toDouble(),
  //       'Lifestyle': (data['lifestyleExpense'] ?? 0.0).toDouble(),
  //       'Investment': (data['investmentExpense'] ?? 0.0).toDouble(),
  //       'Emergency': (data['emergencyExpense'] ?? 0.0).toDouble(),
  //       'Buffer': (data['bufferExpense'] ?? 0.0).toDouble(),
  //     };
  //   }

  //   return Settlement(
  //     id: doc.id,
  //     year: data['year'] ?? 0,
  //     month: data['month'] ?? 0,
  //     allocations: allocations,
  //     expenses: expenses,
  //     totalIncome: (data['totalIncome'] ?? 0.0).toDouble(),
  //     totalExpense: (data['totalExpense'] ?? 0.0).toDouble(),
  //     settledAt: data['settledAt'] ?? Timestamp.now(),
  //     // Load bucketOrder or empty list for legacy
  //     bucketOrder:
  //         (data['bucketOrder'] as List<dynamic>?)
  //             ?.map((e) => e.toString())
  //             .toList() ??
  //         [],
  //   );
  // }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'year': year,
      'month': month,
      'allocations': allocations,
      'expenses': expenses,
      'totalIncome': totalIncome,
      'totalExpense': totalExpense,
      'totalBalance': totalBalance,
      'settledAt': settledAt,
      'bucketOrder': bucketOrder, // Persist order
    };
  }
}
