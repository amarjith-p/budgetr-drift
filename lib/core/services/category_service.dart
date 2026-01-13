import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../database/app_database.dart' as db;
import '../models/transaction_category_model.dart';

class CategoryService {
  final db.AppDatabase _db = db.AppDatabase.instance;
  final _uuid = const Uuid();

  // --- EXPANDED DEFAULT EXPENSES ---
  final Map<String, dynamic> _defaultExpense = {
    'Food & Drink': {
      'subs': [
        'Groceries',
        'Meat & Seafood',
        'Fruits & Vegetables',
        'Dining Out',
        'Online Delivery',
        'Coffee/Tea',
        'Cooldrinks/Juices',
        'Liquor/Bars',
        'Snacks',
      ],
      'icon': 57538,
    },
    'Housing': {
      'subs': [
        'Rent',
        'Maintenance',
        'Repairs',
        'Furniture',
        'Decor',
        'Property Tax'
      ],
      'icon': 57933,
    },
    'Transportation': {
      'subs': [
        'Fuel',
        'Cab/Taxi',
        'Train/Bus',
        'Metro/Tram',
        'Public Transport',
        'Vehicle Maintenance',
        'Parking/Tolls',
        'Vehicle Insurance',
      ],
      'icon': 57681,
    },
    'Utilities': {
      'subs': [
        'Electricity',
        'Water',
        'WiFi/Internet',
        'Mobile Recharge',
        'Gas/LPG',
        'DTH/Cable'
      ],
      'icon': 58256,
    },
    'Shopping': {
      'subs': [
        'Clothing',
        'Electronics',
        'Footwear',
        'Accessories',
        'Online Shopping',
        'Home Appliances',
        'Books/Magazines',
        'Gifts Purchased',
        'Sports Equipment',
        'Stationery',
        'Jewelry',
        'Personal Items',
        'Mobile/Accessories',
      ],
      'icon': 58694,
    },
    'Personal Care': {
      'subs': ['Salon/Spa', 'Gym/Fitness', 'Cosmetics', 'Grooming', 'Massage'],
      'icon': 58654,
    },
    'Health': {
      'subs': ['Doctor Fees', 'Medicine', 'Lab Tests', 'Health Insurance'],
      'icon': 58361,
    },
    'Education': {
      'subs': [
        'School Fees',
        'College Fees',
        'Books',
        'Online Courses',
        'Stationery',
        'Tuition'
      ],
      'icon': 58620,
    },
    'Entertainment': {
      'subs': [
        'Movies',
        'OTT Subscriptions',
        'Gaming',
        'Concerts',
        'Hobbies',
        'Events',
        'Entry Fees',
        'Clubs/Bars'
      ],
      'icon': 58372,
    },
    'Travel': {
      'subs': ['Flights', 'Hotels', 'Vacation', 'Visa Fees'],
      'icon': 57744,
    },
    'Family & Kids': {
      'subs': [
        'Childcare',
        'Family Outings',
        'Family Support',
        'Domestic Help',
        'Baby Supplies',
        'Toys'
      ],
      'icon': 58002,
    },
    'Pet Care': {
      'subs': [
        'Pet Food',
        'Grooming',
        'Pet Accessories',
        'Vet Visits',
        'Training'
      ],
      'icon': 58493,
    },
    'Financial': {
      'subs': [
        'Loan EMI',
        'Credit Card Bill',
        'Taxes',
        'Investments',
        'Bank Charges',
        'Fines',
        'Failed Transactions',
        'Capital Losses'
      ],
      'icon': 57356,
    },
    'Work': {
      'subs': ['Office Commute', 'Business Expense', 'Tools/Software'],
      'icon': 58857,
    },
    'Miscellaneous': {
      'subs': ['Charity', 'Donations', 'Gifts Given', 'Unexpected'],
      'icon': 57540,
    },
    'Other': {
      'subs': ['Missing', 'Uncategorized'],
      'icon': 57415,
    },
    'Non-Calculated Expense': {
      'subs': [],
      'icon': 57550,
    },
  };

