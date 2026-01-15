import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../database/app_database.dart' as db;
import '../models/transaction_category_model.dart';

class CategoryService {
  final db.AppDatabase _db = db.AppDatabase.instance;
  final _uuid = const Uuid();

  // --- EXPANDED DEFAULT EXPENSES (Now using dynamic Icons.codePoint) ---
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
      'icon': Icons.restaurant.codePoint,
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
      'icon': Icons.home.codePoint,
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
      'icon': Icons.directions_car.codePoint,
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
        'Books/Magazines',
        'Gifts Purchased',
        'Sports Equipment',
        'Stationery',
        'Jewelry',
        'Personal Items',
        'Mobile/Accessories',
      ],
      'icon': Icons.shopping_bag.codePoint,
    },
    'Personal Care': {
      'subs': ['Salon/Spa', 'Gym/Fitness', 'Cosmetics', 'Grooming', 'Massage'],
      'icon': Icons.spa.codePoint,
    },
    'Health': {
      'subs': ['Doctor Fees', 'Medicine', 'Lab Tests', 'Health Insurance'],
      'icon': Icons.medical_services.codePoint,
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
        'Entry Fees',
        'Clubs/Bars'
      ],
      'icon': Icons.movie.codePoint,
    },
    'Travel': {
      'subs': ['Flights', 'Hotels', 'Vacation', 'Visa Fees'],
      'icon': Icons.flight.codePoint,
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
      'icon': Icons.family_restroom.codePoint,
    },
    'Pet Care': {
      'subs': [
        'Pet Food',
        'Grooming',
        'Pet Accessories',
        'Vet Visits',
        'Training'
      ],
      'icon': Icons.pets.codePoint,
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
    'Other': {
      'subs': ['Missing', 'Uncategorized'],
      'icon': Icons.help_outline.codePoint,
    },
    'Non-Calculated Expense': {
      'subs': [],
      'icon': Icons.money_off.codePoint,
    },
  };

  // --- EXPANDED DEFAULT INCOME ---
  final Map<String, dynamic> _defaultIncome = {
    'Salary': {
      'subs': ['Monthly Salary', 'Bonus', 'Incentives', 'Overtime', 'Stipend'],
      'icon': Icons.currency_rupee_sharp.codePoint,
    },
    'Business': {
      'subs': [
        'Business Profit',
        'Sales',
        'Freelance',
        'Consulting',
        'Royalty'
      ],
      'icon': Icons.store.codePoint,
    },
    'Investments': {
      'subs': [
        'Dividends',
        'Interest',
        'Trading Profit',
        'Rental Income',
        'Capital Gains'
      ],
      'icon': Icons.trending_up.codePoint,
    },
    'Gifts & Rewards': {
      'subs': ['Cash Gift', 'Cashback', 'Rewards', 'Lottery', 'Scholarship'],
      'icon': Icons.card_giftcard.codePoint,
    },
    'Refunds': {
      'subs': [
        'Tax Refund',
        'Reimbursements',
        'Bill Adjustments',
        'Failed Transaction Reversals'
      ],
      'icon': Icons.replay.codePoint,
    },
    'Sold Items': {
      'subs': ['Second-hand Sales', 'Property Sale', 'Scrap'],
      'icon': Icons.sell.codePoint,
    },
    'Other': {
      'subs': ['Miscellaneous', 'Uncategorized'],
      'icon': Icons.help_outline.codePoint,
    },
    'Non-Calculated Income': {
      'subs': [],
      'icon': Icons.money_off.codePoint,
    },
  };

  /// INITIALIZE SERVICE (Run once on startup)
  /// Checks for data and seeds if empty
  Future<void> init() async {
    final countExp = _db.transactionCategories.id.count();
    final count = await (_db.selectOnly(_db.transactionCategories)
              ..addColumns([countExp]))
            .map((row) => row.read(countExp))
            .getSingle() ??
        0;

    if (count == 0) {
      await _seedDefaults();
    }
  }

  /// Fetches categories - Pure stream, no side effects
  Stream<List<TransactionCategoryModel>> getCategories() {
    return _db.select(_db.transactionCategories).watch().map((rows) {
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
