// lib/features/dashboard/widgets/category_allocation_list_item.dart
import 'package:budget/core/constants/icon_constants.dart';
import 'package:budget/core/design/budgetr_colors.dart';
import 'package:budget/core/services/category_service.dart';
import 'package:budget/core/models/transaction_category_model.dart';
import 'package:budget/core/widgets/status_bottom_sheet.dart';
import 'package:budget/features/dashboard/models/category_budget_models.dart';
import 'package:budget/features/dashboard/screens/category_budget_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';

class CategoryAllocationListItem extends StatelessWidget {
  final CategoryBudgetSummaryModel model;
  final NumberFormat currencyFormat;
  final VoidCallback? onEdit;
  final VoidCallback? onSettle;
  final VoidCallback onDelete;

  const CategoryAllocationListItem({
    super.key,
    required this.model,
    required this.currencyFormat,
    this.onEdit,
    this.onSettle,
    required this.onDelete,
  });

  void _showSelectedCategoriesInfo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding:
            const EdgeInsets.only(top: 24, bottom: 32, left: 24, right: 24),
        decoration: const BoxDecoration(
          color: BudgetrColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                  width: 48,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10))),
            ),
            Row(
              children: [
                Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: BudgetrColors.accent.withOpacity(0.1),
                        shape: BoxShape.circle),
                    child: const Icon(Icons.account_tree_rounded,
                        color: BudgetrColors.accent, size: 24)),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Matrix Filters",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5)),
                      SizedBox(height: 2),
                      Text("Items tracking this budget",
                          style:
                              TextStyle(color: Colors.white54, fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (model.bucketList.isNotEmpty) ...[
              Text("TARGET BUCKETS",
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2)),
              const SizedBox(height: 12),
              Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children:
                      model.bucketList.map((b) => _buildChip(b)).toList()),
              const SizedBox(height: 24),
            ],
            if (model.categoryList.isNotEmpty) ...[
              Text("TARGET CATEGORIES",
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2)),
              const SizedBox(height: 12),
              Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children:
                      model.categoryList.map((c) => _buildChip(c)).toList()),
              const SizedBox(height: 24),
            ],
            // [NEW] Subcategories Info Display
            if (model.subCategoryList.isNotEmpty) ...[
              Text("TARGET SUBCATEGORIES",
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2)),
              const SizedBox(height: 12),
              Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children:
                      model.subCategoryList.map((s) => _buildChip(s)).toList()),
              const SizedBox(height: 36),
            ] else ...[
              const SizedBox(height: 12),
            ],
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.08),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    elevation: 0),
                onPressed: () => Navigator.pop(context),
                child: const Text("Close",
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

  Widget _buildChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.1))),
      child: Text(text,
          style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontWeight: FontWeight.w600)),
    );
  }

  void _handleDelete(BuildContext context) {
    HapticFeedback.mediumImpact();
    showStatusSheet(
      context: context,
      title: "Delete Budget?",
      message:
          "Are you sure you want to delete this custom budget?\n\nThis will remove the tracking limit, but your actual expense transactions will not be deleted.",
      icon: Icons.delete_outline_rounded,
      color: Colors.redAccent,
      cancelButtonText: "Cancel",
      onCancel: () {},
      buttonText: "Delete Budget",
      onDismiss: () => onDelete(),
    );
  }

  void _handleSettle(BuildContext context) {
    HapticFeedback.mediumImpact();
    showStatusSheet(
      context: context,
      title: "Settle & Close Budget?",
      message:
          "Are you sure you want to close this custom budget?\n\nIt will be moved to the Settled tab and can no longer be edited.",
      icon: Icons.lock_outline_rounded,
      color: const Color(0xFF00E676),
      cancelButtonText: "Cancel",
      onCancel: () {},
      buttonText: "Settle Budget",
      onDismiss: () {
        if (onSettle != null) onSettle!();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isClosed = model.budget.isClosed;

    Color progressColor = isClosed ? Colors.white54 : const Color(0xFF00E676);
    if (!isClosed) {
      if (model.progressPercentage > 0.85)
        progressColor = const Color(0xFFFF5252);
      else if (model.progressPercentage > 0.65)
        progressColor = const Color(0xFFFFB74D);
    }

    final dateStr =
        "${DateFormat('dd MMM').format(model.budget.startDate)} - ${DateFormat('dd MMM').format(model.budget.endDate)}";

    // [NEW] Dynamic Title Builder with Subcategory Support
    String title = "Global Budget";
    final int cats = model.categoryList.length;
    final int bucks = model.bucketList.length;
    final int subs = model.subCategoryList.length;

    if (cats > 0 && bucks > 0 && subs > 0) {
      title = "Complex Matrix";
    } else if (cats > 0 && bucks > 0) {
      title = "$cats Cats in $bucks Buckets";
    } else if (subs > 0 && bucks > 0) {
      title = "$subs Subs in $bucks Buckets";
    } else if (cats > 0 && subs > 0) {
      title = "$subs Subs in $cats Cats";
    } else if (subs > 0) {
      title = subs > 1 ? "$subs Subcategories" : model.subCategoryList.first;
    } else if (cats > 0) {
      title = cats > 1 ? "$cats Categories" : model.categoryList.first;
    } else if (bucks > 0) {
      title = bucks > 1 ? "$bucks Buckets" : model.bucketList.first;
    }

    int activeLists =
        (cats > 0 ? 1 : 0) + (bucks > 0 ? 1 : 0) + (subs > 0 ? 1 : 0);
    final bool showInfoIcon =
        activeLists > 1 || cats > 1 || bucks > 1 || subs > 1;

    return StreamBuilder<List<TransactionCategoryModel>>(
        stream: GetIt.I<CategoryService>().getCategories(),
        builder: (context, snapshot) {
          final categories = snapshot.data ?? [];
          IconData displayIcon = Icons.account_tree_rounded;

          if (cats == 0 && subs == 0 && bucks > 0)
            displayIcon = Icons.account_balance_wallet_rounded;
          else if (cats == 1 && bucks == 0 && subs == 0) {
            try {
              final cat = categories
                  .firstWhere((c) => c.name == model.categoryList.first);
              if (cat.iconCode != null)
                displayIcon = IconConstants.getIconByCode(cat.iconCode!);
            } catch (_) {}
          } else if (cats == 0 && bucks == 0 && subs == 0)
            displayIcon = Icons.all_inclusive_rounded;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Slidable(
              key: ValueKey(model.budget.id),
              startActionPane: isClosed
                  ? null
                  : ActionPane(
                      motion: const DrawerMotion(),
                      extentRatio: 0.5,
                      children: [
                        SlidableAction(
                          onPressed: (_) {
                            HapticFeedback.mediumImpact();
                            if (onEdit != null) onEdit!();
                          },
                          backgroundColor: Colors.blueAccent.withOpacity(0.9),
                          foregroundColor: Colors.white,
                          icon: Icons.edit_outlined,
                          label: "Edit",
                          borderRadius: const BorderRadius.horizontal(
                              left: Radius.circular(8)),
                        ),
                        SlidableAction(
                          onPressed: (_) => _handleSettle(context),
                          backgroundColor:
                              const Color(0xFF00E676).withOpacity(0.9),
                          foregroundColor: Colors.white,
                          icon: Icons.check_circle_outline_rounded,
                          label: "Settle",
                        ),
                      ],
                    ),
              endActionPane: ActionPane(
                motion: const DrawerMotion(),
                extentRatio: 0.26,
                children: [
                  SlidableAction(
                    onPressed: (_) => _handleDelete(context),
                    backgroundColor: Colors.redAccent.withOpacity(0.9),
                    foregroundColor: Colors.white,
                    icon: Icons.delete_outline,
                    label: "Delete",
                    borderRadius: isClosed
                        ? BorderRadius.circular(8)
                        : const BorderRadius.horizontal(
                            right: Radius.circular(8)),
                  ),
                ],
              ),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => CategoryBudgetDetailsScreen(
                            model: model, currencyFormat: currencyFormat)),
                  );
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: isClosed
                        ? const Color(0xFF0F172A)
                        : const Color(0xFF1B263B).withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            backgroundColor: isClosed
                                ? Colors.white.withOpacity(0.05)
                                : BudgetrColors.accent.withOpacity(0.1),
                            radius: 20,
                            child: Icon(
                                isClosed
                                    ? Icons.lock_outline_rounded
                                    : displayIcon,
                                color: isClosed
                                    ? Colors.white54
                                    : BudgetrColors.accent,
                                size: 20),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Flexible(
                                      child: Text(
                                        title,
                                        style: TextStyle(
                                            color: isClosed
                                                ? Colors.white54
                                                : Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (showInfoIcon) ...[
                                      const SizedBox(width: 6),
                                      GestureDetector(
                                        onTap: () {
                                          HapticFeedback.lightImpact();
                                          _showSelectedCategoriesInfo(context);
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                              color: Colors.white
                                                  .withOpacity(0.05),
                                              shape: BoxShape.circle),
                                          child: Icon(
                                              Icons.info_outline_rounded,
                                              color: isClosed
                                                  ? Colors.white54
                                                  : BudgetrColors.accent,
                                              size: 14),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 6,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Text(dateStr,
                                        style: TextStyle(
                                            color: Colors.white.withOpacity(
                                                isClosed ? 0.3 : 0.5),
                                            fontSize: 11)),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.05),
                                          borderRadius:
                                              BorderRadius.circular(4)),
                                      child: Text(model.budget.periodType,
                                          style: TextStyle(
                                              color: Colors.white.withOpacity(
                                                  isClosed ? 0.4 : 0.7),
                                              fontSize: 9,
                                              fontWeight: FontWeight.w600)),
                                    ),
                                    if (isClosed)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                            color: Colors.orangeAccent
                                                .withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(4)),
                                        child: const Text("SETTLED",
                                            style: TextStyle(
                                                color: Colors.orangeAccent,
                                                fontSize: 9,
                                                fontWeight: FontWeight.w600)),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(currencyFormat.format(model.budget.amount),
                                  style: TextStyle(
                                      color: isClosed
                                          ? Colors.white54
                                          : Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15)),
                              const SizedBox(height: 4),
                              Text("Limit",
                                  style: TextStyle(
                                      color: Colors.white.withOpacity(0.4),
                                      fontSize: 11)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: model.progressPercentage,
                          backgroundColor: Colors.white.withOpacity(0.05),
                          valueColor:
                              AlwaysStoppedAnimation<Color>(progressColor),
                          minHeight: 6,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                              "Spent: ${currencyFormat.format(model.spentAmount)}",
                              style: TextStyle(
                                  color: Colors.white
                                      .withOpacity(isClosed ? 0.3 : 0.5),
                                  fontSize: 11)),
                          Text(
                              "Left: ${currencyFormat.format(model.remainingAmount)}",
                              style: TextStyle(
                                  color: progressColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
  }
}