  // --- EXPANDED DEFAULT INCOME ---
  final Map<String, dynamic> _defaultIncome = {
    'Salary': {
      'subs': ['Monthly Salary', 'Bonus', 'Incentives', 'Overtime', 'Stipend'],
      'icon': 57359,
    },
    'Business': {
      'subs': [
        'Business Profit',
        'Sales',
        'Freelance',
        'Consulting',
        'Royalty'
      ],
      'icon': 58715,
    },
    'Investments': {
      'subs': [
        'Dividends',
        'Interest',
        'Trading Profit',
        'Rental Income',
        'Capital Gains'
      ],
      'icon': 58808,
    },
    'Gifts & Rewards': {
      'subs': ['Cash Gift', 'Cashback', 'Rewards', 'Lottery', 'Scholarship'],
      'icon': 58696,
    },
    'Refunds': {
      'subs': [
        'Tax Refund',
        'Reimbursements',
        'Bill Adjustments',
        'Failed Transaction Reversals'
      ],
      'icon': 57429,
    },
    'Sold Items': {
      'subs': ['Second-hand Sales', 'Property Sale', 'Scrap'],
      'icon': 58652,
    },
    'Other': {
      'subs': ['Miscellaneous', 'Uncategorized'],
      'icon': 57415,
    },
    'Non-Calculated Income': {
      'subs': [],
      'icon': 57550,
    },
  };

  /// Fetches categories
  Stream<List<TransactionCategoryModel>> getCategories() async* {
    // Check if table is empty
    final countExp = _db.transactionCategories.id.count();

    // FIX: Using cascade operator (..) so we can chain .map on the query object, not on 'void'
    final count = await (_db.selectOnly(_db.transactionCategories)
              ..addColumns([countExp]))
            .map((row) => row.read(countExp))
            .getSingle() ??
        0;

    if (count == 0) {
      await _seedDefaults();
    }

    yield* _db.select(_db.transactionCategories).watch().map((rows) {
      final list = rows.map((row) {
        return TransactionCategoryModel(
          id: row.id,
          name: row.name,
          type: row.type,
          subCategories: List<String>.from(jsonDecode(row.subCategories)),
          iconCode: row.iconCode,
        );
      }).toList();
      list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      return list;
    });
  }

  Future<bool> checkDuplicate(String name, String type,
      {String? excludeId}) async {
    final normalizedName = name.trim().toLowerCase();

    final rows = await (_db.select(_db.transactionCategories)
          ..where((t) => t.type.equals(type)))
        .get();

    return rows.any((row) {
      if (excludeId != null && row.id == excludeId) return false;
      return row.name.toLowerCase() == normalizedName;
    });
  }

  Future<void> _seedDefaults() async {
    await _db.batch((batch) {
      _defaultExpense.forEach((key, value) {
        batch.insert(
            _db.transactionCategories,
            db.TransactionCategoriesCompanion.insert(
              id: _uuid.v4(),
              name: key,
              type: 'Expense',
              subCategories: jsonEncode(value['subs']),
              iconCode: Value(value['icon']),
            ));
      });

      _defaultIncome.forEach((key, value) {
        batch.insert(
            _db.transactionCategories,
            db.TransactionCategoriesCompanion.insert(
              id: _uuid.v4(),
              name: key,
              type: 'Income',
              subCategories: jsonEncode(value['subs']),
              iconCode: Value(value['icon']),
            ));
      });
    });
  }

  /// FACTORY RESET: Deletes ALL categories and re-seeds defaults
  Future<void> resetToDefaults() async {
    await _db.transaction(() async {
      await _db.delete(_db.transactionCategories).go();
      await _seedDefaults();
    });
  }

  Future<void> addCategory(
      String name, String type, List<String> subs, int iconCode) async {
    await _db
        .into(_db.transactionCategories)
        .insert(db.TransactionCategoriesCompanion.insert(
          id: _uuid.v4(),
          name: name,
          type: type,
          subCategories: jsonEncode(subs),
          iconCode: Value(iconCode),
        ));
  }

  Future<void> updateCategory(TransactionCategoryModel category) async {
    await (_db.update(_db.transactionCategories)
          ..where((t) => t.id.equals(category.id)))
        .write(db.TransactionCategoriesCompanion(
      name: Value(category.name),
      type: Value(category.type),
      subCategories: Value(jsonEncode(category.subCategories)),
      iconCode: Value(category.iconCode),
    ));
  }

  Future<void> deleteCategory(String id) async {
    await (_db.delete(_db.transactionCategories)..where((t) => t.id.equals(id)))
        .go();
  }
}
