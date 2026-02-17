import 'package:drift/drift.dart';

class AppNotifications extends Table {
  TextColumn get id => text()(); // UUID
  TextColumn get type =>
      text()(); // 'statement', 'due_date', 'high_util', 'limit_exceeded'
  TextColumn get title => text()();
  TextColumn get message => text()();
  TextColumn get payload => text().nullable()(); // E.g., Card ID to navigate to
  BoolColumn get isRead => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
