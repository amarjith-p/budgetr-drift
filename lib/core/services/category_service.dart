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
    'Food & Grocery': {
      'subs': [
        'Groceries',
        'Meat/Seafood',
        'Fruits/Vegetables',
        'Online Mart Delivery',
        'Bakery/Snacks',
        'Supplements',
        'Baby Food',
        'Other Food & Grocery'
      ],
      'icon': Icons.local_grocery_store.codePoint,
    },
    'Dining Out': {
      'subs': [
        'Restaurants',
        'Online Food Delivery',
        'Coffee/Tea',
        'Cooldrinks/Juices',
        'Cakes/Bakes',
        'Liquor/Bars',
        'Snacks',
        'Fast Food',
        'Cafe',
        'Street Food',
        'Other Dining Out'
      ],
      'icon': Icons.restaurant.codePoint,
    },
    'Housing': {
      'subs': [
        'Rent',
        'Maintenance Charges',
        'Housing Repairs',
        'Furniture',
        'Home Decor',
        'Other Housing'
      ],
      'icon': Icons.home.codePoint,
    },
    'Travel & Transportation': {
      'subs': [
        'Bus Fare',
        'Auto Rickshaw',
        'Cab/Taxi',
        'Train Fare',
        'Metro/Tram',
        'Flight',
        'Public Transport',
        'Hotel Stays',
        'Tour Packages',
        'Sightseeing',
        'Travel Food',
        'Travel Insurance',
        'Visa Fees',
        'Entry Fees',
      ],
      'icon': Icons.flight.codePoint,
    },
    'Vehicles': {
      'subs': [
        'Petrol/Diesel',
        'EV Charging',
        'Vehicle Services',
        'Vehicle Repairs',
        'Vehicle Insurance',
        'Vehicle Accessories',
        'Vehicle Spare Parts',
        'Vehicle Cleaning',
        'Tyre Replacement',
        'Road Tax',
        'Parking Fees',
        'Toll Charges',
        'Pollution Certificate',
        'Other Vehicle Expenses'
      ],
      'icon': Icons.directions_car.codePoint,
    },
    'Utilities & Bills': {
      'subs': [
        'Electricity',
        'Water',
        'WiFi/Internet',
        'Mobile Recharge',
        'Gas/LPG',
        'DTH/Cable',
        'Streaming Services',
        'OTT Subscriptions',
        'Software Subscriptions',
        'Other Utilities & Bills'
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
      'subs': ['Salon/Spa', 'Gym/Fitness', 'Cosmetics', 'Grooming', 'Spa/Wellness', 'Personal Hygiene', 'Other Personal Care'],
      'icon': Icons.spa.codePoint,
    },
    'Healthcare': {
      'subs': ['Doctor Consultation', 'Medicine', 'Lab Tests', 'Scans/Imaging', 'Health Insurance', 'Hospital Expenses', 'Therapy/Counseling', 'Physiotherapy', 'Other Healthcare'],
      'icon': Icons.medical_services.codePoint,
    },
    'Education': {
      'subs': [
        'School Fees',
        'College Fees',
        'Coaching Classes',
        'Tution Fees',
        'Books',
        'Online Courses',
        'Certifications',
        'Exam Fees',
      ],
      'icon': Icons.school.codePoint,
    },
    'Entertainment': {
      'subs': [
        'Movies',
        'Gaming',
        'Concerts',
        'Hobbies',
        'Events',
        'Clubs/Bars',
        'Hobbies',
        'Recreation'
      ],
      'icon': Icons.movie.codePoint,
    },
    'Family & Dependents': {
      'subs': [
        'Parent Support',
        'Spouse Support',
        'Childcare',
        'Child Activities',
        'Family Outings',
        'Family Support',
        'Domestic Help',
        'Baby Supplies',
        'Toys'
        'Family Gifts',
      ],
      'icon': Icons.family_restroom.codePoint,
    },
    'Pet Care': {
      'subs': [
        'Pet Food',
        'Grooming',
        'Pet Accessories',
        'Vet Visits',
        'Training',
        'Pet Medicine'
      ],
      'icon': Icons.pets.codePoint,
    },
    'Taxes & Government Charges': {
      'subs': [
        'Income Tax',
        'Property Tax',
        'Professional Tax',
        'Government Fees',
        'Documentation Charges',
        'Surcharges',
        'Fines/Penalties',
        'Other Taxes & Charges'
      ],
      'icon': Icons.account_balance.codePoint,
    },
    'Banking & Financial': {
      'subs': [
        'Loan EMIs',
        'Credit Card Payments',
        'Interest Charges',
        'Late Fees',
        'Service Charges',
        'Transaction Fees',
        'Financial Advisor Fees',
        'Failed Transactions',
        'Processing Fees',
        'Maintenance Charges',
        'SMS Charges',
        'Annual Fees',
        'Other Banking & Financial Charges'
      ],
      'icon': Icons.savings.codePoint,
    },
    'Miscellaneous': {
      'subs': ['Emergency Expenses', 'Miscellaneous Purchases', 'Unexpected'],
      'icon': Icons.category.codePoint,
    },
    'Gifts & Donations': {
      'subs': ['Birthday Gifts', 'Wedding Gifts','Office Gifts', 'Festival Gifts', 'Charitable Donations','Offerings', 'Religious Donations', 'Other Gifts & Donations'],
      'icon': Icons.card_giftcard.codePoint,
    },
    'Other': {
      'subs': ['Missing', 'Uncategorized', 'Account Adjustments'],
      'icon': Icons.help_outline.codePoint,
    },
    'Non-Calculated Expense': {
      'subs': ['Untracked', 'Missing Money', 'Account Adjustments'],
      'icon': Icons.money_off.codePoint,
    },
  };

  // --- EXPANDED DEFAULT INCOME ---
  final Map<String, dynamic> _defaultIncome = {
    'Salary': {
      'subs': ['Monthly Salary', 'Bonus', 'Incentives', 'Overtime', 'Stipend', 'Arrears', 'Leave Encashment', 'Other Allowances'],
      'icon': Icons.currency_rupee_sharp.codePoint,
    },
    'Business': {
      'subs': [
        'Business Profit',
        'Freelance',
        'Consulting',
        'Royalty',
        'Affiliate Income',
        'Commission',
        'Product Sales',
        'Service Income',
        'Other Business Income'

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
        'Mutual Fund Redemptions',
        'Bond Interest',
        'Stock Sales',
        'Cryptocurrency Gains',
        'Other Investment Income'
      ],
      'icon': Icons.trending_up.codePoint,
    },
    'Rental': {
      'subs': [
        'House Rent',
        'Commercial Rent',
        'Vehicle Rent',
        'Equipment Rent',
        'Land Rent',
        'Other Rental Income'
      ],
      'icon': Icons.receipt_long.codePoint,
    },
    'Gifts & Rewards': {
      'subs': ['Family Support','Cashback', 'Rewards Redemption', 'Cash Gift', 'Festival Gifts', 'Scholarship', 'Loyalty Rewards', 'Other Gifts & Rewards'],
      'icon': Icons.card_giftcard.codePoint,
    },
    'Refunds & Claims': {
      'subs': [
        'Tax Refund',
        'Reimbursements',
        'Purchase Returns',
        'Surcharge Reversals',
        'Insurance Claims',
        'Bill Adjustments',
        'Failed Transaction Reversals',
        'Other Refunds & Claims'
      ],
      'icon': Icons.replay.codePoint,
    },
    'Sold Items': {
      'subs': ['Second-hand Sales', 'Property Sale', 'Scrap', 'Other Sold Items'],
      'icon': Icons.sell.codePoint,
    },
    'Others': {
      'subs': ['Miscellaneous', 'Uncategorized', 'Account Adjustments', 'Unexpected', 'Lottery/Contest Winnings'],
      'icon': Icons.help_outline.codePoint,
    },
    'Non-Calculated Income': {
      'subs': ['Untracked', 'Account Adjustments'],
      'icon': Icons.money_off.codePoint,
    },
    'Repayment': {
      'subs': ['Credit Card Bill', 'Loan Repayment', 'Debt Collection'],
      'icon': Icons.payments.codePoint,
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
