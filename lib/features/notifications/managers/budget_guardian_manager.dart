import 'package:flutter/material.dart';
import '../services/notification_service.dart';
import '../services/notification_channels.dart';

class BudgetGuardianManager {
  static final BudgetGuardianManager _instance =
      BudgetGuardianManager._internal();
  factory BudgetGuardianManager() => _instance;
  BudgetGuardianManager._internal();

  final NotificationService _service = NotificationService();

  Future<void> checkBudgetHealth({
    required String bucketName,
    required double currentSpent,
    required double totalAllocated,
    bool isEnabled = true,
  }) async {
    if (!isEnabled) return;
    if (totalAllocated <= 0) return;

    final double usageRatio = currentSpent / totalAllocated;

    // 1. Critical Breach (Over 100%)
    if (usageRatio >= 1.0) {
      await _service.showImmediate(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: '⚠️ Budget Breach: $bucketName',
        body:
            'You have exceeded your $bucketName limit. Stop spending immediately.',
        channelId: NotificationChannels.budgetBreach,
      );
    }
    // 2. Warning Zone (90%)
    else if (usageRatio >= 0.90) {
      await _service.showImmediate(
        id: 888 + bucketName.hashCode, // One warning per bucket session/refresh
        title: 'High Usage Warning: $bucketName',
        body: 'You are at ${(usageRatio * 100).toInt()}% of your budget.',
        channelId: NotificationChannels.budgetBreach,
      );
    }
  }
}
