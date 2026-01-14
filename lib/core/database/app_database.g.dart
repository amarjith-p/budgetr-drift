// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $FinancialRecordsTable extends FinancialRecords
    with TableInfo<$FinancialRecordsTable, FinancialRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FinancialRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _yearMeta = const VerificationMeta('year');
  @override
  late final GeneratedColumn<int> year = GeneratedColumn<int>(
      'year', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _monthMeta = const VerificationMeta('month');
  @override
  late final GeneratedColumn<int> month = GeneratedColumn<int>(
      'month', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _salaryMeta = const VerificationMeta('salary');
  @override
  late final GeneratedColumn<double> salary = GeneratedColumn<double>(
      'salary', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _extraIncomeMeta =
      const VerificationMeta('extraIncome');
  @override
  late final GeneratedColumn<double> extraIncome = GeneratedColumn<double>(
      'extra_income', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _emiMeta = const VerificationMeta('emi');
  @override
  late final GeneratedColumn<double> emi = GeneratedColumn<double>(
      'emi', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _effectiveIncomeMeta =
      const VerificationMeta('effectiveIncome');
  @override
  late final GeneratedColumn<double> effectiveIncome = GeneratedColumn<double>(
      'effective_income', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _budgetMeta = const VerificationMeta('budget');
  @override
  late final GeneratedColumn<double> budget = GeneratedColumn<double>(
      'budget', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _allocationsMeta =
      const VerificationMeta('allocations');
  @override
  late final GeneratedColumn<String> allocations = GeneratedColumn<String>(
      'allocations', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _allocationPercentagesMeta =
      const VerificationMeta('allocationPercentages');
  @override
  late final GeneratedColumn<String> allocationPercentages =
      GeneratedColumn<String>('allocation_percentages', aliasedName, false,
          type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _bucketOrderMeta =
      const VerificationMeta('bucketOrder');
  @override
  late final GeneratedColumn<String> bucketOrder = GeneratedColumn<String>(
      'bucket_order', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        year,
        month,
        salary,
        extraIncome,
        emi,
        effectiveIncome,
        budget,
        allocations,
        allocationPercentages,
        bucketOrder,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'financial_records';
  @override
  VerificationContext validateIntegrity(Insertable<FinancialRecord> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('year')) {
      context.handle(
          _yearMeta, year.isAcceptableOrUnknown(data['year']!, _yearMeta));
    } else if (isInserting) {
      context.missing(_yearMeta);
    }
    if (data.containsKey('month')) {
      context.handle(
          _monthMeta, month.isAcceptableOrUnknown(data['month']!, _monthMeta));
    } else if (isInserting) {
      context.missing(_monthMeta);
    }
    if (data.containsKey('salary')) {
      context.handle(_salaryMeta,
          salary.isAcceptableOrUnknown(data['salary']!, _salaryMeta));
    }
    if (data.containsKey('extra_income')) {
      context.handle(
          _extraIncomeMeta,
          extraIncome.isAcceptableOrUnknown(
              data['extra_income']!, _extraIncomeMeta));
    }
    if (data.containsKey('emi')) {
      context.handle(
          _emiMeta, emi.isAcceptableOrUnknown(data['emi']!, _emiMeta));
    }
    if (data.containsKey('effective_income')) {
      context.handle(
          _effectiveIncomeMeta,
          effectiveIncome.isAcceptableOrUnknown(
              data['effective_income']!, _effectiveIncomeMeta));
    }
    if (data.containsKey('budget')) {
      context.handle(_budgetMeta,
          budget.isAcceptableOrUnknown(data['budget']!, _budgetMeta));
    }
    if (data.containsKey('allocations')) {
      context.handle(
          _allocationsMeta,
          allocations.isAcceptableOrUnknown(
              data['allocations']!, _allocationsMeta));
    } else if (isInserting) {
      context.missing(_allocationsMeta);
    }
    if (data.containsKey('allocation_percentages')) {
      context.handle(
          _allocationPercentagesMeta,
          allocationPercentages.isAcceptableOrUnknown(
              data['allocation_percentages']!, _allocationPercentagesMeta));
    } else if (isInserting) {
      context.missing(_allocationPercentagesMeta);
    }
    if (data.containsKey('bucket_order')) {
      context.handle(
          _bucketOrderMeta,
          bucketOrder.isAcceptableOrUnknown(
              data['bucket_order']!, _bucketOrderMeta));
    } else if (isInserting) {
      context.missing(_bucketOrderMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FinancialRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FinancialRecord(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      year: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}year'])!,
      month: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}month'])!,
      salary: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}salary'])!,
      extraIncome: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}extra_income'])!,
      emi: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}emi'])!,
      effectiveIncome: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}effective_income'])!,
      budget: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}budget'])!,
      allocations: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}allocations'])!,
      allocationPercentages: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}allocation_percentages'])!,
      bucketOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}bucket_order'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $FinancialRecordsTable createAlias(String alias) {
    return $FinancialRecordsTable(attachedDatabase, alias);
  }
}

class FinancialRecord extends DataClass implements Insertable<FinancialRecord> {
  final String id;
  final int year;
  final int month;
  final double salary;
  final double extraIncome;
  final double emi;
  final double effectiveIncome;
  final double budget;
  final String allocations;
  final String allocationPercentages;
  final String bucketOrder;
  final DateTime createdAt;
  final DateTime updatedAt;
  const FinancialRecord(
      {required this.id,
      required this.year,
      required this.month,
      required this.salary,
      required this.extraIncome,
      required this.emi,
      required this.effectiveIncome,
      required this.budget,
      required this.allocations,
      required this.allocationPercentages,
      required this.bucketOrder,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['year'] = Variable<int>(year);
    map['month'] = Variable<int>(month);
    map['salary'] = Variable<double>(salary);
    map['extra_income'] = Variable<double>(extraIncome);
    map['emi'] = Variable<double>(emi);
    map['effective_income'] = Variable<double>(effectiveIncome);
    map['budget'] = Variable<double>(budget);
    map['allocations'] = Variable<String>(allocations);
    map['allocation_percentages'] = Variable<String>(allocationPercentages);
    map['bucket_order'] = Variable<String>(bucketOrder);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  FinancialRecordsCompanion toCompanion(bool nullToAbsent) {
    return FinancialRecordsCompanion(
      id: Value(id),
      year: Value(year),
      month: Value(month),
      salary: Value(salary),
      extraIncome: Value(extraIncome),
      emi: Value(emi),
      effectiveIncome: Value(effectiveIncome),
      budget: Value(budget),
      allocations: Value(allocations),
      allocationPercentages: Value(allocationPercentages),
      bucketOrder: Value(bucketOrder),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory FinancialRecord.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FinancialRecord(
      id: serializer.fromJson<String>(json['id']),
      year: serializer.fromJson<int>(json['year']),
      month: serializer.fromJson<int>(json['month']),
      salary: serializer.fromJson<double>(json['salary']),
      extraIncome: serializer.fromJson<double>(json['extraIncome']),
      emi: serializer.fromJson<double>(json['emi']),
      effectiveIncome: serializer.fromJson<double>(json['effectiveIncome']),
      budget: serializer.fromJson<double>(json['budget']),
      allocations: serializer.fromJson<String>(json['allocations']),
      allocationPercentages:
          serializer.fromJson<String>(json['allocationPercentages']),
      bucketOrder: serializer.fromJson<String>(json['bucketOrder']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'year': serializer.toJson<int>(year),
      'month': serializer.toJson<int>(month),
      'salary': serializer.toJson<double>(salary),
      'extraIncome': serializer.toJson<double>(extraIncome),
      'emi': serializer.toJson<double>(emi),
      'effectiveIncome': serializer.toJson<double>(effectiveIncome),
      'budget': serializer.toJson<double>(budget),
      'allocations': serializer.toJson<String>(allocations),
      'allocationPercentages': serializer.toJson<String>(allocationPercentages),
      'bucketOrder': serializer.toJson<String>(bucketOrder),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  FinancialRecord copyWith(
          {String? id,
          int? year,
          int? month,
          double? salary,
          double? extraIncome,
          double? emi,
          double? effectiveIncome,
          double? budget,
          String? allocations,
          String? allocationPercentages,
          String? bucketOrder,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      FinancialRecord(
        id: id ?? this.id,
        year: year ?? this.year,
        month: month ?? this.month,
        salary: salary ?? this.salary,
        extraIncome: extraIncome ?? this.extraIncome,
        emi: emi ?? this.emi,
        effectiveIncome: effectiveIncome ?? this.effectiveIncome,
        budget: budget ?? this.budget,
        allocations: allocations ?? this.allocations,
        allocationPercentages:
            allocationPercentages ?? this.allocationPercentages,
        bucketOrder: bucketOrder ?? this.bucketOrder,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  FinancialRecord copyWithCompanion(FinancialRecordsCompanion data) {
    return FinancialRecord(
      id: data.id.present ? data.id.value : this.id,
      year: data.year.present ? data.year.value : this.year,
      month: data.month.present ? data.month.value : this.month,
      salary: data.salary.present ? data.salary.value : this.salary,
      extraIncome:
          data.extraIncome.present ? data.extraIncome.value : this.extraIncome,
      emi: data.emi.present ? data.emi.value : this.emi,
      effectiveIncome: data.effectiveIncome.present
          ? data.effectiveIncome.value
          : this.effectiveIncome,
      budget: data.budget.present ? data.budget.value : this.budget,
      allocations:
          data.allocations.present ? data.allocations.value : this.allocations,
      allocationPercentages: data.allocationPercentages.present
          ? data.allocationPercentages.value
          : this.allocationPercentages,
      bucketOrder:
          data.bucketOrder.present ? data.bucketOrder.value : this.bucketOrder,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FinancialRecord(')
          ..write('id: $id, ')
          ..write('year: $year, ')
          ..write('month: $month, ')
          ..write('salary: $salary, ')
          ..write('extraIncome: $extraIncome, ')
          ..write('emi: $emi, ')
          ..write('effectiveIncome: $effectiveIncome, ')
          ..write('budget: $budget, ')
          ..write('allocations: $allocations, ')
          ..write('allocationPercentages: $allocationPercentages, ')
          ..write('bucketOrder: $bucketOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      year,
      month,
      salary,
      extraIncome,
      emi,
      effectiveIncome,
      budget,
      allocations,
      allocationPercentages,
      bucketOrder,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FinancialRecord &&
          other.id == this.id &&
          other.year == this.year &&
          other.month == this.month &&
          other.salary == this.salary &&
          other.extraIncome == this.extraIncome &&
          other.emi == this.emi &&
          other.effectiveIncome == this.effectiveIncome &&
          other.budget == this.budget &&
          other.allocations == this.allocations &&
          other.allocationPercentages == this.allocationPercentages &&
          other.bucketOrder == this.bucketOrder &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class FinancialRecordsCompanion extends UpdateCompanion<FinancialRecord> {
  final Value<String> id;
  final Value<int> year;
  final Value<int> month;
  final Value<double> salary;
  final Value<double> extraIncome;
  final Value<double> emi;
  final Value<double> effectiveIncome;
  final Value<double> budget;
  final Value<String> allocations;
  final Value<String> allocationPercentages;
  final Value<String> bucketOrder;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const FinancialRecordsCompanion({
    this.id = const Value.absent(),
    this.year = const Value.absent(),
    this.month = const Value.absent(),
    this.salary = const Value.absent(),
    this.extraIncome = const Value.absent(),
    this.emi = const Value.absent(),
    this.effectiveIncome = const Value.absent(),
    this.budget = const Value.absent(),
    this.allocations = const Value.absent(),
    this.allocationPercentages = const Value.absent(),
    this.bucketOrder = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FinancialRecordsCompanion.insert({
    required String id,
    required int year,
    required int month,
    this.salary = const Value.absent(),
    this.extraIncome = const Value.absent(),
    this.emi = const Value.absent(),
    this.effectiveIncome = const Value.absent(),
    this.budget = const Value.absent(),
    required String allocations,
    required String allocationPercentages,
    required String bucketOrder,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        year = Value(year),
        month = Value(month),
        allocations = Value(allocations),
        allocationPercentages = Value(allocationPercentages),
        bucketOrder = Value(bucketOrder),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<FinancialRecord> custom({
    Expression<String>? id,
    Expression<int>? year,
    Expression<int>? month,
    Expression<double>? salary,
    Expression<double>? extraIncome,
    Expression<double>? emi,
    Expression<double>? effectiveIncome,
    Expression<double>? budget,
    Expression<String>? allocations,
    Expression<String>? allocationPercentages,
    Expression<String>? bucketOrder,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (year != null) 'year': year,
      if (month != null) 'month': month,
      if (salary != null) 'salary': salary,
      if (extraIncome != null) 'extra_income': extraIncome,
      if (emi != null) 'emi': emi,
      if (effectiveIncome != null) 'effective_income': effectiveIncome,
      if (budget != null) 'budget': budget,
      if (allocations != null) 'allocations': allocations,
      if (allocationPercentages != null)
        'allocation_percentages': allocationPercentages,
      if (bucketOrder != null) 'bucket_order': bucketOrder,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FinancialRecordsCompanion copyWith(
      {Value<String>? id,
      Value<int>? year,
      Value<int>? month,
      Value<double>? salary,
      Value<double>? extraIncome,
      Value<double>? emi,
      Value<double>? effectiveIncome,
      Value<double>? budget,
      Value<String>? allocations,
      Value<String>? allocationPercentages,
      Value<String>? bucketOrder,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return FinancialRecordsCompanion(
      id: id ?? this.id,
      year: year ?? this.year,
      month: month ?? this.month,
      salary: salary ?? this.salary,
      extraIncome: extraIncome ?? this.extraIncome,
      emi: emi ?? this.emi,
      effectiveIncome: effectiveIncome ?? this.effectiveIncome,
      budget: budget ?? this.budget,
      allocations: allocations ?? this.allocations,
      allocationPercentages:
          allocationPercentages ?? this.allocationPercentages,
      bucketOrder: bucketOrder ?? this.bucketOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (year.present) {
      map['year'] = Variable<int>(year.value);
    }
    if (month.present) {
      map['month'] = Variable<int>(month.value);
    }
    if (salary.present) {
      map['salary'] = Variable<double>(salary.value);
    }
    if (extraIncome.present) {
      map['extra_income'] = Variable<double>(extraIncome.value);
    }
    if (emi.present) {
      map['emi'] = Variable<double>(emi.value);
    }
    if (effectiveIncome.present) {
      map['effective_income'] = Variable<double>(effectiveIncome.value);
    }
    if (budget.present) {
      map['budget'] = Variable<double>(budget.value);
    }
    if (allocations.present) {
      map['allocations'] = Variable<String>(allocations.value);
    }
    if (allocationPercentages.present) {
      map['allocation_percentages'] =
          Variable<String>(allocationPercentages.value);
    }
    if (bucketOrder.present) {
      map['bucket_order'] = Variable<String>(bucketOrder.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FinancialRecordsCompanion(')
          ..write('id: $id, ')
          ..write('year: $year, ')
          ..write('month: $month, ')
          ..write('salary: $salary, ')
          ..write('extraIncome: $extraIncome, ')
          ..write('emi: $emi, ')
          ..write('effectiveIncome: $effectiveIncome, ')
          ..write('budget: $budget, ')
          ..write('allocations: $allocations, ')
          ..write('allocationPercentages: $allocationPercentages, ')
          ..write('bucketOrder: $bucketOrder, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SettlementsTable extends Settlements
    with TableInfo<$SettlementsTable, Settlement> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettlementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _yearMeta = const VerificationMeta('year');
  @override
  late final GeneratedColumn<int> year = GeneratedColumn<int>(
      'year', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _monthMeta = const VerificationMeta('month');
  @override
  late final GeneratedColumn<int> month = GeneratedColumn<int>(
      'month', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _allocationsMeta =
      const VerificationMeta('allocations');
  @override
  late final GeneratedColumn<String> allocations = GeneratedColumn<String>(
      'allocations', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _expensesMeta =
      const VerificationMeta('expenses');
  @override
  late final GeneratedColumn<String> expenses = GeneratedColumn<String>(
      'expenses', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _bucketOrderMeta =
      const VerificationMeta('bucketOrder');
  @override
  late final GeneratedColumn<String> bucketOrder = GeneratedColumn<String>(
      'bucket_order', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _totalIncomeMeta =
      const VerificationMeta('totalIncome');
  @override
  late final GeneratedColumn<double> totalIncome = GeneratedColumn<double>(
      'total_income', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _totalExpenseMeta =
      const VerificationMeta('totalExpense');
  @override
  late final GeneratedColumn<double> totalExpense = GeneratedColumn<double>(
      'total_expense', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _settledAtMeta =
      const VerificationMeta('settledAt');
  @override
  late final GeneratedColumn<DateTime> settledAt = GeneratedColumn<DateTime>(
      'settled_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        year,
        month,
        allocations,
        expenses,
        bucketOrder,
        totalIncome,
        totalExpense,
        settledAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settlements';
  @override
  VerificationContext validateIntegrity(Insertable<Settlement> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('year')) {
      context.handle(
          _yearMeta, year.isAcceptableOrUnknown(data['year']!, _yearMeta));
    } else if (isInserting) {
      context.missing(_yearMeta);
    }
    if (data.containsKey('month')) {
      context.handle(
          _monthMeta, month.isAcceptableOrUnknown(data['month']!, _monthMeta));
    } else if (isInserting) {
      context.missing(_monthMeta);
    }
    if (data.containsKey('allocations')) {
      context.handle(
          _allocationsMeta,
          allocations.isAcceptableOrUnknown(
              data['allocations']!, _allocationsMeta));
    } else if (isInserting) {
      context.missing(_allocationsMeta);
    }
    if (data.containsKey('expenses')) {
      context.handle(_expensesMeta,
          expenses.isAcceptableOrUnknown(data['expenses']!, _expensesMeta));
    } else if (isInserting) {
      context.missing(_expensesMeta);
    }
    if (data.containsKey('bucket_order')) {
      context.handle(
          _bucketOrderMeta,
          bucketOrder.isAcceptableOrUnknown(
              data['bucket_order']!, _bucketOrderMeta));
    } else if (isInserting) {
      context.missing(_bucketOrderMeta);
    }
    if (data.containsKey('total_income')) {
      context.handle(
          _totalIncomeMeta,
          totalIncome.isAcceptableOrUnknown(
              data['total_income']!, _totalIncomeMeta));
    }
    if (data.containsKey('total_expense')) {
      context.handle(
          _totalExpenseMeta,
          totalExpense.isAcceptableOrUnknown(
              data['total_expense']!, _totalExpenseMeta));
    }
    if (data.containsKey('settled_at')) {
      context.handle(_settledAtMeta,
          settledAt.isAcceptableOrUnknown(data['settled_at']!, _settledAtMeta));
    } else if (isInserting) {
      context.missing(_settledAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Settlement map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Settlement(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      year: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}year'])!,
      month: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}month'])!,
      allocations: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}allocations'])!,
      expenses: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}expenses'])!,
      bucketOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}bucket_order'])!,
      totalIncome: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}total_income'])!,
      totalExpense: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}total_expense'])!,
      settledAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}settled_at'])!,
    );
  }

  @override
  $SettlementsTable createAlias(String alias) {
    return $SettlementsTable(attachedDatabase, alias);
  }
}

class Settlement extends DataClass implements Insertable<Settlement> {
  final String id;
  final int year;
  final int month;
  final String allocations;
  final String expenses;
  final String bucketOrder;
  final double totalIncome;
  final double totalExpense;
  final DateTime settledAt;
  const Settlement(
      {required this.id,
      required this.year,
      required this.month,
      required this.allocations,
      required this.expenses,
      required this.bucketOrder,
      required this.totalIncome,
      required this.totalExpense,
      required this.settledAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['year'] = Variable<int>(year);
    map['month'] = Variable<int>(month);
    map['allocations'] = Variable<String>(allocations);
    map['expenses'] = Variable<String>(expenses);
    map['bucket_order'] = Variable<String>(bucketOrder);
    map['total_income'] = Variable<double>(totalIncome);
    map['total_expense'] = Variable<double>(totalExpense);
    map['settled_at'] = Variable<DateTime>(settledAt);
    return map;
  }

  SettlementsCompanion toCompanion(bool nullToAbsent) {
    return SettlementsCompanion(
      id: Value(id),
      year: Value(year),
      month: Value(month),
      allocations: Value(allocations),
      expenses: Value(expenses),
      bucketOrder: Value(bucketOrder),
      totalIncome: Value(totalIncome),
      totalExpense: Value(totalExpense),
      settledAt: Value(settledAt),
    );
  }

  factory Settlement.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Settlement(
      id: serializer.fromJson<String>(json['id']),
      year: serializer.fromJson<int>(json['year']),
      month: serializer.fromJson<int>(json['month']),
      allocations: serializer.fromJson<String>(json['allocations']),
      expenses: serializer.fromJson<String>(json['expenses']),
      bucketOrder: serializer.fromJson<String>(json['bucketOrder']),
      totalIncome: serializer.fromJson<double>(json['totalIncome']),
      totalExpense: serializer.fromJson<double>(json['totalExpense']),
      settledAt: serializer.fromJson<DateTime>(json['settledAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'year': serializer.toJson<int>(year),
      'month': serializer.toJson<int>(month),
      'allocations': serializer.toJson<String>(allocations),
      'expenses': serializer.toJson<String>(expenses),
      'bucketOrder': serializer.toJson<String>(bucketOrder),
      'totalIncome': serializer.toJson<double>(totalIncome),
      'totalExpense': serializer.toJson<double>(totalExpense),
      'settledAt': serializer.toJson<DateTime>(settledAt),
    };
  }

  Settlement copyWith(
          {String? id,
          int? year,
          int? month,
          String? allocations,
          String? expenses,
          String? bucketOrder,
          double? totalIncome,
          double? totalExpense,
          DateTime? settledAt}) =>
      Settlement(
        id: id ?? this.id,
        year: year ?? this.year,
        month: month ?? this.month,
        allocations: allocations ?? this.allocations,
        expenses: expenses ?? this.expenses,
        bucketOrder: bucketOrder ?? this.bucketOrder,
        totalIncome: totalIncome ?? this.totalIncome,
        totalExpense: totalExpense ?? this.totalExpense,
        settledAt: settledAt ?? this.settledAt,
      );
  Settlement copyWithCompanion(SettlementsCompanion data) {
    return Settlement(
      id: data.id.present ? data.id.value : this.id,
      year: data.year.present ? data.year.value : this.year,
      month: data.month.present ? data.month.value : this.month,
      allocations:
          data.allocations.present ? data.allocations.value : this.allocations,
      expenses: data.expenses.present ? data.expenses.value : this.expenses,
      bucketOrder:
          data.bucketOrder.present ? data.bucketOrder.value : this.bucketOrder,
      totalIncome:
          data.totalIncome.present ? data.totalIncome.value : this.totalIncome,
      totalExpense: data.totalExpense.present
          ? data.totalExpense.value
          : this.totalExpense,
      settledAt: data.settledAt.present ? data.settledAt.value : this.settledAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Settlement(')
          ..write('id: $id, ')
          ..write('year: $year, ')
          ..write('month: $month, ')
          ..write('allocations: $allocations, ')
          ..write('expenses: $expenses, ')
          ..write('bucketOrder: $bucketOrder, ')
          ..write('totalIncome: $totalIncome, ')
          ..write('totalExpense: $totalExpense, ')
          ..write('settledAt: $settledAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, year, month, allocations, expenses,
      bucketOrder, totalIncome, totalExpense, settledAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Settlement &&
          other.id == this.id &&
          other.year == this.year &&
          other.month == this.month &&
          other.allocations == this.allocations &&
          other.expenses == this.expenses &&
          other.bucketOrder == this.bucketOrder &&
          other.totalIncome == this.totalIncome &&
          other.totalExpense == this.totalExpense &&
          other.settledAt == this.settledAt);
}

class SettlementsCompanion extends UpdateCompanion<Settlement> {
  final Value<String> id;
  final Value<int> year;
  final Value<int> month;
  final Value<String> allocations;
  final Value<String> expenses;
  final Value<String> bucketOrder;
  final Value<double> totalIncome;
  final Value<double> totalExpense;
  final Value<DateTime> settledAt;
  final Value<int> rowid;
  const SettlementsCompanion({
    this.id = const Value.absent(),
    this.year = const Value.absent(),
    this.month = const Value.absent(),
    this.allocations = const Value.absent(),
    this.expenses = const Value.absent(),
    this.bucketOrder = const Value.absent(),
    this.totalIncome = const Value.absent(),
    this.totalExpense = const Value.absent(),
    this.settledAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettlementsCompanion.insert({
    required String id,
    required int year,
    required int month,
    required String allocations,
    required String expenses,
    required String bucketOrder,
    this.totalIncome = const Value.absent(),
    this.totalExpense = const Value.absent(),
    required DateTime settledAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        year = Value(year),
        month = Value(month),
        allocations = Value(allocations),
        expenses = Value(expenses),
        bucketOrder = Value(bucketOrder),
        settledAt = Value(settledAt);
  static Insertable<Settlement> custom({
    Expression<String>? id,
    Expression<int>? year,
    Expression<int>? month,
    Expression<String>? allocations,
    Expression<String>? expenses,
    Expression<String>? bucketOrder,
    Expression<double>? totalIncome,
    Expression<double>? totalExpense,
    Expression<DateTime>? settledAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (year != null) 'year': year,
      if (month != null) 'month': month,
      if (allocations != null) 'allocations': allocations,
      if (expenses != null) 'expenses': expenses,
      if (bucketOrder != null) 'bucket_order': bucketOrder,
      if (totalIncome != null) 'total_income': totalIncome,
      if (totalExpense != null) 'total_expense': totalExpense,
      if (settledAt != null) 'settled_at': settledAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettlementsCompanion copyWith(
      {Value<String>? id,
      Value<int>? year,
      Value<int>? month,
      Value<String>? allocations,
      Value<String>? expenses,
      Value<String>? bucketOrder,
      Value<double>? totalIncome,
      Value<double>? totalExpense,
      Value<DateTime>? settledAt,
      Value<int>? rowid}) {
    return SettlementsCompanion(
      id: id ?? this.id,
      year: year ?? this.year,
      month: month ?? this.month,
      allocations: allocations ?? this.allocations,
      expenses: expenses ?? this.expenses,
      bucketOrder: bucketOrder ?? this.bucketOrder,
      totalIncome: totalIncome ?? this.totalIncome,
      totalExpense: totalExpense ?? this.totalExpense,
      settledAt: settledAt ?? this.settledAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (year.present) {
      map['year'] = Variable<int>(year.value);
    }
    if (month.present) {
      map['month'] = Variable<int>(month.value);
    }
    if (allocations.present) {
      map['allocations'] = Variable<String>(allocations.value);
    }
    if (expenses.present) {
      map['expenses'] = Variable<String>(expenses.value);
    }
    if (bucketOrder.present) {
      map['bucket_order'] = Variable<String>(bucketOrder.value);
    }
    if (totalIncome.present) {
      map['total_income'] = Variable<double>(totalIncome.value);
    }
    if (totalExpense.present) {
      map['total_expense'] = Variable<double>(totalExpense.value);
    }
    if (settledAt.present) {
      map['settled_at'] = Variable<DateTime>(settledAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettlementsCompanion(')
          ..write('id: $id, ')
          ..write('year: $year, ')
          ..write('month: $month, ')
          ..write('allocations: $allocations, ')
          ..write('expenses: $expenses, ')
          ..write('bucketOrder: $bucketOrder, ')
          ..write('totalIncome: $totalIncome, ')
          ..write('totalExpense: $totalExpense, ')
          ..write('settledAt: $settledAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExpenseAccountsTable extends ExpenseAccounts
    with TableInfo<$ExpenseAccountsTable, ExpenseAccount> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExpenseAccountsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _bankNameMeta =
      const VerificationMeta('bankName');
  @override
  late final GeneratedColumn<String> bankName = GeneratedColumn<String>(
      'bank_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('Bank'));
  static const VerificationMeta _currentBalanceMeta =
      const VerificationMeta('currentBalance');
  @override
  late final GeneratedColumn<double> currentBalance = GeneratedColumn<double>(
      'current_balance', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _accountTypeMeta =
      const VerificationMeta('accountType');
  @override
  late final GeneratedColumn<String> accountType = GeneratedColumn<String>(
      'account_type', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('Savings Account'));
  static const VerificationMeta _accountNumberMeta =
      const VerificationMeta('accountNumber');
  @override
  late final GeneratedColumn<String> accountNumber = GeneratedColumn<String>(
      'account_number', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<int> color = GeneratedColumn<int>(
      'color', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0xFF1E1E1E));
  static const VerificationMeta _showOnDashboardMeta =
      const VerificationMeta('showOnDashboard');
  @override
  late final GeneratedColumn<bool> showOnDashboard = GeneratedColumn<bool>(
      'show_on_dashboard', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("show_on_dashboard" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _dashboardOrderMeta =
      const VerificationMeta('dashboardOrder');
  @override
  late final GeneratedColumn<int> dashboardOrder = GeneratedColumn<int>(
      'dashboard_order', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        bankName,
        type,
        currentBalance,
        createdAt,
        accountType,
        accountNumber,
        color,
        showOnDashboard,
        dashboardOrder
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'expense_accounts';
  @override
  VerificationContext validateIntegrity(Insertable<ExpenseAccount> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('bank_name')) {
      context.handle(_bankNameMeta,
          bankName.isAcceptableOrUnknown(data['bank_name']!, _bankNameMeta));
    } else if (isInserting) {
      context.missing(_bankNameMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    }
    if (data.containsKey('current_balance')) {
      context.handle(
          _currentBalanceMeta,
          currentBalance.isAcceptableOrUnknown(
              data['current_balance']!, _currentBalanceMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('account_type')) {
      context.handle(
          _accountTypeMeta,
          accountType.isAcceptableOrUnknown(
              data['account_type']!, _accountTypeMeta));
    }
    if (data.containsKey('account_number')) {
      context.handle(
          _accountNumberMeta,
          accountNumber.isAcceptableOrUnknown(
              data['account_number']!, _accountNumberMeta));
    }
    if (data.containsKey('color')) {
      context.handle(
          _colorMeta, color.isAcceptableOrUnknown(data['color']!, _colorMeta));
    }
    if (data.containsKey('show_on_dashboard')) {
      context.handle(
          _showOnDashboardMeta,
          showOnDashboard.isAcceptableOrUnknown(
              data['show_on_dashboard']!, _showOnDashboardMeta));
    }
    if (data.containsKey('dashboard_order')) {
      context.handle(
          _dashboardOrderMeta,
          dashboardOrder.isAcceptableOrUnknown(
              data['dashboard_order']!, _dashboardOrderMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExpenseAccount map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExpenseAccount(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      bankName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}bank_name'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      currentBalance: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}current_balance'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      accountType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}account_type'])!,
      accountNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}account_number'])!,
      color: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}color'])!,
      showOnDashboard: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}show_on_dashboard'])!,
      dashboardOrder: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}dashboard_order'])!,
    );
  }

  @override
  $ExpenseAccountsTable createAlias(String alias) {
    return $ExpenseAccountsTable(attachedDatabase, alias);
  }
}

class ExpenseAccount extends DataClass implements Insertable<ExpenseAccount> {
  final String id;
  final String name;
  final String bankName;
  final String type;
  final double currentBalance;
  final DateTime createdAt;
  final String accountType;
  final String accountNumber;
  final int color;
  final bool showOnDashboard;
  final int dashboardOrder;
  const ExpenseAccount(
      {required this.id,
      required this.name,
      required this.bankName,
      required this.type,
      required this.currentBalance,
      required this.createdAt,
      required this.accountType,
      required this.accountNumber,
      required this.color,
      required this.showOnDashboard,
      required this.dashboardOrder});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['bank_name'] = Variable<String>(bankName);
    map['type'] = Variable<String>(type);
    map['current_balance'] = Variable<double>(currentBalance);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['account_type'] = Variable<String>(accountType);
    map['account_number'] = Variable<String>(accountNumber);
    map['color'] = Variable<int>(color);
    map['show_on_dashboard'] = Variable<bool>(showOnDashboard);
    map['dashboard_order'] = Variable<int>(dashboardOrder);
    return map;
  }

  ExpenseAccountsCompanion toCompanion(bool nullToAbsent) {
    return ExpenseAccountsCompanion(
      id: Value(id),
      name: Value(name),
      bankName: Value(bankName),
      type: Value(type),
      currentBalance: Value(currentBalance),
      createdAt: Value(createdAt),
      accountType: Value(accountType),
      accountNumber: Value(accountNumber),
      color: Value(color),
      showOnDashboard: Value(showOnDashboard),
      dashboardOrder: Value(dashboardOrder),
    );
  }

  factory ExpenseAccount.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExpenseAccount(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      bankName: serializer.fromJson<String>(json['bankName']),
      type: serializer.fromJson<String>(json['type']),
      currentBalance: serializer.fromJson<double>(json['currentBalance']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      accountType: serializer.fromJson<String>(json['accountType']),
      accountNumber: serializer.fromJson<String>(json['accountNumber']),
      color: serializer.fromJson<int>(json['color']),
      showOnDashboard: serializer.fromJson<bool>(json['showOnDashboard']),
      dashboardOrder: serializer.fromJson<int>(json['dashboardOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'bankName': serializer.toJson<String>(bankName),
      'type': serializer.toJson<String>(type),
      'currentBalance': serializer.toJson<double>(currentBalance),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'accountType': serializer.toJson<String>(accountType),
      'accountNumber': serializer.toJson<String>(accountNumber),
      'color': serializer.toJson<int>(color),
      'showOnDashboard': serializer.toJson<bool>(showOnDashboard),
      'dashboardOrder': serializer.toJson<int>(dashboardOrder),
    };
  }

  ExpenseAccount copyWith(
          {String? id,
          String? name,
          String? bankName,
          String? type,
          double? currentBalance,
          DateTime? createdAt,
          String? accountType,
          String? accountNumber,
          int? color,
          bool? showOnDashboard,
          int? dashboardOrder}) =>
      ExpenseAccount(
        id: id ?? this.id,
        name: name ?? this.name,
        bankName: bankName ?? this.bankName,
        type: type ?? this.type,
        currentBalance: currentBalance ?? this.currentBalance,
        createdAt: createdAt ?? this.createdAt,
        accountType: accountType ?? this.accountType,
        accountNumber: accountNumber ?? this.accountNumber,
        color: color ?? this.color,
        showOnDashboard: showOnDashboard ?? this.showOnDashboard,
        dashboardOrder: dashboardOrder ?? this.dashboardOrder,
      );
  ExpenseAccount copyWithCompanion(ExpenseAccountsCompanion data) {
    return ExpenseAccount(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      bankName: data.bankName.present ? data.bankName.value : this.bankName,
      type: data.type.present ? data.type.value : this.type,
      currentBalance: data.currentBalance.present
          ? data.currentBalance.value
          : this.currentBalance,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      accountType:
          data.accountType.present ? data.accountType.value : this.accountType,
      accountNumber: data.accountNumber.present
          ? data.accountNumber.value
          : this.accountNumber,
      color: data.color.present ? data.color.value : this.color,
      showOnDashboard: data.showOnDashboard.present
          ? data.showOnDashboard.value
          : this.showOnDashboard,
      dashboardOrder: data.dashboardOrder.present
          ? data.dashboardOrder.value
          : this.dashboardOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExpenseAccount(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('bankName: $bankName, ')
          ..write('type: $type, ')
          ..write('currentBalance: $currentBalance, ')
          ..write('createdAt: $createdAt, ')
          ..write('accountType: $accountType, ')
          ..write('accountNumber: $accountNumber, ')
          ..write('color: $color, ')
          ..write('showOnDashboard: $showOnDashboard, ')
          ..write('dashboardOrder: $dashboardOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      name,
      bankName,
      type,
      currentBalance,
      createdAt,
      accountType,
      accountNumber,
      color,
      showOnDashboard,
      dashboardOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExpenseAccount &&
          other.id == this.id &&
          other.name == this.name &&
          other.bankName == this.bankName &&
          other.type == this.type &&
          other.currentBalance == this.currentBalance &&
          other.createdAt == this.createdAt &&
          other.accountType == this.accountType &&
          other.accountNumber == this.accountNumber &&
          other.color == this.color &&
          other.showOnDashboard == this.showOnDashboard &&
          other.dashboardOrder == this.dashboardOrder);
}

class ExpenseAccountsCompanion extends UpdateCompanion<ExpenseAccount> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> bankName;
  final Value<String> type;
  final Value<double> currentBalance;
  final Value<DateTime> createdAt;
  final Value<String> accountType;
  final Value<String> accountNumber;
  final Value<int> color;
  final Value<bool> showOnDashboard;
  final Value<int> dashboardOrder;
  final Value<int> rowid;
  const ExpenseAccountsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.bankName = const Value.absent(),
    this.type = const Value.absent(),
    this.currentBalance = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.accountType = const Value.absent(),
    this.accountNumber = const Value.absent(),
    this.color = const Value.absent(),
    this.showOnDashboard = const Value.absent(),
    this.dashboardOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExpenseAccountsCompanion.insert({
    required String id,
    required String name,
    required String bankName,
    this.type = const Value.absent(),
    this.currentBalance = const Value.absent(),
    required DateTime createdAt,
    this.accountType = const Value.absent(),
    this.accountNumber = const Value.absent(),
    this.color = const Value.absent(),
    this.showOnDashboard = const Value.absent(),
    this.dashboardOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        bankName = Value(bankName),
        createdAt = Value(createdAt);
  static Insertable<ExpenseAccount> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? bankName,
    Expression<String>? type,
    Expression<double>? currentBalance,
    Expression<DateTime>? createdAt,
    Expression<String>? accountType,
    Expression<String>? accountNumber,
    Expression<int>? color,
    Expression<bool>? showOnDashboard,
    Expression<int>? dashboardOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (bankName != null) 'bank_name': bankName,
      if (type != null) 'type': type,
      if (currentBalance != null) 'current_balance': currentBalance,
      if (createdAt != null) 'created_at': createdAt,
      if (accountType != null) 'account_type': accountType,
      if (accountNumber != null) 'account_number': accountNumber,
      if (color != null) 'color': color,
      if (showOnDashboard != null) 'show_on_dashboard': showOnDashboard,
      if (dashboardOrder != null) 'dashboard_order': dashboardOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExpenseAccountsCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String>? bankName,
      Value<String>? type,
      Value<double>? currentBalance,
      Value<DateTime>? createdAt,
      Value<String>? accountType,
      Value<String>? accountNumber,
      Value<int>? color,
      Value<bool>? showOnDashboard,
      Value<int>? dashboardOrder,
      Value<int>? rowid}) {
    return ExpenseAccountsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      bankName: bankName ?? this.bankName,
      type: type ?? this.type,
      currentBalance: currentBalance ?? this.currentBalance,
      createdAt: createdAt ?? this.createdAt,
      accountType: accountType ?? this.accountType,
      accountNumber: accountNumber ?? this.accountNumber,
      color: color ?? this.color,
      showOnDashboard: showOnDashboard ?? this.showOnDashboard,
      dashboardOrder: dashboardOrder ?? this.dashboardOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (bankName.present) {
      map['bank_name'] = Variable<String>(bankName.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (currentBalance.present) {
      map['current_balance'] = Variable<double>(currentBalance.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (accountType.present) {
      map['account_type'] = Variable<String>(accountType.value);
    }
    if (accountNumber.present) {
      map['account_number'] = Variable<String>(accountNumber.value);
    }
    if (color.present) {
      map['color'] = Variable<int>(color.value);
    }
    if (showOnDashboard.present) {
      map['show_on_dashboard'] = Variable<bool>(showOnDashboard.value);
    }
    if (dashboardOrder.present) {
      map['dashboard_order'] = Variable<int>(dashboardOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExpenseAccountsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('bankName: $bankName, ')
          ..write('type: $type, ')
          ..write('currentBalance: $currentBalance, ')
          ..write('createdAt: $createdAt, ')
          ..write('accountType: $accountType, ')
          ..write('accountNumber: $accountNumber, ')
          ..write('color: $color, ')
          ..write('showOnDashboard: $showOnDashboard, ')
          ..write('dashboardOrder: $dashboardOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExpenseTransactionsTable extends ExpenseTransactions
    with TableInfo<$ExpenseTransactionsTable, ExpenseTransaction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExpenseTransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _accountIdMeta =
      const VerificationMeta('accountId');
  @override
  late final GeneratedColumn<String> accountId = GeneratedColumn<String>(
      'account_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES expense_accounts (id)'));
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
      'amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _bucketMeta = const VerificationMeta('bucket');
  @override
  late final GeneratedColumn<String> bucket = GeneratedColumn<String>(
      'bucket', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('Unallocated'));
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('Expense'));
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('General'));
  static const VerificationMeta _subCategoryMeta =
      const VerificationMeta('subCategory');
  @override
  late final GeneratedColumn<String> subCategory = GeneratedColumn<String>(
      'sub_category', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('General'));
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _transferAccountIdMeta =
      const VerificationMeta('transferAccountId');
  @override
  late final GeneratedColumn<String> transferAccountId =
      GeneratedColumn<String>('transfer_account_id', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _transferAccountNameMeta =
      const VerificationMeta('transferAccountName');
  @override
  late final GeneratedColumn<String> transferAccountName =
      GeneratedColumn<String>('transfer_account_name', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _transferAccountBankNameMeta =
      const VerificationMeta('transferAccountBankName');
  @override
  late final GeneratedColumn<String> transferAccountBankName =
      GeneratedColumn<String>('transfer_account_bank_name', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _linkedCreditCardIdMeta =
      const VerificationMeta('linkedCreditCardId');
  @override
  late final GeneratedColumn<String> linkedCreditCardId =
      GeneratedColumn<String>('linked_credit_card_id', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        accountId,
        amount,
        date,
        bucket,
        type,
        category,
        subCategory,
        notes,
        transferAccountId,
        transferAccountName,
        transferAccountBankName,
        linkedCreditCardId
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'expense_transactions';
  @override
  VerificationContext validateIntegrity(Insertable<ExpenseTransaction> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('account_id')) {
      context.handle(_accountIdMeta,
          accountId.isAcceptableOrUnknown(data['account_id']!, _accountIdMeta));
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('bucket')) {
      context.handle(_bucketMeta,
          bucket.isAcceptableOrUnknown(data['bucket']!, _bucketMeta));
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    }
    if (data.containsKey('sub_category')) {
      context.handle(
          _subCategoryMeta,
          subCategory.isAcceptableOrUnknown(
              data['sub_category']!, _subCategoryMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('transfer_account_id')) {
      context.handle(
          _transferAccountIdMeta,
          transferAccountId.isAcceptableOrUnknown(
              data['transfer_account_id']!, _transferAccountIdMeta));
    }
    if (data.containsKey('transfer_account_name')) {
      context.handle(
          _transferAccountNameMeta,
          transferAccountName.isAcceptableOrUnknown(
              data['transfer_account_name']!, _transferAccountNameMeta));
    }
    if (data.containsKey('transfer_account_bank_name')) {
      context.handle(
          _transferAccountBankNameMeta,
          transferAccountBankName.isAcceptableOrUnknown(
              data['transfer_account_bank_name']!,
              _transferAccountBankNameMeta));
    }
    if (data.containsKey('linked_credit_card_id')) {
      context.handle(
          _linkedCreditCardIdMeta,
          linkedCreditCardId.isAcceptableOrUnknown(
              data['linked_credit_card_id']!, _linkedCreditCardIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExpenseTransaction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExpenseTransaction(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      accountId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}account_id']),
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}amount'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      bucket: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}bucket'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      subCategory: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sub_category'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes'])!,
      transferAccountId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}transfer_account_id']),
      transferAccountName: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}transfer_account_name']),
      transferAccountBankName: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}transfer_account_bank_name']),
      linkedCreditCardId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}linked_credit_card_id']),
    );
  }

  @override
  $ExpenseTransactionsTable createAlias(String alias) {
    return $ExpenseTransactionsTable(attachedDatabase, alias);
  }
}

class ExpenseTransaction extends DataClass
    implements Insertable<ExpenseTransaction> {
  final String id;
  final String? accountId;
  final double amount;
  final DateTime date;
  final String bucket;
  final String type;
  final String category;
  final String subCategory;
  final String notes;
  final String? transferAccountId;
  final String? transferAccountName;
  final String? transferAccountBankName;
  final String? linkedCreditCardId;
  const ExpenseTransaction(
      {required this.id,
      this.accountId,
      required this.amount,
      required this.date,
      required this.bucket,
      required this.type,
      required this.category,
      required this.subCategory,
      required this.notes,
      this.transferAccountId,
      this.transferAccountName,
      this.transferAccountBankName,
      this.linkedCreditCardId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || accountId != null) {
      map['account_id'] = Variable<String>(accountId);
    }
    map['amount'] = Variable<double>(amount);
    map['date'] = Variable<DateTime>(date);
    map['bucket'] = Variable<String>(bucket);
    map['type'] = Variable<String>(type);
    map['category'] = Variable<String>(category);
    map['sub_category'] = Variable<String>(subCategory);
    map['notes'] = Variable<String>(notes);
    if (!nullToAbsent || transferAccountId != null) {
      map['transfer_account_id'] = Variable<String>(transferAccountId);
    }
    if (!nullToAbsent || transferAccountName != null) {
      map['transfer_account_name'] = Variable<String>(transferAccountName);
    }
    if (!nullToAbsent || transferAccountBankName != null) {
      map['transfer_account_bank_name'] =
          Variable<String>(transferAccountBankName);
    }
    if (!nullToAbsent || linkedCreditCardId != null) {
      map['linked_credit_card_id'] = Variable<String>(linkedCreditCardId);
    }
    return map;
  }

  ExpenseTransactionsCompanion toCompanion(bool nullToAbsent) {
    return ExpenseTransactionsCompanion(
      id: Value(id),
      accountId: accountId == null && nullToAbsent
          ? const Value.absent()
          : Value(accountId),
      amount: Value(amount),
      date: Value(date),
      bucket: Value(bucket),
      type: Value(type),
      category: Value(category),
      subCategory: Value(subCategory),
      notes: Value(notes),
      transferAccountId: transferAccountId == null && nullToAbsent
          ? const Value.absent()
          : Value(transferAccountId),
      transferAccountName: transferAccountName == null && nullToAbsent
          ? const Value.absent()
          : Value(transferAccountName),
      transferAccountBankName: transferAccountBankName == null && nullToAbsent
          ? const Value.absent()
          : Value(transferAccountBankName),
      linkedCreditCardId: linkedCreditCardId == null && nullToAbsent
          ? const Value.absent()
          : Value(linkedCreditCardId),
    );
  }

  factory ExpenseTransaction.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExpenseTransaction(
      id: serializer.fromJson<String>(json['id']),
      accountId: serializer.fromJson<String?>(json['accountId']),
      amount: serializer.fromJson<double>(json['amount']),
      date: serializer.fromJson<DateTime>(json['date']),
      bucket: serializer.fromJson<String>(json['bucket']),
      type: serializer.fromJson<String>(json['type']),
      category: serializer.fromJson<String>(json['category']),
      subCategory: serializer.fromJson<String>(json['subCategory']),
      notes: serializer.fromJson<String>(json['notes']),
      transferAccountId:
          serializer.fromJson<String?>(json['transferAccountId']),
      transferAccountName:
          serializer.fromJson<String?>(json['transferAccountName']),
      transferAccountBankName:
          serializer.fromJson<String?>(json['transferAccountBankName']),
      linkedCreditCardId:
          serializer.fromJson<String?>(json['linkedCreditCardId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'accountId': serializer.toJson<String?>(accountId),
      'amount': serializer.toJson<double>(amount),
      'date': serializer.toJson<DateTime>(date),
      'bucket': serializer.toJson<String>(bucket),
      'type': serializer.toJson<String>(type),
      'category': serializer.toJson<String>(category),
      'subCategory': serializer.toJson<String>(subCategory),
      'notes': serializer.toJson<String>(notes),
      'transferAccountId': serializer.toJson<String?>(transferAccountId),
      'transferAccountName': serializer.toJson<String?>(transferAccountName),
      'transferAccountBankName':
          serializer.toJson<String?>(transferAccountBankName),
      'linkedCreditCardId': serializer.toJson<String?>(linkedCreditCardId),
    };
  }

  ExpenseTransaction copyWith(
          {String? id,
          Value<String?> accountId = const Value.absent(),
          double? amount,
          DateTime? date,
          String? bucket,
          String? type,
          String? category,
          String? subCategory,
          String? notes,
          Value<String?> transferAccountId = const Value.absent(),
          Value<String?> transferAccountName = const Value.absent(),
          Value<String?> transferAccountBankName = const Value.absent(),
          Value<String?> linkedCreditCardId = const Value.absent()}) =>
      ExpenseTransaction(
        id: id ?? this.id,
        accountId: accountId.present ? accountId.value : this.accountId,
        amount: amount ?? this.amount,
        date: date ?? this.date,
        bucket: bucket ?? this.bucket,
        type: type ?? this.type,
        category: category ?? this.category,
        subCategory: subCategory ?? this.subCategory,
        notes: notes ?? this.notes,
        transferAccountId: transferAccountId.present
            ? transferAccountId.value
            : this.transferAccountId,
        transferAccountName: transferAccountName.present
            ? transferAccountName.value
            : this.transferAccountName,
        transferAccountBankName: transferAccountBankName.present
            ? transferAccountBankName.value
            : this.transferAccountBankName,
        linkedCreditCardId: linkedCreditCardId.present
            ? linkedCreditCardId.value
            : this.linkedCreditCardId,
      );
  ExpenseTransaction copyWithCompanion(ExpenseTransactionsCompanion data) {
    return ExpenseTransaction(
      id: data.id.present ? data.id.value : this.id,
      accountId: data.accountId.present ? data.accountId.value : this.accountId,
      amount: data.amount.present ? data.amount.value : this.amount,
      date: data.date.present ? data.date.value : this.date,
      bucket: data.bucket.present ? data.bucket.value : this.bucket,
      type: data.type.present ? data.type.value : this.type,
      category: data.category.present ? data.category.value : this.category,
      subCategory:
          data.subCategory.present ? data.subCategory.value : this.subCategory,
      notes: data.notes.present ? data.notes.value : this.notes,
      transferAccountId: data.transferAccountId.present
          ? data.transferAccountId.value
          : this.transferAccountId,
      transferAccountName: data.transferAccountName.present
          ? data.transferAccountName.value
          : this.transferAccountName,
      transferAccountBankName: data.transferAccountBankName.present
          ? data.transferAccountBankName.value
          : this.transferAccountBankName,
      linkedCreditCardId: data.linkedCreditCardId.present
          ? data.linkedCreditCardId.value
          : this.linkedCreditCardId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExpenseTransaction(')
          ..write('id: $id, ')
          ..write('accountId: $accountId, ')
          ..write('amount: $amount, ')
          ..write('date: $date, ')
          ..write('bucket: $bucket, ')
          ..write('type: $type, ')
          ..write('category: $category, ')
          ..write('subCategory: $subCategory, ')
          ..write('notes: $notes, ')
          ..write('transferAccountId: $transferAccountId, ')
          ..write('transferAccountName: $transferAccountName, ')
          ..write('transferAccountBankName: $transferAccountBankName, ')
          ..write('linkedCreditCardId: $linkedCreditCardId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      accountId,
      amount,
      date,
      bucket,
      type,
      category,
      subCategory,
      notes,
      transferAccountId,
      transferAccountName,
      transferAccountBankName,
      linkedCreditCardId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExpenseTransaction &&
          other.id == this.id &&
          other.accountId == this.accountId &&
          other.amount == this.amount &&
          other.date == this.date &&
          other.bucket == this.bucket &&
          other.type == this.type &&
          other.category == this.category &&
          other.subCategory == this.subCategory &&
          other.notes == this.notes &&
          other.transferAccountId == this.transferAccountId &&
          other.transferAccountName == this.transferAccountName &&
          other.transferAccountBankName == this.transferAccountBankName &&
          other.linkedCreditCardId == this.linkedCreditCardId);
}

class ExpenseTransactionsCompanion extends UpdateCompanion<ExpenseTransaction> {
  final Value<String> id;
  final Value<String?> accountId;
  final Value<double> amount;
  final Value<DateTime> date;
  final Value<String> bucket;
  final Value<String> type;
  final Value<String> category;
  final Value<String> subCategory;
  final Value<String> notes;
  final Value<String?> transferAccountId;
  final Value<String?> transferAccountName;
  final Value<String?> transferAccountBankName;
  final Value<String?> linkedCreditCardId;
  final Value<int> rowid;
  const ExpenseTransactionsCompanion({
    this.id = const Value.absent(),
    this.accountId = const Value.absent(),
    this.amount = const Value.absent(),
    this.date = const Value.absent(),
    this.bucket = const Value.absent(),
    this.type = const Value.absent(),
    this.category = const Value.absent(),
    this.subCategory = const Value.absent(),
    this.notes = const Value.absent(),
    this.transferAccountId = const Value.absent(),
    this.transferAccountName = const Value.absent(),
    this.transferAccountBankName = const Value.absent(),
    this.linkedCreditCardId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExpenseTransactionsCompanion.insert({
    required String id,
    this.accountId = const Value.absent(),
    required double amount,
    required DateTime date,
    this.bucket = const Value.absent(),
    this.type = const Value.absent(),
    this.category = const Value.absent(),
    this.subCategory = const Value.absent(),
    this.notes = const Value.absent(),
    this.transferAccountId = const Value.absent(),
    this.transferAccountName = const Value.absent(),
    this.transferAccountBankName = const Value.absent(),
    this.linkedCreditCardId = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        amount = Value(amount),
        date = Value(date);
  static Insertable<ExpenseTransaction> custom({
    Expression<String>? id,
    Expression<String>? accountId,
    Expression<double>? amount,
    Expression<DateTime>? date,
    Expression<String>? bucket,
    Expression<String>? type,
    Expression<String>? category,
    Expression<String>? subCategory,
    Expression<String>? notes,
    Expression<String>? transferAccountId,
    Expression<String>? transferAccountName,
    Expression<String>? transferAccountBankName,
    Expression<String>? linkedCreditCardId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (accountId != null) 'account_id': accountId,
      if (amount != null) 'amount': amount,
      if (date != null) 'date': date,
      if (bucket != null) 'bucket': bucket,
      if (type != null) 'type': type,
      if (category != null) 'category': category,
      if (subCategory != null) 'sub_category': subCategory,
      if (notes != null) 'notes': notes,
      if (transferAccountId != null) 'transfer_account_id': transferAccountId,
      if (transferAccountName != null)
        'transfer_account_name': transferAccountName,
      if (transferAccountBankName != null)
        'transfer_account_bank_name': transferAccountBankName,
      if (linkedCreditCardId != null)
        'linked_credit_card_id': linkedCreditCardId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExpenseTransactionsCompanion copyWith(
      {Value<String>? id,
      Value<String?>? accountId,
      Value<double>? amount,
      Value<DateTime>? date,
      Value<String>? bucket,
      Value<String>? type,
      Value<String>? category,
      Value<String>? subCategory,
      Value<String>? notes,
      Value<String?>? transferAccountId,
      Value<String?>? transferAccountName,
      Value<String?>? transferAccountBankName,
      Value<String?>? linkedCreditCardId,
      Value<int>? rowid}) {
    return ExpenseTransactionsCompanion(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      bucket: bucket ?? this.bucket,
      type: type ?? this.type,
      category: category ?? this.category,
      subCategory: subCategory ?? this.subCategory,
      notes: notes ?? this.notes,
      transferAccountId: transferAccountId ?? this.transferAccountId,
      transferAccountName: transferAccountName ?? this.transferAccountName,
      transferAccountBankName:
          transferAccountBankName ?? this.transferAccountBankName,
      linkedCreditCardId: linkedCreditCardId ?? this.linkedCreditCardId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (accountId.present) {
      map['account_id'] = Variable<String>(accountId.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (bucket.present) {
      map['bucket'] = Variable<String>(bucket.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (subCategory.present) {
      map['sub_category'] = Variable<String>(subCategory.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (transferAccountId.present) {
      map['transfer_account_id'] = Variable<String>(transferAccountId.value);
    }
    if (transferAccountName.present) {
      map['transfer_account_name'] =
          Variable<String>(transferAccountName.value);
    }
    if (transferAccountBankName.present) {
      map['transfer_account_bank_name'] =
          Variable<String>(transferAccountBankName.value);
    }
    if (linkedCreditCardId.present) {
      map['linked_credit_card_id'] = Variable<String>(linkedCreditCardId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExpenseTransactionsCompanion(')
          ..write('id: $id, ')
          ..write('accountId: $accountId, ')
          ..write('amount: $amount, ')
          ..write('date: $date, ')
          ..write('bucket: $bucket, ')
          ..write('type: $type, ')
          ..write('category: $category, ')
          ..write('subCategory: $subCategory, ')
          ..write('notes: $notes, ')
          ..write('transferAccountId: $transferAccountId, ')
          ..write('transferAccountName: $transferAccountName, ')
          ..write('transferAccountBankName: $transferAccountBankName, ')
          ..write('linkedCreditCardId: $linkedCreditCardId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CreditCardsTable extends CreditCards
    with TableInfo<$CreditCardsTable, CreditCard> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CreditCardsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _bankNameMeta =
      const VerificationMeta('bankName');
  @override
  late final GeneratedColumn<String> bankName = GeneratedColumn<String>(
      'bank_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _lastFourDigitsMeta =
      const VerificationMeta('lastFourDigits');
  @override
  late final GeneratedColumn<String> lastFourDigits = GeneratedColumn<String>(
      'last_four_digits', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _creditLimitMeta =
      const VerificationMeta('creditLimit');
  @override
  late final GeneratedColumn<double> creditLimit = GeneratedColumn<double>(
      'credit_limit', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _currentBalanceMeta =
      const VerificationMeta('currentBalance');
  @override
  late final GeneratedColumn<double> currentBalance = GeneratedColumn<double>(
      'current_balance', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _billDateMeta =
      const VerificationMeta('billDate');
  @override
  late final GeneratedColumn<int> billDate = GeneratedColumn<int>(
      'bill_date', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _dueDateMeta =
      const VerificationMeta('dueDate');
  @override
  late final GeneratedColumn<int> dueDate = GeneratedColumn<int>(
      'due_date', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<int> color = GeneratedColumn<int>(
      'color', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0xFF1E1E1E));
  static const VerificationMeta _isArchivedMeta =
      const VerificationMeta('isArchived');
  @override
  late final GeneratedColumn<bool> isArchived = GeneratedColumn<bool>(
      'is_archived', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_archived" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        bankName,
        lastFourDigits,
        creditLimit,
        currentBalance,
        billDate,
        dueDate,
        color,
        isArchived,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'credit_cards';
  @override
  VerificationContext validateIntegrity(Insertable<CreditCard> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('bank_name')) {
      context.handle(_bankNameMeta,
          bankName.isAcceptableOrUnknown(data['bank_name']!, _bankNameMeta));
    } else if (isInserting) {
      context.missing(_bankNameMeta);
    }
    if (data.containsKey('last_four_digits')) {
      context.handle(
          _lastFourDigitsMeta,
          lastFourDigits.isAcceptableOrUnknown(
              data['last_four_digits']!, _lastFourDigitsMeta));
    }
    if (data.containsKey('credit_limit')) {
      context.handle(
          _creditLimitMeta,
          creditLimit.isAcceptableOrUnknown(
              data['credit_limit']!, _creditLimitMeta));
    } else if (isInserting) {
      context.missing(_creditLimitMeta);
    }
    if (data.containsKey('current_balance')) {
      context.handle(
          _currentBalanceMeta,
          currentBalance.isAcceptableOrUnknown(
              data['current_balance']!, _currentBalanceMeta));
    }
    if (data.containsKey('bill_date')) {
      context.handle(_billDateMeta,
          billDate.isAcceptableOrUnknown(data['bill_date']!, _billDateMeta));
    } else if (isInserting) {
      context.missing(_billDateMeta);
    }
    if (data.containsKey('due_date')) {
      context.handle(_dueDateMeta,
          dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta));
    } else if (isInserting) {
      context.missing(_dueDateMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
          _colorMeta, color.isAcceptableOrUnknown(data['color']!, _colorMeta));
    }
    if (data.containsKey('is_archived')) {
      context.handle(
          _isArchivedMeta,
          isArchived.isAcceptableOrUnknown(
              data['is_archived']!, _isArchivedMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CreditCard map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CreditCard(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      bankName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}bank_name'])!,
      lastFourDigits: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}last_four_digits'])!,
      creditLimit: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}credit_limit'])!,
      currentBalance: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}current_balance'])!,
      billDate: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}bill_date'])!,
      dueDate: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}due_date'])!,
      color: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}color'])!,
      isArchived: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_archived'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $CreditCardsTable createAlias(String alias) {
    return $CreditCardsTable(attachedDatabase, alias);
  }
}

class CreditCard extends DataClass implements Insertable<CreditCard> {
  final String id;
  final String name;
  final String bankName;
  final String lastFourDigits;
  final double creditLimit;
  final double currentBalance;
  final int billDate;
  final int dueDate;
  final int color;
  final bool isArchived;
  final DateTime createdAt;
  final DateTime updatedAt;
  const CreditCard(
      {required this.id,
      required this.name,
      required this.bankName,
      required this.lastFourDigits,
      required this.creditLimit,
      required this.currentBalance,
      required this.billDate,
      required this.dueDate,
      required this.color,
      required this.isArchived,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['bank_name'] = Variable<String>(bankName);
    map['last_four_digits'] = Variable<String>(lastFourDigits);
    map['credit_limit'] = Variable<double>(creditLimit);
    map['current_balance'] = Variable<double>(currentBalance);
    map['bill_date'] = Variable<int>(billDate);
    map['due_date'] = Variable<int>(dueDate);
    map['color'] = Variable<int>(color);
    map['is_archived'] = Variable<bool>(isArchived);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CreditCardsCompanion toCompanion(bool nullToAbsent) {
    return CreditCardsCompanion(
      id: Value(id),
      name: Value(name),
      bankName: Value(bankName),
      lastFourDigits: Value(lastFourDigits),
      creditLimit: Value(creditLimit),
      currentBalance: Value(currentBalance),
      billDate: Value(billDate),
      dueDate: Value(dueDate),
      color: Value(color),
      isArchived: Value(isArchived),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory CreditCard.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CreditCard(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      bankName: serializer.fromJson<String>(json['bankName']),
      lastFourDigits: serializer.fromJson<String>(json['lastFourDigits']),
      creditLimit: serializer.fromJson<double>(json['creditLimit']),
      currentBalance: serializer.fromJson<double>(json['currentBalance']),
      billDate: serializer.fromJson<int>(json['billDate']),
      dueDate: serializer.fromJson<int>(json['dueDate']),
      color: serializer.fromJson<int>(json['color']),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'bankName': serializer.toJson<String>(bankName),
      'lastFourDigits': serializer.toJson<String>(lastFourDigits),
      'creditLimit': serializer.toJson<double>(creditLimit),
      'currentBalance': serializer.toJson<double>(currentBalance),
      'billDate': serializer.toJson<int>(billDate),
      'dueDate': serializer.toJson<int>(dueDate),
      'color': serializer.toJson<int>(color),
      'isArchived': serializer.toJson<bool>(isArchived),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  CreditCard copyWith(
          {String? id,
          String? name,
          String? bankName,
          String? lastFourDigits,
          double? creditLimit,
          double? currentBalance,
          int? billDate,
          int? dueDate,
          int? color,
          bool? isArchived,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      CreditCard(
        id: id ?? this.id,
        name: name ?? this.name,
        bankName: bankName ?? this.bankName,
        lastFourDigits: lastFourDigits ?? this.lastFourDigits,
        creditLimit: creditLimit ?? this.creditLimit,
        currentBalance: currentBalance ?? this.currentBalance,
        billDate: billDate ?? this.billDate,
        dueDate: dueDate ?? this.dueDate,
        color: color ?? this.color,
        isArchived: isArchived ?? this.isArchived,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  CreditCard copyWithCompanion(CreditCardsCompanion data) {
    return CreditCard(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      bankName: data.bankName.present ? data.bankName.value : this.bankName,
      lastFourDigits: data.lastFourDigits.present
          ? data.lastFourDigits.value
          : this.lastFourDigits,
      creditLimit:
          data.creditLimit.present ? data.creditLimit.value : this.creditLimit,
      currentBalance: data.currentBalance.present
          ? data.currentBalance.value
          : this.currentBalance,
      billDate: data.billDate.present ? data.billDate.value : this.billDate,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      color: data.color.present ? data.color.value : this.color,
      isArchived:
          data.isArchived.present ? data.isArchived.value : this.isArchived,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CreditCard(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('bankName: $bankName, ')
          ..write('lastFourDigits: $lastFourDigits, ')
          ..write('creditLimit: $creditLimit, ')
          ..write('currentBalance: $currentBalance, ')
          ..write('billDate: $billDate, ')
          ..write('dueDate: $dueDate, ')
          ..write('color: $color, ')
          ..write('isArchived: $isArchived, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      name,
      bankName,
      lastFourDigits,
      creditLimit,
      currentBalance,
      billDate,
      dueDate,
      color,
      isArchived,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CreditCard &&
          other.id == this.id &&
          other.name == this.name &&
          other.bankName == this.bankName &&
          other.lastFourDigits == this.lastFourDigits &&
          other.creditLimit == this.creditLimit &&
          other.currentBalance == this.currentBalance &&
          other.billDate == this.billDate &&
          other.dueDate == this.dueDate &&
          other.color == this.color &&
          other.isArchived == this.isArchived &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class CreditCardsCompanion extends UpdateCompanion<CreditCard> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> bankName;
  final Value<String> lastFourDigits;
  final Value<double> creditLimit;
  final Value<double> currentBalance;
  final Value<int> billDate;
  final Value<int> dueDate;
  final Value<int> color;
  final Value<bool> isArchived;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const CreditCardsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.bankName = const Value.absent(),
    this.lastFourDigits = const Value.absent(),
    this.creditLimit = const Value.absent(),
    this.currentBalance = const Value.absent(),
    this.billDate = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.color = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CreditCardsCompanion.insert({
    required String id,
    required String name,
    required String bankName,
    this.lastFourDigits = const Value.absent(),
    required double creditLimit,
    this.currentBalance = const Value.absent(),
    required int billDate,
    required int dueDate,
    this.color = const Value.absent(),
    this.isArchived = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        bankName = Value(bankName),
        creditLimit = Value(creditLimit),
        billDate = Value(billDate),
        dueDate = Value(dueDate),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<CreditCard> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? bankName,
    Expression<String>? lastFourDigits,
    Expression<double>? creditLimit,
    Expression<double>? currentBalance,
    Expression<int>? billDate,
    Expression<int>? dueDate,
    Expression<int>? color,
    Expression<bool>? isArchived,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (bankName != null) 'bank_name': bankName,
      if (lastFourDigits != null) 'last_four_digits': lastFourDigits,
      if (creditLimit != null) 'credit_limit': creditLimit,
      if (currentBalance != null) 'current_balance': currentBalance,
      if (billDate != null) 'bill_date': billDate,
      if (dueDate != null) 'due_date': dueDate,
      if (color != null) 'color': color,
      if (isArchived != null) 'is_archived': isArchived,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CreditCardsCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String>? bankName,
      Value<String>? lastFourDigits,
      Value<double>? creditLimit,
      Value<double>? currentBalance,
      Value<int>? billDate,
      Value<int>? dueDate,
      Value<int>? color,
      Value<bool>? isArchived,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return CreditCardsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      bankName: bankName ?? this.bankName,
      lastFourDigits: lastFourDigits ?? this.lastFourDigits,
      creditLimit: creditLimit ?? this.creditLimit,
      currentBalance: currentBalance ?? this.currentBalance,
      billDate: billDate ?? this.billDate,
      dueDate: dueDate ?? this.dueDate,
      color: color ?? this.color,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (bankName.present) {
      map['bank_name'] = Variable<String>(bankName.value);
    }
    if (lastFourDigits.present) {
      map['last_four_digits'] = Variable<String>(lastFourDigits.value);
    }
    if (creditLimit.present) {
      map['credit_limit'] = Variable<double>(creditLimit.value);
    }
    if (currentBalance.present) {
      map['current_balance'] = Variable<double>(currentBalance.value);
    }
    if (billDate.present) {
      map['bill_date'] = Variable<int>(billDate.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<int>(dueDate.value);
    }
    if (color.present) {
      map['color'] = Variable<int>(color.value);
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<bool>(isArchived.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CreditCardsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('bankName: $bankName, ')
          ..write('lastFourDigits: $lastFourDigits, ')
          ..write('creditLimit: $creditLimit, ')
          ..write('currentBalance: $currentBalance, ')
          ..write('billDate: $billDate, ')
          ..write('dueDate: $dueDate, ')
          ..write('color: $color, ')
          ..write('isArchived: $isArchived, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CreditTransactionsTable extends CreditTransactions
    with TableInfo<$CreditTransactionsTable, CreditTransaction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CreditTransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _cardIdMeta = const VerificationMeta('cardId');
  @override
  late final GeneratedColumn<String> cardId = GeneratedColumn<String>(
      'card_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES credit_cards (id)'));
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
      'amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _bucketMeta = const VerificationMeta('bucket');
  @override
  late final GeneratedColumn<String> bucket = GeneratedColumn<String>(
      'bucket', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('Unallocated'));
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _subCategoryMeta =
      const VerificationMeta('subCategory');
  @override
  late final GeneratedColumn<String> subCategory = GeneratedColumn<String>(
      'sub_category', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _linkedExpenseIdMeta =
      const VerificationMeta('linkedExpenseId');
  @override
  late final GeneratedColumn<String> linkedExpenseId = GeneratedColumn<String>(
      'linked_expense_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _includeInNextStatementMeta =
      const VerificationMeta('includeInNextStatement');
  @override
  late final GeneratedColumn<bool> includeInNextStatement =
      GeneratedColumn<bool>('include_in_next_statement', aliasedName, false,
          type: DriftSqlType.bool,
          requiredDuringInsert: false,
          defaultConstraints: GeneratedColumn.constraintIsAlways(
              'CHECK ("include_in_next_statement" IN (0, 1))'),
          defaultValue: const Constant(false));
  static const VerificationMeta _isSettlementVerifiedMeta =
      const VerificationMeta('isSettlementVerified');
  @override
  late final GeneratedColumn<bool> isSettlementVerified = GeneratedColumn<bool>(
      'is_settlement_verified', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_settlement_verified" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _isEmiMeta = const VerificationMeta('isEmi');
  @override
  late final GeneratedColumn<bool> isEmi = GeneratedColumn<bool>(
      'is_emi', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_emi" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _emiMonthsMeta =
      const VerificationMeta('emiMonths');
  @override
  late final GeneratedColumn<int> emiMonths = GeneratedColumn<int>(
      'emi_months', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _emiRemainingMeta =
      const VerificationMeta('emiRemaining');
  @override
  late final GeneratedColumn<int> emiRemaining = GeneratedColumn<int>(
      'emi_remaining', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        cardId,
        amount,
        date,
        description,
        bucket,
        type,
        category,
        subCategory,
        notes,
        linkedExpenseId,
        includeInNextStatement,
        isSettlementVerified,
        isEmi,
        emiMonths,
        emiRemaining
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'credit_transactions';
  @override
  VerificationContext validateIntegrity(Insertable<CreditTransaction> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('card_id')) {
      context.handle(_cardIdMeta,
          cardId.isAcceptableOrUnknown(data['card_id']!, _cardIdMeta));
    } else if (isInserting) {
      context.missing(_cardIdMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('bucket')) {
      context.handle(_bucketMeta,
          bucket.isAcceptableOrUnknown(data['bucket']!, _bucketMeta));
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('sub_category')) {
      context.handle(
          _subCategoryMeta,
          subCategory.isAcceptableOrUnknown(
              data['sub_category']!, _subCategoryMeta));
    } else if (isInserting) {
      context.missing(_subCategoryMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    } else if (isInserting) {
      context.missing(_notesMeta);
    }
    if (data.containsKey('linked_expense_id')) {
      context.handle(
          _linkedExpenseIdMeta,
          linkedExpenseId.isAcceptableOrUnknown(
              data['linked_expense_id']!, _linkedExpenseIdMeta));
    }
    if (data.containsKey('include_in_next_statement')) {
      context.handle(
          _includeInNextStatementMeta,
          includeInNextStatement.isAcceptableOrUnknown(
              data['include_in_next_statement']!, _includeInNextStatementMeta));
    }
    if (data.containsKey('is_settlement_verified')) {
      context.handle(
          _isSettlementVerifiedMeta,
          isSettlementVerified.isAcceptableOrUnknown(
              data['is_settlement_verified']!, _isSettlementVerifiedMeta));
    }
    if (data.containsKey('is_emi')) {
      context.handle(
          _isEmiMeta, isEmi.isAcceptableOrUnknown(data['is_emi']!, _isEmiMeta));
    }
    if (data.containsKey('emi_months')) {
      context.handle(_emiMonthsMeta,
          emiMonths.isAcceptableOrUnknown(data['emi_months']!, _emiMonthsMeta));
    }
    if (data.containsKey('emi_remaining')) {
      context.handle(
          _emiRemainingMeta,
          emiRemaining.isAcceptableOrUnknown(
              data['emi_remaining']!, _emiRemainingMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CreditTransaction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CreditTransaction(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      cardId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}card_id'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}amount'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description'])!,
      bucket: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}bucket'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      subCategory: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sub_category'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes'])!,
      linkedExpenseId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}linked_expense_id']),
      includeInNextStatement: attachedDatabase.typeMapping.read(
          DriftSqlType.bool,
          data['${effectivePrefix}include_in_next_statement'])!,
      isSettlementVerified: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}is_settlement_verified'])!,
      isEmi: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_emi'])!,
      emiMonths: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}emi_months'])!,
      emiRemaining: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}emi_remaining'])!,
    );
  }

  @override
  $CreditTransactionsTable createAlias(String alias) {
    return $CreditTransactionsTable(attachedDatabase, alias);
  }
}

class CreditTransaction extends DataClass
    implements Insertable<CreditTransaction> {
  final String id;
  final String cardId;
  final double amount;
  final DateTime date;
  final String description;
  final String bucket;
  final String type;
  final String category;
  final String subCategory;
  final String notes;
  final String? linkedExpenseId;
  final bool includeInNextStatement;
  final bool isSettlementVerified;
  final bool isEmi;
  final int emiMonths;
  final int emiRemaining;
  const CreditTransaction(
      {required this.id,
      required this.cardId,
      required this.amount,
      required this.date,
      required this.description,
      required this.bucket,
      required this.type,
      required this.category,
      required this.subCategory,
      required this.notes,
      this.linkedExpenseId,
      required this.includeInNextStatement,
      required this.isSettlementVerified,
      required this.isEmi,
      required this.emiMonths,
      required this.emiRemaining});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['card_id'] = Variable<String>(cardId);
    map['amount'] = Variable<double>(amount);
    map['date'] = Variable<DateTime>(date);
    map['description'] = Variable<String>(description);
    map['bucket'] = Variable<String>(bucket);
    map['type'] = Variable<String>(type);
    map['category'] = Variable<String>(category);
    map['sub_category'] = Variable<String>(subCategory);
    map['notes'] = Variable<String>(notes);
    if (!nullToAbsent || linkedExpenseId != null) {
      map['linked_expense_id'] = Variable<String>(linkedExpenseId);
    }
    map['include_in_next_statement'] = Variable<bool>(includeInNextStatement);
    map['is_settlement_verified'] = Variable<bool>(isSettlementVerified);
    map['is_emi'] = Variable<bool>(isEmi);
    map['emi_months'] = Variable<int>(emiMonths);
    map['emi_remaining'] = Variable<int>(emiRemaining);
    return map;
  }

  CreditTransactionsCompanion toCompanion(bool nullToAbsent) {
    return CreditTransactionsCompanion(
      id: Value(id),
      cardId: Value(cardId),
      amount: Value(amount),
      date: Value(date),
      description: Value(description),
      bucket: Value(bucket),
      type: Value(type),
      category: Value(category),
      subCategory: Value(subCategory),
      notes: Value(notes),
      linkedExpenseId: linkedExpenseId == null && nullToAbsent
          ? const Value.absent()
          : Value(linkedExpenseId),
      includeInNextStatement: Value(includeInNextStatement),
      isSettlementVerified: Value(isSettlementVerified),
      isEmi: Value(isEmi),
      emiMonths: Value(emiMonths),
      emiRemaining: Value(emiRemaining),
    );
  }

  factory CreditTransaction.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CreditTransaction(
      id: serializer.fromJson<String>(json['id']),
      cardId: serializer.fromJson<String>(json['cardId']),
      amount: serializer.fromJson<double>(json['amount']),
      date: serializer.fromJson<DateTime>(json['date']),
      description: serializer.fromJson<String>(json['description']),
      bucket: serializer.fromJson<String>(json['bucket']),
      type: serializer.fromJson<String>(json['type']),
      category: serializer.fromJson<String>(json['category']),
      subCategory: serializer.fromJson<String>(json['subCategory']),
      notes: serializer.fromJson<String>(json['notes']),
      linkedExpenseId: serializer.fromJson<String?>(json['linkedExpenseId']),
      includeInNextStatement:
          serializer.fromJson<bool>(json['includeInNextStatement']),
      isSettlementVerified:
          serializer.fromJson<bool>(json['isSettlementVerified']),
      isEmi: serializer.fromJson<bool>(json['isEmi']),
      emiMonths: serializer.fromJson<int>(json['emiMonths']),
      emiRemaining: serializer.fromJson<int>(json['emiRemaining']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'cardId': serializer.toJson<String>(cardId),
      'amount': serializer.toJson<double>(amount),
      'date': serializer.toJson<DateTime>(date),
      'description': serializer.toJson<String>(description),
      'bucket': serializer.toJson<String>(bucket),
      'type': serializer.toJson<String>(type),
      'category': serializer.toJson<String>(category),
      'subCategory': serializer.toJson<String>(subCategory),
      'notes': serializer.toJson<String>(notes),
      'linkedExpenseId': serializer.toJson<String?>(linkedExpenseId),
      'includeInNextStatement': serializer.toJson<bool>(includeInNextStatement),
      'isSettlementVerified': serializer.toJson<bool>(isSettlementVerified),
      'isEmi': serializer.toJson<bool>(isEmi),
      'emiMonths': serializer.toJson<int>(emiMonths),
      'emiRemaining': serializer.toJson<int>(emiRemaining),
    };
  }

  CreditTransaction copyWith(
          {String? id,
          String? cardId,
          double? amount,
          DateTime? date,
          String? description,
          String? bucket,
          String? type,
          String? category,
          String? subCategory,
          String? notes,
          Value<String?> linkedExpenseId = const Value.absent(),
          bool? includeInNextStatement,
          bool? isSettlementVerified,
          bool? isEmi,
          int? emiMonths,
          int? emiRemaining}) =>
      CreditTransaction(
        id: id ?? this.id,
        cardId: cardId ?? this.cardId,
        amount: amount ?? this.amount,
        date: date ?? this.date,
        description: description ?? this.description,
        bucket: bucket ?? this.bucket,
        type: type ?? this.type,
        category: category ?? this.category,
        subCategory: subCategory ?? this.subCategory,
        notes: notes ?? this.notes,
        linkedExpenseId: linkedExpenseId.present
            ? linkedExpenseId.value
            : this.linkedExpenseId,
        includeInNextStatement:
            includeInNextStatement ?? this.includeInNextStatement,
        isSettlementVerified: isSettlementVerified ?? this.isSettlementVerified,
        isEmi: isEmi ?? this.isEmi,
        emiMonths: emiMonths ?? this.emiMonths,
        emiRemaining: emiRemaining ?? this.emiRemaining,
      );
  CreditTransaction copyWithCompanion(CreditTransactionsCompanion data) {
    return CreditTransaction(
      id: data.id.present ? data.id.value : this.id,
      cardId: data.cardId.present ? data.cardId.value : this.cardId,
      amount: data.amount.present ? data.amount.value : this.amount,
      date: data.date.present ? data.date.value : this.date,
      description:
          data.description.present ? data.description.value : this.description,
      bucket: data.bucket.present ? data.bucket.value : this.bucket,
      type: data.type.present ? data.type.value : this.type,
      category: data.category.present ? data.category.value : this.category,
      subCategory:
          data.subCategory.present ? data.subCategory.value : this.subCategory,
      notes: data.notes.present ? data.notes.value : this.notes,
      linkedExpenseId: data.linkedExpenseId.present
          ? data.linkedExpenseId.value
          : this.linkedExpenseId,
      includeInNextStatement: data.includeInNextStatement.present
          ? data.includeInNextStatement.value
          : this.includeInNextStatement,
      isSettlementVerified: data.isSettlementVerified.present
          ? data.isSettlementVerified.value
          : this.isSettlementVerified,
      isEmi: data.isEmi.present ? data.isEmi.value : this.isEmi,
      emiMonths: data.emiMonths.present ? data.emiMonths.value : this.emiMonths,
      emiRemaining: data.emiRemaining.present
          ? data.emiRemaining.value
          : this.emiRemaining,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CreditTransaction(')
          ..write('id: $id, ')
          ..write('cardId: $cardId, ')
          ..write('amount: $amount, ')
          ..write('date: $date, ')
          ..write('description: $description, ')
          ..write('bucket: $bucket, ')
          ..write('type: $type, ')
          ..write('category: $category, ')
          ..write('subCategory: $subCategory, ')
          ..write('notes: $notes, ')
          ..write('linkedExpenseId: $linkedExpenseId, ')
          ..write('includeInNextStatement: $includeInNextStatement, ')
          ..write('isSettlementVerified: $isSettlementVerified, ')
          ..write('isEmi: $isEmi, ')
          ..write('emiMonths: $emiMonths, ')
          ..write('emiRemaining: $emiRemaining')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      cardId,
      amount,
      date,
      description,
      bucket,
      type,
      category,
      subCategory,
      notes,
      linkedExpenseId,
      includeInNextStatement,
      isSettlementVerified,
      isEmi,
      emiMonths,
      emiRemaining);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CreditTransaction &&
          other.id == this.id &&
          other.cardId == this.cardId &&
          other.amount == this.amount &&
          other.date == this.date &&
          other.description == this.description &&
          other.bucket == this.bucket &&
          other.type == this.type &&
          other.category == this.category &&
          other.subCategory == this.subCategory &&
          other.notes == this.notes &&
          other.linkedExpenseId == this.linkedExpenseId &&
          other.includeInNextStatement == this.includeInNextStatement &&
          other.isSettlementVerified == this.isSettlementVerified &&
          other.isEmi == this.isEmi &&
          other.emiMonths == this.emiMonths &&
          other.emiRemaining == this.emiRemaining);
}

class CreditTransactionsCompanion extends UpdateCompanion<CreditTransaction> {
  final Value<String> id;
  final Value<String> cardId;
  final Value<double> amount;
  final Value<DateTime> date;
  final Value<String> description;
  final Value<String> bucket;
  final Value<String> type;
  final Value<String> category;
  final Value<String> subCategory;
  final Value<String> notes;
  final Value<String?> linkedExpenseId;
  final Value<bool> includeInNextStatement;
  final Value<bool> isSettlementVerified;
  final Value<bool> isEmi;
  final Value<int> emiMonths;
  final Value<int> emiRemaining;
  final Value<int> rowid;
  const CreditTransactionsCompanion({
    this.id = const Value.absent(),
    this.cardId = const Value.absent(),
    this.amount = const Value.absent(),
    this.date = const Value.absent(),
    this.description = const Value.absent(),
    this.bucket = const Value.absent(),
    this.type = const Value.absent(),
    this.category = const Value.absent(),
    this.subCategory = const Value.absent(),
    this.notes = const Value.absent(),
    this.linkedExpenseId = const Value.absent(),
    this.includeInNextStatement = const Value.absent(),
    this.isSettlementVerified = const Value.absent(),
    this.isEmi = const Value.absent(),
    this.emiMonths = const Value.absent(),
    this.emiRemaining = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CreditTransactionsCompanion.insert({
    required String id,
    required String cardId,
    required double amount,
    required DateTime date,
    required String description,
    this.bucket = const Value.absent(),
    required String type,
    required String category,
    required String subCategory,
    required String notes,
    this.linkedExpenseId = const Value.absent(),
    this.includeInNextStatement = const Value.absent(),
    this.isSettlementVerified = const Value.absent(),
    this.isEmi = const Value.absent(),
    this.emiMonths = const Value.absent(),
    this.emiRemaining = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        cardId = Value(cardId),
        amount = Value(amount),
        date = Value(date),
        description = Value(description),
        type = Value(type),
        category = Value(category),
        subCategory = Value(subCategory),
        notes = Value(notes);
  static Insertable<CreditTransaction> custom({
    Expression<String>? id,
    Expression<String>? cardId,
    Expression<double>? amount,
    Expression<DateTime>? date,
    Expression<String>? description,
    Expression<String>? bucket,
    Expression<String>? type,
    Expression<String>? category,
    Expression<String>? subCategory,
    Expression<String>? notes,
    Expression<String>? linkedExpenseId,
    Expression<bool>? includeInNextStatement,
    Expression<bool>? isSettlementVerified,
    Expression<bool>? isEmi,
    Expression<int>? emiMonths,
    Expression<int>? emiRemaining,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (cardId != null) 'card_id': cardId,
      if (amount != null) 'amount': amount,
      if (date != null) 'date': date,
      if (description != null) 'description': description,
      if (bucket != null) 'bucket': bucket,
      if (type != null) 'type': type,
      if (category != null) 'category': category,
      if (subCategory != null) 'sub_category': subCategory,
      if (notes != null) 'notes': notes,
      if (linkedExpenseId != null) 'linked_expense_id': linkedExpenseId,
      if (includeInNextStatement != null)
        'include_in_next_statement': includeInNextStatement,
      if (isSettlementVerified != null)
        'is_settlement_verified': isSettlementVerified,
      if (isEmi != null) 'is_emi': isEmi,
      if (emiMonths != null) 'emi_months': emiMonths,
      if (emiRemaining != null) 'emi_remaining': emiRemaining,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CreditTransactionsCompanion copyWith(
      {Value<String>? id,
      Value<String>? cardId,
      Value<double>? amount,
      Value<DateTime>? date,
      Value<String>? description,
      Value<String>? bucket,
      Value<String>? type,
      Value<String>? category,
      Value<String>? subCategory,
      Value<String>? notes,
      Value<String?>? linkedExpenseId,
      Value<bool>? includeInNextStatement,
      Value<bool>? isSettlementVerified,
      Value<bool>? isEmi,
      Value<int>? emiMonths,
      Value<int>? emiRemaining,
      Value<int>? rowid}) {
    return CreditTransactionsCompanion(
      id: id ?? this.id,
      cardId: cardId ?? this.cardId,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      description: description ?? this.description,
      bucket: bucket ?? this.bucket,
      type: type ?? this.type,
      category: category ?? this.category,
      subCategory: subCategory ?? this.subCategory,
      notes: notes ?? this.notes,
      linkedExpenseId: linkedExpenseId ?? this.linkedExpenseId,
      includeInNextStatement:
          includeInNextStatement ?? this.includeInNextStatement,
      isSettlementVerified: isSettlementVerified ?? this.isSettlementVerified,
      isEmi: isEmi ?? this.isEmi,
      emiMonths: emiMonths ?? this.emiMonths,
      emiRemaining: emiRemaining ?? this.emiRemaining,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (cardId.present) {
      map['card_id'] = Variable<String>(cardId.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (bucket.present) {
      map['bucket'] = Variable<String>(bucket.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (subCategory.present) {
      map['sub_category'] = Variable<String>(subCategory.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (linkedExpenseId.present) {
      map['linked_expense_id'] = Variable<String>(linkedExpenseId.value);
    }
    if (includeInNextStatement.present) {
      map['include_in_next_statement'] =
          Variable<bool>(includeInNextStatement.value);
    }
    if (isSettlementVerified.present) {
      map['is_settlement_verified'] =
          Variable<bool>(isSettlementVerified.value);
    }
    if (isEmi.present) {
      map['is_emi'] = Variable<bool>(isEmi.value);
    }
    if (emiMonths.present) {
      map['emi_months'] = Variable<int>(emiMonths.value);
    }
    if (emiRemaining.present) {
      map['emi_remaining'] = Variable<int>(emiRemaining.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CreditTransactionsCompanion(')
          ..write('id: $id, ')
          ..write('cardId: $cardId, ')
          ..write('amount: $amount, ')
          ..write('date: $date, ')
          ..write('description: $description, ')
          ..write('bucket: $bucket, ')
          ..write('type: $type, ')
          ..write('category: $category, ')
          ..write('subCategory: $subCategory, ')
          ..write('notes: $notes, ')
          ..write('linkedExpenseId: $linkedExpenseId, ')
          ..write('includeInNextStatement: $includeInNextStatement, ')
          ..write('isSettlementVerified: $isSettlementVerified, ')
          ..write('isEmi: $isEmi, ')
          ..write('emiMonths: $emiMonths, ')
          ..write('emiRemaining: $emiRemaining, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InvestmentRecordsTable extends InvestmentRecords
    with TableInfo<$InvestmentRecordsTable, InvestmentRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InvestmentRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _symbolMeta = const VerificationMeta('symbol');
  @override
  late final GeneratedColumn<String> symbol = GeneratedColumn<String>(
      'symbol', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _quantityMeta =
      const VerificationMeta('quantity');
  @override
  late final GeneratedColumn<double> quantity = GeneratedColumn<double>(
      'quantity', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _averagePriceMeta =
      const VerificationMeta('averagePrice');
  @override
  late final GeneratedColumn<double> averagePrice = GeneratedColumn<double>(
      'average_price', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _currentPriceMeta =
      const VerificationMeta('currentPrice');
  @override
  late final GeneratedColumn<double> currentPrice = GeneratedColumn<double>(
      'current_price', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _previousCloseMeta =
      const VerificationMeta('previousClose');
  @override
  late final GeneratedColumn<double> previousClose = GeneratedColumn<double>(
      'previous_close', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _bucketMeta = const VerificationMeta('bucket');
  @override
  late final GeneratedColumn<String> bucket = GeneratedColumn<String>(
      'bucket', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('General'));
  static const VerificationMeta _lastPurchasedDateMeta =
      const VerificationMeta('lastPurchasedDate');
  @override
  late final GeneratedColumn<DateTime> lastPurchasedDate =
      GeneratedColumn<DateTime>('last_purchased_date', aliasedName, false,
          type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _lastUpdatedMeta =
      const VerificationMeta('lastUpdated');
  @override
  late final GeneratedColumn<DateTime> lastUpdated = GeneratedColumn<DateTime>(
      'last_updated', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _isManualMeta =
      const VerificationMeta('isManual');
  @override
  late final GeneratedColumn<bool> isManual = GeneratedColumn<bool>(
      'is_manual', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_manual" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        symbol,
        name,
        type,
        quantity,
        averagePrice,
        currentPrice,
        previousClose,
        bucket,
        lastPurchasedDate,
        lastUpdated,
        isManual
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'investment_records';
  @override
  VerificationContext validateIntegrity(Insertable<InvestmentRecord> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('symbol')) {
      context.handle(_symbolMeta,
          symbol.isAcceptableOrUnknown(data['symbol']!, _symbolMeta));
    } else if (isInserting) {
      context.missing(_symbolMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(_quantityMeta,
          quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta));
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('average_price')) {
      context.handle(
          _averagePriceMeta,
          averagePrice.isAcceptableOrUnknown(
              data['average_price']!, _averagePriceMeta));
    } else if (isInserting) {
      context.missing(_averagePriceMeta);
    }
    if (data.containsKey('current_price')) {
      context.handle(
          _currentPriceMeta,
          currentPrice.isAcceptableOrUnknown(
              data['current_price']!, _currentPriceMeta));
    } else if (isInserting) {
      context.missing(_currentPriceMeta);
    }
    if (data.containsKey('previous_close')) {
      context.handle(
          _previousCloseMeta,
          previousClose.isAcceptableOrUnknown(
              data['previous_close']!, _previousCloseMeta));
    }
    if (data.containsKey('bucket')) {
      context.handle(_bucketMeta,
          bucket.isAcceptableOrUnknown(data['bucket']!, _bucketMeta));
    }
    if (data.containsKey('last_purchased_date')) {
      context.handle(
          _lastPurchasedDateMeta,
          lastPurchasedDate.isAcceptableOrUnknown(
              data['last_purchased_date']!, _lastPurchasedDateMeta));
    } else if (isInserting) {
      context.missing(_lastPurchasedDateMeta);
    }
    if (data.containsKey('last_updated')) {
      context.handle(
          _lastUpdatedMeta,
          lastUpdated.isAcceptableOrUnknown(
              data['last_updated']!, _lastUpdatedMeta));
    } else if (isInserting) {
      context.missing(_lastUpdatedMeta);
    }
    if (data.containsKey('is_manual')) {
      context.handle(_isManualMeta,
          isManual.isAcceptableOrUnknown(data['is_manual']!, _isManualMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  InvestmentRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InvestmentRecord(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      symbol: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}symbol'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      quantity: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}quantity'])!,
      averagePrice: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}average_price'])!,
      currentPrice: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}current_price'])!,
      previousClose: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}previous_close'])!,
      bucket: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}bucket'])!,
      lastPurchasedDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime,
          data['${effectivePrefix}last_purchased_date'])!,
      lastUpdated: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}last_updated'])!,
      isManual: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_manual'])!,
    );
  }

  @override
  $InvestmentRecordsTable createAlias(String alias) {
    return $InvestmentRecordsTable(attachedDatabase, alias);
  }
}

class InvestmentRecord extends DataClass
    implements Insertable<InvestmentRecord> {
  final String id;
  final String symbol;
  final String name;
  final String type;
  final double quantity;
  final double averagePrice;
  final double currentPrice;
  final double previousClose;
  final String bucket;
  final DateTime lastPurchasedDate;
  final DateTime lastUpdated;
  final bool isManual;
  const InvestmentRecord(
      {required this.id,
      required this.symbol,
      required this.name,
      required this.type,
      required this.quantity,
      required this.averagePrice,
      required this.currentPrice,
      required this.previousClose,
      required this.bucket,
      required this.lastPurchasedDate,
      required this.lastUpdated,
      required this.isManual});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['symbol'] = Variable<String>(symbol);
    map['name'] = Variable<String>(name);
    map['type'] = Variable<String>(type);
    map['quantity'] = Variable<double>(quantity);
    map['average_price'] = Variable<double>(averagePrice);
    map['current_price'] = Variable<double>(currentPrice);
    map['previous_close'] = Variable<double>(previousClose);
    map['bucket'] = Variable<String>(bucket);
    map['last_purchased_date'] = Variable<DateTime>(lastPurchasedDate);
    map['last_updated'] = Variable<DateTime>(lastUpdated);
    map['is_manual'] = Variable<bool>(isManual);
    return map;
  }

  InvestmentRecordsCompanion toCompanion(bool nullToAbsent) {
    return InvestmentRecordsCompanion(
      id: Value(id),
      symbol: Value(symbol),
      name: Value(name),
      type: Value(type),
      quantity: Value(quantity),
      averagePrice: Value(averagePrice),
      currentPrice: Value(currentPrice),
      previousClose: Value(previousClose),
      bucket: Value(bucket),
      lastPurchasedDate: Value(lastPurchasedDate),
      lastUpdated: Value(lastUpdated),
      isManual: Value(isManual),
    );
  }

  factory InvestmentRecord.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InvestmentRecord(
      id: serializer.fromJson<String>(json['id']),
      symbol: serializer.fromJson<String>(json['symbol']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<String>(json['type']),
      quantity: serializer.fromJson<double>(json['quantity']),
      averagePrice: serializer.fromJson<double>(json['averagePrice']),
      currentPrice: serializer.fromJson<double>(json['currentPrice']),
      previousClose: serializer.fromJson<double>(json['previousClose']),
      bucket: serializer.fromJson<String>(json['bucket']),
      lastPurchasedDate:
          serializer.fromJson<DateTime>(json['lastPurchasedDate']),
      lastUpdated: serializer.fromJson<DateTime>(json['lastUpdated']),
      isManual: serializer.fromJson<bool>(json['isManual']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'symbol': serializer.toJson<String>(symbol),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(type),
      'quantity': serializer.toJson<double>(quantity),
      'averagePrice': serializer.toJson<double>(averagePrice),
      'currentPrice': serializer.toJson<double>(currentPrice),
      'previousClose': serializer.toJson<double>(previousClose),
      'bucket': serializer.toJson<String>(bucket),
      'lastPurchasedDate': serializer.toJson<DateTime>(lastPurchasedDate),
      'lastUpdated': serializer.toJson<DateTime>(lastUpdated),
      'isManual': serializer.toJson<bool>(isManual),
    };
  }

  InvestmentRecord copyWith(
          {String? id,
          String? symbol,
          String? name,
          String? type,
          double? quantity,
          double? averagePrice,
          double? currentPrice,
          double? previousClose,
          String? bucket,
          DateTime? lastPurchasedDate,
          DateTime? lastUpdated,
          bool? isManual}) =>
      InvestmentRecord(
        id: id ?? this.id,
        symbol: symbol ?? this.symbol,
        name: name ?? this.name,
        type: type ?? this.type,
        quantity: quantity ?? this.quantity,
        averagePrice: averagePrice ?? this.averagePrice,
        currentPrice: currentPrice ?? this.currentPrice,
        previousClose: previousClose ?? this.previousClose,
        bucket: bucket ?? this.bucket,
        lastPurchasedDate: lastPurchasedDate ?? this.lastPurchasedDate,
        lastUpdated: lastUpdated ?? this.lastUpdated,
        isManual: isManual ?? this.isManual,
      );
  InvestmentRecord copyWithCompanion(InvestmentRecordsCompanion data) {
    return InvestmentRecord(
      id: data.id.present ? data.id.value : this.id,
      symbol: data.symbol.present ? data.symbol.value : this.symbol,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      averagePrice: data.averagePrice.present
          ? data.averagePrice.value
          : this.averagePrice,
      currentPrice: data.currentPrice.present
          ? data.currentPrice.value
          : this.currentPrice,
      previousClose: data.previousClose.present
          ? data.previousClose.value
          : this.previousClose,
      bucket: data.bucket.present ? data.bucket.value : this.bucket,
      lastPurchasedDate: data.lastPurchasedDate.present
          ? data.lastPurchasedDate.value
          : this.lastPurchasedDate,
      lastUpdated:
          data.lastUpdated.present ? data.lastUpdated.value : this.lastUpdated,
      isManual: data.isManual.present ? data.isManual.value : this.isManual,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InvestmentRecord(')
          ..write('id: $id, ')
          ..write('symbol: $symbol, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('quantity: $quantity, ')
          ..write('averagePrice: $averagePrice, ')
          ..write('currentPrice: $currentPrice, ')
          ..write('previousClose: $previousClose, ')
          ..write('bucket: $bucket, ')
          ..write('lastPurchasedDate: $lastPurchasedDate, ')
          ..write('lastUpdated: $lastUpdated, ')
          ..write('isManual: $isManual')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      symbol,
      name,
      type,
      quantity,
      averagePrice,
      currentPrice,
      previousClose,
      bucket,
      lastPurchasedDate,
      lastUpdated,
      isManual);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InvestmentRecord &&
          other.id == this.id &&
          other.symbol == this.symbol &&
          other.name == this.name &&
          other.type == this.type &&
          other.quantity == this.quantity &&
          other.averagePrice == this.averagePrice &&
          other.currentPrice == this.currentPrice &&
          other.previousClose == this.previousClose &&
          other.bucket == this.bucket &&
          other.lastPurchasedDate == this.lastPurchasedDate &&
          other.lastUpdated == this.lastUpdated &&
          other.isManual == this.isManual);
}

class InvestmentRecordsCompanion extends UpdateCompanion<InvestmentRecord> {
  final Value<String> id;
  final Value<String> symbol;
  final Value<String> name;
  final Value<String> type;
  final Value<double> quantity;
  final Value<double> averagePrice;
  final Value<double> currentPrice;
  final Value<double> previousClose;
  final Value<String> bucket;
  final Value<DateTime> lastPurchasedDate;
  final Value<DateTime> lastUpdated;
  final Value<bool> isManual;
  final Value<int> rowid;
  const InvestmentRecordsCompanion({
    this.id = const Value.absent(),
    this.symbol = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.quantity = const Value.absent(),
    this.averagePrice = const Value.absent(),
    this.currentPrice = const Value.absent(),
    this.previousClose = const Value.absent(),
    this.bucket = const Value.absent(),
    this.lastPurchasedDate = const Value.absent(),
    this.lastUpdated = const Value.absent(),
    this.isManual = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InvestmentRecordsCompanion.insert({
    required String id,
    required String symbol,
    required String name,
    required String type,
    required double quantity,
    required double averagePrice,
    required double currentPrice,
    this.previousClose = const Value.absent(),
    this.bucket = const Value.absent(),
    required DateTime lastPurchasedDate,
    required DateTime lastUpdated,
    this.isManual = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        symbol = Value(symbol),
        name = Value(name),
        type = Value(type),
        quantity = Value(quantity),
        averagePrice = Value(averagePrice),
        currentPrice = Value(currentPrice),
        lastPurchasedDate = Value(lastPurchasedDate),
        lastUpdated = Value(lastUpdated);
  static Insertable<InvestmentRecord> custom({
    Expression<String>? id,
    Expression<String>? symbol,
    Expression<String>? name,
    Expression<String>? type,
    Expression<double>? quantity,
    Expression<double>? averagePrice,
    Expression<double>? currentPrice,
    Expression<double>? previousClose,
    Expression<String>? bucket,
    Expression<DateTime>? lastPurchasedDate,
    Expression<DateTime>? lastUpdated,
    Expression<bool>? isManual,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (symbol != null) 'symbol': symbol,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (quantity != null) 'quantity': quantity,
      if (averagePrice != null) 'average_price': averagePrice,
      if (currentPrice != null) 'current_price': currentPrice,
      if (previousClose != null) 'previous_close': previousClose,
      if (bucket != null) 'bucket': bucket,
      if (lastPurchasedDate != null) 'last_purchased_date': lastPurchasedDate,
      if (lastUpdated != null) 'last_updated': lastUpdated,
      if (isManual != null) 'is_manual': isManual,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InvestmentRecordsCompanion copyWith(
      {Value<String>? id,
      Value<String>? symbol,
      Value<String>? name,
      Value<String>? type,
      Value<double>? quantity,
      Value<double>? averagePrice,
      Value<double>? currentPrice,
      Value<double>? previousClose,
      Value<String>? bucket,
      Value<DateTime>? lastPurchasedDate,
      Value<DateTime>? lastUpdated,
      Value<bool>? isManual,
      Value<int>? rowid}) {
    return InvestmentRecordsCompanion(
      id: id ?? this.id,
      symbol: symbol ?? this.symbol,
      name: name ?? this.name,
      type: type ?? this.type,
      quantity: quantity ?? this.quantity,
      averagePrice: averagePrice ?? this.averagePrice,
      currentPrice: currentPrice ?? this.currentPrice,
      previousClose: previousClose ?? this.previousClose,
      bucket: bucket ?? this.bucket,
      lastPurchasedDate: lastPurchasedDate ?? this.lastPurchasedDate,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      isManual: isManual ?? this.isManual,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (symbol.present) {
      map['symbol'] = Variable<String>(symbol.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<double>(quantity.value);
    }
    if (averagePrice.present) {
      map['average_price'] = Variable<double>(averagePrice.value);
    }
    if (currentPrice.present) {
      map['current_price'] = Variable<double>(currentPrice.value);
    }
    if (previousClose.present) {
      map['previous_close'] = Variable<double>(previousClose.value);
    }
    if (bucket.present) {
      map['bucket'] = Variable<String>(bucket.value);
    }
    if (lastPurchasedDate.present) {
      map['last_purchased_date'] = Variable<DateTime>(lastPurchasedDate.value);
    }
    if (lastUpdated.present) {
      map['last_updated'] = Variable<DateTime>(lastUpdated.value);
    }
    if (isManual.present) {
      map['is_manual'] = Variable<bool>(isManual.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InvestmentRecordsCompanion(')
          ..write('id: $id, ')
          ..write('symbol: $symbol, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('quantity: $quantity, ')
          ..write('averagePrice: $averagePrice, ')
          ..write('currentPrice: $currentPrice, ')
          ..write('previousClose: $previousClose, ')
          ..write('bucket: $bucket, ')
          ..write('lastPurchasedDate: $lastPurchasedDate, ')
          ..write('lastUpdated: $lastUpdated, ')
          ..write('isManual: $isManual, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $NetWorthRecordsTable extends NetWorthRecords
    with TableInfo<$NetWorthRecordsTable, NetWorthRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NetWorthRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
      'amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, date, amount];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'net_worth_records';
  @override
  VerificationContext validateIntegrity(Insertable<NetWorthRecord> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  NetWorthRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NetWorthRecord(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}amount'])!,
    );
  }

  @override
  $NetWorthRecordsTable createAlias(String alias) {
    return $NetWorthRecordsTable(attachedDatabase, alias);
  }
}

class NetWorthRecord extends DataClass implements Insertable<NetWorthRecord> {
  final String id;
  final DateTime date;
  final double amount;
  const NetWorthRecord(
      {required this.id, required this.date, required this.amount});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['date'] = Variable<DateTime>(date);
    map['amount'] = Variable<double>(amount);
    return map;
  }

  NetWorthRecordsCompanion toCompanion(bool nullToAbsent) {
    return NetWorthRecordsCompanion(
      id: Value(id),
      date: Value(date),
      amount: Value(amount),
    );
  }

  factory NetWorthRecord.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NetWorthRecord(
      id: serializer.fromJson<String>(json['id']),
      date: serializer.fromJson<DateTime>(json['date']),
      amount: serializer.fromJson<double>(json['amount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'date': serializer.toJson<DateTime>(date),
      'amount': serializer.toJson<double>(amount),
    };
  }

  NetWorthRecord copyWith({String? id, DateTime? date, double? amount}) =>
      NetWorthRecord(
        id: id ?? this.id,
        date: date ?? this.date,
        amount: amount ?? this.amount,
      );
  NetWorthRecord copyWithCompanion(NetWorthRecordsCompanion data) {
    return NetWorthRecord(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      amount: data.amount.present ? data.amount.value : this.amount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NetWorthRecord(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('amount: $amount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, date, amount);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NetWorthRecord &&
          other.id == this.id &&
          other.date == this.date &&
          other.amount == this.amount);
}

class NetWorthRecordsCompanion extends UpdateCompanion<NetWorthRecord> {
  final Value<String> id;
  final Value<DateTime> date;
  final Value<double> amount;
  final Value<int> rowid;
  const NetWorthRecordsCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.amount = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NetWorthRecordsCompanion.insert({
    required String id,
    required DateTime date,
    required double amount,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        date = Value(date),
        amount = Value(amount);
  static Insertable<NetWorthRecord> custom({
    Expression<String>? id,
    Expression<DateTime>? date,
    Expression<double>? amount,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (amount != null) 'amount': amount,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NetWorthRecordsCompanion copyWith(
      {Value<String>? id,
      Value<DateTime>? date,
      Value<double>? amount,
      Value<int>? rowid}) {
    return NetWorthRecordsCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      amount: amount ?? this.amount,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NetWorthRecordsCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('amount: $amount, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $NetWorthSplitsTable extends NetWorthSplits
    with TableInfo<$NetWorthSplitsTable, NetWorthSplit> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NetWorthSplitsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _netIncomeMeta =
      const VerificationMeta('netIncome');
  @override
  late final GeneratedColumn<double> netIncome = GeneratedColumn<double>(
      'net_income', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _netExpenseMeta =
      const VerificationMeta('netExpense');
  @override
  late final GeneratedColumn<double> netExpense = GeneratedColumn<double>(
      'net_expense', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _capitalGainMeta =
      const VerificationMeta('capitalGain');
  @override
  late final GeneratedColumn<double> capitalGain = GeneratedColumn<double>(
      'capital_gain', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _capitalLossMeta =
      const VerificationMeta('capitalLoss');
  @override
  late final GeneratedColumn<double> capitalLoss = GeneratedColumn<double>(
      'capital_loss', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _nonCalcIncomeMeta =
      const VerificationMeta('nonCalcIncome');
  @override
  late final GeneratedColumn<double> nonCalcIncome = GeneratedColumn<double>(
      'non_calc_income', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _nonCalcExpenseMeta =
      const VerificationMeta('nonCalcExpense');
  @override
  late final GeneratedColumn<double> nonCalcExpense = GeneratedColumn<double>(
      'non_calc_expense', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        date,
        netIncome,
        netExpense,
        capitalGain,
        capitalLoss,
        nonCalcIncome,
        nonCalcExpense
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'net_worth_splits';
  @override
  VerificationContext validateIntegrity(Insertable<NetWorthSplit> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('net_income')) {
      context.handle(_netIncomeMeta,
          netIncome.isAcceptableOrUnknown(data['net_income']!, _netIncomeMeta));
    }
    if (data.containsKey('net_expense')) {
      context.handle(
          _netExpenseMeta,
          netExpense.isAcceptableOrUnknown(
              data['net_expense']!, _netExpenseMeta));
    }
    if (data.containsKey('capital_gain')) {
      context.handle(
          _capitalGainMeta,
          capitalGain.isAcceptableOrUnknown(
              data['capital_gain']!, _capitalGainMeta));
    }
    if (data.containsKey('capital_loss')) {
      context.handle(
          _capitalLossMeta,
          capitalLoss.isAcceptableOrUnknown(
              data['capital_loss']!, _capitalLossMeta));
    }
    if (data.containsKey('non_calc_income')) {
      context.handle(
          _nonCalcIncomeMeta,
          nonCalcIncome.isAcceptableOrUnknown(
              data['non_calc_income']!, _nonCalcIncomeMeta));
    }
    if (data.containsKey('non_calc_expense')) {
      context.handle(
          _nonCalcExpenseMeta,
          nonCalcExpense.isAcceptableOrUnknown(
              data['non_calc_expense']!, _nonCalcExpenseMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  NetWorthSplit map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NetWorthSplit(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      netIncome: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}net_income'])!,
      netExpense: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}net_expense'])!,
      capitalGain: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}capital_gain'])!,
      capitalLoss: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}capital_loss'])!,
      nonCalcIncome: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}non_calc_income'])!,
      nonCalcExpense: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}non_calc_expense'])!,
    );
  }

  @override
  $NetWorthSplitsTable createAlias(String alias) {
    return $NetWorthSplitsTable(attachedDatabase, alias);
  }
}

class NetWorthSplit extends DataClass implements Insertable<NetWorthSplit> {
  final String id;
  final DateTime date;
  final double netIncome;
  final double netExpense;
  final double capitalGain;
  final double capitalLoss;
  final double nonCalcIncome;
  final double nonCalcExpense;
  const NetWorthSplit(
      {required this.id,
      required this.date,
      required this.netIncome,
      required this.netExpense,
      required this.capitalGain,
      required this.capitalLoss,
      required this.nonCalcIncome,
      required this.nonCalcExpense});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['date'] = Variable<DateTime>(date);
    map['net_income'] = Variable<double>(netIncome);
    map['net_expense'] = Variable<double>(netExpense);
    map['capital_gain'] = Variable<double>(capitalGain);
    map['capital_loss'] = Variable<double>(capitalLoss);
    map['non_calc_income'] = Variable<double>(nonCalcIncome);
    map['non_calc_expense'] = Variable<double>(nonCalcExpense);
    return map;
  }

  NetWorthSplitsCompanion toCompanion(bool nullToAbsent) {
    return NetWorthSplitsCompanion(
      id: Value(id),
      date: Value(date),
      netIncome: Value(netIncome),
      netExpense: Value(netExpense),
      capitalGain: Value(capitalGain),
      capitalLoss: Value(capitalLoss),
      nonCalcIncome: Value(nonCalcIncome),
      nonCalcExpense: Value(nonCalcExpense),
    );
  }

  factory NetWorthSplit.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NetWorthSplit(
      id: serializer.fromJson<String>(json['id']),
      date: serializer.fromJson<DateTime>(json['date']),
      netIncome: serializer.fromJson<double>(json['netIncome']),
      netExpense: serializer.fromJson<double>(json['netExpense']),
      capitalGain: serializer.fromJson<double>(json['capitalGain']),
      capitalLoss: serializer.fromJson<double>(json['capitalLoss']),
      nonCalcIncome: serializer.fromJson<double>(json['nonCalcIncome']),
      nonCalcExpense: serializer.fromJson<double>(json['nonCalcExpense']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'date': serializer.toJson<DateTime>(date),
      'netIncome': serializer.toJson<double>(netIncome),
      'netExpense': serializer.toJson<double>(netExpense),
      'capitalGain': serializer.toJson<double>(capitalGain),
      'capitalLoss': serializer.toJson<double>(capitalLoss),
      'nonCalcIncome': serializer.toJson<double>(nonCalcIncome),
      'nonCalcExpense': serializer.toJson<double>(nonCalcExpense),
    };
  }

  NetWorthSplit copyWith(
          {String? id,
          DateTime? date,
          double? netIncome,
          double? netExpense,
          double? capitalGain,
          double? capitalLoss,
          double? nonCalcIncome,
          double? nonCalcExpense}) =>
      NetWorthSplit(
        id: id ?? this.id,
        date: date ?? this.date,
        netIncome: netIncome ?? this.netIncome,
        netExpense: netExpense ?? this.netExpense,
        capitalGain: capitalGain ?? this.capitalGain,
        capitalLoss: capitalLoss ?? this.capitalLoss,
        nonCalcIncome: nonCalcIncome ?? this.nonCalcIncome,
        nonCalcExpense: nonCalcExpense ?? this.nonCalcExpense,
      );
  NetWorthSplit copyWithCompanion(NetWorthSplitsCompanion data) {
    return NetWorthSplit(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      netIncome: data.netIncome.present ? data.netIncome.value : this.netIncome,
      netExpense:
          data.netExpense.present ? data.netExpense.value : this.netExpense,
      capitalGain:
          data.capitalGain.present ? data.capitalGain.value : this.capitalGain,
      capitalLoss:
          data.capitalLoss.present ? data.capitalLoss.value : this.capitalLoss,
      nonCalcIncome: data.nonCalcIncome.present
          ? data.nonCalcIncome.value
          : this.nonCalcIncome,
      nonCalcExpense: data.nonCalcExpense.present
          ? data.nonCalcExpense.value
          : this.nonCalcExpense,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NetWorthSplit(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('netIncome: $netIncome, ')
          ..write('netExpense: $netExpense, ')
          ..write('capitalGain: $capitalGain, ')
          ..write('capitalLoss: $capitalLoss, ')
          ..write('nonCalcIncome: $nonCalcIncome, ')
          ..write('nonCalcExpense: $nonCalcExpense')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, date, netIncome, netExpense, capitalGain,
      capitalLoss, nonCalcIncome, nonCalcExpense);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NetWorthSplit &&
          other.id == this.id &&
          other.date == this.date &&
          other.netIncome == this.netIncome &&
          other.netExpense == this.netExpense &&
          other.capitalGain == this.capitalGain &&
          other.capitalLoss == this.capitalLoss &&
          other.nonCalcIncome == this.nonCalcIncome &&
          other.nonCalcExpense == this.nonCalcExpense);
}

class NetWorthSplitsCompanion extends UpdateCompanion<NetWorthSplit> {
  final Value<String> id;
  final Value<DateTime> date;
  final Value<double> netIncome;
  final Value<double> netExpense;
  final Value<double> capitalGain;
  final Value<double> capitalLoss;
  final Value<double> nonCalcIncome;
  final Value<double> nonCalcExpense;
  final Value<int> rowid;
  const NetWorthSplitsCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.netIncome = const Value.absent(),
    this.netExpense = const Value.absent(),
    this.capitalGain = const Value.absent(),
    this.capitalLoss = const Value.absent(),
    this.nonCalcIncome = const Value.absent(),
    this.nonCalcExpense = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NetWorthSplitsCompanion.insert({
    required String id,
    required DateTime date,
    this.netIncome = const Value.absent(),
    this.netExpense = const Value.absent(),
    this.capitalGain = const Value.absent(),
    this.capitalLoss = const Value.absent(),
    this.nonCalcIncome = const Value.absent(),
    this.nonCalcExpense = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        date = Value(date);
  static Insertable<NetWorthSplit> custom({
    Expression<String>? id,
    Expression<DateTime>? date,
    Expression<double>? netIncome,
    Expression<double>? netExpense,
    Expression<double>? capitalGain,
    Expression<double>? capitalLoss,
    Expression<double>? nonCalcIncome,
    Expression<double>? nonCalcExpense,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (netIncome != null) 'net_income': netIncome,
      if (netExpense != null) 'net_expense': netExpense,
      if (capitalGain != null) 'capital_gain': capitalGain,
      if (capitalLoss != null) 'capital_loss': capitalLoss,
      if (nonCalcIncome != null) 'non_calc_income': nonCalcIncome,
      if (nonCalcExpense != null) 'non_calc_expense': nonCalcExpense,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NetWorthSplitsCompanion copyWith(
      {Value<String>? id,
      Value<DateTime>? date,
      Value<double>? netIncome,
      Value<double>? netExpense,
      Value<double>? capitalGain,
      Value<double>? capitalLoss,
      Value<double>? nonCalcIncome,
      Value<double>? nonCalcExpense,
      Value<int>? rowid}) {
    return NetWorthSplitsCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      netIncome: netIncome ?? this.netIncome,
      netExpense: netExpense ?? this.netExpense,
      capitalGain: capitalGain ?? this.capitalGain,
      capitalLoss: capitalLoss ?? this.capitalLoss,
      nonCalcIncome: nonCalcIncome ?? this.nonCalcIncome,
      nonCalcExpense: nonCalcExpense ?? this.nonCalcExpense,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (netIncome.present) {
      map['net_income'] = Variable<double>(netIncome.value);
    }
    if (netExpense.present) {
      map['net_expense'] = Variable<double>(netExpense.value);
    }
    if (capitalGain.present) {
      map['capital_gain'] = Variable<double>(capitalGain.value);
    }
    if (capitalLoss.present) {
      map['capital_loss'] = Variable<double>(capitalLoss.value);
    }
    if (nonCalcIncome.present) {
      map['non_calc_income'] = Variable<double>(nonCalcIncome.value);
    }
    if (nonCalcExpense.present) {
      map['non_calc_expense'] = Variable<double>(nonCalcExpense.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NetWorthSplitsCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('netIncome: $netIncome, ')
          ..write('netExpense: $netExpense, ')
          ..write('capitalGain: $capitalGain, ')
          ..write('capitalLoss: $capitalLoss, ')
          ..write('nonCalcIncome: $nonCalcIncome, ')
          ..write('nonCalcExpense: $nonCalcExpense, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CustomTemplatesTable extends CustomTemplates
    with TableInfo<$CustomTemplatesTable, CustomTemplate> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomTemplatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _fieldsMeta = const VerificationMeta('fields');
  @override
  late final GeneratedColumn<String> fields = GeneratedColumn<String>(
      'fields', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _xAxisFieldMeta =
      const VerificationMeta('xAxisField');
  @override
  late final GeneratedColumn<String> xAxisField = GeneratedColumn<String>(
      'x_axis_field', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _yAxisFieldMeta =
      const VerificationMeta('yAxisField');
  @override
  late final GeneratedColumn<String> yAxisField = GeneratedColumn<String>(
      'y_axis_field', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, createdAt, fields, xAxisField, yAxisField];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'custom_templates';
  @override
  VerificationContext validateIntegrity(Insertable<CustomTemplate> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('fields')) {
      context.handle(_fieldsMeta,
          fields.isAcceptableOrUnknown(data['fields']!, _fieldsMeta));
    } else if (isInserting) {
      context.missing(_fieldsMeta);
    }
    if (data.containsKey('x_axis_field')) {
      context.handle(
          _xAxisFieldMeta,
          xAxisField.isAcceptableOrUnknown(
              data['x_axis_field']!, _xAxisFieldMeta));
    }
    if (data.containsKey('y_axis_field')) {
      context.handle(
          _yAxisFieldMeta,
          yAxisField.isAcceptableOrUnknown(
              data['y_axis_field']!, _yAxisFieldMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CustomTemplate map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CustomTemplate(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      fields: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}fields'])!,
      xAxisField: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}x_axis_field']),
      yAxisField: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}y_axis_field']),
    );
  }

  @override
  $CustomTemplatesTable createAlias(String alias) {
    return $CustomTemplatesTable(attachedDatabase, alias);
  }
}

class CustomTemplate extends DataClass implements Insertable<CustomTemplate> {
  final String id;
  final String name;
  final DateTime createdAt;
  final String fields;
  final String? xAxisField;
  final String? yAxisField;
  const CustomTemplate(
      {required this.id,
      required this.name,
      required this.createdAt,
      required this.fields,
      this.xAxisField,
      this.yAxisField});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['fields'] = Variable<String>(fields);
    if (!nullToAbsent || xAxisField != null) {
      map['x_axis_field'] = Variable<String>(xAxisField);
    }
    if (!nullToAbsent || yAxisField != null) {
      map['y_axis_field'] = Variable<String>(yAxisField);
    }
    return map;
  }

  CustomTemplatesCompanion toCompanion(bool nullToAbsent) {
    return CustomTemplatesCompanion(
      id: Value(id),
      name: Value(name),
      createdAt: Value(createdAt),
      fields: Value(fields),
      xAxisField: xAxisField == null && nullToAbsent
          ? const Value.absent()
          : Value(xAxisField),
      yAxisField: yAxisField == null && nullToAbsent
          ? const Value.absent()
          : Value(yAxisField),
    );
  }

  factory CustomTemplate.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CustomTemplate(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      fields: serializer.fromJson<String>(json['fields']),
      xAxisField: serializer.fromJson<String?>(json['xAxisField']),
      yAxisField: serializer.fromJson<String?>(json['yAxisField']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'fields': serializer.toJson<String>(fields),
      'xAxisField': serializer.toJson<String?>(xAxisField),
      'yAxisField': serializer.toJson<String?>(yAxisField),
    };
  }

  CustomTemplate copyWith(
          {String? id,
          String? name,
          DateTime? createdAt,
          String? fields,
          Value<String?> xAxisField = const Value.absent(),
          Value<String?> yAxisField = const Value.absent()}) =>
      CustomTemplate(
        id: id ?? this.id,
        name: name ?? this.name,
        createdAt: createdAt ?? this.createdAt,
        fields: fields ?? this.fields,
        xAxisField: xAxisField.present ? xAxisField.value : this.xAxisField,
        yAxisField: yAxisField.present ? yAxisField.value : this.yAxisField,
      );
  CustomTemplate copyWithCompanion(CustomTemplatesCompanion data) {
    return CustomTemplate(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      fields: data.fields.present ? data.fields.value : this.fields,
      xAxisField:
          data.xAxisField.present ? data.xAxisField.value : this.xAxisField,
      yAxisField:
          data.yAxisField.present ? data.yAxisField.value : this.yAxisField,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CustomTemplate(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('fields: $fields, ')
          ..write('xAxisField: $xAxisField, ')
          ..write('yAxisField: $yAxisField')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, createdAt, fields, xAxisField, yAxisField);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CustomTemplate &&
          other.id == this.id &&
          other.name == this.name &&
          other.createdAt == this.createdAt &&
          other.fields == this.fields &&
          other.xAxisField == this.xAxisField &&
          other.yAxisField == this.yAxisField);
}

class CustomTemplatesCompanion extends UpdateCompanion<CustomTemplate> {
  final Value<String> id;
  final Value<String> name;
  final Value<DateTime> createdAt;
  final Value<String> fields;
  final Value<String?> xAxisField;
  final Value<String?> yAxisField;
  final Value<int> rowid;
  const CustomTemplatesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.fields = const Value.absent(),
    this.xAxisField = const Value.absent(),
    this.yAxisField = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CustomTemplatesCompanion.insert({
    required String id,
    required String name,
    required DateTime createdAt,
    required String fields,
    this.xAxisField = const Value.absent(),
    this.yAxisField = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        createdAt = Value(createdAt),
        fields = Value(fields);
  static Insertable<CustomTemplate> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<DateTime>? createdAt,
    Expression<String>? fields,
    Expression<String>? xAxisField,
    Expression<String>? yAxisField,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (createdAt != null) 'created_at': createdAt,
      if (fields != null) 'fields': fields,
      if (xAxisField != null) 'x_axis_field': xAxisField,
      if (yAxisField != null) 'y_axis_field': yAxisField,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CustomTemplatesCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<DateTime>? createdAt,
      Value<String>? fields,
      Value<String?>? xAxisField,
      Value<String?>? yAxisField,
      Value<int>? rowid}) {
    return CustomTemplatesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      fields: fields ?? this.fields,
      xAxisField: xAxisField ?? this.xAxisField,
      yAxisField: yAxisField ?? this.yAxisField,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (fields.present) {
      map['fields'] = Variable<String>(fields.value);
    }
    if (xAxisField.present) {
      map['x_axis_field'] = Variable<String>(xAxisField.value);
    }
    if (yAxisField.present) {
      map['y_axis_field'] = Variable<String>(yAxisField.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CustomTemplatesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('fields: $fields, ')
          ..write('xAxisField: $xAxisField, ')
          ..write('yAxisField: $yAxisField, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CustomRecordsTable extends CustomRecords
    with TableInfo<$CustomRecordsTable, CustomRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _templateIdMeta =
      const VerificationMeta('templateId');
  @override
  late final GeneratedColumn<String> templateId = GeneratedColumn<String>(
      'template_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES custom_templates (id)'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _dataMeta = const VerificationMeta('data');
  @override
  late final GeneratedColumn<String> data = GeneratedColumn<String>(
      'data', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, templateId, createdAt, data];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'custom_records';
  @override
  VerificationContext validateIntegrity(Insertable<CustomRecord> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('template_id')) {
      context.handle(
          _templateIdMeta,
          templateId.isAcceptableOrUnknown(
              data['template_id']!, _templateIdMeta));
    } else if (isInserting) {
      context.missing(_templateIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('data')) {
      context.handle(
          _dataMeta, this.data.isAcceptableOrUnknown(data['data']!, _dataMeta));
    } else if (isInserting) {
      context.missing(_dataMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CustomRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CustomRecord(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      templateId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}template_id'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      data: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}data'])!,
    );
  }

  @override
  $CustomRecordsTable createAlias(String alias) {
    return $CustomRecordsTable(attachedDatabase, alias);
  }
}

class CustomRecord extends DataClass implements Insertable<CustomRecord> {
  final String id;
  final String templateId;
  final DateTime createdAt;
  final String data;
  const CustomRecord(
      {required this.id,
      required this.templateId,
      required this.createdAt,
      required this.data});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['template_id'] = Variable<String>(templateId);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['data'] = Variable<String>(data);
    return map;
  }

  CustomRecordsCompanion toCompanion(bool nullToAbsent) {
    return CustomRecordsCompanion(
      id: Value(id),
      templateId: Value(templateId),
      createdAt: Value(createdAt),
      data: Value(data),
    );
  }

  factory CustomRecord.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CustomRecord(
      id: serializer.fromJson<String>(json['id']),
      templateId: serializer.fromJson<String>(json['templateId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      data: serializer.fromJson<String>(json['data']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'templateId': serializer.toJson<String>(templateId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'data': serializer.toJson<String>(data),
    };
  }

  CustomRecord copyWith(
          {String? id,
          String? templateId,
          DateTime? createdAt,
          String? data}) =>
      CustomRecord(
        id: id ?? this.id,
        templateId: templateId ?? this.templateId,
        createdAt: createdAt ?? this.createdAt,
        data: data ?? this.data,
      );
  CustomRecord copyWithCompanion(CustomRecordsCompanion data) {
    return CustomRecord(
      id: data.id.present ? data.id.value : this.id,
      templateId:
          data.templateId.present ? data.templateId.value : this.templateId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      data: data.data.present ? data.data.value : this.data,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CustomRecord(')
          ..write('id: $id, ')
          ..write('templateId: $templateId, ')
          ..write('createdAt: $createdAt, ')
          ..write('data: $data')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, templateId, createdAt, data);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CustomRecord &&
          other.id == this.id &&
          other.templateId == this.templateId &&
          other.createdAt == this.createdAt &&
          other.data == this.data);
}

class CustomRecordsCompanion extends UpdateCompanion<CustomRecord> {
  final Value<String> id;
  final Value<String> templateId;
  final Value<DateTime> createdAt;
  final Value<String> data;
  final Value<int> rowid;
  const CustomRecordsCompanion({
    this.id = const Value.absent(),
    this.templateId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.data = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CustomRecordsCompanion.insert({
    required String id,
    required String templateId,
    required DateTime createdAt,
    required String data,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        templateId = Value(templateId),
        createdAt = Value(createdAt),
        data = Value(data);
  static Insertable<CustomRecord> custom({
    Expression<String>? id,
    Expression<String>? templateId,
    Expression<DateTime>? createdAt,
    Expression<String>? data,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (templateId != null) 'template_id': templateId,
      if (createdAt != null) 'created_at': createdAt,
      if (data != null) 'data': data,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CustomRecordsCompanion copyWith(
      {Value<String>? id,
      Value<String>? templateId,
      Value<DateTime>? createdAt,
      Value<String>? data,
      Value<int>? rowid}) {
    return CustomRecordsCompanion(
      id: id ?? this.id,
      templateId: templateId ?? this.templateId,
      createdAt: createdAt ?? this.createdAt,
      data: data ?? this.data,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (templateId.present) {
      map['template_id'] = Variable<String>(templateId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (data.present) {
      map['data'] = Variable<String>(data.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CustomRecordsCompanion(')
          ..write('id: $id, ')
          ..write('templateId: $templateId, ')
          ..write('createdAt: $createdAt, ')
          ..write('data: $data, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TransactionCategoriesTable extends TransactionCategories
    with TableInfo<$TransactionCategoriesTable, TransactionCategory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionCategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _subCategoriesMeta =
      const VerificationMeta('subCategories');
  @override
  late final GeneratedColumn<String> subCategories = GeneratedColumn<String>(
      'sub_categories', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _iconCodeMeta =
      const VerificationMeta('iconCode');
  @override
  late final GeneratedColumn<int> iconCode = GeneratedColumn<int>(
      'icon_code', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, type, subCategories, iconCode];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transaction_categories';
  @override
  VerificationContext validateIntegrity(
      Insertable<TransactionCategory> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('sub_categories')) {
      context.handle(
          _subCategoriesMeta,
          subCategories.isAcceptableOrUnknown(
              data['sub_categories']!, _subCategoriesMeta));
    } else if (isInserting) {
      context.missing(_subCategoriesMeta);
    }
    if (data.containsKey('icon_code')) {
      context.handle(_iconCodeMeta,
          iconCode.isAcceptableOrUnknown(data['icon_code']!, _iconCodeMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TransactionCategory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TransactionCategory(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      subCategories: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sub_categories'])!,
      iconCode: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}icon_code']),
    );
  }

  @override
  $TransactionCategoriesTable createAlias(String alias) {
    return $TransactionCategoriesTable(attachedDatabase, alias);
  }
}

class TransactionCategory extends DataClass
    implements Insertable<TransactionCategory> {
  final String id;
  final String name;
  final String type;
  final String subCategories;
  final int? iconCode;
  const TransactionCategory(
      {required this.id,
      required this.name,
      required this.type,
      required this.subCategories,
      this.iconCode});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['type'] = Variable<String>(type);
    map['sub_categories'] = Variable<String>(subCategories);
    if (!nullToAbsent || iconCode != null) {
      map['icon_code'] = Variable<int>(iconCode);
    }
    return map;
  }

  TransactionCategoriesCompanion toCompanion(bool nullToAbsent) {
    return TransactionCategoriesCompanion(
      id: Value(id),
      name: Value(name),
      type: Value(type),
      subCategories: Value(subCategories),
      iconCode: iconCode == null && nullToAbsent
          ? const Value.absent()
          : Value(iconCode),
    );
  }

  factory TransactionCategory.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TransactionCategory(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<String>(json['type']),
      subCategories: serializer.fromJson<String>(json['subCategories']),
      iconCode: serializer.fromJson<int?>(json['iconCode']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(type),
      'subCategories': serializer.toJson<String>(subCategories),
      'iconCode': serializer.toJson<int?>(iconCode),
    };
  }

  TransactionCategory copyWith(
          {String? id,
          String? name,
          String? type,
          String? subCategories,
          Value<int?> iconCode = const Value.absent()}) =>
      TransactionCategory(
        id: id ?? this.id,
        name: name ?? this.name,
        type: type ?? this.type,
        subCategories: subCategories ?? this.subCategories,
        iconCode: iconCode.present ? iconCode.value : this.iconCode,
      );
  TransactionCategory copyWithCompanion(TransactionCategoriesCompanion data) {
    return TransactionCategory(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      subCategories: data.subCategories.present
          ? data.subCategories.value
          : this.subCategories,
      iconCode: data.iconCode.present ? data.iconCode.value : this.iconCode,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TransactionCategory(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('subCategories: $subCategories, ')
          ..write('iconCode: $iconCode')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, type, subCategories, iconCode);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TransactionCategory &&
          other.id == this.id &&
          other.name == this.name &&
          other.type == this.type &&
          other.subCategories == this.subCategories &&
          other.iconCode == this.iconCode);
}

class TransactionCategoriesCompanion
    extends UpdateCompanion<TransactionCategory> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> type;
  final Value<String> subCategories;
  final Value<int?> iconCode;
  final Value<int> rowid;
  const TransactionCategoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.subCategories = const Value.absent(),
    this.iconCode = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TransactionCategoriesCompanion.insert({
    required String id,
    required String name,
    required String type,
    required String subCategories,
    this.iconCode = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        type = Value(type),
        subCategories = Value(subCategories);
  static Insertable<TransactionCategory> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? type,
    Expression<String>? subCategories,
    Expression<int>? iconCode,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (subCategories != null) 'sub_categories': subCategories,
      if (iconCode != null) 'icon_code': iconCode,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TransactionCategoriesCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String>? type,
      Value<String>? subCategories,
      Value<int?>? iconCode,
      Value<int>? rowid}) {
    return TransactionCategoriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      subCategories: subCategories ?? this.subCategories,
      iconCode: iconCode ?? this.iconCode,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (subCategories.present) {
      map['sub_categories'] = Variable<String>(subCategories.value);
    }
    if (iconCode.present) {
      map['icon_code'] = Variable<int>(iconCode.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionCategoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('subCategories: $subCategories, ')
          ..write('iconCode: $iconCode, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SettingsTable extends Settings with TableInfo<$SettingsTable, Setting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
      'key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
      'value', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(Insertable<Setting> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
          _keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
          _valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  Setting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Setting(
      key: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      value: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}value'])!,
    );
  }

  @override
  $SettingsTable createAlias(String alias) {
    return $SettingsTable(attachedDatabase, alias);
  }
}

class Setting extends DataClass implements Insertable<Setting> {
  final String key;
  final String value;
  const Setting({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(
      key: Value(key),
      value: Value(value),
    );
  }

  factory Setting.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Setting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  Setting copyWith({String? key, String? value}) => Setting(
        key: key ?? this.key,
        value: value ?? this.value,
      );
  Setting copyWithCompanion(SettingsCompanion data) {
    return Setting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Setting(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Setting && other.key == this.key && other.value == this.value);
}

class SettingsCompanion extends UpdateCompanion<Setting> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const SettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  })  : key = Value(key),
        value = Value(value);
  static Insertable<Setting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingsCompanion copyWith(
      {Value<String>? key, Value<String>? value, Value<int>? rowid}) {
    return SettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $FinancialRecordsTable financialRecords =
      $FinancialRecordsTable(this);
  late final $SettlementsTable settlements = $SettlementsTable(this);
  late final $ExpenseAccountsTable expenseAccounts =
      $ExpenseAccountsTable(this);
  late final $ExpenseTransactionsTable expenseTransactions =
      $ExpenseTransactionsTable(this);
  late final $CreditCardsTable creditCards = $CreditCardsTable(this);
  late final $CreditTransactionsTable creditTransactions =
      $CreditTransactionsTable(this);
  late final $InvestmentRecordsTable investmentRecords =
      $InvestmentRecordsTable(this);
  late final $NetWorthRecordsTable netWorthRecords =
      $NetWorthRecordsTable(this);
  late final $NetWorthSplitsTable netWorthSplits = $NetWorthSplitsTable(this);
  late final $CustomTemplatesTable customTemplates =
      $CustomTemplatesTable(this);
  late final $CustomRecordsTable customRecords = $CustomRecordsTable(this);
  late final $TransactionCategoriesTable transactionCategories =
      $TransactionCategoriesTable(this);
  late final $SettingsTable settings = $SettingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        financialRecords,
        settlements,
        expenseAccounts,
        expenseTransactions,
        creditCards,
        creditTransactions,
        investmentRecords,
        netWorthRecords,
        netWorthSplits,
        customTemplates,
        customRecords,
        transactionCategories,
        settings
      ];
}

typedef $$FinancialRecordsTableCreateCompanionBuilder
    = FinancialRecordsCompanion Function({
  required String id,
  required int year,
  required int month,
  Value<double> salary,
  Value<double> extraIncome,
  Value<double> emi,
  Value<double> effectiveIncome,
  Value<double> budget,
  required String allocations,
  required String allocationPercentages,
  required String bucketOrder,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$FinancialRecordsTableUpdateCompanionBuilder
    = FinancialRecordsCompanion Function({
  Value<String> id,
  Value<int> year,
  Value<int> month,
  Value<double> salary,
  Value<double> extraIncome,
  Value<double> emi,
  Value<double> effectiveIncome,
  Value<double> budget,
  Value<String> allocations,
  Value<String> allocationPercentages,
  Value<String> bucketOrder,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$FinancialRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $FinancialRecordsTable> {
  $$FinancialRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get year => $composableBuilder(
      column: $table.year, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get month => $composableBuilder(
      column: $table.month, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get salary => $composableBuilder(
      column: $table.salary, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get extraIncome => $composableBuilder(
      column: $table.extraIncome, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get emi => $composableBuilder(
      column: $table.emi, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get effectiveIncome => $composableBuilder(
      column: $table.effectiveIncome,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get budget => $composableBuilder(
      column: $table.budget, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get allocations => $composableBuilder(
      column: $table.allocations, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get allocationPercentages => $composableBuilder(
      column: $table.allocationPercentages,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get bucketOrder => $composableBuilder(
      column: $table.bucketOrder, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$FinancialRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $FinancialRecordsTable> {
  $$FinancialRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get year => $composableBuilder(
      column: $table.year, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get month => $composableBuilder(
      column: $table.month, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get salary => $composableBuilder(
      column: $table.salary, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get extraIncome => $composableBuilder(
      column: $table.extraIncome, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get emi => $composableBuilder(
      column: $table.emi, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get effectiveIncome => $composableBuilder(
      column: $table.effectiveIncome,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get budget => $composableBuilder(
      column: $table.budget, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get allocations => $composableBuilder(
      column: $table.allocations, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get allocationPercentages => $composableBuilder(
      column: $table.allocationPercentages,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get bucketOrder => $composableBuilder(
      column: $table.bucketOrder, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$FinancialRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FinancialRecordsTable> {
  $$FinancialRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get year =>
      $composableBuilder(column: $table.year, builder: (column) => column);

  GeneratedColumn<int> get month =>
      $composableBuilder(column: $table.month, builder: (column) => column);

  GeneratedColumn<double> get salary =>
      $composableBuilder(column: $table.salary, builder: (column) => column);

  GeneratedColumn<double> get extraIncome => $composableBuilder(
      column: $table.extraIncome, builder: (column) => column);

  GeneratedColumn<double> get emi =>
      $composableBuilder(column: $table.emi, builder: (column) => column);

  GeneratedColumn<double> get effectiveIncome => $composableBuilder(
      column: $table.effectiveIncome, builder: (column) => column);

  GeneratedColumn<double> get budget =>
      $composableBuilder(column: $table.budget, builder: (column) => column);

  GeneratedColumn<String> get allocations => $composableBuilder(
      column: $table.allocations, builder: (column) => column);

  GeneratedColumn<String> get allocationPercentages => $composableBuilder(
      column: $table.allocationPercentages, builder: (column) => column);

  GeneratedColumn<String> get bucketOrder => $composableBuilder(
      column: $table.bucketOrder, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$FinancialRecordsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $FinancialRecordsTable,
    FinancialRecord,
    $$FinancialRecordsTableFilterComposer,
    $$FinancialRecordsTableOrderingComposer,
    $$FinancialRecordsTableAnnotationComposer,
    $$FinancialRecordsTableCreateCompanionBuilder,
    $$FinancialRecordsTableUpdateCompanionBuilder,
    (
      FinancialRecord,
      BaseReferences<_$AppDatabase, $FinancialRecordsTable, FinancialRecord>
    ),
    FinancialRecord,
    PrefetchHooks Function()> {
  $$FinancialRecordsTableTableManager(
      _$AppDatabase db, $FinancialRecordsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FinancialRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FinancialRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FinancialRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<int> year = const Value.absent(),
            Value<int> month = const Value.absent(),
            Value<double> salary = const Value.absent(),
            Value<double> extraIncome = const Value.absent(),
            Value<double> emi = const Value.absent(),
            Value<double> effectiveIncome = const Value.absent(),
            Value<double> budget = const Value.absent(),
            Value<String> allocations = const Value.absent(),
            Value<String> allocationPercentages = const Value.absent(),
            Value<String> bucketOrder = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              FinancialRecordsCompanion(
            id: id,
            year: year,
            month: month,
            salary: salary,
            extraIncome: extraIncome,
            emi: emi,
            effectiveIncome: effectiveIncome,
            budget: budget,
            allocations: allocations,
            allocationPercentages: allocationPercentages,
            bucketOrder: bucketOrder,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required int year,
            required int month,
            Value<double> salary = const Value.absent(),
            Value<double> extraIncome = const Value.absent(),
            Value<double> emi = const Value.absent(),
            Value<double> effectiveIncome = const Value.absent(),
            Value<double> budget = const Value.absent(),
            required String allocations,
            required String allocationPercentages,
            required String bucketOrder,
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              FinancialRecordsCompanion.insert(
            id: id,
            year: year,
            month: month,
            salary: salary,
            extraIncome: extraIncome,
            emi: emi,
            effectiveIncome: effectiveIncome,
            budget: budget,
            allocations: allocations,
            allocationPercentages: allocationPercentages,
            bucketOrder: bucketOrder,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$FinancialRecordsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $FinancialRecordsTable,
    FinancialRecord,
    $$FinancialRecordsTableFilterComposer,
    $$FinancialRecordsTableOrderingComposer,
    $$FinancialRecordsTableAnnotationComposer,
    $$FinancialRecordsTableCreateCompanionBuilder,
    $$FinancialRecordsTableUpdateCompanionBuilder,
    (
      FinancialRecord,
      BaseReferences<_$AppDatabase, $FinancialRecordsTable, FinancialRecord>
    ),
    FinancialRecord,
    PrefetchHooks Function()>;
typedef $$SettlementsTableCreateCompanionBuilder = SettlementsCompanion
    Function({
  required String id,
  required int year,
  required int month,
  required String allocations,
  required String expenses,
  required String bucketOrder,
  Value<double> totalIncome,
  Value<double> totalExpense,
  required DateTime settledAt,
  Value<int> rowid,
});
typedef $$SettlementsTableUpdateCompanionBuilder = SettlementsCompanion
    Function({
  Value<String> id,
  Value<int> year,
  Value<int> month,
  Value<String> allocations,
  Value<String> expenses,
  Value<String> bucketOrder,
  Value<double> totalIncome,
  Value<double> totalExpense,
  Value<DateTime> settledAt,
  Value<int> rowid,
});

class $$SettlementsTableFilterComposer
    extends Composer<_$AppDatabase, $SettlementsTable> {
  $$SettlementsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get year => $composableBuilder(
      column: $table.year, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get month => $composableBuilder(
      column: $table.month, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get allocations => $composableBuilder(
      column: $table.allocations, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get expenses => $composableBuilder(
      column: $table.expenses, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get bucketOrder => $composableBuilder(
      column: $table.bucketOrder, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get totalIncome => $composableBuilder(
      column: $table.totalIncome, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get totalExpense => $composableBuilder(
      column: $table.totalExpense, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get settledAt => $composableBuilder(
      column: $table.settledAt, builder: (column) => ColumnFilters(column));
}

class $$SettlementsTableOrderingComposer
    extends Composer<_$AppDatabase, $SettlementsTable> {
  $$SettlementsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get year => $composableBuilder(
      column: $table.year, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get month => $composableBuilder(
      column: $table.month, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get allocations => $composableBuilder(
      column: $table.allocations, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get expenses => $composableBuilder(
      column: $table.expenses, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get bucketOrder => $composableBuilder(
      column: $table.bucketOrder, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get totalIncome => $composableBuilder(
      column: $table.totalIncome, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get totalExpense => $composableBuilder(
      column: $table.totalExpense,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get settledAt => $composableBuilder(
      column: $table.settledAt, builder: (column) => ColumnOrderings(column));
}

class $$SettlementsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettlementsTable> {
  $$SettlementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get year =>
      $composableBuilder(column: $table.year, builder: (column) => column);

  GeneratedColumn<int> get month =>
      $composableBuilder(column: $table.month, builder: (column) => column);

  GeneratedColumn<String> get allocations => $composableBuilder(
      column: $table.allocations, builder: (column) => column);

  GeneratedColumn<String> get expenses =>
      $composableBuilder(column: $table.expenses, builder: (column) => column);

  GeneratedColumn<String> get bucketOrder => $composableBuilder(
      column: $table.bucketOrder, builder: (column) => column);

  GeneratedColumn<double> get totalIncome => $composableBuilder(
      column: $table.totalIncome, builder: (column) => column);

  GeneratedColumn<double> get totalExpense => $composableBuilder(
      column: $table.totalExpense, builder: (column) => column);

  GeneratedColumn<DateTime> get settledAt =>
      $composableBuilder(column: $table.settledAt, builder: (column) => column);
}

class $$SettlementsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SettlementsTable,
    Settlement,
    $$SettlementsTableFilterComposer,
    $$SettlementsTableOrderingComposer,
    $$SettlementsTableAnnotationComposer,
    $$SettlementsTableCreateCompanionBuilder,
    $$SettlementsTableUpdateCompanionBuilder,
    (Settlement, BaseReferences<_$AppDatabase, $SettlementsTable, Settlement>),
    Settlement,
    PrefetchHooks Function()> {
  $$SettlementsTableTableManager(_$AppDatabase db, $SettlementsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettlementsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettlementsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettlementsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<int> year = const Value.absent(),
            Value<int> month = const Value.absent(),
            Value<String> allocations = const Value.absent(),
            Value<String> expenses = const Value.absent(),
            Value<String> bucketOrder = const Value.absent(),
            Value<double> totalIncome = const Value.absent(),
            Value<double> totalExpense = const Value.absent(),
            Value<DateTime> settledAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SettlementsCompanion(
            id: id,
            year: year,
            month: month,
            allocations: allocations,
            expenses: expenses,
            bucketOrder: bucketOrder,
            totalIncome: totalIncome,
            totalExpense: totalExpense,
            settledAt: settledAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required int year,
            required int month,
            required String allocations,
            required String expenses,
            required String bucketOrder,
            Value<double> totalIncome = const Value.absent(),
            Value<double> totalExpense = const Value.absent(),
            required DateTime settledAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              SettlementsCompanion.insert(
            id: id,
            year: year,
            month: month,
            allocations: allocations,
            expenses: expenses,
            bucketOrder: bucketOrder,
            totalIncome: totalIncome,
            totalExpense: totalExpense,
            settledAt: settledAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SettlementsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SettlementsTable,
    Settlement,
    $$SettlementsTableFilterComposer,
    $$SettlementsTableOrderingComposer,
    $$SettlementsTableAnnotationComposer,
    $$SettlementsTableCreateCompanionBuilder,
    $$SettlementsTableUpdateCompanionBuilder,
    (Settlement, BaseReferences<_$AppDatabase, $SettlementsTable, Settlement>),
    Settlement,
    PrefetchHooks Function()>;
typedef $$ExpenseAccountsTableCreateCompanionBuilder = ExpenseAccountsCompanion
    Function({
  required String id,
  required String name,
  required String bankName,
  Value<String> type,
  Value<double> currentBalance,
  required DateTime createdAt,
  Value<String> accountType,
  Value<String> accountNumber,
  Value<int> color,
  Value<bool> showOnDashboard,
  Value<int> dashboardOrder,
  Value<int> rowid,
});
typedef $$ExpenseAccountsTableUpdateCompanionBuilder = ExpenseAccountsCompanion
    Function({
  Value<String> id,
  Value<String> name,
  Value<String> bankName,
  Value<String> type,
  Value<double> currentBalance,
  Value<DateTime> createdAt,
  Value<String> accountType,
  Value<String> accountNumber,
  Value<int> color,
  Value<bool> showOnDashboard,
  Value<int> dashboardOrder,
  Value<int> rowid,
});

final class $$ExpenseAccountsTableReferences extends BaseReferences<
    _$AppDatabase, $ExpenseAccountsTable, ExpenseAccount> {
  $$ExpenseAccountsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ExpenseTransactionsTable,
      List<ExpenseTransaction>> _expenseTransactionsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.expenseTransactions,
          aliasName: $_aliasNameGenerator(
              db.expenseAccounts.id, db.expenseTransactions.accountId));

  $$ExpenseTransactionsTableProcessedTableManager get expenseTransactionsRefs {
    final manager = $$ExpenseTransactionsTableTableManager(
            $_db, $_db.expenseTransactions)
        .filter((f) => f.accountId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_expenseTransactionsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$ExpenseAccountsTableFilterComposer
    extends Composer<_$AppDatabase, $ExpenseAccountsTable> {
  $$ExpenseAccountsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get bankName => $composableBuilder(
      column: $table.bankName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get currentBalance => $composableBuilder(
      column: $table.currentBalance,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get accountType => $composableBuilder(
      column: $table.accountType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get accountNumber => $composableBuilder(
      column: $table.accountNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get color => $composableBuilder(
      column: $table.color, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get showOnDashboard => $composableBuilder(
      column: $table.showOnDashboard,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get dashboardOrder => $composableBuilder(
      column: $table.dashboardOrder,
      builder: (column) => ColumnFilters(column));

  Expression<bool> expenseTransactionsRefs(
      Expression<bool> Function($$ExpenseTransactionsTableFilterComposer f) f) {
    final $$ExpenseTransactionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.expenseTransactions,
        getReferencedColumn: (t) => t.accountId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ExpenseTransactionsTableFilterComposer(
              $db: $db,
              $table: $db.expenseTransactions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ExpenseAccountsTableOrderingComposer
    extends Composer<_$AppDatabase, $ExpenseAccountsTable> {
  $$ExpenseAccountsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get bankName => $composableBuilder(
      column: $table.bankName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get currentBalance => $composableBuilder(
      column: $table.currentBalance,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get accountType => $composableBuilder(
      column: $table.accountType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get accountNumber => $composableBuilder(
      column: $table.accountNumber,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get color => $composableBuilder(
      column: $table.color, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get showOnDashboard => $composableBuilder(
      column: $table.showOnDashboard,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get dashboardOrder => $composableBuilder(
      column: $table.dashboardOrder,
      builder: (column) => ColumnOrderings(column));
}

class $$ExpenseAccountsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExpenseAccountsTable> {
  $$ExpenseAccountsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get bankName =>
      $composableBuilder(column: $table.bankName, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<double> get currentBalance => $composableBuilder(
      column: $table.currentBalance, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get accountType => $composableBuilder(
      column: $table.accountType, builder: (column) => column);

  GeneratedColumn<String> get accountNumber => $composableBuilder(
      column: $table.accountNumber, builder: (column) => column);

  GeneratedColumn<int> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<bool> get showOnDashboard => $composableBuilder(
      column: $table.showOnDashboard, builder: (column) => column);

  GeneratedColumn<int> get dashboardOrder => $composableBuilder(
      column: $table.dashboardOrder, builder: (column) => column);

  Expression<T> expenseTransactionsRefs<T extends Object>(
      Expression<T> Function($$ExpenseTransactionsTableAnnotationComposer a)
          f) {
    final $$ExpenseTransactionsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.expenseTransactions,
            getReferencedColumn: (t) => t.accountId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$ExpenseTransactionsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.expenseTransactions,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$ExpenseAccountsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ExpenseAccountsTable,
    ExpenseAccount,
    $$ExpenseAccountsTableFilterComposer,
    $$ExpenseAccountsTableOrderingComposer,
    $$ExpenseAccountsTableAnnotationComposer,
    $$ExpenseAccountsTableCreateCompanionBuilder,
    $$ExpenseAccountsTableUpdateCompanionBuilder,
    (ExpenseAccount, $$ExpenseAccountsTableReferences),
    ExpenseAccount,
    PrefetchHooks Function({bool expenseTransactionsRefs})> {
  $$ExpenseAccountsTableTableManager(
      _$AppDatabase db, $ExpenseAccountsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExpenseAccountsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExpenseAccountsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExpenseAccountsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> bankName = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<double> currentBalance = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<String> accountType = const Value.absent(),
            Value<String> accountNumber = const Value.absent(),
            Value<int> color = const Value.absent(),
            Value<bool> showOnDashboard = const Value.absent(),
            Value<int> dashboardOrder = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ExpenseAccountsCompanion(
            id: id,
            name: name,
            bankName: bankName,
            type: type,
            currentBalance: currentBalance,
            createdAt: createdAt,
            accountType: accountType,
            accountNumber: accountNumber,
            color: color,
            showOnDashboard: showOnDashboard,
            dashboardOrder: dashboardOrder,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            required String bankName,
            Value<String> type = const Value.absent(),
            Value<double> currentBalance = const Value.absent(),
            required DateTime createdAt,
            Value<String> accountType = const Value.absent(),
            Value<String> accountNumber = const Value.absent(),
            Value<int> color = const Value.absent(),
            Value<bool> showOnDashboard = const Value.absent(),
            Value<int> dashboardOrder = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ExpenseAccountsCompanion.insert(
            id: id,
            name: name,
            bankName: bankName,
            type: type,
            currentBalance: currentBalance,
            createdAt: createdAt,
            accountType: accountType,
            accountNumber: accountNumber,
            color: color,
            showOnDashboard: showOnDashboard,
            dashboardOrder: dashboardOrder,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$ExpenseAccountsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({expenseTransactionsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (expenseTransactionsRefs) db.expenseTransactions
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (expenseTransactionsRefs)
                    await $_getPrefetchedData<ExpenseAccount,
                            $ExpenseAccountsTable, ExpenseTransaction>(
                        currentTable: table,
                        referencedTable: $$ExpenseAccountsTableReferences
                            ._expenseTransactionsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ExpenseAccountsTableReferences(db, table, p0)
                                .expenseTransactionsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.accountId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$ExpenseAccountsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ExpenseAccountsTable,
    ExpenseAccount,
    $$ExpenseAccountsTableFilterComposer,
    $$ExpenseAccountsTableOrderingComposer,
    $$ExpenseAccountsTableAnnotationComposer,
    $$ExpenseAccountsTableCreateCompanionBuilder,
    $$ExpenseAccountsTableUpdateCompanionBuilder,
    (ExpenseAccount, $$ExpenseAccountsTableReferences),
    ExpenseAccount,
    PrefetchHooks Function({bool expenseTransactionsRefs})>;
typedef $$ExpenseTransactionsTableCreateCompanionBuilder
    = ExpenseTransactionsCompanion Function({
  required String id,
  Value<String?> accountId,
  required double amount,
  required DateTime date,
  Value<String> bucket,
  Value<String> type,
  Value<String> category,
  Value<String> subCategory,
  Value<String> notes,
  Value<String?> transferAccountId,
  Value<String?> transferAccountName,
  Value<String?> transferAccountBankName,
  Value<String?> linkedCreditCardId,
  Value<int> rowid,
});
typedef $$ExpenseTransactionsTableUpdateCompanionBuilder
    = ExpenseTransactionsCompanion Function({
  Value<String> id,
  Value<String?> accountId,
  Value<double> amount,
  Value<DateTime> date,
  Value<String> bucket,
  Value<String> type,
  Value<String> category,
  Value<String> subCategory,
  Value<String> notes,
  Value<String?> transferAccountId,
  Value<String?> transferAccountName,
  Value<String?> transferAccountBankName,
  Value<String?> linkedCreditCardId,
  Value<int> rowid,
});

final class $$ExpenseTransactionsTableReferences extends BaseReferences<
    _$AppDatabase, $ExpenseTransactionsTable, ExpenseTransaction> {
  $$ExpenseTransactionsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $ExpenseAccountsTable _accountIdTable(_$AppDatabase db) =>
      db.expenseAccounts.createAlias($_aliasNameGenerator(
          db.expenseTransactions.accountId, db.expenseAccounts.id));

  $$ExpenseAccountsTableProcessedTableManager? get accountId {
    final $_column = $_itemColumn<String>('account_id');
    if ($_column == null) return null;
    final manager =
        $$ExpenseAccountsTableTableManager($_db, $_db.expenseAccounts)
            .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_accountIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$ExpenseTransactionsTableFilterComposer
    extends Composer<_$AppDatabase, $ExpenseTransactionsTable> {
  $$ExpenseTransactionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get bucket => $composableBuilder(
      column: $table.bucket, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get subCategory => $composableBuilder(
      column: $table.subCategory, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get transferAccountId => $composableBuilder(
      column: $table.transferAccountId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get transferAccountName => $composableBuilder(
      column: $table.transferAccountName,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get transferAccountBankName => $composableBuilder(
      column: $table.transferAccountBankName,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get linkedCreditCardId => $composableBuilder(
      column: $table.linkedCreditCardId,
      builder: (column) => ColumnFilters(column));

  $$ExpenseAccountsTableFilterComposer get accountId {
    final $$ExpenseAccountsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.accountId,
        referencedTable: $db.expenseAccounts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ExpenseAccountsTableFilterComposer(
              $db: $db,
              $table: $db.expenseAccounts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ExpenseTransactionsTableOrderingComposer
    extends Composer<_$AppDatabase, $ExpenseTransactionsTable> {
  $$ExpenseTransactionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get bucket => $composableBuilder(
      column: $table.bucket, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get subCategory => $composableBuilder(
      column: $table.subCategory, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get transferAccountId => $composableBuilder(
      column: $table.transferAccountId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get transferAccountName => $composableBuilder(
      column: $table.transferAccountName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get transferAccountBankName => $composableBuilder(
      column: $table.transferAccountBankName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get linkedCreditCardId => $composableBuilder(
      column: $table.linkedCreditCardId,
      builder: (column) => ColumnOrderings(column));

  $$ExpenseAccountsTableOrderingComposer get accountId {
    final $$ExpenseAccountsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.accountId,
        referencedTable: $db.expenseAccounts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ExpenseAccountsTableOrderingComposer(
              $db: $db,
              $table: $db.expenseAccounts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ExpenseTransactionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExpenseTransactionsTable> {
  $$ExpenseTransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get bucket =>
      $composableBuilder(column: $table.bucket, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get subCategory => $composableBuilder(
      column: $table.subCategory, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get transferAccountId => $composableBuilder(
      column: $table.transferAccountId, builder: (column) => column);

  GeneratedColumn<String> get transferAccountName => $composableBuilder(
      column: $table.transferAccountName, builder: (column) => column);

  GeneratedColumn<String> get transferAccountBankName => $composableBuilder(
      column: $table.transferAccountBankName, builder: (column) => column);

  GeneratedColumn<String> get linkedCreditCardId => $composableBuilder(
      column: $table.linkedCreditCardId, builder: (column) => column);

  $$ExpenseAccountsTableAnnotationComposer get accountId {
    final $$ExpenseAccountsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.accountId,
        referencedTable: $db.expenseAccounts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ExpenseAccountsTableAnnotationComposer(
              $db: $db,
              $table: $db.expenseAccounts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ExpenseTransactionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ExpenseTransactionsTable,
    ExpenseTransaction,
    $$ExpenseTransactionsTableFilterComposer,
    $$ExpenseTransactionsTableOrderingComposer,
    $$ExpenseTransactionsTableAnnotationComposer,
    $$ExpenseTransactionsTableCreateCompanionBuilder,
    $$ExpenseTransactionsTableUpdateCompanionBuilder,
    (ExpenseTransaction, $$ExpenseTransactionsTableReferences),
    ExpenseTransaction,
    PrefetchHooks Function({bool accountId})> {
  $$ExpenseTransactionsTableTableManager(
      _$AppDatabase db, $ExpenseTransactionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExpenseTransactionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExpenseTransactionsTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExpenseTransactionsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> accountId = const Value.absent(),
            Value<double> amount = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
            Value<String> bucket = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<String> subCategory = const Value.absent(),
            Value<String> notes = const Value.absent(),
            Value<String?> transferAccountId = const Value.absent(),
            Value<String?> transferAccountName = const Value.absent(),
            Value<String?> transferAccountBankName = const Value.absent(),
            Value<String?> linkedCreditCardId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ExpenseTransactionsCompanion(
            id: id,
            accountId: accountId,
            amount: amount,
            date: date,
            bucket: bucket,
            type: type,
            category: category,
            subCategory: subCategory,
            notes: notes,
            transferAccountId: transferAccountId,
            transferAccountName: transferAccountName,
            transferAccountBankName: transferAccountBankName,
            linkedCreditCardId: linkedCreditCardId,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String?> accountId = const Value.absent(),
            required double amount,
            required DateTime date,
            Value<String> bucket = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<String> subCategory = const Value.absent(),
            Value<String> notes = const Value.absent(),
            Value<String?> transferAccountId = const Value.absent(),
            Value<String?> transferAccountName = const Value.absent(),
            Value<String?> transferAccountBankName = const Value.absent(),
            Value<String?> linkedCreditCardId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ExpenseTransactionsCompanion.insert(
            id: id,
            accountId: accountId,
            amount: amount,
            date: date,
            bucket: bucket,
            type: type,
            category: category,
            subCategory: subCategory,
            notes: notes,
            transferAccountId: transferAccountId,
            transferAccountName: transferAccountName,
            transferAccountBankName: transferAccountBankName,
            linkedCreditCardId: linkedCreditCardId,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$ExpenseTransactionsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({accountId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (accountId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.accountId,
                    referencedTable: $$ExpenseTransactionsTableReferences
                        ._accountIdTable(db),
                    referencedColumn: $$ExpenseTransactionsTableReferences
                        ._accountIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$ExpenseTransactionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ExpenseTransactionsTable,
    ExpenseTransaction,
    $$ExpenseTransactionsTableFilterComposer,
    $$ExpenseTransactionsTableOrderingComposer,
    $$ExpenseTransactionsTableAnnotationComposer,
    $$ExpenseTransactionsTableCreateCompanionBuilder,
    $$ExpenseTransactionsTableUpdateCompanionBuilder,
    (ExpenseTransaction, $$ExpenseTransactionsTableReferences),
    ExpenseTransaction,
    PrefetchHooks Function({bool accountId})>;
typedef $$CreditCardsTableCreateCompanionBuilder = CreditCardsCompanion
    Function({
  required String id,
  required String name,
  required String bankName,
  Value<String> lastFourDigits,
  required double creditLimit,
  Value<double> currentBalance,
  required int billDate,
  required int dueDate,
  Value<int> color,
  Value<bool> isArchived,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$CreditCardsTableUpdateCompanionBuilder = CreditCardsCompanion
    Function({
  Value<String> id,
  Value<String> name,
  Value<String> bankName,
  Value<String> lastFourDigits,
  Value<double> creditLimit,
  Value<double> currentBalance,
  Value<int> billDate,
  Value<int> dueDate,
  Value<int> color,
  Value<bool> isArchived,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

final class $$CreditCardsTableReferences
    extends BaseReferences<_$AppDatabase, $CreditCardsTable, CreditCard> {
  $$CreditCardsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$CreditTransactionsTable, List<CreditTransaction>>
      _creditTransactionsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.creditTransactions,
              aliasName: $_aliasNameGenerator(
                  db.creditCards.id, db.creditTransactions.cardId));

  $$CreditTransactionsTableProcessedTableManager get creditTransactionsRefs {
    final manager =
        $$CreditTransactionsTableTableManager($_db, $_db.creditTransactions)
            .filter((f) => f.cardId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_creditTransactionsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$CreditCardsTableFilterComposer
    extends Composer<_$AppDatabase, $CreditCardsTable> {
  $$CreditCardsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get bankName => $composableBuilder(
      column: $table.bankName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get lastFourDigits => $composableBuilder(
      column: $table.lastFourDigits,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get creditLimit => $composableBuilder(
      column: $table.creditLimit, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get currentBalance => $composableBuilder(
      column: $table.currentBalance,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get billDate => $composableBuilder(
      column: $table.billDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get dueDate => $composableBuilder(
      column: $table.dueDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get color => $composableBuilder(
      column: $table.color, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isArchived => $composableBuilder(
      column: $table.isArchived, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  Expression<bool> creditTransactionsRefs(
      Expression<bool> Function($$CreditTransactionsTableFilterComposer f) f) {
    final $$CreditTransactionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.creditTransactions,
        getReferencedColumn: (t) => t.cardId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CreditTransactionsTableFilterComposer(
              $db: $db,
              $table: $db.creditTransactions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$CreditCardsTableOrderingComposer
    extends Composer<_$AppDatabase, $CreditCardsTable> {
  $$CreditCardsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get bankName => $composableBuilder(
      column: $table.bankName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get lastFourDigits => $composableBuilder(
      column: $table.lastFourDigits,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get creditLimit => $composableBuilder(
      column: $table.creditLimit, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get currentBalance => $composableBuilder(
      column: $table.currentBalance,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get billDate => $composableBuilder(
      column: $table.billDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get dueDate => $composableBuilder(
      column: $table.dueDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get color => $composableBuilder(
      column: $table.color, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isArchived => $composableBuilder(
      column: $table.isArchived, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$CreditCardsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CreditCardsTable> {
  $$CreditCardsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get bankName =>
      $composableBuilder(column: $table.bankName, builder: (column) => column);

  GeneratedColumn<String> get lastFourDigits => $composableBuilder(
      column: $table.lastFourDigits, builder: (column) => column);

  GeneratedColumn<double> get creditLimit => $composableBuilder(
      column: $table.creditLimit, builder: (column) => column);

  GeneratedColumn<double> get currentBalance => $composableBuilder(
      column: $table.currentBalance, builder: (column) => column);

  GeneratedColumn<int> get billDate =>
      $composableBuilder(column: $table.billDate, builder: (column) => column);

  GeneratedColumn<int> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<int> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<bool> get isArchived => $composableBuilder(
      column: $table.isArchived, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> creditTransactionsRefs<T extends Object>(
      Expression<T> Function($$CreditTransactionsTableAnnotationComposer a) f) {
    final $$CreditTransactionsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.creditTransactions,
            getReferencedColumn: (t) => t.cardId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$CreditTransactionsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.creditTransactions,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$CreditCardsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CreditCardsTable,
    CreditCard,
    $$CreditCardsTableFilterComposer,
    $$CreditCardsTableOrderingComposer,
    $$CreditCardsTableAnnotationComposer,
    $$CreditCardsTableCreateCompanionBuilder,
    $$CreditCardsTableUpdateCompanionBuilder,
    (CreditCard, $$CreditCardsTableReferences),
    CreditCard,
    PrefetchHooks Function({bool creditTransactionsRefs})> {
  $$CreditCardsTableTableManager(_$AppDatabase db, $CreditCardsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CreditCardsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CreditCardsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CreditCardsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> bankName = const Value.absent(),
            Value<String> lastFourDigits = const Value.absent(),
            Value<double> creditLimit = const Value.absent(),
            Value<double> currentBalance = const Value.absent(),
            Value<int> billDate = const Value.absent(),
            Value<int> dueDate = const Value.absent(),
            Value<int> color = const Value.absent(),
            Value<bool> isArchived = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CreditCardsCompanion(
            id: id,
            name: name,
            bankName: bankName,
            lastFourDigits: lastFourDigits,
            creditLimit: creditLimit,
            currentBalance: currentBalance,
            billDate: billDate,
            dueDate: dueDate,
            color: color,
            isArchived: isArchived,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            required String bankName,
            Value<String> lastFourDigits = const Value.absent(),
            required double creditLimit,
            Value<double> currentBalance = const Value.absent(),
            required int billDate,
            required int dueDate,
            Value<int> color = const Value.absent(),
            Value<bool> isArchived = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              CreditCardsCompanion.insert(
            id: id,
            name: name,
            bankName: bankName,
            lastFourDigits: lastFourDigits,
            creditLimit: creditLimit,
            currentBalance: currentBalance,
            billDate: billDate,
            dueDate: dueDate,
            color: color,
            isArchived: isArchived,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$CreditCardsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({creditTransactionsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (creditTransactionsRefs) db.creditTransactions
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (creditTransactionsRefs)
                    await $_getPrefetchedData<CreditCard, $CreditCardsTable,
                            CreditTransaction>(
                        currentTable: table,
                        referencedTable: $$CreditCardsTableReferences
                            ._creditTransactionsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$CreditCardsTableReferences(db, table, p0)
                                .creditTransactionsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.cardId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$CreditCardsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CreditCardsTable,
    CreditCard,
    $$CreditCardsTableFilterComposer,
    $$CreditCardsTableOrderingComposer,
    $$CreditCardsTableAnnotationComposer,
    $$CreditCardsTableCreateCompanionBuilder,
    $$CreditCardsTableUpdateCompanionBuilder,
    (CreditCard, $$CreditCardsTableReferences),
    CreditCard,
    PrefetchHooks Function({bool creditTransactionsRefs})>;
typedef $$CreditTransactionsTableCreateCompanionBuilder
    = CreditTransactionsCompanion Function({
  required String id,
  required String cardId,
  required double amount,
  required DateTime date,
  required String description,
  Value<String> bucket,
  required String type,
  required String category,
  required String subCategory,
  required String notes,
  Value<String?> linkedExpenseId,
  Value<bool> includeInNextStatement,
  Value<bool> isSettlementVerified,
  Value<bool> isEmi,
  Value<int> emiMonths,
  Value<int> emiRemaining,
  Value<int> rowid,
});
typedef $$CreditTransactionsTableUpdateCompanionBuilder
    = CreditTransactionsCompanion Function({
  Value<String> id,
  Value<String> cardId,
  Value<double> amount,
  Value<DateTime> date,
  Value<String> description,
  Value<String> bucket,
  Value<String> type,
  Value<String> category,
  Value<String> subCategory,
  Value<String> notes,
  Value<String?> linkedExpenseId,
  Value<bool> includeInNextStatement,
  Value<bool> isSettlementVerified,
  Value<bool> isEmi,
  Value<int> emiMonths,
  Value<int> emiRemaining,
  Value<int> rowid,
});

final class $$CreditTransactionsTableReferences extends BaseReferences<
    _$AppDatabase, $CreditTransactionsTable, CreditTransaction> {
  $$CreditTransactionsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $CreditCardsTable _cardIdTable(_$AppDatabase db) =>
      db.creditCards.createAlias($_aliasNameGenerator(
          db.creditTransactions.cardId, db.creditCards.id));

  $$CreditCardsTableProcessedTableManager get cardId {
    final $_column = $_itemColumn<String>('card_id')!;

    final manager = $$CreditCardsTableTableManager($_db, $_db.creditCards)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_cardIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$CreditTransactionsTableFilterComposer
    extends Composer<_$AppDatabase, $CreditTransactionsTable> {
  $$CreditTransactionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get bucket => $composableBuilder(
      column: $table.bucket, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get subCategory => $composableBuilder(
      column: $table.subCategory, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get linkedExpenseId => $composableBuilder(
      column: $table.linkedExpenseId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get includeInNextStatement => $composableBuilder(
      column: $table.includeInNextStatement,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isSettlementVerified => $composableBuilder(
      column: $table.isSettlementVerified,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isEmi => $composableBuilder(
      column: $table.isEmi, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get emiMonths => $composableBuilder(
      column: $table.emiMonths, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get emiRemaining => $composableBuilder(
      column: $table.emiRemaining, builder: (column) => ColumnFilters(column));

  $$CreditCardsTableFilterComposer get cardId {
    final $$CreditCardsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.cardId,
        referencedTable: $db.creditCards,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CreditCardsTableFilterComposer(
              $db: $db,
              $table: $db.creditCards,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$CreditTransactionsTableOrderingComposer
    extends Composer<_$AppDatabase, $CreditTransactionsTable> {
  $$CreditTransactionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get bucket => $composableBuilder(
      column: $table.bucket, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get subCategory => $composableBuilder(
      column: $table.subCategory, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get linkedExpenseId => $composableBuilder(
      column: $table.linkedExpenseId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get includeInNextStatement => $composableBuilder(
      column: $table.includeInNextStatement,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isSettlementVerified => $composableBuilder(
      column: $table.isSettlementVerified,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isEmi => $composableBuilder(
      column: $table.isEmi, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get emiMonths => $composableBuilder(
      column: $table.emiMonths, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get emiRemaining => $composableBuilder(
      column: $table.emiRemaining,
      builder: (column) => ColumnOrderings(column));

  $$CreditCardsTableOrderingComposer get cardId {
    final $$CreditCardsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.cardId,
        referencedTable: $db.creditCards,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CreditCardsTableOrderingComposer(
              $db: $db,
              $table: $db.creditCards,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$CreditTransactionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CreditTransactionsTable> {
  $$CreditTransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<String> get bucket =>
      $composableBuilder(column: $table.bucket, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get subCategory => $composableBuilder(
      column: $table.subCategory, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get linkedExpenseId => $composableBuilder(
      column: $table.linkedExpenseId, builder: (column) => column);

  GeneratedColumn<bool> get includeInNextStatement => $composableBuilder(
      column: $table.includeInNextStatement, builder: (column) => column);

  GeneratedColumn<bool> get isSettlementVerified => $composableBuilder(
      column: $table.isSettlementVerified, builder: (column) => column);

  GeneratedColumn<bool> get isEmi =>
      $composableBuilder(column: $table.isEmi, builder: (column) => column);

  GeneratedColumn<int> get emiMonths =>
      $composableBuilder(column: $table.emiMonths, builder: (column) => column);

  GeneratedColumn<int> get emiRemaining => $composableBuilder(
      column: $table.emiRemaining, builder: (column) => column);

  $$CreditCardsTableAnnotationComposer get cardId {
    final $$CreditCardsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.cardId,
        referencedTable: $db.creditCards,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CreditCardsTableAnnotationComposer(
              $db: $db,
              $table: $db.creditCards,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$CreditTransactionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CreditTransactionsTable,
    CreditTransaction,
    $$CreditTransactionsTableFilterComposer,
    $$CreditTransactionsTableOrderingComposer,
    $$CreditTransactionsTableAnnotationComposer,
    $$CreditTransactionsTableCreateCompanionBuilder,
    $$CreditTransactionsTableUpdateCompanionBuilder,
    (CreditTransaction, $$CreditTransactionsTableReferences),
    CreditTransaction,
    PrefetchHooks Function({bool cardId})> {
  $$CreditTransactionsTableTableManager(
      _$AppDatabase db, $CreditTransactionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CreditTransactionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CreditTransactionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CreditTransactionsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> cardId = const Value.absent(),
            Value<double> amount = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
            Value<String> description = const Value.absent(),
            Value<String> bucket = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<String> subCategory = const Value.absent(),
            Value<String> notes = const Value.absent(),
            Value<String?> linkedExpenseId = const Value.absent(),
            Value<bool> includeInNextStatement = const Value.absent(),
            Value<bool> isSettlementVerified = const Value.absent(),
            Value<bool> isEmi = const Value.absent(),
            Value<int> emiMonths = const Value.absent(),
            Value<int> emiRemaining = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CreditTransactionsCompanion(
            id: id,
            cardId: cardId,
            amount: amount,
            date: date,
            description: description,
            bucket: bucket,
            type: type,
            category: category,
            subCategory: subCategory,
            notes: notes,
            linkedExpenseId: linkedExpenseId,
            includeInNextStatement: includeInNextStatement,
            isSettlementVerified: isSettlementVerified,
            isEmi: isEmi,
            emiMonths: emiMonths,
            emiRemaining: emiRemaining,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String cardId,
            required double amount,
            required DateTime date,
            required String description,
            Value<String> bucket = const Value.absent(),
            required String type,
            required String category,
            required String subCategory,
            required String notes,
            Value<String?> linkedExpenseId = const Value.absent(),
            Value<bool> includeInNextStatement = const Value.absent(),
            Value<bool> isSettlementVerified = const Value.absent(),
            Value<bool> isEmi = const Value.absent(),
            Value<int> emiMonths = const Value.absent(),
            Value<int> emiRemaining = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CreditTransactionsCompanion.insert(
            id: id,
            cardId: cardId,
            amount: amount,
            date: date,
            description: description,
            bucket: bucket,
            type: type,
            category: category,
            subCategory: subCategory,
            notes: notes,
            linkedExpenseId: linkedExpenseId,
            includeInNextStatement: includeInNextStatement,
            isSettlementVerified: isSettlementVerified,
            isEmi: isEmi,
            emiMonths: emiMonths,
            emiRemaining: emiRemaining,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$CreditTransactionsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({cardId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (cardId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.cardId,
                    referencedTable:
                        $$CreditTransactionsTableReferences._cardIdTable(db),
                    referencedColumn:
                        $$CreditTransactionsTableReferences._cardIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$CreditTransactionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CreditTransactionsTable,
    CreditTransaction,
    $$CreditTransactionsTableFilterComposer,
    $$CreditTransactionsTableOrderingComposer,
    $$CreditTransactionsTableAnnotationComposer,
    $$CreditTransactionsTableCreateCompanionBuilder,
    $$CreditTransactionsTableUpdateCompanionBuilder,
    (CreditTransaction, $$CreditTransactionsTableReferences),
    CreditTransaction,
    PrefetchHooks Function({bool cardId})>;
typedef $$InvestmentRecordsTableCreateCompanionBuilder
    = InvestmentRecordsCompanion Function({
  required String id,
  required String symbol,
  required String name,
  required String type,
  required double quantity,
  required double averagePrice,
  required double currentPrice,
  Value<double> previousClose,
  Value<String> bucket,
  required DateTime lastPurchasedDate,
  required DateTime lastUpdated,
  Value<bool> isManual,
  Value<int> rowid,
});
typedef $$InvestmentRecordsTableUpdateCompanionBuilder
    = InvestmentRecordsCompanion Function({
  Value<String> id,
  Value<String> symbol,
  Value<String> name,
  Value<String> type,
  Value<double> quantity,
  Value<double> averagePrice,
  Value<double> currentPrice,
  Value<double> previousClose,
  Value<String> bucket,
  Value<DateTime> lastPurchasedDate,
  Value<DateTime> lastUpdated,
  Value<bool> isManual,
  Value<int> rowid,
});

class $$InvestmentRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $InvestmentRecordsTable> {
  $$InvestmentRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get symbol => $composableBuilder(
      column: $table.symbol, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get averagePrice => $composableBuilder(
      column: $table.averagePrice, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get currentPrice => $composableBuilder(
      column: $table.currentPrice, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get previousClose => $composableBuilder(
      column: $table.previousClose, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get bucket => $composableBuilder(
      column: $table.bucket, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastPurchasedDate => $composableBuilder(
      column: $table.lastPurchasedDate,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastUpdated => $composableBuilder(
      column: $table.lastUpdated, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isManual => $composableBuilder(
      column: $table.isManual, builder: (column) => ColumnFilters(column));
}

class $$InvestmentRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $InvestmentRecordsTable> {
  $$InvestmentRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get symbol => $composableBuilder(
      column: $table.symbol, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get averagePrice => $composableBuilder(
      column: $table.averagePrice,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get currentPrice => $composableBuilder(
      column: $table.currentPrice,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get previousClose => $composableBuilder(
      column: $table.previousClose,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get bucket => $composableBuilder(
      column: $table.bucket, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastPurchasedDate => $composableBuilder(
      column: $table.lastPurchasedDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastUpdated => $composableBuilder(
      column: $table.lastUpdated, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isManual => $composableBuilder(
      column: $table.isManual, builder: (column) => ColumnOrderings(column));
}

class $$InvestmentRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $InvestmentRecordsTable> {
  $$InvestmentRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get symbol =>
      $composableBuilder(column: $table.symbol, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<double> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<double> get averagePrice => $composableBuilder(
      column: $table.averagePrice, builder: (column) => column);

  GeneratedColumn<double> get currentPrice => $composableBuilder(
      column: $table.currentPrice, builder: (column) => column);

  GeneratedColumn<double> get previousClose => $composableBuilder(
      column: $table.previousClose, builder: (column) => column);

  GeneratedColumn<String> get bucket =>
      $composableBuilder(column: $table.bucket, builder: (column) => column);

  GeneratedColumn<DateTime> get lastPurchasedDate => $composableBuilder(
      column: $table.lastPurchasedDate, builder: (column) => column);

  GeneratedColumn<DateTime> get lastUpdated => $composableBuilder(
      column: $table.lastUpdated, builder: (column) => column);

  GeneratedColumn<bool> get isManual =>
      $composableBuilder(column: $table.isManual, builder: (column) => column);
}

class $$InvestmentRecordsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $InvestmentRecordsTable,
    InvestmentRecord,
    $$InvestmentRecordsTableFilterComposer,
    $$InvestmentRecordsTableOrderingComposer,
    $$InvestmentRecordsTableAnnotationComposer,
    $$InvestmentRecordsTableCreateCompanionBuilder,
    $$InvestmentRecordsTableUpdateCompanionBuilder,
    (
      InvestmentRecord,
      BaseReferences<_$AppDatabase, $InvestmentRecordsTable, InvestmentRecord>
    ),
    InvestmentRecord,
    PrefetchHooks Function()> {
  $$InvestmentRecordsTableTableManager(
      _$AppDatabase db, $InvestmentRecordsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InvestmentRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InvestmentRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InvestmentRecordsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> symbol = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<double> quantity = const Value.absent(),
            Value<double> averagePrice = const Value.absent(),
            Value<double> currentPrice = const Value.absent(),
            Value<double> previousClose = const Value.absent(),
            Value<String> bucket = const Value.absent(),
            Value<DateTime> lastPurchasedDate = const Value.absent(),
            Value<DateTime> lastUpdated = const Value.absent(),
            Value<bool> isManual = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              InvestmentRecordsCompanion(
            id: id,
            symbol: symbol,
            name: name,
            type: type,
            quantity: quantity,
            averagePrice: averagePrice,
            currentPrice: currentPrice,
            previousClose: previousClose,
            bucket: bucket,
            lastPurchasedDate: lastPurchasedDate,
            lastUpdated: lastUpdated,
            isManual: isManual,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String symbol,
            required String name,
            required String type,
            required double quantity,
            required double averagePrice,
            required double currentPrice,
            Value<double> previousClose = const Value.absent(),
            Value<String> bucket = const Value.absent(),
            required DateTime lastPurchasedDate,
            required DateTime lastUpdated,
            Value<bool> isManual = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              InvestmentRecordsCompanion.insert(
            id: id,
            symbol: symbol,
            name: name,
            type: type,
            quantity: quantity,
            averagePrice: averagePrice,
            currentPrice: currentPrice,
            previousClose: previousClose,
            bucket: bucket,
            lastPurchasedDate: lastPurchasedDate,
            lastUpdated: lastUpdated,
            isManual: isManual,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$InvestmentRecordsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $InvestmentRecordsTable,
    InvestmentRecord,
    $$InvestmentRecordsTableFilterComposer,
    $$InvestmentRecordsTableOrderingComposer,
    $$InvestmentRecordsTableAnnotationComposer,
    $$InvestmentRecordsTableCreateCompanionBuilder,
    $$InvestmentRecordsTableUpdateCompanionBuilder,
    (
      InvestmentRecord,
      BaseReferences<_$AppDatabase, $InvestmentRecordsTable, InvestmentRecord>
    ),
    InvestmentRecord,
    PrefetchHooks Function()>;
typedef $$NetWorthRecordsTableCreateCompanionBuilder = NetWorthRecordsCompanion
    Function({
  required String id,
  required DateTime date,
  required double amount,
  Value<int> rowid,
});
typedef $$NetWorthRecordsTableUpdateCompanionBuilder = NetWorthRecordsCompanion
    Function({
  Value<String> id,
  Value<DateTime> date,
  Value<double> amount,
  Value<int> rowid,
});

class $$NetWorthRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $NetWorthRecordsTable> {
  $$NetWorthRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnFilters(column));
}

class $$NetWorthRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $NetWorthRecordsTable> {
  $$NetWorthRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnOrderings(column));
}

class $$NetWorthRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $NetWorthRecordsTable> {
  $$NetWorthRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);
}

class $$NetWorthRecordsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $NetWorthRecordsTable,
    NetWorthRecord,
    $$NetWorthRecordsTableFilterComposer,
    $$NetWorthRecordsTableOrderingComposer,
    $$NetWorthRecordsTableAnnotationComposer,
    $$NetWorthRecordsTableCreateCompanionBuilder,
    $$NetWorthRecordsTableUpdateCompanionBuilder,
    (
      NetWorthRecord,
      BaseReferences<_$AppDatabase, $NetWorthRecordsTable, NetWorthRecord>
    ),
    NetWorthRecord,
    PrefetchHooks Function()> {
  $$NetWorthRecordsTableTableManager(
      _$AppDatabase db, $NetWorthRecordsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NetWorthRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NetWorthRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NetWorthRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
            Value<double> amount = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              NetWorthRecordsCompanion(
            id: id,
            date: date,
            amount: amount,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required DateTime date,
            required double amount,
            Value<int> rowid = const Value.absent(),
          }) =>
              NetWorthRecordsCompanion.insert(
            id: id,
            date: date,
            amount: amount,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$NetWorthRecordsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $NetWorthRecordsTable,
    NetWorthRecord,
    $$NetWorthRecordsTableFilterComposer,
    $$NetWorthRecordsTableOrderingComposer,
    $$NetWorthRecordsTableAnnotationComposer,
    $$NetWorthRecordsTableCreateCompanionBuilder,
    $$NetWorthRecordsTableUpdateCompanionBuilder,
    (
      NetWorthRecord,
      BaseReferences<_$AppDatabase, $NetWorthRecordsTable, NetWorthRecord>
    ),
    NetWorthRecord,
    PrefetchHooks Function()>;
typedef $$NetWorthSplitsTableCreateCompanionBuilder = NetWorthSplitsCompanion
    Function({
  required String id,
  required DateTime date,
  Value<double> netIncome,
  Value<double> netExpense,
  Value<double> capitalGain,
  Value<double> capitalLoss,
  Value<double> nonCalcIncome,
  Value<double> nonCalcExpense,
  Value<int> rowid,
});
typedef $$NetWorthSplitsTableUpdateCompanionBuilder = NetWorthSplitsCompanion
    Function({
  Value<String> id,
  Value<DateTime> date,
  Value<double> netIncome,
  Value<double> netExpense,
  Value<double> capitalGain,
  Value<double> capitalLoss,
  Value<double> nonCalcIncome,
  Value<double> nonCalcExpense,
  Value<int> rowid,
});

class $$NetWorthSplitsTableFilterComposer
    extends Composer<_$AppDatabase, $NetWorthSplitsTable> {
  $$NetWorthSplitsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get netIncome => $composableBuilder(
      column: $table.netIncome, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get netExpense => $composableBuilder(
      column: $table.netExpense, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get capitalGain => $composableBuilder(
      column: $table.capitalGain, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get capitalLoss => $composableBuilder(
      column: $table.capitalLoss, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get nonCalcIncome => $composableBuilder(
      column: $table.nonCalcIncome, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get nonCalcExpense => $composableBuilder(
      column: $table.nonCalcExpense,
      builder: (column) => ColumnFilters(column));
}

class $$NetWorthSplitsTableOrderingComposer
    extends Composer<_$AppDatabase, $NetWorthSplitsTable> {
  $$NetWorthSplitsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get netIncome => $composableBuilder(
      column: $table.netIncome, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get netExpense => $composableBuilder(
      column: $table.netExpense, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get capitalGain => $composableBuilder(
      column: $table.capitalGain, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get capitalLoss => $composableBuilder(
      column: $table.capitalLoss, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get nonCalcIncome => $composableBuilder(
      column: $table.nonCalcIncome,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get nonCalcExpense => $composableBuilder(
      column: $table.nonCalcExpense,
      builder: (column) => ColumnOrderings(column));
}

class $$NetWorthSplitsTableAnnotationComposer
    extends Composer<_$AppDatabase, $NetWorthSplitsTable> {
  $$NetWorthSplitsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<double> get netIncome =>
      $composableBuilder(column: $table.netIncome, builder: (column) => column);

  GeneratedColumn<double> get netExpense => $composableBuilder(
      column: $table.netExpense, builder: (column) => column);

  GeneratedColumn<double> get capitalGain => $composableBuilder(
      column: $table.capitalGain, builder: (column) => column);

  GeneratedColumn<double> get capitalLoss => $composableBuilder(
      column: $table.capitalLoss, builder: (column) => column);

  GeneratedColumn<double> get nonCalcIncome => $composableBuilder(
      column: $table.nonCalcIncome, builder: (column) => column);

  GeneratedColumn<double> get nonCalcExpense => $composableBuilder(
      column: $table.nonCalcExpense, builder: (column) => column);
}

class $$NetWorthSplitsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $NetWorthSplitsTable,
    NetWorthSplit,
    $$NetWorthSplitsTableFilterComposer,
    $$NetWorthSplitsTableOrderingComposer,
    $$NetWorthSplitsTableAnnotationComposer,
    $$NetWorthSplitsTableCreateCompanionBuilder,
    $$NetWorthSplitsTableUpdateCompanionBuilder,
    (
      NetWorthSplit,
      BaseReferences<_$AppDatabase, $NetWorthSplitsTable, NetWorthSplit>
    ),
    NetWorthSplit,
    PrefetchHooks Function()> {
  $$NetWorthSplitsTableTableManager(
      _$AppDatabase db, $NetWorthSplitsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NetWorthSplitsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NetWorthSplitsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NetWorthSplitsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
            Value<double> netIncome = const Value.absent(),
            Value<double> netExpense = const Value.absent(),
            Value<double> capitalGain = const Value.absent(),
            Value<double> capitalLoss = const Value.absent(),
            Value<double> nonCalcIncome = const Value.absent(),
            Value<double> nonCalcExpense = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              NetWorthSplitsCompanion(
            id: id,
            date: date,
            netIncome: netIncome,
            netExpense: netExpense,
            capitalGain: capitalGain,
            capitalLoss: capitalLoss,
            nonCalcIncome: nonCalcIncome,
            nonCalcExpense: nonCalcExpense,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required DateTime date,
            Value<double> netIncome = const Value.absent(),
            Value<double> netExpense = const Value.absent(),
            Value<double> capitalGain = const Value.absent(),
            Value<double> capitalLoss = const Value.absent(),
            Value<double> nonCalcIncome = const Value.absent(),
            Value<double> nonCalcExpense = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              NetWorthSplitsCompanion.insert(
            id: id,
            date: date,
            netIncome: netIncome,
            netExpense: netExpense,
            capitalGain: capitalGain,
            capitalLoss: capitalLoss,
            nonCalcIncome: nonCalcIncome,
            nonCalcExpense: nonCalcExpense,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$NetWorthSplitsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $NetWorthSplitsTable,
    NetWorthSplit,
    $$NetWorthSplitsTableFilterComposer,
    $$NetWorthSplitsTableOrderingComposer,
    $$NetWorthSplitsTableAnnotationComposer,
    $$NetWorthSplitsTableCreateCompanionBuilder,
    $$NetWorthSplitsTableUpdateCompanionBuilder,
    (
      NetWorthSplit,
      BaseReferences<_$AppDatabase, $NetWorthSplitsTable, NetWorthSplit>
    ),
    NetWorthSplit,
    PrefetchHooks Function()>;
typedef $$CustomTemplatesTableCreateCompanionBuilder = CustomTemplatesCompanion
    Function({
  required String id,
  required String name,
  required DateTime createdAt,
  required String fields,
  Value<String?> xAxisField,
  Value<String?> yAxisField,
  Value<int> rowid,
});
typedef $$CustomTemplatesTableUpdateCompanionBuilder = CustomTemplatesCompanion
    Function({
  Value<String> id,
  Value<String> name,
  Value<DateTime> createdAt,
  Value<String> fields,
  Value<String?> xAxisField,
  Value<String?> yAxisField,
  Value<int> rowid,
});

final class $$CustomTemplatesTableReferences extends BaseReferences<
    _$AppDatabase, $CustomTemplatesTable, CustomTemplate> {
  $$CustomTemplatesTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$CustomRecordsTable, List<CustomRecord>>
      _customRecordsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.customRecords,
              aliasName: $_aliasNameGenerator(
                  db.customTemplates.id, db.customRecords.templateId));

  $$CustomRecordsTableProcessedTableManager get customRecordsRefs {
    final manager = $$CustomRecordsTableTableManager($_db, $_db.customRecords)
        .filter((f) => f.templateId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_customRecordsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$CustomTemplatesTableFilterComposer
    extends Composer<_$AppDatabase, $CustomTemplatesTable> {
  $$CustomTemplatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fields => $composableBuilder(
      column: $table.fields, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get xAxisField => $composableBuilder(
      column: $table.xAxisField, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get yAxisField => $composableBuilder(
      column: $table.yAxisField, builder: (column) => ColumnFilters(column));

  Expression<bool> customRecordsRefs(
      Expression<bool> Function($$CustomRecordsTableFilterComposer f) f) {
    final $$CustomRecordsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.customRecords,
        getReferencedColumn: (t) => t.templateId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CustomRecordsTableFilterComposer(
              $db: $db,
              $table: $db.customRecords,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$CustomTemplatesTableOrderingComposer
    extends Composer<_$AppDatabase, $CustomTemplatesTable> {
  $$CustomTemplatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fields => $composableBuilder(
      column: $table.fields, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get xAxisField => $composableBuilder(
      column: $table.xAxisField, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get yAxisField => $composableBuilder(
      column: $table.yAxisField, builder: (column) => ColumnOrderings(column));
}

class $$CustomTemplatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CustomTemplatesTable> {
  $$CustomTemplatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get fields =>
      $composableBuilder(column: $table.fields, builder: (column) => column);

  GeneratedColumn<String> get xAxisField => $composableBuilder(
      column: $table.xAxisField, builder: (column) => column);

  GeneratedColumn<String> get yAxisField => $composableBuilder(
      column: $table.yAxisField, builder: (column) => column);

  Expression<T> customRecordsRefs<T extends Object>(
      Expression<T> Function($$CustomRecordsTableAnnotationComposer a) f) {
    final $$CustomRecordsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.customRecords,
        getReferencedColumn: (t) => t.templateId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CustomRecordsTableAnnotationComposer(
              $db: $db,
              $table: $db.customRecords,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$CustomTemplatesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CustomTemplatesTable,
    CustomTemplate,
    $$CustomTemplatesTableFilterComposer,
    $$CustomTemplatesTableOrderingComposer,
    $$CustomTemplatesTableAnnotationComposer,
    $$CustomTemplatesTableCreateCompanionBuilder,
    $$CustomTemplatesTableUpdateCompanionBuilder,
    (CustomTemplate, $$CustomTemplatesTableReferences),
    CustomTemplate,
    PrefetchHooks Function({bool customRecordsRefs})> {
  $$CustomTemplatesTableTableManager(
      _$AppDatabase db, $CustomTemplatesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CustomTemplatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CustomTemplatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CustomTemplatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<String> fields = const Value.absent(),
            Value<String?> xAxisField = const Value.absent(),
            Value<String?> yAxisField = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CustomTemplatesCompanion(
            id: id,
            name: name,
            createdAt: createdAt,
            fields: fields,
            xAxisField: xAxisField,
            yAxisField: yAxisField,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            required DateTime createdAt,
            required String fields,
            Value<String?> xAxisField = const Value.absent(),
            Value<String?> yAxisField = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CustomTemplatesCompanion.insert(
            id: id,
            name: name,
            createdAt: createdAt,
            fields: fields,
            xAxisField: xAxisField,
            yAxisField: yAxisField,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$CustomTemplatesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({customRecordsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (customRecordsRefs) db.customRecords
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (customRecordsRefs)
                    await $_getPrefetchedData<CustomTemplate,
                            $CustomTemplatesTable, CustomRecord>(
                        currentTable: table,
                        referencedTable: $$CustomTemplatesTableReferences
                            ._customRecordsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$CustomTemplatesTableReferences(db, table, p0)
                                .customRecordsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.templateId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$CustomTemplatesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CustomTemplatesTable,
    CustomTemplate,
    $$CustomTemplatesTableFilterComposer,
    $$CustomTemplatesTableOrderingComposer,
    $$CustomTemplatesTableAnnotationComposer,
    $$CustomTemplatesTableCreateCompanionBuilder,
    $$CustomTemplatesTableUpdateCompanionBuilder,
    (CustomTemplate, $$CustomTemplatesTableReferences),
    CustomTemplate,
    PrefetchHooks Function({bool customRecordsRefs})>;
typedef $$CustomRecordsTableCreateCompanionBuilder = CustomRecordsCompanion
    Function({
  required String id,
  required String templateId,
  required DateTime createdAt,
  required String data,
  Value<int> rowid,
});
typedef $$CustomRecordsTableUpdateCompanionBuilder = CustomRecordsCompanion
    Function({
  Value<String> id,
  Value<String> templateId,
  Value<DateTime> createdAt,
  Value<String> data,
  Value<int> rowid,
});

final class $$CustomRecordsTableReferences
    extends BaseReferences<_$AppDatabase, $CustomRecordsTable, CustomRecord> {
  $$CustomRecordsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $CustomTemplatesTable _templateIdTable(_$AppDatabase db) =>
      db.customTemplates.createAlias($_aliasNameGenerator(
          db.customRecords.templateId, db.customTemplates.id));

  $$CustomTemplatesTableProcessedTableManager get templateId {
    final $_column = $_itemColumn<String>('template_id')!;

    final manager =
        $$CustomTemplatesTableTableManager($_db, $_db.customTemplates)
            .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_templateIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$CustomRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $CustomRecordsTable> {
  $$CustomRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get data => $composableBuilder(
      column: $table.data, builder: (column) => ColumnFilters(column));

  $$CustomTemplatesTableFilterComposer get templateId {
    final $$CustomTemplatesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.templateId,
        referencedTable: $db.customTemplates,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CustomTemplatesTableFilterComposer(
              $db: $db,
              $table: $db.customTemplates,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$CustomRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $CustomRecordsTable> {
  $$CustomRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get data => $composableBuilder(
      column: $table.data, builder: (column) => ColumnOrderings(column));

  $$CustomTemplatesTableOrderingComposer get templateId {
    final $$CustomTemplatesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.templateId,
        referencedTable: $db.customTemplates,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CustomTemplatesTableOrderingComposer(
              $db: $db,
              $table: $db.customTemplates,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$CustomRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CustomRecordsTable> {
  $$CustomRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get data =>
      $composableBuilder(column: $table.data, builder: (column) => column);

  $$CustomTemplatesTableAnnotationComposer get templateId {
    final $$CustomTemplatesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.templateId,
        referencedTable: $db.customTemplates,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CustomTemplatesTableAnnotationComposer(
              $db: $db,
              $table: $db.customTemplates,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$CustomRecordsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CustomRecordsTable,
    CustomRecord,
    $$CustomRecordsTableFilterComposer,
    $$CustomRecordsTableOrderingComposer,
    $$CustomRecordsTableAnnotationComposer,
    $$CustomRecordsTableCreateCompanionBuilder,
    $$CustomRecordsTableUpdateCompanionBuilder,
    (CustomRecord, $$CustomRecordsTableReferences),
    CustomRecord,
    PrefetchHooks Function({bool templateId})> {
  $$CustomRecordsTableTableManager(_$AppDatabase db, $CustomRecordsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CustomRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CustomRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CustomRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> templateId = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<String> data = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CustomRecordsCompanion(
            id: id,
            templateId: templateId,
            createdAt: createdAt,
            data: data,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String templateId,
            required DateTime createdAt,
            required String data,
            Value<int> rowid = const Value.absent(),
          }) =>
              CustomRecordsCompanion.insert(
            id: id,
            templateId: templateId,
            createdAt: createdAt,
            data: data,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$CustomRecordsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({templateId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (templateId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.templateId,
                    referencedTable:
                        $$CustomRecordsTableReferences._templateIdTable(db),
                    referencedColumn:
                        $$CustomRecordsTableReferences._templateIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$CustomRecordsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CustomRecordsTable,
    CustomRecord,
    $$CustomRecordsTableFilterComposer,
    $$CustomRecordsTableOrderingComposer,
    $$CustomRecordsTableAnnotationComposer,
    $$CustomRecordsTableCreateCompanionBuilder,
    $$CustomRecordsTableUpdateCompanionBuilder,
    (CustomRecord, $$CustomRecordsTableReferences),
    CustomRecord,
    PrefetchHooks Function({bool templateId})>;
typedef $$TransactionCategoriesTableCreateCompanionBuilder
    = TransactionCategoriesCompanion Function({
  required String id,
  required String name,
  required String type,
  required String subCategories,
  Value<int?> iconCode,
  Value<int> rowid,
});
typedef $$TransactionCategoriesTableUpdateCompanionBuilder
    = TransactionCategoriesCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String> type,
  Value<String> subCategories,
  Value<int?> iconCode,
  Value<int> rowid,
});

class $$TransactionCategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $TransactionCategoriesTable> {
  $$TransactionCategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get subCategories => $composableBuilder(
      column: $table.subCategories, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get iconCode => $composableBuilder(
      column: $table.iconCode, builder: (column) => ColumnFilters(column));
}

class $$TransactionCategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $TransactionCategoriesTable> {
  $$TransactionCategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get subCategories => $composableBuilder(
      column: $table.subCategories,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get iconCode => $composableBuilder(
      column: $table.iconCode, builder: (column) => ColumnOrderings(column));
}

class $$TransactionCategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $TransactionCategoriesTable> {
  $$TransactionCategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get subCategories => $composableBuilder(
      column: $table.subCategories, builder: (column) => column);

  GeneratedColumn<int> get iconCode =>
      $composableBuilder(column: $table.iconCode, builder: (column) => column);
}

class $$TransactionCategoriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TransactionCategoriesTable,
    TransactionCategory,
    $$TransactionCategoriesTableFilterComposer,
    $$TransactionCategoriesTableOrderingComposer,
    $$TransactionCategoriesTableAnnotationComposer,
    $$TransactionCategoriesTableCreateCompanionBuilder,
    $$TransactionCategoriesTableUpdateCompanionBuilder,
    (
      TransactionCategory,
      BaseReferences<_$AppDatabase, $TransactionCategoriesTable,
          TransactionCategory>
    ),
    TransactionCategory,
    PrefetchHooks Function()> {
  $$TransactionCategoriesTableTableManager(
      _$AppDatabase db, $TransactionCategoriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransactionCategoriesTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$TransactionCategoriesTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransactionCategoriesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String> subCategories = const Value.absent(),
            Value<int?> iconCode = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TransactionCategoriesCompanion(
            id: id,
            name: name,
            type: type,
            subCategories: subCategories,
            iconCode: iconCode,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            required String type,
            required String subCategories,
            Value<int?> iconCode = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TransactionCategoriesCompanion.insert(
            id: id,
            name: name,
            type: type,
            subCategories: subCategories,
            iconCode: iconCode,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$TransactionCategoriesTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $TransactionCategoriesTable,
        TransactionCategory,
        $$TransactionCategoriesTableFilterComposer,
        $$TransactionCategoriesTableOrderingComposer,
        $$TransactionCategoriesTableAnnotationComposer,
        $$TransactionCategoriesTableCreateCompanionBuilder,
        $$TransactionCategoriesTableUpdateCompanionBuilder,
        (
          TransactionCategory,
          BaseReferences<_$AppDatabase, $TransactionCategoriesTable,
              TransactionCategory>
        ),
        TransactionCategory,
        PrefetchHooks Function()>;
typedef $$SettingsTableCreateCompanionBuilder = SettingsCompanion Function({
  required String key,
  required String value,
  Value<int> rowid,
});
typedef $$SettingsTableUpdateCompanionBuilder = SettingsCompanion Function({
  Value<String> key,
  Value<String> value,
  Value<int> rowid,
});

class $$SettingsTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnFilters(column));
}

class $$SettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnOrderings(column));
}

class $$SettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$SettingsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SettingsTable,
    Setting,
    $$SettingsTableFilterComposer,
    $$SettingsTableOrderingComposer,
    $$SettingsTableAnnotationComposer,
    $$SettingsTableCreateCompanionBuilder,
    $$SettingsTableUpdateCompanionBuilder,
    (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
    Setting,
    PrefetchHooks Function()> {
  $$SettingsTableTableManager(_$AppDatabase db, $SettingsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SettingsCompanion(
            key: key,
            value: value,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String key,
            required String value,
            Value<int> rowid = const Value.absent(),
          }) =>
              SettingsCompanion.insert(
            key: key,
            value: value,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SettingsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SettingsTable,
    Setting,
    $$SettingsTableFilterComposer,
    $$SettingsTableOrderingComposer,
    $$SettingsTableAnnotationComposer,
    $$SettingsTableCreateCompanionBuilder,
    $$SettingsTableUpdateCompanionBuilder,
    (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
    Setting,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$FinancialRecordsTableTableManager get financialRecords =>
      $$FinancialRecordsTableTableManager(_db, _db.financialRecords);
  $$SettlementsTableTableManager get settlements =>
      $$SettlementsTableTableManager(_db, _db.settlements);
  $$ExpenseAccountsTableTableManager get expenseAccounts =>
      $$ExpenseAccountsTableTableManager(_db, _db.expenseAccounts);
  $$ExpenseTransactionsTableTableManager get expenseTransactions =>
      $$ExpenseTransactionsTableTableManager(_db, _db.expenseTransactions);
  $$CreditCardsTableTableManager get creditCards =>
      $$CreditCardsTableTableManager(_db, _db.creditCards);
  $$CreditTransactionsTableTableManager get creditTransactions =>
      $$CreditTransactionsTableTableManager(_db, _db.creditTransactions);
  $$InvestmentRecordsTableTableManager get investmentRecords =>
      $$InvestmentRecordsTableTableManager(_db, _db.investmentRecords);
  $$NetWorthRecordsTableTableManager get netWorthRecords =>
      $$NetWorthRecordsTableTableManager(_db, _db.netWorthRecords);
  $$NetWorthSplitsTableTableManager get netWorthSplits =>
      $$NetWorthSplitsTableTableManager(_db, _db.netWorthSplits);
  $$CustomTemplatesTableTableManager get customTemplates =>
      $$CustomTemplatesTableTableManager(_db, _db.customTemplates);
  $$CustomRecordsTableTableManager get customRecords =>
      $$CustomRecordsTableTableManager(_db, _db.customRecords);
  $$TransactionCategoriesTableTableManager get transactionCategories =>
      $$TransactionCategoriesTableTableManager(_db, _db.transactionCategories);
  $$SettingsTableTableManager get settings =>
      $$SettingsTableTableManager(_db, _db.settings);
}
