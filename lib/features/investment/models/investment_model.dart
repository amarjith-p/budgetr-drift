import 'package:cloud_firestore/cloud_firestore.dart';

enum InvestmentType { stock, mutualFund, other }

class InvestmentRecord {
  final String id;
  final String symbol;
  final String name;
  final InvestmentType type;
  final double quantity;
  final double averagePrice;
  final double currentPrice;
  final double previousClose; // NEW: For Day Gain calc
  final String bucket;
  final DateTime lastPurchasedDate;
  final DateTime lastUpdated;

  InvestmentRecord({
    required this.id,
    required this.symbol,
    required this.name,
    required this.type,
    required this.quantity,
    required this.averagePrice,
    required this.currentPrice,
    required this.previousClose,
    required this.bucket,
    required this.lastPurchasedDate,
    required this.lastUpdated,
  });

  // Total Return (Overall)
  double get totalInvested => quantity * averagePrice;
  double get currentValue => quantity * currentPrice;
  double get totalReturn => currentValue - totalInvested;
  double get returnPercentage =>
      totalInvested == 0 ? 0 : (totalReturn / totalInvested) * 100;

  // Day Return (Today)
  double get dayReturn => (currentPrice - previousClose) * quantity;
  double get dayReturnPercentage => previousClose == 0
      ? 0
      : ((currentPrice - previousClose) / previousClose) * 100;

  factory InvestmentRecord.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;

    String typeStr = data['type'] ?? 'InvestmentType.stock';
    InvestmentType t = InvestmentType.stock;
    if (typeStr.contains('mutualFund')) t = InvestmentType.mutualFund;
    if (typeStr.contains('other')) t = InvestmentType.other;

    return InvestmentRecord(
      id: doc.id,
      symbol: data['symbol'] ?? '',
      name: data['name'] ?? '',
      type: t,
      quantity: (data['quantity'] ?? 0.0).toDouble(),
      averagePrice: (data['averagePrice'] ?? 0.0).toDouble(),
      currentPrice: (data['currentPrice'] ?? 0.0).toDouble(),
      previousClose: (data['previousClose'] ?? 0.0).toDouble(), // Load
      bucket: data['bucket'] ?? 'General',
      lastPurchasedDate:
          (data['lastPurchasedDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastUpdated:
          (data['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'symbol': symbol,
      'name': name,
      'type': type.toString(),
      'quantity': quantity,
      'averagePrice': averagePrice,
      'currentPrice': currentPrice,
      'previousClose': previousClose, // Save
      'bucket': bucket,
      'lastPurchasedDate': Timestamp.fromDate(lastPurchasedDate),
      'lastUpdated': Timestamp.fromDate(lastUpdated),
    };
  }
}
