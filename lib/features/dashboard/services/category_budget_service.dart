// lib/features/dashboard/services/category_budget_service.dart
import 'dart:convert';
import 'package:budget/core/database/app_database.dart';
import 'package:budget/features/dashboard/models/category_budget_models.dart';
import 'package:drift/drift.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';

class CategoryBudgetService {
  final AppDatabase _db = GetIt.I<AppDatabase>();
  final Uuid _uuid = const Uuid();

  Stream<List<CategoryBudgetSummaryModel>> watchCategoryBudgets() {
    return _db.select(_db.categoryBudgets).watch().switchMap((budgets) {
      if (budgets.isEmpty) return Stream.value([]);

      return Rx.combineLatest2(
        _db.select(_db.expenseTransactions).watch(),
        _db.select(_db.creditTransactions).watch(),
        (List<ExpenseTransaction> expenses, List<CreditTransaction> credits) {
          return budgets.map((budget) {
            final catList = List<String>.from(jsonDecode(budget.categories));
            final bucketList = List<String>.from(jsonDecode(budget.buckets));
            // [NEW] Parse the subcategories list
            final subCatList =
                List<String>.from(jsonDecode(budget.subCategories));

            final spentExpenses = expenses.where((t) {
              if (t.accountId == null || t.accountId!.isEmpty) return false;

              final matchCat = catList.isEmpty || catList.contains(t.category);
              final matchBucket =
                  bucketList.isEmpty || bucketList.contains(t.bucket);
              // [NEW] Check Subcategory match
              final matchSubCat =
                  subCatList.isEmpty || subCatList.contains(t.subCategory);

              return matchCat &&
                  matchBucket &&
                  matchSubCat && // [NEW] Added to condition
                  t.type == 'Expense' &&
                  t.date.isAfter(
                      budget.startDate.subtract(const Duration(seconds: 1))) &&
                  t.date.isBefore(budget.endDate.add(const Duration(days: 1)));
            }).fold(0.0, (sum, t) => sum + t.amount);

            final spentCredits = credits.where((c) {
              final matchCat = catList.isEmpty || catList.contains(c.category);
              final matchBucket =
                  bucketList.isEmpty || bucketList.contains(c.bucket);
              // [NEW] Check Subcategory match
              final matchSubCat =
                  subCatList.isEmpty || subCatList.contains(c.subCategory);

              return matchCat &&
                  matchBucket &&
                  matchSubCat && // [NEW] Added to condition
                  c.type == 'Expense' &&
                  c.date.isAfter(
                      budget.startDate.subtract(const Duration(seconds: 1))) &&
                  c.date.isBefore(budget.endDate.add(const Duration(days: 1)));
            }).fold(0.0, (sum, c) => sum + c.amount);

            return CategoryBudgetSummaryModel(
                budget: budget, spentAmount: spentExpenses + spentCredits);
          }).toList();
        },
      );
    });
  }

  Future<void> addCategoryBudget({
    required List<String> categories,
    required List<String> buckets,
    List<String> subCategories =
        const [], // [NEW] Added with default to avoid breaking old code
    required double amount,
    required String periodType,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    await _db.into(_db.categoryBudgets).insert(
          CategoryBudgetsCompanion(
            id: Value(_uuid.v4()),
            categories: Value(jsonEncode(categories)),
            buckets: Value(jsonEncode(buckets)),
            subCategories: Value(jsonEncode(subCategories)), // [NEW] Save it
            amount: Value(amount),
            periodType: Value(periodType),
            startDate: Value(startDate),
            endDate: Value(endDate),
            isClosed: const Value(false),
          ),
        );
  }

  Future<void> updateCategoryBudget({
    required String id,
    required List<String> categories,
    required List<String> buckets,
    List<String> subCategories = const [], // [NEW] Added with default
    required double amount,
    required String periodType,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    await (_db.update(_db.categoryBudgets)..where((t) => t.id.equals(id)))
        .write(
      CategoryBudgetsCompanion(
        categories: Value(jsonEncode(categories)),
        buckets: Value(jsonEncode(buckets)),
        subCategories: Value(jsonEncode(subCategories)), // [NEW] Update it
        amount: Value(amount),
        periodType: Value(periodType),
        startDate: Value(startDate),
        endDate: Value(endDate),
      ),
    );
  }

  Future<void> settleCategoryBudget(String id) async {
    await (_db.update(_db.categoryBudgets)..where((t) => t.id.equals(id)))
        .write(
      const CategoryBudgetsCompanion(
        isClosed: Value(true),
      ),
    );
  }

  Future<void> deleteCategoryBudget(String id) async {
    await (_db.delete(_db.categoryBudgets)..where((t) => t.id.equals(id))).go();
  }
}
