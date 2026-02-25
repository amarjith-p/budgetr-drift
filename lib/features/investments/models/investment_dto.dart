import 'package:flutter/foundation.dart';

enum InvestmentType {
  mutualFund,
  stocks,
  bonds,
  fixedDeposit,
  recurringDeposit,
  p2pLending,
  savingsAccount,
  others
}

class InvestmentDto {
  final int? id;
  final String name;
  final InvestmentType type;
  final String? subType;
  final String providerName;
  final String? providerWebsite;
  final DateTime startDate;
  final DateTime? endDate;
  final double? expectedReturn;
  final bool isActive;

  // Additional Info
  final String? folioNumber;
  final String? units;
  final String? brokerName;
  final String? linkedBankName;
  final String? linkedBankAccount;
  final String? purpose;
  final String? notes;

  // [NEW]
  final String? specialId;

  // Dashboard Aggregates
  final double totalInvestedAmount;
  final double currentMarketValue;
  final double totalGainLoss;
  final double returnPercentage;
  final double? xirr;

  InvestmentDto({
    this.id,
    required this.name,
    required this.type,
    this.subType,
    required this.providerName,
    this.providerWebsite,
    required this.startDate,
    this.endDate,
    this.expectedReturn,
    this.isActive = true,
    this.folioNumber,
    this.units,
    this.brokerName,
    this.linkedBankName,
    this.linkedBankAccount,
    this.purpose,
    this.notes,
    this.specialId, // [NEW]
    this.totalInvestedAmount = 0.0,
    this.currentMarketValue = 0.0,
    this.totalGainLoss = 0.0,
    this.returnPercentage = 0.0,
    this.xirr,
  });

  static InvestmentType stringToType(String typeStr) {
    return InvestmentType.values.firstWhere(
      (e) => e.toString().split('.').last == typeStr,
      orElse: () => InvestmentType.others,
    );
  }

  static String typeToString(InvestmentType type) {
    return type.toString().split('.').last;
  }

  String get displayType {
    if (type == InvestmentType.others &&
        subType != null &&
        subType!.isNotEmpty) {
      return subType!;
    }
    switch (type) {
      case InvestmentType.mutualFund:
        return 'Mutual Fund';
      case InvestmentType.stocks:
        return 'Stocks';
      case InvestmentType.bonds:
        return 'Bonds';
      case InvestmentType.fixedDeposit:
        return 'Fixed Deposit';
      case InvestmentType.recurringDeposit:
        return 'Recurring Deposit';
      case InvestmentType.p2pLending:
        return 'P2P Lending';
      case InvestmentType.savingsAccount:
        return 'Savings Account';
      default:
        return 'Other';
    }
  }
}
