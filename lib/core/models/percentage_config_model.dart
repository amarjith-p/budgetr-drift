class CategoryConfig {
  String name;
  double percentage;
  String note;

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

  Map<String, dynamic> toMap() => {
        'categories': categories.map((x) => x.toMap()).toList(),
      };

  factory PercentageConfig.fromMap(Map<String, dynamic> map) {
    return PercentageConfig(
      categories: List<CategoryConfig>.from(
        (map['categories'] as List? ?? [])
            .map((x) => CategoryConfig.fromMap(x)),
      ),
    );
  }

  factory PercentageConfig.defaultConfig() {
    return PercentageConfig(
      categories: [
        CategoryConfig(
            name: 'Necessities',
            percentage: 45.0,
            note: 'Rent, Grocery, Bills'),
        CategoryConfig(
            name: 'Lifestyle', percentage: 15.0, note: 'Shopping, Dining out'),
        CategoryConfig(
            name: 'Investment', percentage: 20.0, note: 'SIP, Stocks, Gold'),
        CategoryConfig(name: 'Debt', percentage: 10.0, note: 'Loans, EMI'),
        CategoryConfig(
            name: 'Savings', percentage: 10.0, note: 'Emergency Fund'),
      ],
    );
  }
}
