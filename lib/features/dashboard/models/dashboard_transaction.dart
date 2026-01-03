// lib/features/dashboard/models/dashboard_transaction.dart

import 'package:cloud_firestore/cloud_firestore.dart';

enum TransactionSourceType { creditCard, bankAccount }

class DashboardTransaction {
  final String id;
  final double amount;
  final Timestamp date;
  final String category;
  final String subCategory; // NEW FIELD
  final String notes;
  final String bucket;

  final String sourceId;
  final TransactionSourceType sourceType;

  DashboardTransaction({
    required this.id,
    required this.amount,
    required this.date,
    required this.category,
    required this.subCategory, // Required in constructor
    required this.notes,
    required this.bucket,
    required this.sourceId,
    required this.sourceType,
  });
}
