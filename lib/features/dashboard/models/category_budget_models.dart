// lib/features/dashboard/models/category_budget_models.dart
import 'dart:convert';
import 'package:budget/core/database/app_database.dart';

class CategoryBudgetSummaryModel {
  final CategoryBudget budget;
  final double spentAmount;
  final double remainingAmount;
  final double progressPercentage;
  final List<String> categoryList;
  final List<String> bucketList;
  final List<String> subCategoryList; // [NEW] Added Subcategory List

  CategoryBudgetSummaryModel({
    required this.budget,
    required this.spentAmount,
  })  : remainingAmount = budget.amount - spentAmount,
        progressPercentage = (budget.amount > 0)
            ? (spentAmount / budget.amount).clamp(0.0, 1.0)
            : 0.0,
        categoryList = List<String>.from(jsonDecode(budget.categories)),
        bucketList = List<String>.from(jsonDecode(budget.buckets)),
        // [NEW] Decode the subcategories safely
        subCategoryList = List<String>.from(jsonDecode(budget.subCategories));
}
