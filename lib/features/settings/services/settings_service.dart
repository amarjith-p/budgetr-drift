import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/constants/firebase_constants.dart';
import '../../../core/models/percentage_config_model.dart';

class SettingsService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<PercentageConfig> getPercentageConfig() async {
    final doc = await _db
        .collection(FirebaseConstants.settings)
        .doc('percentages')
        .get();
    if (doc.exists) {
      return PercentageConfig.fromFirestore(doc);
    } else {
      return PercentageConfig.defaultConfig();
    }
  }

  Future<void> setPercentageConfig(PercentageConfig config) {
    return _db
        .collection(FirebaseConstants.settings)
        .doc('percentages')
        .set(config.toMap());
  }

  /// Checks if a Financial Record exists for the current month.
  /// Uses 'financial_records' collection and queries by year/month fields.
  Future<bool> hasCurrentMonthBudget() async {
    final now = DateTime.now();

    // We query for the year and month fields instead of guessing the Doc ID
    final snapshot = await _db
        .collection(FirebaseConstants.financialRecords)
        .where('year', isEqualTo: now.year)
        .where('month', isEqualTo: now.month)
        .limit(1)
        .get();

    return snapshot.docs.isNotEmpty;
  }
}
