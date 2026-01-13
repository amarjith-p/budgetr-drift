class CategoryConfig {
  String name;
  double percentage;
  String note; // New field for notes

  CategoryConfig({
    required this.name,
    required this.percentage,
    this.note = '',
  });

  Map<String, dynamic> toMap() => {
        'name': name,
        'percentage': percentage,
        'note': note,
      };

  factory CategoryConfig.fromMap(Map<String, dynamic> map) {
    return CategoryConfig(
      name: map['name'] ?? '',
      percentage: (map['percentage'] ?? 0.0).toDouble(),
      note: map['note'] ?? '',
    );
  }
}

class PercentageConfig {
  List<CategoryConfig> categories;

  PercentageConfig({required this.categories});

  factory PercentageConfig.defaultConfig() {
    return PercentageConfig(
      categories: [
        CategoryConfig(
          name: 'Necessities',
          percentage: 45.0,
          note: 'Rent, Grocery, Bills',
        ),
        CategoryConfig(
          name: 'Lifestyle',
          percentage: 15.0,
          note: 'Shopping, Dining out',
        ),
        CategoryConfig(
          name: 'Investment',
          percentage: 20.0,
          note: 'SIP, Stocks, Gold',
        ),
        CategoryConfig(
          name: 'Emergency',
          percentage: 5.0,
          note: 'Medical, Unplanned',
        ),
        CategoryConfig(
          name: 'Buffer',
          percentage: 15.0,
          note: 'Short term savings',
        ),
      ],
    );
  }

  // factory PercentageConfig.fromFirestore(DocumentSnapshot doc) {
  //   Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

  //   if (data.containsKey('categories')) {
  //     var list = data['categories'] as List;
  //     List<CategoryConfig> categories = list
  //         .map((i) => CategoryConfig.fromMap(i))
  //         .toList();
  //     return PercentageConfig(categories: categories);
  //   } else {
  //     // Legacy support for old format
  //     return PercentageConfig(
  //       categories: [
  //         CategoryConfig(
  //           name: 'Necessities',
  //           percentage: (data['necessities'] ?? 45.0).toDouble(),
  //         ),
  //         CategoryConfig(
  //           name: 'Lifestyle',
  //           percentage: (data['lifestyle'] ?? 15.0).toDouble(),
  //         ),
  //         CategoryConfig(
  //           name: 'Investment',
  //           percentage: (data['investment'] ?? 20.0).toDouble(),
  //         ),
  //         CategoryConfig(
  //           name: 'Emergency',
  //           percentage: (data['emergency'] ?? 5.0).toDouble(),
  //         ),
  //         CategoryConfig(
  //           name: 'Buffer',
  //           percentage: (data['buffer'] ?? 15.0).toDouble(),
  //         ),
  //       ],
  //     );
  //   }
  // }

  Map<String, dynamic> toMap() {
    return {'categories': categories.map((e) => e.toMap()).toList()};
  }
}
