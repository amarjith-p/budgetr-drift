import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/firebase_constants.dart';
import '../../../core/models/percentage_config_model.dart';
import '../../daily_expense/models/expense_models.dart';
import '../managers/budget_guardian_manager.dart';

class BudgetNotificationService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Call this from your UI immediately after a successful transaction add.
  Future<void> checkAndTriggerNotification(
      ExpenseTransactionModel newTxn) async {
    // 1. Basic Validation
    if (newTxn.type != 'Expense') return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final isEnabled = prefs.getBool('notif_budget_enabled') ?? false;

      if (!isEnabled) {
        print("🔕 [Budget Service] Budget Guardian is disabled in settings.");
        return;
      }

      print(
          "🔍 [Budget Service] Analyzing budget health for: ${newTxn.bucket}...");

      // 2. Define Time Window (Current Month)
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

      // 3. Fetch Total Income (The Baseline)
      final incomeQuery = await _db
          .collection(FirebaseConstants.expenseTransactions)
          .where('type', isEqualTo: 'Income')
          .where('date',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth))
          .get();

      double totalIncome = 0.0;
      for (var doc in incomeQuery.docs) {
        totalIncome += (doc.data()['amount'] ?? 0.0) as double;
      }

      if (totalIncome <= 0) {
        print(
            "⚠️ [Budget Service] No income recorded this month. Cannot calculate ratios.");
        return;
      }

      // 4. Fetch Config from Firestore
      // Ensure your Firestore has collection 'settings' -> doc 'percentage_config'
      final configDoc =
          await _db.collection('settings').doc('percentages').get();

      if (!configDoc.exists) {
        print(
            "❌ [Budget Service] Config document 'settings/percentage_config' not found.");
        return;
      }

      final config = PercentageConfig.fromFirestore(configDoc);

      // Find the specific bucket config (e.g., 'Lifestyle' -> 30%)
      final categoryConfig = config.categories.firstWhere(
        (c) => c.name == newTxn.bucket,
        orElse: () => CategoryConfig(name: 'Unknown', percentage: 0),
      );

      if (categoryConfig.percentage <= 0) {
        print(
            "ℹ️ [Budget Service] No budget allocated for bucket: ${newTxn.bucket}");
        return;
      }

      // 5. Calculate Limits
      final double limitAmount =
          totalIncome * (categoryConfig.percentage / 100);

      // 6. Fetch Current Spending in this Bucket
      final expenseQuery = await _db
          .collection(FirebaseConstants.expenseTransactions)
          .where('type', isEqualTo: 'Expense')
          .where('bucket', isEqualTo: newTxn.bucket)
          .where('date',
              isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfMonth))
          .get();

      double currentSpent = 0.0;
      for (var doc in expenseQuery.docs) {
        currentSpent += (doc.data()['amount'] ?? 0.0) as double;
      }

      print(
          "📊 [Budget Service] ${newTxn.bucket}: Spent $currentSpent / Limit $limitAmount");

      // 7. Trigger Notification Manager
      await BudgetGuardianManager().checkBudgetHealth(
        bucketName: newTxn.bucket,
        currentSpent: currentSpent,
        totalAllocated: limitAmount,
        isEnabled: true,
      );
    } catch (e) {
      print("❌ [Budget Service] Error executing check: $e");
    }
  }
}
