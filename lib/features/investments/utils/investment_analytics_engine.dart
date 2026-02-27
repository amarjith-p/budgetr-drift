import 'dart:math';
import 'package:budget/core/design/budgetr_colors.dart';
import 'package:budget/features/investments/models/investment_dto.dart';
import 'package:budget/features/investments/models/investment_log_dto.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SmartInsight {
  final String title;
  final String message;
  final Color color;
  final IconData icon;
  final double? projectedValue;

  SmartInsight({
    required this.title,
    required this.message,
    required this.color,
    required this.icon,
    this.projectedValue,
  });
}

class InvestmentAnalyticsEngine {
  static SmartInsight analyze(InvestmentDto item, List<InvestmentLogDto> logs) {
    final now = DateTime.now();
    // [UPDATED] Strict 2-decimal format
    final fmt =
        NumberFormat.currency(symbol: '₹', decimalDigits: 2, locale: "en_IN");

    if (item.targetAmount == null || item.targetAmount! <= 0) {
      return SmartInsight(
        title: "SET A TARGET",
        message:
            "Add a Target Amount and End Date to unlock AI projections and smart insights.",
        color: Colors.white54,
        icon: Icons.lightbulb_outline_rounded,
      );
    }
    if (item.endDate == null) {
      return SmartInsight(
        title: "MISSING TIMELINE",
        message:
            "You have a target of ${fmt.format(item.targetAmount!)}. Set an End Date to see if you are on track.",
        color: Colors.white54,
        icon: Icons.schedule_rounded,
      );
    }

    final elapsedDays = now.difference(item.startDate).inDays;
    final remainingDays = item.endDate!.difference(now).inDays;

    if (remainingDays <= 0) {
      final hit = item.currentMarketValue >= item.targetAmount!;
      return SmartInsight(
        title: hit ? "TARGET REACHED \uD83C\uDF89" : "DEADLINE REACHED",
        message: hit
            ? "Congratulations! You successfully reached your target amount."
            : "The end date has passed, and you fell short by ${fmt.format(item.targetAmount! - item.currentMarketValue)}.",
        color: hit ? BudgetrColors.success : Colors.redAccent,
        icon: hit ? Icons.emoji_events_rounded : Icons.warning_amber_rounded,
      );
    }

    final ninetyDaysAgo = now.subtract(const Duration(days: 90));
    double recentInvestments = 0.0;

    for (var log in logs) {
      if (log.date.isAfter(ninetyDaysAgo)) {
        if (log.type == 'invested') {
          recentInvestments += log.amountInvested.abs();
        } else if (log.type == 'withdrawn') {
          recentInvestments -= log.amountInvested.abs();
        }
      }
    }

    double divisor = 3.0;
    if (elapsedDays < 90 && elapsedDays > 0) {
      divisor = elapsedDays / 30.44;
    }
    final monthlyVelocity = max(0.0, recentInvestments / max(1.0, divisor));
    final monthsLeft = remainingDays / 30.44;

    double annualRate = 0.0;
    bool isZeroGrowthWarning = false;
    bool usingExpectedReturnFallback = false;
    bool hasActualGrowth =
        (item.currentMarketValue - item.totalInvestedAmount).abs() > 1.0;

    if (hasActualGrowth &&
        item.xirr != null &&
        item.xirr! != 0.0 &&
        item.xirr! > -100 &&
        item.xirr! < 200) {
      annualRate = item.xirr!;
    } else if (hasActualGrowth &&
        elapsedDays > 30 &&
        item.totalInvestedAmount > 0) {
      double years = elapsedDays / 365.25;
      annualRate =
          (pow(item.currentMarketValue / item.totalInvestedAmount, 1 / years) -
                  1) *
              100;
      annualRate = annualRate.clamp(-100.0, 100.0);
    } else if (item.expectedReturn != null && item.expectedReturn! > 0) {
      annualRate = item.expectedReturn!;
      usingExpectedReturnFallback = true;
    } else {
      annualRate = 0.0;
      if (!hasActualGrowth) isZeroGrowthWarning = true;
    }

    double monthlyRate = annualRate / 12 / 100;

    double fvCorpus = item.currentMarketValue;

    if (usingExpectedReturnFallback && !hasActualGrowth) {
      fvCorpus = 0.0;
      for (var log in logs) {
        if (log.type == 'invested' || log.type == 'withdrawn') {
          double amount = log.amountInvested;
          int daysToEnd = item.endDate!.difference(log.date).inDays;

          if (daysToEnd > 0) {
            double months = daysToEnd / 30.44;
            fvCorpus += amount * pow((1 + monthlyRate), months);
          } else {
            fvCorpus += amount;
          }
        }
      }
    } else {
      if (monthlyRate != 0) {
        fvCorpus = item.currentMarketValue * pow((1 + monthlyRate), monthsLeft);
      }
    }

    double fvSips = 0.0;
    if (monthlyRate > 0 && monthlyVelocity > 0) {
      fvSips = monthlyVelocity *
          ((pow(1 + monthlyRate, monthsLeft) - 1) / monthlyRate) *
          (1 + monthlyRate);
    } else {
      fvSips = monthlyVelocity * monthsLeft;
    }

    double projectedValue = fvCorpus + fvSips;

    if (isZeroGrowthWarning && projectedValue < item.targetAmount!) {
      return SmartInsight(
        title: "NEED MORE DATA",
        message:
            "We don't have enough history to calculate growth. Edit the asset to add an 'Exp. Return %' for accurate projections.",
        color: Colors.blueAccent,
        icon: Icons.info_outline_rounded,
        projectedValue: projectedValue,
      );
    }

    if (projectedValue >= item.targetAmount!) {
      return SmartInsight(
        title: "ON TRACK",
        message:
            "Great job! Based on your pace and returns, you are projected to hit ${fmt.format(projectedValue)}, beating your target.",
        color: BudgetrColors.success,
        icon: Icons.check_circle_outline_rounded,
        projectedValue: projectedValue,
      );
    } else {
      double shortfall = item.targetAmount! - projectedValue;
      double requiredExtraMonthly = shortfall / max(1.0, monthsLeft);

      return SmartInsight(
        title: "FALLING SHORT",
        message:
            "You are projected to reach ${fmt.format(projectedValue)}. Try investing an extra ${fmt.format(requiredExtraMonthly)} per month to close the gap.",
        color: Colors.amber,
        icon: Icons.trending_up_rounded,
        projectedValue: projectedValue,
      );
    }
  }
}
