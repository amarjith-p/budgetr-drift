import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionCategoryModel {
  final String id;
  final String name;
  final String type; // 'Expense' or 'Income'
  final List<String> subCategories;
  final int? iconCode;

  TransactionCategoryModel({
    required this.id,
    required this.name,
    required this.type,
    required this.subCategories,
    this.iconCode,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'type': type,
      'subCategories': subCategories,
      'iconCode': iconCode,
    };
  }

  factory TransactionCategoryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Sort Sub-Categories Alphabetically immediately upon creation
    final subs = List<String>.from(data['subCategories'] ?? []);
    subs.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

    return TransactionCategoryModel(
      id: doc.id,
      name: data['name'] ?? '',
      type: data['type'] ?? 'Expense',
      subCategories: subs,
      iconCode: data['iconCode'],
    );
  }
}
