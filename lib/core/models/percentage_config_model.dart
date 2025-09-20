import 'package:cloud_firestore/cloud_firestore.dart';

class PercentageConfig {
  double necessities;
  double lifestyle;
  double investment;
  double emergency;
  double buffer;

  PercentageConfig({
    required this.necessities,
    required this.lifestyle,
    required this.investment,
    required this.emergency,
    required this.buffer,
  });

  factory PercentageConfig.defaultConfig() {
    return PercentageConfig(
      necessities: 45.0,
      lifestyle: 15.0,
      investment: 20.0,
      emergency: 5.0,
      buffer: 15.0,
    );
  }

  factory PercentageConfig.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map<String, dynamic>;
    return PercentageConfig(
      necessities: (data['necessities'] ?? 45.0).toDouble(),
      lifestyle: (data['lifestyle'] ?? 15.0).toDouble(),
      investment: (data['investment'] ?? 20.0).toDouble(),
      emergency: (data['emergency'] ?? 5.0).toDouble(),
      buffer: (data['buffer'] ?? 15.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'necessities': necessities,
      'lifestyle': lifestyle,
      'investment': investment,
      'emergency': emergency,
      'buffer': buffer,
    };
  }
}
