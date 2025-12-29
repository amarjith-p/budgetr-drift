import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../constants/firebase_constants.dart';
import '../models/transaction_category_model.dart';

class CategoryService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // --- EXPANDED DEFAULT EXPENSES ---
  final Map<String, dynamic> _defaultExpense = {
    'Food & Drink': {
      'subs': [
        'Groceries',
        'Dining Out',
        'Online Delivery',
        'Coffee/Tea',
        'Liquor/Bars',
        'Snacks',
      ],
      'icon': Icons.restaurant.codePoint,
    },
    'Housing': {
      'subs': [
        'Rent',
        'Maintenance',
        'Repairs',
        'Furniture',
        'Decor',
        'Property Tax',
      ],
      'icon': Icons.home.codePoint,
    },
    'Transportation': {
      'subs': [
        'Fuel',
        'Cab/Taxi',
        'Public Transport',
        'Vehicle Service',
        'Parking/Tolls',
        'Car Insurance',
      ],
      'icon': Icons.directions_car.codePoint,
    },
    'Utilities': {
      'subs': [
        'Electricity',
        'Water',
        'Internet',
        'Mobile Recharge',
        'Gas/LPG',
        'DTH/Cable',
      ],
      'icon': Icons.lightbulb.codePoint,
    },
    'Shopping': {
      'subs': [
        'Clothing',
        'Electronics',
        'Footwear',
        'Accessories',
        'Online Shopping',
        'Home Appliances',
      ],
      'icon': Icons.shopping_bag.codePoint,
    },
    'Personal Care': {
      'subs': ['Salon/Spa', 'Gym/Fitness', 'Cosmetics', 'Grooming', 'Massage'],
      'icon': Icons.self_improvement.codePoint,
    },
    'Health': {
      'subs': [
        'Doctor Fees',
        'Medicine',
        'Lab Tests',
        'Health Insurance',
        'Dentist',
      ],
      'icon': Icons.medical_services.codePoint,
    },
    'Education': {
      'subs': [
        'School Fees',
        'College Fees',
        'Books',
        'Online Courses',
        'Stationery',
        'Tuition',
      ],
      'icon': Icons.school.codePoint,
    },
    'Entertainment': {
      'subs': [
        'Movies',
        'OTT Subscriptions',
        'Gaming',
        'Concerts',
        'Hobbies',
        'Events',
      ],
      'icon': Icons.movie.codePoint,
    },
    'Travel': {
      'subs': ['Flights', 'Hotels', 'Train/Bus', 'Vacation', 'Visa Fees'],
      'icon': Icons.flight.codePoint,
    },
    'Family & Kids': {
      'subs': [
        'Childcare',
        'Pet Care',
        'Domestic Help',
        'Baby Supplies',
        'Toys',
      ],
      'icon': Icons.family_restroom.codePoint,
    },
    'Financial': {
      'subs': [
        'Loan EMI',
        'Credit Card Bill',
        'Taxes',
        'Investments',
        'Bank Charges',
        'Fines',
      ],
      'icon': Icons.account_balance.codePoint,
    },
    'Work': {
      'subs': ['Office Commute', 'Business Expense', 'Tools/Software'],
      'icon': Icons.work.codePoint,
    },
    'Miscellaneous': {
      'subs': ['Charity', 'Donations', 'Gifts Given', 'Unexpected'],
      'icon': Icons.category.codePoint,
    },
  };

  // --- EXPANDED DEFAULT INCOME ---
  final Map<String, dynamic> _defaultIncome = {
    'Salary': {
      'subs': ['Monthly Salary', 'Bonus', 'Incentives', 'Overtime', 'Stipend'],
      'icon': Icons.account_balance_wallet.codePoint,
    },
    'Business': {
      'subs': [
        'Business Profit',
        'Sales',
        'Freelance',
        'Consulting',
        'Royalty',
      ],
      'icon': Icons.store.codePoint,
    },
    'Investments': {
      'subs': [
        'Dividends',
        'Interest',
        'Trading Profit',
        'Rental Income',
        'Capital Gains',
      ],
      'icon': Icons.trending_up.codePoint,
    },
    'Gifts & Rewards': {
      'subs': ['Cash Gift', 'Cashback', 'Rewards', 'Lottery', 'Scholarship'],
      'icon': Icons.card_giftcard.codePoint,
    },
    'Refunds': {
      'subs': ['Tax Refund', 'Reimbursements', 'Bill Adjustments'],
      'icon': Icons.replay.codePoint,
    },
    'Sold Items': {
      'subs': ['Second-hand Sales', 'Property Sale', 'Scrap'],
      'icon': Icons.sell.codePoint,
    },
    'Other': {
      'subs': ['Miscellaneous', 'Uncategorized'],
      'icon': Icons.add_circle_outline.codePoint,
    },
  };

  /// Fetches categories
  Stream<List<TransactionCategoryModel>> getCategories() async* {
    final collection = _db.collection(FirebaseConstants.categories);
    final snapshot = await collection.get();

    if (snapshot.docs.isEmpty) {
      await _seedDefaults();
    }

    yield* collection.snapshots().map((s) {
      final list = s.docs
          .map((d) => TransactionCategoryModel.fromFirestore(d))
          .toList();
      list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      return list;
    });
  }

  Future<bool> checkDuplicate(
    String name,
    String type, {
    String? excludeId,
  }) async {
    final normalizedName = name.trim().toLowerCase();
    final query = await _db
        .collection(FirebaseConstants.categories)
        .where('type', isEqualTo: type)
        .get();

    return query.docs.any((doc) {
      if (excludeId != null && doc.id == excludeId) return false;
      final docName = (doc.data()['name'] as String?)?.toLowerCase() ?? '';
      return docName == normalizedName;
    });
  }

  Future<void> _seedDefaults() async {
    final batch = _db.batch();
    final collection = _db.collection(FirebaseConstants.categories);

    _defaultExpense.forEach((key, value) {
      final doc = collection.doc();
      batch.set(doc, {
        'name': key,
        'type': 'Expense',
        'subCategories': value['subs'],
        'iconCode': value['icon'],
      });
    });

    _defaultIncome.forEach((key, value) {
      final doc = collection.doc();
      batch.set(doc, {
        'name': key,
        'type': 'Income',
        'subCategories': value['subs'],
        'iconCode': value['icon'],
      });
    });

    await batch.commit();
  }

  /// FACTORY RESET: Deletes ALL categories and re-seeds defaults
  Future<void> resetToDefaults() async {
    final collection = _db.collection(FirebaseConstants.categories);
    final snapshot = await collection.get();

    // Batch limits are 500 ops, generally safe here, but robust logic:
    WriteBatch batch = _db.batch();
    int count = 0;

    for (var doc in snapshot.docs) {
      batch.delete(doc.reference);
      count++;
      // Safety commit if lots of categories
      if (count >= 400) {
        await batch.commit();
        batch = _db.batch();
        count = 0;
      }
    }

    if (count > 0) {
      await batch.commit();
    }

    // Re-create from scratch
    await _seedDefaults();
  }

  Future<void> addCategory(
    String name,
    String type,
    List<String> subs,
    int iconCode,
  ) async {
    await _db.collection(FirebaseConstants.categories).add({
      'name': name,
      'type': type,
      'subCategories': subs,
      'iconCode': iconCode,
    });
  }

  Future<void> updateCategory(TransactionCategoryModel category) async {
    await _db
        .collection(FirebaseConstants.categories)
        .doc(category.id)
        .update(category.toMap());
  }

  Future<void> deleteCategory(String id) async {
    await _db.collection(FirebaseConstants.categories).doc(id).delete();
  }
}
