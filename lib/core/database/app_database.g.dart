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
  @override
  late final GeneratedColumnWithTypeConverter<double, double> currentBalance =
      GeneratedColumn<double>('current_balance', aliasedName, false,
              type: DriftSqlType.double,
              requiredDuringInsert: false,
              defaultValue: const Constant(0.0))
          .withConverter<double>(
              $ExpenseAccountsTable.$convertercurrentBalance);
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
      currentBalance: $ExpenseAccountsTable.$convertercurrentBalance.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.double, data['${effectivePrefix}current_balance'])!),
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

  static TypeConverter<double, double> $convertercurrentBalance =
      const TwoDecimalConverter();
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
    {
      map['current_balance'] = Variable<double>(
          $ExpenseAccountsTable.$convertercurrentBalance.toSql(currentBalance));
    }
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
      map['current_balance'] = Variable<double>($ExpenseAccountsTable
          .$convertercurrentBalance
          .toSql(currentBalance.value));
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
  @override
  late final GeneratedColumnWithTypeConverter<double, double> currentBalance =
      GeneratedColumn<double>('current_balance', aliasedName, false,
              type: DriftSqlType.double,
              requiredDuringInsert: false,
              defaultValue: const Constant(0.0))
          .withConverter<double>($CreditCardsTable.$convertercurrentBalance);
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
      currentBalance: $CreditCardsTable.$convertercurrentBalance.fromSql(
          attachedDatabase.typeMapping.read(
              DriftSqlType.double, data['${effectivePrefix}current_balance'])!),
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

  static TypeConverter<double, double> $convertercurrentBalance =
      const TwoDecimalConverter();
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
    {
      map['current_balance'] = Variable<double>(
          $CreditCardsTable.$convertercurrentBalance.toSql(currentBalance));
    }
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
      map['current_balance'] = Variable<double>($CreditCardsTable
          .$convertercurrentBalance
          .toSql(currentBalance.value));
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
  static const VerificationMeta _bankAccountsMeta =
      const VerificationMeta('bankAccounts');
  @override
  late final GeneratedColumn<double> bankAccounts = GeneratedColumn<double>(
      'bank_accounts', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _cashInHandMeta =
      const VerificationMeta('cashInHand');
  @override
  late final GeneratedColumn<double> cashInHand = GeneratedColumn<double>(
      'cash_in_hand', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _mutualFundsMeta =
      const VerificationMeta('mutualFunds');
  @override
  late final GeneratedColumn<double> mutualFunds = GeneratedColumn<double>(
      'mutual_funds', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _equityMeta = const VerificationMeta('equity');
  @override
  late final GeneratedColumn<double> equity = GeneratedColumn<double>(
      'equity', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _bondsMeta = const VerificationMeta('bonds');
  @override
  late final GeneratedColumn<double> bonds = GeneratedColumn<double>(
      'bonds', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _depositsMeta =
      const VerificationMeta('deposits');
  @override
  late final GeneratedColumn<double> deposits = GeneratedColumn<double>(
      'deposits', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _realEstateMeta =
      const VerificationMeta('realEstate');
  @override
  late final GeneratedColumn<double> realEstate = GeneratedColumn<double>(
      'real_estate', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _otherAssetsMeta =
      const VerificationMeta('otherAssets');
  @override
  late final GeneratedColumn<double> otherAssets = GeneratedColumn<double>(
      'other_assets', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _assetNotesMeta =
      const VerificationMeta('assetNotes');
  @override
  late final GeneratedColumn<String> assetNotes = GeneratedColumn<String>(
      'asset_notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _loansMeta = const VerificationMeta('loans');
  @override
  late final GeneratedColumn<double> loans = GeneratedColumn<double>(
      'loans', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _creditCardOutstandingMeta =
      const VerificationMeta('creditCardOutstanding');
  @override
  late final GeneratedColumn<double> creditCardOutstanding =
      GeneratedColumn<double>('credit_card_outstanding', aliasedName, false,
          type: DriftSqlType.double,
          requiredDuringInsert: false,
          defaultValue: const Constant(0.0));
  static const VerificationMeta _creditLineOutstandingMeta =
      const VerificationMeta('creditLineOutstanding');
  @override
  late final GeneratedColumn<double> creditLineOutstanding =
      GeneratedColumn<double>('credit_line_outstanding', aliasedName, false,
          type: DriftSqlType.double,
          requiredDuringInsert: false,
          defaultValue: const Constant(0.0));
  static const VerificationMeta _otherDebtsMeta =
      const VerificationMeta('otherDebts');
  @override
  late final GeneratedColumn<double> otherDebts = GeneratedColumn<double>(
      'other_debts', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _liabilityNotesMeta =
      const VerificationMeta('liabilityNotes');
  @override
  late final GeneratedColumn<String> liabilityNotes = GeneratedColumn<String>(
      'liability_notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
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
  static const VerificationMeta _budgetedIncomeMeta =
      const VerificationMeta('budgetedIncome');
  @override
  late final GeneratedColumn<double> budgetedIncome = GeneratedColumn<double>(
      'budgeted_income', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _budgetedExpenseMeta =
      const VerificationMeta('budgetedExpense');
  @override
  late final GeneratedColumn<double> budgetedExpense = GeneratedColumn<double>(
      'budgeted_expense', aliasedName, false,
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
  static const VerificationMeta _outOfBucketExpenseMeta =
      const VerificationMeta('outOfBucketExpense');
  @override
  late final GeneratedColumn<double> outOfBucketExpense =
      GeneratedColumn<double>('out_of_bucket_expense', aliasedName, false,
          type: DriftSqlType.double,
          requiredDuringInsert: false,
          defaultValue: const Constant(0.0));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        date,
        bankAccounts,
        cashInHand,
        mutualFunds,
        equity,
        bonds,
        deposits,
        realEstate,
        otherAssets,
        assetNotes,
        loans,
        creditCardOutstanding,
        creditLineOutstanding,
        otherDebts,
        liabilityNotes,
        totalIncome,
        totalExpense,
        budgetedIncome,
        budgetedExpense,
        nonCalcIncome,
        nonCalcExpense,
        outOfBucketExpense
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
    if (data.containsKey('bank_accounts')) {
      context.handle(
          _bankAccountsMeta,
          bankAccounts.isAcceptableOrUnknown(
              data['bank_accounts']!, _bankAccountsMeta));
    }
    if (data.containsKey('cash_in_hand')) {
      context.handle(
          _cashInHandMeta,
          cashInHand.isAcceptableOrUnknown(
              data['cash_in_hand']!, _cashInHandMeta));
    }
    if (data.containsKey('mutual_funds')) {
      context.handle(
          _mutualFundsMeta,
          mutualFunds.isAcceptableOrUnknown(
              data['mutual_funds']!, _mutualFundsMeta));
    }
    if (data.containsKey('equity')) {
      context.handle(_equityMeta,
          equity.isAcceptableOrUnknown(data['equity']!, _equityMeta));
    }
    if (data.containsKey('bonds')) {
      context.handle(
          _bondsMeta, bonds.isAcceptableOrUnknown(data['bonds']!, _bondsMeta));
    }
    if (data.containsKey('deposits')) {
      context.handle(_depositsMeta,
          deposits.isAcceptableOrUnknown(data['deposits']!, _depositsMeta));
    }
    if (data.containsKey('real_estate')) {
      context.handle(
          _realEstateMeta,
          realEstate.isAcceptableOrUnknown(
              data['real_estate']!, _realEstateMeta));
    }
    if (data.containsKey('other_assets')) {
      context.handle(
          _otherAssetsMeta,
          otherAssets.isAcceptableOrUnknown(
              data['other_assets']!, _otherAssetsMeta));
    }
    if (data.containsKey('asset_notes')) {
      context.handle(
          _assetNotesMeta,
          assetNotes.isAcceptableOrUnknown(
              data['asset_notes']!, _assetNotesMeta));
    }
    if (data.containsKey('loans')) {
      context.handle(
          _loansMeta, loans.isAcceptableOrUnknown(data['loans']!, _loansMeta));
    }
    if (data.containsKey('credit_card_outstanding')) {
      context.handle(
          _creditCardOutstandingMeta,
          creditCardOutstanding.isAcceptableOrUnknown(
              data['credit_card_outstanding']!, _creditCardOutstandingMeta));
    }
    if (data.containsKey('credit_line_outstanding')) {
      context.handle(
          _creditLineOutstandingMeta,
          creditLineOutstanding.isAcceptableOrUnknown(
              data['credit_line_outstanding']!, _creditLineOutstandingMeta));
    }
    if (data.containsKey('other_debts')) {
      context.handle(
          _otherDebtsMeta,
          otherDebts.isAcceptableOrUnknown(
              data['other_debts']!, _otherDebtsMeta));
    }
    if (data.containsKey('liability_notes')) {
      context.handle(
          _liabilityNotesMeta,
          liabilityNotes.isAcceptableOrUnknown(
              data['liability_notes']!, _liabilityNotesMeta));
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
    if (data.containsKey('budgeted_income')) {
      context.handle(
          _budgetedIncomeMeta,
          budgetedIncome.isAcceptableOrUnknown(
              data['budgeted_income']!, _budgetedIncomeMeta));
    }
    if (data.containsKey('budgeted_expense')) {
      context.handle(
          _budgetedExpenseMeta,
          budgetedExpense.isAcceptableOrUnknown(
              data['budgeted_expense']!, _budgetedExpenseMeta));
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
    if (data.containsKey('out_of_bucket_expense')) {
      context.handle(
          _outOfBucketExpenseMeta,
          outOfBucketExpense.isAcceptableOrUnknown(
              data['out_of_bucket_expense']!, _outOfBucketExpenseMeta));
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
      bankAccounts: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}bank_accounts'])!,
      cashInHand: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}cash_in_hand'])!,
      mutualFunds: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}mutual_funds'])!,
      equity: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}equity'])!,
      bonds: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}bonds'])!,
      deposits: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}deposits'])!,
      realEstate: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}real_estate'])!,
      otherAssets: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}other_assets'])!,
      assetNotes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}asset_notes']),
      loans: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}loans'])!,
      creditCardOutstanding: attachedDatabase.typeMapping.read(
          DriftSqlType.double,
          data['${effectivePrefix}credit_card_outstanding'])!,
      creditLineOutstanding: attachedDatabase.typeMapping.read(
          DriftSqlType.double,
          data['${effectivePrefix}credit_line_outstanding'])!,
      otherDebts: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}other_debts'])!,
      liabilityNotes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}liability_notes']),
      totalIncome: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}total_income'])!,
      totalExpense: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}total_expense'])!,
      budgetedIncome: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}budgeted_income'])!,
      budgetedExpense: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}budgeted_expense'])!,
      nonCalcIncome: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}non_calc_income'])!,
      nonCalcExpense: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}non_calc_expense'])!,
      outOfBucketExpense: attachedDatabase.typeMapping.read(DriftSqlType.double,
          data['${effectivePrefix}out_of_bucket_expense'])!,
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
  final double bankAccounts;
  final double cashInHand;
  final double mutualFunds;
  final double equity;
  final double bonds;
  final double deposits;
  final double realEstate;
  final double otherAssets;
  final String? assetNotes;
  final double loans;
  final double creditCardOutstanding;
  final double creditLineOutstanding;
  final double otherDebts;
  final String? liabilityNotes;
  final double totalIncome;
  final double totalExpense;
  final double budgetedIncome;
  final double budgetedExpense;
  final double nonCalcIncome;
  final double nonCalcExpense;
  final double outOfBucketExpense;
  const NetWorthSplit(
      {required this.id,
      required this.date,
      required this.bankAccounts,
      required this.cashInHand,
      required this.mutualFunds,
      required this.equity,
      required this.bonds,
      required this.deposits,
      required this.realEstate,
      required this.otherAssets,
      this.assetNotes,
      required this.loans,
      required this.creditCardOutstanding,
      required this.creditLineOutstanding,
      required this.otherDebts,
      this.liabilityNotes,
      required this.totalIncome,
      required this.totalExpense,
      required this.budgetedIncome,
      required this.budgetedExpense,
      required this.nonCalcIncome,
      required this.nonCalcExpense,
      required this.outOfBucketExpense});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['date'] = Variable<DateTime>(date);
    map['bank_accounts'] = Variable<double>(bankAccounts);
    map['cash_in_hand'] = Variable<double>(cashInHand);
    map['mutual_funds'] = Variable<double>(mutualFunds);
    map['equity'] = Variable<double>(equity);
    map['bonds'] = Variable<double>(bonds);
    map['deposits'] = Variable<double>(deposits);
    map['real_estate'] = Variable<double>(realEstate);
    map['other_assets'] = Variable<double>(otherAssets);
    if (!nullToAbsent || assetNotes != null) {
      map['asset_notes'] = Variable<String>(assetNotes);
    }
    map['loans'] = Variable<double>(loans);
    map['credit_card_outstanding'] = Variable<double>(creditCardOutstanding);
    map['credit_line_outstanding'] = Variable<double>(creditLineOutstanding);
    map['other_debts'] = Variable<double>(otherDebts);
    if (!nullToAbsent || liabilityNotes != null) {
      map['liability_notes'] = Variable<String>(liabilityNotes);
    }
    map['total_income'] = Variable<double>(totalIncome);
    map['total_expense'] = Variable<double>(totalExpense);
    map['budgeted_income'] = Variable<double>(budgetedIncome);
    map['budgeted_expense'] = Variable<double>(budgetedExpense);
    map['non_calc_income'] = Variable<double>(nonCalcIncome);
    map['non_calc_expense'] = Variable<double>(nonCalcExpense);
    map['out_of_bucket_expense'] = Variable<double>(outOfBucketExpense);
    return map;
  }

  NetWorthSplitsCompanion toCompanion(bool nullToAbsent) {
    return NetWorthSplitsCompanion(
      id: Value(id),
      date: Value(date),
      bankAccounts: Value(bankAccounts),
      cashInHand: Value(cashInHand),
      mutualFunds: Value(mutualFunds),
      equity: Value(equity),
      bonds: Value(bonds),
      deposits: Value(deposits),
      realEstate: Value(realEstate),
      otherAssets: Value(otherAssets),
      assetNotes: assetNotes == null && nullToAbsent
          ? const Value.absent()
          : Value(assetNotes),
      loans: Value(loans),
      creditCardOutstanding: Value(creditCardOutstanding),
      creditLineOutstanding: Value(creditLineOutstanding),
      otherDebts: Value(otherDebts),
      liabilityNotes: liabilityNotes == null && nullToAbsent
          ? const Value.absent()
          : Value(liabilityNotes),
      totalIncome: Value(totalIncome),
      totalExpense: Value(totalExpense),
      budgetedIncome: Value(budgetedIncome),
      budgetedExpense: Value(budgetedExpense),
      nonCalcIncome: Value(nonCalcIncome),
      nonCalcExpense: Value(nonCalcExpense),
      outOfBucketExpense: Value(outOfBucketExpense),
    );
  }

  factory NetWorthSplit.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NetWorthSplit(
      id: serializer.fromJson<String>(json['id']),
      date: serializer.fromJson<DateTime>(json['date']),
      bankAccounts: serializer.fromJson<double>(json['bankAccounts']),
      cashInHand: serializer.fromJson<double>(json['cashInHand']),
      mutualFunds: serializer.fromJson<double>(json['mutualFunds']),
      equity: serializer.fromJson<double>(json['equity']),
      bonds: serializer.fromJson<double>(json['bonds']),
      deposits: serializer.fromJson<double>(json['deposits']),
      realEstate: serializer.fromJson<double>(json['realEstate']),
      otherAssets: serializer.fromJson<double>(json['otherAssets']),
      assetNotes: serializer.fromJson<String?>(json['assetNotes']),
      loans: serializer.fromJson<double>(json['loans']),
      creditCardOutstanding:
          serializer.fromJson<double>(json['creditCardOutstanding']),
      creditLineOutstanding:
          serializer.fromJson<double>(json['creditLineOutstanding']),
      otherDebts: serializer.fromJson<double>(json['otherDebts']),
      liabilityNotes: serializer.fromJson<String?>(json['liabilityNotes']),
      totalIncome: serializer.fromJson<double>(json['totalIncome']),
      totalExpense: serializer.fromJson<double>(json['totalExpense']),
      budgetedIncome: serializer.fromJson<double>(json['budgetedIncome']),
      budgetedExpense: serializer.fromJson<double>(json['budgetedExpense']),
      nonCalcIncome: serializer.fromJson<double>(json['nonCalcIncome']),
      nonCalcExpense: serializer.fromJson<double>(json['nonCalcExpense']),
      outOfBucketExpense:
          serializer.fromJson<double>(json['outOfBucketExpense']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'date': serializer.toJson<DateTime>(date),
      'bankAccounts': serializer.toJson<double>(bankAccounts),
      'cashInHand': serializer.toJson<double>(cashInHand),
      'mutualFunds': serializer.toJson<double>(mutualFunds),
      'equity': serializer.toJson<double>(equity),
      'bonds': serializer.toJson<double>(bonds),
      'deposits': serializer.toJson<double>(deposits),
      'realEstate': serializer.toJson<double>(realEstate),
      'otherAssets': serializer.toJson<double>(otherAssets),
      'assetNotes': serializer.toJson<String?>(assetNotes),
      'loans': serializer.toJson<double>(loans),
      'creditCardOutstanding': serializer.toJson<double>(creditCardOutstanding),
      'creditLineOutstanding': serializer.toJson<double>(creditLineOutstanding),
      'otherDebts': serializer.toJson<double>(otherDebts),
      'liabilityNotes': serializer.toJson<String?>(liabilityNotes),
      'totalIncome': serializer.toJson<double>(totalIncome),
      'totalExpense': serializer.toJson<double>(totalExpense),
      'budgetedIncome': serializer.toJson<double>(budgetedIncome),
      'budgetedExpense': serializer.toJson<double>(budgetedExpense),
      'nonCalcIncome': serializer.toJson<double>(nonCalcIncome),
      'nonCalcExpense': serializer.toJson<double>(nonCalcExpense),
      'outOfBucketExpense': serializer.toJson<double>(outOfBucketExpense),
    };
  }

  NetWorthSplit copyWith(
          {String? id,
          DateTime? date,
          double? bankAccounts,
          double? cashInHand,
          double? mutualFunds,
          double? equity,
          double? bonds,
          double? deposits,
          double? realEstate,
          double? otherAssets,
          Value<String?> assetNotes = const Value.absent(),
          double? loans,
          double? creditCardOutstanding,
          double? creditLineOutstanding,
          double? otherDebts,
          Value<String?> liabilityNotes = const Value.absent(),
          double? totalIncome,
          double? totalExpense,
          double? budgetedIncome,
          double? budgetedExpense,
          double? nonCalcIncome,
          double? nonCalcExpense,
          double? outOfBucketExpense}) =>
      NetWorthSplit(
        id: id ?? this.id,
        date: date ?? this.date,
        bankAccounts: bankAccounts ?? this.bankAccounts,
        cashInHand: cashInHand ?? this.cashInHand,
        mutualFunds: mutualFunds ?? this.mutualFunds,
        equity: equity ?? this.equity,
        bonds: bonds ?? this.bonds,
        deposits: deposits ?? this.deposits,
        realEstate: realEstate ?? this.realEstate,
        otherAssets: otherAssets ?? this.otherAssets,
        assetNotes: assetNotes.present ? assetNotes.value : this.assetNotes,
        loans: loans ?? this.loans,
        creditCardOutstanding:
            creditCardOutstanding ?? this.creditCardOutstanding,
        creditLineOutstanding:
            creditLineOutstanding ?? this.creditLineOutstanding,
        otherDebts: otherDebts ?? this.otherDebts,
        liabilityNotes:
            liabilityNotes.present ? liabilityNotes.value : this.liabilityNotes,
        totalIncome: totalIncome ?? this.totalIncome,
        totalExpense: totalExpense ?? this.totalExpense,
        budgetedIncome: budgetedIncome ?? this.budgetedIncome,
        budgetedExpense: budgetedExpense ?? this.budgetedExpense,
        nonCalcIncome: nonCalcIncome ?? this.nonCalcIncome,
        nonCalcExpense: nonCalcExpense ?? this.nonCalcExpense,
        outOfBucketExpense: outOfBucketExpense ?? this.outOfBucketExpense,
      );
  NetWorthSplit copyWithCompanion(NetWorthSplitsCompanion data) {
    return NetWorthSplit(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      bankAccounts: data.bankAccounts.present
          ? data.bankAccounts.value
          : this.bankAccounts,
      cashInHand:
          data.cashInHand.present ? data.cashInHand.value : this.cashInHand,
      mutualFunds:
          data.mutualFunds.present ? data.mutualFunds.value : this.mutualFunds,
      equity: data.equity.present ? data.equity.value : this.equity,
      bonds: data.bonds.present ? data.bonds.value : this.bonds,
      deposits: data.deposits.present ? data.deposits.value : this.deposits,
      realEstate:
          data.realEstate.present ? data.realEstate.value : this.realEstate,
      otherAssets:
          data.otherAssets.present ? data.otherAssets.value : this.otherAssets,
      assetNotes:
          data.assetNotes.present ? data.assetNotes.value : this.assetNotes,
      loans: data.loans.present ? data.loans.value : this.loans,
      creditCardOutstanding: data.creditCardOutstanding.present
          ? data.creditCardOutstanding.value
          : this.creditCardOutstanding,
      creditLineOutstanding: data.creditLineOutstanding.present
          ? data.creditLineOutstanding.value
          : this.creditLineOutstanding,
      otherDebts:
          data.otherDebts.present ? data.otherDebts.value : this.otherDebts,
      liabilityNotes: data.liabilityNotes.present
          ? data.liabilityNotes.value
          : this.liabilityNotes,
      totalIncome:
          data.totalIncome.present ? data.totalIncome.value : this.totalIncome,
      totalExpense: data.totalExpense.present
          ? data.totalExpense.value
          : this.totalExpense,
      budgetedIncome: data.budgetedIncome.present
          ? data.budgetedIncome.value
          : this.budgetedIncome,
      budgetedExpense: data.budgetedExpense.present
          ? data.budgetedExpense.value
          : this.budgetedExpense,
      nonCalcIncome: data.nonCalcIncome.present
          ? data.nonCalcIncome.value
          : this.nonCalcIncome,
      nonCalcExpense: data.nonCalcExpense.present
          ? data.nonCalcExpense.value
          : this.nonCalcExpense,
      outOfBucketExpense: data.outOfBucketExpense.present
          ? data.outOfBucketExpense.value
          : this.outOfBucketExpense,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NetWorthSplit(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('bankAccounts: $bankAccounts, ')
          ..write('cashInHand: $cashInHand, ')
          ..write('mutualFunds: $mutualFunds, ')
          ..write('equity: $equity, ')
          ..write('bonds: $bonds, ')
          ..write('deposits: $deposits, ')
          ..write('realEstate: $realEstate, ')
          ..write('otherAssets: $otherAssets, ')
          ..write('assetNotes: $assetNotes, ')
          ..write('loans: $loans, ')
          ..write('creditCardOutstanding: $creditCardOutstanding, ')
          ..write('creditLineOutstanding: $creditLineOutstanding, ')
          ..write('otherDebts: $otherDebts, ')
          ..write('liabilityNotes: $liabilityNotes, ')
          ..write('totalIncome: $totalIncome, ')
          ..write('totalExpense: $totalExpense, ')
          ..write('budgetedIncome: $budgetedIncome, ')
          ..write('budgetedExpense: $budgetedExpense, ')
          ..write('nonCalcIncome: $nonCalcIncome, ')
          ..write('nonCalcExpense: $nonCalcExpense, ')
          ..write('outOfBucketExpense: $outOfBucketExpense')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        date,
        bankAccounts,
        cashInHand,
        mutualFunds,
        equity,
        bonds,
        deposits,
        realEstate,
        otherAssets,
        assetNotes,
        loans,
        creditCardOutstanding,
        creditLineOutstanding,
        otherDebts,
        liabilityNotes,
        totalIncome,
        totalExpense,
        budgetedIncome,
        budgetedExpense,
        nonCalcIncome,
        nonCalcExpense,
        outOfBucketExpense
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NetWorthSplit &&
          other.id == this.id &&
          other.date == this.date &&
          other.bankAccounts == this.bankAccounts &&
          other.cashInHand == this.cashInHand &&
          other.mutualFunds == this.mutualFunds &&
          other.equity == this.equity &&
          other.bonds == this.bonds &&
          other.deposits == this.deposits &&
          other.realEstate == this.realEstate &&
          other.otherAssets == this.otherAssets &&
          other.assetNotes == this.assetNotes &&
          other.loans == this.loans &&
          other.creditCardOutstanding == this.creditCardOutstanding &&
          other.creditLineOutstanding == this.creditLineOutstanding &&
          other.otherDebts == this.otherDebts &&
          other.liabilityNotes == this.liabilityNotes &&
          other.totalIncome == this.totalIncome &&
          other.totalExpense == this.totalExpense &&
          other.budgetedIncome == this.budgetedIncome &&
          other.budgetedExpense == this.budgetedExpense &&
          other.nonCalcIncome == this.nonCalcIncome &&
          other.nonCalcExpense == this.nonCalcExpense &&
          other.outOfBucketExpense == this.outOfBucketExpense);
}

class NetWorthSplitsCompanion extends UpdateCompanion<NetWorthSplit> {
  final Value<String> id;
  final Value<DateTime> date;
  final Value<double> bankAccounts;
  final Value<double> cashInHand;
  final Value<double> mutualFunds;
  final Value<double> equity;
  final Value<double> bonds;
  final Value<double> deposits;
  final Value<double> realEstate;
  final Value<double> otherAssets;
  final Value<String?> assetNotes;
  final Value<double> loans;
  final Value<double> creditCardOutstanding;
  final Value<double> creditLineOutstanding;
  final Value<double> otherDebts;
  final Value<String?> liabilityNotes;
  final Value<double> totalIncome;
  final Value<double> totalExpense;
  final Value<double> budgetedIncome;
  final Value<double> budgetedExpense;
  final Value<double> nonCalcIncome;
  final Value<double> nonCalcExpense;
  final Value<double> outOfBucketExpense;
  final Value<int> rowid;
  const NetWorthSplitsCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.bankAccounts = const Value.absent(),
    this.cashInHand = const Value.absent(),
    this.mutualFunds = const Value.absent(),
    this.equity = const Value.absent(),
    this.bonds = const Value.absent(),
    this.deposits = const Value.absent(),
    this.realEstate = const Value.absent(),
    this.otherAssets = const Value.absent(),
    this.assetNotes = const Value.absent(),
    this.loans = const Value.absent(),
    this.creditCardOutstanding = const Value.absent(),
    this.creditLineOutstanding = const Value.absent(),
    this.otherDebts = const Value.absent(),
    this.liabilityNotes = const Value.absent(),
    this.totalIncome = const Value.absent(),
    this.totalExpense = const Value.absent(),
    this.budgetedIncome = const Value.absent(),
    this.budgetedExpense = const Value.absent(),
    this.nonCalcIncome = const Value.absent(),
    this.nonCalcExpense = const Value.absent(),
    this.outOfBucketExpense = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NetWorthSplitsCompanion.insert({
    required String id,
    required DateTime date,
    this.bankAccounts = const Value.absent(),
    this.cashInHand = const Value.absent(),
    this.mutualFunds = const Value.absent(),
    this.equity = const Value.absent(),
    this.bonds = const Value.absent(),
    this.deposits = const Value.absent(),
    this.realEstate = const Value.absent(),
    this.otherAssets = const Value.absent(),
    this.assetNotes = const Value.absent(),
    this.loans = const Value.absent(),
    this.creditCardOutstanding = const Value.absent(),
    this.creditLineOutstanding = const Value.absent(),
    this.otherDebts = const Value.absent(),
    this.liabilityNotes = const Value.absent(),
    this.totalIncome = const Value.absent(),
    this.totalExpense = const Value.absent(),
    this.budgetedIncome = const Value.absent(),
    this.budgetedExpense = const Value.absent(),
    this.nonCalcIncome = const Value.absent(),
    this.nonCalcExpense = const Value.absent(),
    this.outOfBucketExpense = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        date = Value(date);
  static Insertable<NetWorthSplit> custom({
    Expression<String>? id,
    Expression<DateTime>? date,
    Expression<double>? bankAccounts,
    Expression<double>? cashInHand,
    Expression<double>? mutualFunds,
    Expression<double>? equity,
    Expression<double>? bonds,
    Expression<double>? deposits,
    Expression<double>? realEstate,
    Expression<double>? otherAssets,
    Expression<String>? assetNotes,
    Expression<double>? loans,
    Expression<double>? creditCardOutstanding,
    Expression<double>? creditLineOutstanding,
    Expression<double>? otherDebts,
    Expression<String>? liabilityNotes,
    Expression<double>? totalIncome,
    Expression<double>? totalExpense,
    Expression<double>? budgetedIncome,
    Expression<double>? budgetedExpense,
    Expression<double>? nonCalcIncome,
    Expression<double>? nonCalcExpense,
    Expression<double>? outOfBucketExpense,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (bankAccounts != null) 'bank_accounts': bankAccounts,
      if (cashInHand != null) 'cash_in_hand': cashInHand,
      if (mutualFunds != null) 'mutual_funds': mutualFunds,
      if (equity != null) 'equity': equity,
      if (bonds != null) 'bonds': bonds,
      if (deposits != null) 'deposits': deposits,
      if (realEstate != null) 'real_estate': realEstate,
      if (otherAssets != null) 'other_assets': otherAssets,
      if (assetNotes != null) 'asset_notes': assetNotes,
      if (loans != null) 'loans': loans,
      if (creditCardOutstanding != null)
        'credit_card_outstanding': creditCardOutstanding,
      if (creditLineOutstanding != null)
        'credit_line_outstanding': creditLineOutstanding,
      if (otherDebts != null) 'other_debts': otherDebts,
      if (liabilityNotes != null) 'liability_notes': liabilityNotes,
      if (totalIncome != null) 'total_income': totalIncome,
      if (totalExpense != null) 'total_expense': totalExpense,
      if (budgetedIncome != null) 'budgeted_income': budgetedIncome,
      if (budgetedExpense != null) 'budgeted_expense': budgetedExpense,
      if (nonCalcIncome != null) 'non_calc_income': nonCalcIncome,
      if (nonCalcExpense != null) 'non_calc_expense': nonCalcExpense,
      if (outOfBucketExpense != null)
        'out_of_bucket_expense': outOfBucketExpense,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NetWorthSplitsCompanion copyWith(
      {Value<String>? id,
      Value<DateTime>? date,
      Value<double>? bankAccounts,
      Value<double>? cashInHand,
      Value<double>? mutualFunds,
      Value<double>? equity,
      Value<double>? bonds,
      Value<double>? deposits,
      Value<double>? realEstate,
      Value<double>? otherAssets,
      Value<String?>? assetNotes,
      Value<double>? loans,
      Value<double>? creditCardOutstanding,
      Value<double>? creditLineOutstanding,
      Value<double>? otherDebts,
      Value<String?>? liabilityNotes,
      Value<double>? totalIncome,
      Value<double>? totalExpense,
      Value<double>? budgetedIncome,
      Value<double>? budgetedExpense,
      Value<double>? nonCalcIncome,
      Value<double>? nonCalcExpense,
      Value<double>? outOfBucketExpense,
      Value<int>? rowid}) {
    return NetWorthSplitsCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      bankAccounts: bankAccounts ?? this.bankAccounts,
      cashInHand: cashInHand ?? this.cashInHand,
      mutualFunds: mutualFunds ?? this.mutualFunds,
      equity: equity ?? this.equity,
      bonds: bonds ?? this.bonds,
      deposits: deposits ?? this.deposits,
      realEstate: realEstate ?? this.realEstate,
      otherAssets: otherAssets ?? this.otherAssets,
      assetNotes: assetNotes ?? this.assetNotes,
      loans: loans ?? this.loans,
      creditCardOutstanding:
          creditCardOutstanding ?? this.creditCardOutstanding,
      creditLineOutstanding:
          creditLineOutstanding ?? this.creditLineOutstanding,
      otherDebts: otherDebts ?? this.otherDebts,
      liabilityNotes: liabilityNotes ?? this.liabilityNotes,
      totalIncome: totalIncome ?? this.totalIncome,
      totalExpense: totalExpense ?? this.totalExpense,
      budgetedIncome: budgetedIncome ?? this.budgetedIncome,
      budgetedExpense: budgetedExpense ?? this.budgetedExpense,
      nonCalcIncome: nonCalcIncome ?? this.nonCalcIncome,
      nonCalcExpense: nonCalcExpense ?? this.nonCalcExpense,
      outOfBucketExpense: outOfBucketExpense ?? this.outOfBucketExpense,
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
    if (bankAccounts.present) {
      map['bank_accounts'] = Variable<double>(bankAccounts.value);
    }
    if (cashInHand.present) {
      map['cash_in_hand'] = Variable<double>(cashInHand.value);
    }
    if (mutualFunds.present) {
      map['mutual_funds'] = Variable<double>(mutualFunds.value);
    }
    if (equity.present) {
      map['equity'] = Variable<double>(equity.value);
    }
    if (bonds.present) {
      map['bonds'] = Variable<double>(bonds.value);
    }
    if (deposits.present) {
      map['deposits'] = Variable<double>(deposits.value);
    }
    if (realEstate.present) {
      map['real_estate'] = Variable<double>(realEstate.value);
    }
    if (otherAssets.present) {
      map['other_assets'] = Variable<double>(otherAssets.value);
    }
    if (assetNotes.present) {
      map['asset_notes'] = Variable<String>(assetNotes.value);
    }
    if (loans.present) {
      map['loans'] = Variable<double>(loans.value);
    }
    if (creditCardOutstanding.present) {
      map['credit_card_outstanding'] =
          Variable<double>(creditCardOutstanding.value);
    }
    if (creditLineOutstanding.present) {
      map['credit_line_outstanding'] =
          Variable<double>(creditLineOutstanding.value);
    }
    if (otherDebts.present) {
      map['other_debts'] = Variable<double>(otherDebts.value);
    }
    if (liabilityNotes.present) {
      map['liability_notes'] = Variable<String>(liabilityNotes.value);
    }
    if (totalIncome.present) {
      map['total_income'] = Variable<double>(totalIncome.value);
    }
    if (totalExpense.present) {
      map['total_expense'] = Variable<double>(totalExpense.value);
    }
    if (budgetedIncome.present) {
      map['budgeted_income'] = Variable<double>(budgetedIncome.value);
    }
    if (budgetedExpense.present) {
      map['budgeted_expense'] = Variable<double>(budgetedExpense.value);
    }
    if (nonCalcIncome.present) {
      map['non_calc_income'] = Variable<double>(nonCalcIncome.value);
    }
    if (nonCalcExpense.present) {
      map['non_calc_expense'] = Variable<double>(nonCalcExpense.value);
    }
    if (outOfBucketExpense.present) {
      map['out_of_bucket_expense'] = Variable<double>(outOfBucketExpense.value);
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
          ..write('bankAccounts: $bankAccounts, ')
          ..write('cashInHand: $cashInHand, ')
          ..write('mutualFunds: $mutualFunds, ')
          ..write('equity: $equity, ')
          ..write('bonds: $bonds, ')
          ..write('deposits: $deposits, ')
          ..write('realEstate: $realEstate, ')
          ..write('otherAssets: $otherAssets, ')
          ..write('assetNotes: $assetNotes, ')
          ..write('loans: $loans, ')
          ..write('creditCardOutstanding: $creditCardOutstanding, ')
          ..write('creditLineOutstanding: $creditLineOutstanding, ')
          ..write('otherDebts: $otherDebts, ')
          ..write('liabilityNotes: $liabilityNotes, ')
          ..write('totalIncome: $totalIncome, ')
          ..write('totalExpense: $totalExpense, ')
          ..write('budgetedIncome: $budgetedIncome, ')
          ..write('budgetedExpense: $budgetedExpense, ')
          ..write('nonCalcIncome: $nonCalcIncome, ')
          ..write('nonCalcExpense: $nonCalcExpense, ')
          ..write('outOfBucketExpense: $outOfBucketExpense, ')
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

class $AssetLogsTable extends AssetLogs
    with TableInfo<$AssetLogsTable, AssetLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AssetLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _parentIdMeta =
      const VerificationMeta('parentId');
  @override
  late final GeneratedColumn<String> parentId = GeneratedColumn<String>(
      'parent_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
      'amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _interestComponentMeta =
      const VerificationMeta('interestComponent');
  @override
  late final GeneratedColumn<double> interestComponent =
      GeneratedColumn<double>('interest_component', aliasedName, false,
          type: DriftSqlType.double,
          requiredDuringInsert: false,
          defaultValue: const Constant(0.0));
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, parentId, type, amount, interestComponent, date, notes];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'asset_logs';
  @override
  VerificationContext validateIntegrity(Insertable<AssetLog> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('parent_id')) {
      context.handle(_parentIdMeta,
          parentId.isAcceptableOrUnknown(data['parent_id']!, _parentIdMeta));
    } else if (isInserting) {
      context.missing(_parentIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('interest_component')) {
      context.handle(
          _interestComponentMeta,
          interestComponent.isAcceptableOrUnknown(
              data['interest_component']!, _interestComponentMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AssetLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AssetLog(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      parentId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}parent_id'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}amount'])!,
      interestComponent: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}interest_component'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
    );
  }

  @override
  $AssetLogsTable createAlias(String alias) {
    return $AssetLogsTable(attachedDatabase, alias);
  }
}

class AssetLog extends DataClass implements Insertable<AssetLog> {
  final String id;
  final String parentId;
  final String type;
  final double amount;
  final double interestComponent;
  final DateTime date;
  final String? notes;
  const AssetLog(
      {required this.id,
      required this.parentId,
      required this.type,
      required this.amount,
      required this.interestComponent,
      required this.date,
      this.notes});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['parent_id'] = Variable<String>(parentId);
    map['type'] = Variable<String>(type);
    map['amount'] = Variable<double>(amount);
    map['interest_component'] = Variable<double>(interestComponent);
    map['date'] = Variable<DateTime>(date);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  AssetLogsCompanion toCompanion(bool nullToAbsent) {
    return AssetLogsCompanion(
      id: Value(id),
      parentId: Value(parentId),
      type: Value(type),
      amount: Value(amount),
      interestComponent: Value(interestComponent),
      date: Value(date),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
    );
  }

  factory AssetLog.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AssetLog(
      id: serializer.fromJson<String>(json['id']),
      parentId: serializer.fromJson<String>(json['parentId']),
      type: serializer.fromJson<String>(json['type']),
      amount: serializer.fromJson<double>(json['amount']),
      interestComponent: serializer.fromJson<double>(json['interestComponent']),
      date: serializer.fromJson<DateTime>(json['date']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'parentId': serializer.toJson<String>(parentId),
      'type': serializer.toJson<String>(type),
      'amount': serializer.toJson<double>(amount),
      'interestComponent': serializer.toJson<double>(interestComponent),
      'date': serializer.toJson<DateTime>(date),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  AssetLog copyWith(
          {String? id,
          String? parentId,
          String? type,
          double? amount,
          double? interestComponent,
          DateTime? date,
          Value<String?> notes = const Value.absent()}) =>
      AssetLog(
        id: id ?? this.id,
        parentId: parentId ?? this.parentId,
        type: type ?? this.type,
        amount: amount ?? this.amount,
        interestComponent: interestComponent ?? this.interestComponent,
        date: date ?? this.date,
        notes: notes.present ? notes.value : this.notes,
      );
  AssetLog copyWithCompanion(AssetLogsCompanion data) {
    return AssetLog(
      id: data.id.present ? data.id.value : this.id,
      parentId: data.parentId.present ? data.parentId.value : this.parentId,
      type: data.type.present ? data.type.value : this.type,
      amount: data.amount.present ? data.amount.value : this.amount,
      interestComponent: data.interestComponent.present
          ? data.interestComponent.value
          : this.interestComponent,
      date: data.date.present ? data.date.value : this.date,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AssetLog(')
          ..write('id: $id, ')
          ..write('parentId: $parentId, ')
          ..write('type: $type, ')
          ..write('amount: $amount, ')
          ..write('interestComponent: $interestComponent, ')
          ..write('date: $date, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, parentId, type, amount, interestComponent, date, notes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AssetLog &&
          other.id == this.id &&
          other.parentId == this.parentId &&
          other.type == this.type &&
          other.amount == this.amount &&
          other.interestComponent == this.interestComponent &&
          other.date == this.date &&
          other.notes == this.notes);
}

class AssetLogsCompanion extends UpdateCompanion<AssetLog> {
  final Value<String> id;
  final Value<String> parentId;
  final Value<String> type;
  final Value<double> amount;
  final Value<double> interestComponent;
  final Value<DateTime> date;
  final Value<String?> notes;
  final Value<int> rowid;
  const AssetLogsCompanion({
    this.id = const Value.absent(),
    this.parentId = const Value.absent(),
    this.type = const Value.absent(),
    this.amount = const Value.absent(),
    this.interestComponent = const Value.absent(),
    this.date = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AssetLogsCompanion.insert({
    required String id,
    required String parentId,
    required String type,
    required double amount,
    this.interestComponent = const Value.absent(),
    required DateTime date,
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        parentId = Value(parentId),
        type = Value(type),
        amount = Value(amount),
        date = Value(date);
  static Insertable<AssetLog> custom({
    Expression<String>? id,
    Expression<String>? parentId,
    Expression<String>? type,
    Expression<double>? amount,
    Expression<double>? interestComponent,
    Expression<DateTime>? date,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (parentId != null) 'parent_id': parentId,
      if (type != null) 'type': type,
      if (amount != null) 'amount': amount,
      if (interestComponent != null) 'interest_component': interestComponent,
      if (date != null) 'date': date,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AssetLogsCompanion copyWith(
      {Value<String>? id,
      Value<String>? parentId,
      Value<String>? type,
      Value<double>? amount,
      Value<double>? interestComponent,
      Value<DateTime>? date,
      Value<String?>? notes,
      Value<int>? rowid}) {
    return AssetLogsCompanion(
      id: id ?? this.id,
      parentId: parentId ?? this.parentId,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      interestComponent: interestComponent ?? this.interestComponent,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (parentId.present) {
      map['parent_id'] = Variable<String>(parentId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (interestComponent.present) {
      map['interest_component'] = Variable<double>(interestComponent.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AssetLogsCompanion(')
          ..write('id: $id, ')
          ..write('parentId: $parentId, ')
          ..write('type: $type, ')
          ..write('amount: $amount, ')
          ..write('interestComponent: $interestComponent, ')
          ..write('date: $date, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LoansTable extends Loans with TableInfo<$LoansTable, Loan> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LoansTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _providerMeta =
      const VerificationMeta('provider');
  @override
  late final GeneratedColumn<String> provider = GeneratedColumn<String>(
      'provider', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _principalAmountMeta =
      const VerificationMeta('principalAmount');
  @override
  late final GeneratedColumn<double> principalAmount = GeneratedColumn<double>(
      'principal_amount', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _totalAmountMeta =
      const VerificationMeta('totalAmount');
  @override
  late final GeneratedColumn<double> totalAmount = GeneratedColumn<double>(
      'total_amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _paidAmountMeta =
      const VerificationMeta('paidAmount');
  @override
  late final GeneratedColumn<double> paidAmount = GeneratedColumn<double>(
      'paid_amount', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _interestRateMeta =
      const VerificationMeta('interestRate');
  @override
  late final GeneratedColumn<double> interestRate = GeneratedColumn<double>(
      'interest_rate', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _emiAmountMeta =
      const VerificationMeta('emiAmount');
  @override
  late final GeneratedColumn<double> emiAmount = GeneratedColumn<double>(
      'emi_amount', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _startDateMeta =
      const VerificationMeta('startDate');
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
      'start_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _dueDateMeta =
      const VerificationMeta('dueDate');
  @override
  late final GeneratedColumn<DateTime> dueDate = GeneratedColumn<DateTime>(
      'due_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _nextPaymentDateMeta =
      const VerificationMeta('nextPaymentDate');
  @override
  late final GeneratedColumn<DateTime> nextPaymentDate =
      GeneratedColumn<DateTime>('next_payment_date', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isClosedMeta =
      const VerificationMeta('isClosed');
  @override
  late final GeneratedColumn<bool> isClosed = GeneratedColumn<bool>(
      'is_closed', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_closed" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        title,
        provider,
        type,
        principalAmount,
        totalAmount,
        paidAmount,
        interestRate,
        emiAmount,
        startDate,
        dueDate,
        nextPaymentDate,
        notes,
        isClosed
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'loans';
  @override
  VerificationContext validateIntegrity(Insertable<Loan> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('provider')) {
      context.handle(_providerMeta,
          provider.isAcceptableOrUnknown(data['provider']!, _providerMeta));
    } else if (isInserting) {
      context.missing(_providerMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('principal_amount')) {
      context.handle(
          _principalAmountMeta,
          principalAmount.isAcceptableOrUnknown(
              data['principal_amount']!, _principalAmountMeta));
    }
    if (data.containsKey('total_amount')) {
      context.handle(
          _totalAmountMeta,
          totalAmount.isAcceptableOrUnknown(
              data['total_amount']!, _totalAmountMeta));
    } else if (isInserting) {
      context.missing(_totalAmountMeta);
    }
    if (data.containsKey('paid_amount')) {
      context.handle(
          _paidAmountMeta,
          paidAmount.isAcceptableOrUnknown(
              data['paid_amount']!, _paidAmountMeta));
    }
    if (data.containsKey('interest_rate')) {
      context.handle(
          _interestRateMeta,
          interestRate.isAcceptableOrUnknown(
              data['interest_rate']!, _interestRateMeta));
    }
    if (data.containsKey('emi_amount')) {
      context.handle(_emiAmountMeta,
          emiAmount.isAcceptableOrUnknown(data['emi_amount']!, _emiAmountMeta));
    }
    if (data.containsKey('start_date')) {
      context.handle(_startDateMeta,
          startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta));
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('due_date')) {
      context.handle(_dueDateMeta,
          dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta));
    }
    if (data.containsKey('next_payment_date')) {
      context.handle(
          _nextPaymentDateMeta,
          nextPaymentDate.isAcceptableOrUnknown(
              data['next_payment_date']!, _nextPaymentDateMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('is_closed')) {
      context.handle(_isClosedMeta,
          isClosed.isAcceptableOrUnknown(data['is_closed']!, _isClosedMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Loan map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Loan(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      provider: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}provider'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      principalAmount: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}principal_amount'])!,
      totalAmount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}total_amount'])!,
      paidAmount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}paid_amount'])!,
      interestRate: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}interest_rate'])!,
      emiAmount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}emi_amount']),
      startDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}start_date'])!,
      dueDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}due_date']),
      nextPaymentDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}next_payment_date']),
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      isClosed: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_closed'])!,
    );
  }

  @override
  $LoansTable createAlias(String alias) {
    return $LoansTable(attachedDatabase, alias);
  }
}

class Loan extends DataClass implements Insertable<Loan> {
  final String id;
  final String title;
  final String provider;
  final String type;
  final double principalAmount;
  final double totalAmount;
  final double paidAmount;
  final double interestRate;
  final double? emiAmount;
  final DateTime startDate;
  final DateTime? dueDate;
  final DateTime? nextPaymentDate;
  final String? notes;
  final bool isClosed;
  const Loan(
      {required this.id,
      required this.title,
      required this.provider,
      required this.type,
      required this.principalAmount,
      required this.totalAmount,
      required this.paidAmount,
      required this.interestRate,
      this.emiAmount,
      required this.startDate,
      this.dueDate,
      this.nextPaymentDate,
      this.notes,
      required this.isClosed});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['provider'] = Variable<String>(provider);
    map['type'] = Variable<String>(type);
    map['principal_amount'] = Variable<double>(principalAmount);
    map['total_amount'] = Variable<double>(totalAmount);
    map['paid_amount'] = Variable<double>(paidAmount);
    map['interest_rate'] = Variable<double>(interestRate);
    if (!nullToAbsent || emiAmount != null) {
      map['emi_amount'] = Variable<double>(emiAmount);
    }
    map['start_date'] = Variable<DateTime>(startDate);
    if (!nullToAbsent || dueDate != null) {
      map['due_date'] = Variable<DateTime>(dueDate);
    }
    if (!nullToAbsent || nextPaymentDate != null) {
      map['next_payment_date'] = Variable<DateTime>(nextPaymentDate);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['is_closed'] = Variable<bool>(isClosed);
    return map;
  }

  LoansCompanion toCompanion(bool nullToAbsent) {
    return LoansCompanion(
      id: Value(id),
      title: Value(title),
      provider: Value(provider),
      type: Value(type),
      principalAmount: Value(principalAmount),
      totalAmount: Value(totalAmount),
      paidAmount: Value(paidAmount),
      interestRate: Value(interestRate),
      emiAmount: emiAmount == null && nullToAbsent
          ? const Value.absent()
          : Value(emiAmount),
      startDate: Value(startDate),
      dueDate: dueDate == null && nullToAbsent
          ? const Value.absent()
          : Value(dueDate),
      nextPaymentDate: nextPaymentDate == null && nullToAbsent
          ? const Value.absent()
          : Value(nextPaymentDate),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      isClosed: Value(isClosed),
    );
  }

  factory Loan.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Loan(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      provider: serializer.fromJson<String>(json['provider']),
      type: serializer.fromJson<String>(json['type']),
      principalAmount: serializer.fromJson<double>(json['principalAmount']),
      totalAmount: serializer.fromJson<double>(json['totalAmount']),
      paidAmount: serializer.fromJson<double>(json['paidAmount']),
      interestRate: serializer.fromJson<double>(json['interestRate']),
      emiAmount: serializer.fromJson<double?>(json['emiAmount']),
      startDate: serializer.fromJson<DateTime>(json['startDate']),
      dueDate: serializer.fromJson<DateTime?>(json['dueDate']),
      nextPaymentDate: serializer.fromJson<DateTime?>(json['nextPaymentDate']),
      notes: serializer.fromJson<String?>(json['notes']),
      isClosed: serializer.fromJson<bool>(json['isClosed']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'provider': serializer.toJson<String>(provider),
      'type': serializer.toJson<String>(type),
      'principalAmount': serializer.toJson<double>(principalAmount),
      'totalAmount': serializer.toJson<double>(totalAmount),
      'paidAmount': serializer.toJson<double>(paidAmount),
      'interestRate': serializer.toJson<double>(interestRate),
      'emiAmount': serializer.toJson<double?>(emiAmount),
      'startDate': serializer.toJson<DateTime>(startDate),
      'dueDate': serializer.toJson<DateTime?>(dueDate),
      'nextPaymentDate': serializer.toJson<DateTime?>(nextPaymentDate),
      'notes': serializer.toJson<String?>(notes),
      'isClosed': serializer.toJson<bool>(isClosed),
    };
  }

  Loan copyWith(
          {String? id,
          String? title,
          String? provider,
          String? type,
          double? principalAmount,
          double? totalAmount,
          double? paidAmount,
          double? interestRate,
          Value<double?> emiAmount = const Value.absent(),
          DateTime? startDate,
          Value<DateTime?> dueDate = const Value.absent(),
          Value<DateTime?> nextPaymentDate = const Value.absent(),
          Value<String?> notes = const Value.absent(),
          bool? isClosed}) =>
      Loan(
        id: id ?? this.id,
        title: title ?? this.title,
        provider: provider ?? this.provider,
        type: type ?? this.type,
        principalAmount: principalAmount ?? this.principalAmount,
        totalAmount: totalAmount ?? this.totalAmount,
        paidAmount: paidAmount ?? this.paidAmount,
        interestRate: interestRate ?? this.interestRate,
        emiAmount: emiAmount.present ? emiAmount.value : this.emiAmount,
        startDate: startDate ?? this.startDate,
        dueDate: dueDate.present ? dueDate.value : this.dueDate,
        nextPaymentDate: nextPaymentDate.present
            ? nextPaymentDate.value
            : this.nextPaymentDate,
        notes: notes.present ? notes.value : this.notes,
        isClosed: isClosed ?? this.isClosed,
      );
  Loan copyWithCompanion(LoansCompanion data) {
    return Loan(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      provider: data.provider.present ? data.provider.value : this.provider,
      type: data.type.present ? data.type.value : this.type,
      principalAmount: data.principalAmount.present
          ? data.principalAmount.value
          : this.principalAmount,
      totalAmount:
          data.totalAmount.present ? data.totalAmount.value : this.totalAmount,
      paidAmount:
          data.paidAmount.present ? data.paidAmount.value : this.paidAmount,
      interestRate: data.interestRate.present
          ? data.interestRate.value
          : this.interestRate,
      emiAmount: data.emiAmount.present ? data.emiAmount.value : this.emiAmount,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      nextPaymentDate: data.nextPaymentDate.present
          ? data.nextPaymentDate.value
          : this.nextPaymentDate,
      notes: data.notes.present ? data.notes.value : this.notes,
      isClosed: data.isClosed.present ? data.isClosed.value : this.isClosed,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Loan(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('provider: $provider, ')
          ..write('type: $type, ')
          ..write('principalAmount: $principalAmount, ')
          ..write('totalAmount: $totalAmount, ')
          ..write('paidAmount: $paidAmount, ')
          ..write('interestRate: $interestRate, ')
          ..write('emiAmount: $emiAmount, ')
          ..write('startDate: $startDate, ')
          ..write('dueDate: $dueDate, ')
          ..write('nextPaymentDate: $nextPaymentDate, ')
          ..write('notes: $notes, ')
          ..write('isClosed: $isClosed')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      title,
      provider,
      type,
      principalAmount,
      totalAmount,
      paidAmount,
      interestRate,
      emiAmount,
      startDate,
      dueDate,
      nextPaymentDate,
      notes,
      isClosed);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Loan &&
          other.id == this.id &&
          other.title == this.title &&
          other.provider == this.provider &&
          other.type == this.type &&
          other.principalAmount == this.principalAmount &&
          other.totalAmount == this.totalAmount &&
          other.paidAmount == this.paidAmount &&
          other.interestRate == this.interestRate &&
          other.emiAmount == this.emiAmount &&
          other.startDate == this.startDate &&
          other.dueDate == this.dueDate &&
          other.nextPaymentDate == this.nextPaymentDate &&
          other.notes == this.notes &&
          other.isClosed == this.isClosed);
}

class LoansCompanion extends UpdateCompanion<Loan> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> provider;
  final Value<String> type;
  final Value<double> principalAmount;
  final Value<double> totalAmount;
  final Value<double> paidAmount;
  final Value<double> interestRate;
  final Value<double?> emiAmount;
  final Value<DateTime> startDate;
  final Value<DateTime?> dueDate;
  final Value<DateTime?> nextPaymentDate;
  final Value<String?> notes;
  final Value<bool> isClosed;
  final Value<int> rowid;
  const LoansCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.provider = const Value.absent(),
    this.type = const Value.absent(),
    this.principalAmount = const Value.absent(),
    this.totalAmount = const Value.absent(),
    this.paidAmount = const Value.absent(),
    this.interestRate = const Value.absent(),
    this.emiAmount = const Value.absent(),
    this.startDate = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.nextPaymentDate = const Value.absent(),
    this.notes = const Value.absent(),
    this.isClosed = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LoansCompanion.insert({
    required String id,
    required String title,
    required String provider,
    required String type,
    this.principalAmount = const Value.absent(),
    required double totalAmount,
    this.paidAmount = const Value.absent(),
    this.interestRate = const Value.absent(),
    this.emiAmount = const Value.absent(),
    required DateTime startDate,
    this.dueDate = const Value.absent(),
    this.nextPaymentDate = const Value.absent(),
    this.notes = const Value.absent(),
    this.isClosed = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        title = Value(title),
        provider = Value(provider),
        type = Value(type),
        totalAmount = Value(totalAmount),
        startDate = Value(startDate);
  static Insertable<Loan> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? provider,
    Expression<String>? type,
    Expression<double>? principalAmount,
    Expression<double>? totalAmount,
    Expression<double>? paidAmount,
    Expression<double>? interestRate,
    Expression<double>? emiAmount,
    Expression<DateTime>? startDate,
    Expression<DateTime>? dueDate,
    Expression<DateTime>? nextPaymentDate,
    Expression<String>? notes,
    Expression<bool>? isClosed,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (provider != null) 'provider': provider,
      if (type != null) 'type': type,
      if (principalAmount != null) 'principal_amount': principalAmount,
      if (totalAmount != null) 'total_amount': totalAmount,
      if (paidAmount != null) 'paid_amount': paidAmount,
      if (interestRate != null) 'interest_rate': interestRate,
      if (emiAmount != null) 'emi_amount': emiAmount,
      if (startDate != null) 'start_date': startDate,
      if (dueDate != null) 'due_date': dueDate,
      if (nextPaymentDate != null) 'next_payment_date': nextPaymentDate,
      if (notes != null) 'notes': notes,
      if (isClosed != null) 'is_closed': isClosed,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LoansCompanion copyWith(
      {Value<String>? id,
      Value<String>? title,
      Value<String>? provider,
      Value<String>? type,
      Value<double>? principalAmount,
      Value<double>? totalAmount,
      Value<double>? paidAmount,
      Value<double>? interestRate,
      Value<double?>? emiAmount,
      Value<DateTime>? startDate,
      Value<DateTime?>? dueDate,
      Value<DateTime?>? nextPaymentDate,
      Value<String?>? notes,
      Value<bool>? isClosed,
      Value<int>? rowid}) {
    return LoansCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      provider: provider ?? this.provider,
      type: type ?? this.type,
      principalAmount: principalAmount ?? this.principalAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      paidAmount: paidAmount ?? this.paidAmount,
      interestRate: interestRate ?? this.interestRate,
      emiAmount: emiAmount ?? this.emiAmount,
      startDate: startDate ?? this.startDate,
      dueDate: dueDate ?? this.dueDate,
      nextPaymentDate: nextPaymentDate ?? this.nextPaymentDate,
      notes: notes ?? this.notes,
      isClosed: isClosed ?? this.isClosed,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (provider.present) {
      map['provider'] = Variable<String>(provider.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (principalAmount.present) {
      map['principal_amount'] = Variable<double>(principalAmount.value);
    }
    if (totalAmount.present) {
      map['total_amount'] = Variable<double>(totalAmount.value);
    }
    if (paidAmount.present) {
      map['paid_amount'] = Variable<double>(paidAmount.value);
    }
    if (interestRate.present) {
      map['interest_rate'] = Variable<double>(interestRate.value);
    }
    if (emiAmount.present) {
      map['emi_amount'] = Variable<double>(emiAmount.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<DateTime>(dueDate.value);
    }
    if (nextPaymentDate.present) {
      map['next_payment_date'] = Variable<DateTime>(nextPaymentDate.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (isClosed.present) {
      map['is_closed'] = Variable<bool>(isClosed.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LoansCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('provider: $provider, ')
          ..write('type: $type, ')
          ..write('principalAmount: $principalAmount, ')
          ..write('totalAmount: $totalAmount, ')
          ..write('paidAmount: $paidAmount, ')
          ..write('interestRate: $interestRate, ')
          ..write('emiAmount: $emiAmount, ')
          ..write('startDate: $startDate, ')
          ..write('dueDate: $dueDate, ')
          ..write('nextPaymentDate: $nextPaymentDate, ')
          ..write('notes: $notes, ')
          ..write('isClosed: $isClosed, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GoalsTable extends Goals with TableInfo<$GoalsTable, Goal> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GoalsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _purposeMeta =
      const VerificationMeta('purpose');
  @override
  late final GeneratedColumn<String> purpose = GeneratedColumn<String>(
      'purpose', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _investmentTypeMeta =
      const VerificationMeta('investmentType');
  @override
  late final GeneratedColumn<String> investmentType = GeneratedColumn<String>(
      'investment_type', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('Others'));
  static const VerificationMeta _identificationNumberMeta =
      const VerificationMeta('identificationNumber');
  @override
  late final GeneratedColumn<String> identificationNumber =
      GeneratedColumn<String>('identification_number', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _currentAmountMeta =
      const VerificationMeta('currentAmount');
  @override
  late final GeneratedColumn<double> currentAmount = GeneratedColumn<double>(
      'current_amount', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _targetAmountMeta =
      const VerificationMeta('targetAmount');
  @override
  late final GeneratedColumn<double> targetAmount = GeneratedColumn<double>(
      'target_amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _startDateMeta =
      const VerificationMeta('startDate');
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
      'start_date', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDate);
  static const VerificationMeta _deadlineMeta =
      const VerificationMeta('deadline');
  @override
  late final GeneratedColumn<DateTime> deadline = GeneratedColumn<DateTime>(
      'deadline', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _expectedReturnMeta =
      const VerificationMeta('expectedReturn');
  @override
  late final GeneratedColumn<double> expectedReturn = GeneratedColumn<double>(
      'expected_return', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<int> color = GeneratedColumn<int>(
      'color', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
      'icon', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isCompletedMeta =
      const VerificationMeta('isCompleted');
  @override
  late final GeneratedColumn<bool> isCompleted = GeneratedColumn<bool>(
      'is_completed', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_completed" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _priorityMeta =
      const VerificationMeta('priority');
  @override
  late final GeneratedColumn<String> priority = GeneratedColumn<String>(
      'priority', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('Medium'));
  static const VerificationMeta _monthlyContributionTargetMeta =
      const VerificationMeta('monthlyContributionTarget');
  @override
  late final GeneratedColumn<double> monthlyContributionTarget =
      GeneratedColumn<double>('monthly_contribution_target', aliasedName, true,
          type: DriftSqlType.double, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        purpose,
        investmentType,
        identificationNumber,
        currentAmount,
        targetAmount,
        startDate,
        deadline,
        expectedReturn,
        color,
        icon,
        isCompleted,
        createdAt,
        category,
        priority,
        monthlyContributionTarget
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'goals';
  @override
  VerificationContext validateIntegrity(Insertable<Goal> instance,
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
    if (data.containsKey('purpose')) {
      context.handle(_purposeMeta,
          purpose.isAcceptableOrUnknown(data['purpose']!, _purposeMeta));
    }
    if (data.containsKey('investment_type')) {
      context.handle(
          _investmentTypeMeta,
          investmentType.isAcceptableOrUnknown(
              data['investment_type']!, _investmentTypeMeta));
    }
    if (data.containsKey('identification_number')) {
      context.handle(
          _identificationNumberMeta,
          identificationNumber.isAcceptableOrUnknown(
              data['identification_number']!, _identificationNumberMeta));
    }
    if (data.containsKey('current_amount')) {
      context.handle(
          _currentAmountMeta,
          currentAmount.isAcceptableOrUnknown(
              data['current_amount']!, _currentAmountMeta));
    }
    if (data.containsKey('target_amount')) {
      context.handle(
          _targetAmountMeta,
          targetAmount.isAcceptableOrUnknown(
              data['target_amount']!, _targetAmountMeta));
    } else if (isInserting) {
      context.missing(_targetAmountMeta);
    }
    if (data.containsKey('start_date')) {
      context.handle(_startDateMeta,
          startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta));
    }
    if (data.containsKey('deadline')) {
      context.handle(_deadlineMeta,
          deadline.isAcceptableOrUnknown(data['deadline']!, _deadlineMeta));
    }
    if (data.containsKey('expected_return')) {
      context.handle(
          _expectedReturnMeta,
          expectedReturn.isAcceptableOrUnknown(
              data['expected_return']!, _expectedReturnMeta));
    }
    if (data.containsKey('color')) {
      context.handle(
          _colorMeta, color.isAcceptableOrUnknown(data['color']!, _colorMeta));
    } else if (isInserting) {
      context.missing(_colorMeta);
    }
    if (data.containsKey('icon')) {
      context.handle(
          _iconMeta, icon.isAcceptableOrUnknown(data['icon']!, _iconMeta));
    }
    if (data.containsKey('is_completed')) {
      context.handle(
          _isCompletedMeta,
          isCompleted.isAcceptableOrUnknown(
              data['is_completed']!, _isCompletedMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    }
    if (data.containsKey('priority')) {
      context.handle(_priorityMeta,
          priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta));
    }
    if (data.containsKey('monthly_contribution_target')) {
      context.handle(
          _monthlyContributionTargetMeta,
          monthlyContributionTarget.isAcceptableOrUnknown(
              data['monthly_contribution_target']!,
              _monthlyContributionTargetMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Goal map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Goal(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      purpose: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}purpose']),
      investmentType: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}investment_type'])!,
      identificationNumber: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}identification_number']),
      currentAmount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}current_amount'])!,
      targetAmount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}target_amount'])!,
      startDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}start_date'])!,
      deadline: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deadline']),
      expectedReturn: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}expected_return']),
      color: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}color'])!,
      icon: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}icon']),
      isCompleted: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_completed'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category']),
      priority: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}priority'])!,
      monthlyContributionTarget: attachedDatabase.typeMapping.read(
          DriftSqlType.double,
          data['${effectivePrefix}monthly_contribution_target']),
    );
  }

  @override
  $GoalsTable createAlias(String alias) {
    return $GoalsTable(attachedDatabase, alias);
  }
}

class Goal extends DataClass implements Insertable<Goal> {
  final String id;
  final String name;
  final String? purpose;
  final String investmentType;
  final String? identificationNumber;
  final double currentAmount;
  final double targetAmount;
  final DateTime startDate;
  final DateTime? deadline;
  final double? expectedReturn;
  final int color;
  final String? icon;
  final bool isCompleted;
  final DateTime createdAt;
  final String? category;
  final String priority;
  final double? monthlyContributionTarget;
  const Goal(
      {required this.id,
      required this.name,
      this.purpose,
      required this.investmentType,
      this.identificationNumber,
      required this.currentAmount,
      required this.targetAmount,
      required this.startDate,
      this.deadline,
      this.expectedReturn,
      required this.color,
      this.icon,
      required this.isCompleted,
      required this.createdAt,
      this.category,
      required this.priority,
      this.monthlyContributionTarget});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || purpose != null) {
      map['purpose'] = Variable<String>(purpose);
    }
    map['investment_type'] = Variable<String>(investmentType);
    if (!nullToAbsent || identificationNumber != null) {
      map['identification_number'] = Variable<String>(identificationNumber);
    }
    map['current_amount'] = Variable<double>(currentAmount);
    map['target_amount'] = Variable<double>(targetAmount);
    map['start_date'] = Variable<DateTime>(startDate);
    if (!nullToAbsent || deadline != null) {
      map['deadline'] = Variable<DateTime>(deadline);
    }
    if (!nullToAbsent || expectedReturn != null) {
      map['expected_return'] = Variable<double>(expectedReturn);
    }
    map['color'] = Variable<int>(color);
    if (!nullToAbsent || icon != null) {
      map['icon'] = Variable<String>(icon);
    }
    map['is_completed'] = Variable<bool>(isCompleted);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<String>(category);
    }
    map['priority'] = Variable<String>(priority);
    if (!nullToAbsent || monthlyContributionTarget != null) {
      map['monthly_contribution_target'] =
          Variable<double>(monthlyContributionTarget);
    }
    return map;
  }

  GoalsCompanion toCompanion(bool nullToAbsent) {
    return GoalsCompanion(
      id: Value(id),
      name: Value(name),
      purpose: purpose == null && nullToAbsent
          ? const Value.absent()
          : Value(purpose),
      investmentType: Value(investmentType),
      identificationNumber: identificationNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(identificationNumber),
      currentAmount: Value(currentAmount),
      targetAmount: Value(targetAmount),
      startDate: Value(startDate),
      deadline: deadline == null && nullToAbsent
          ? const Value.absent()
          : Value(deadline),
      expectedReturn: expectedReturn == null && nullToAbsent
          ? const Value.absent()
          : Value(expectedReturn),
      color: Value(color),
      icon: icon == null && nullToAbsent ? const Value.absent() : Value(icon),
      isCompleted: Value(isCompleted),
      createdAt: Value(createdAt),
      category: category == null && nullToAbsent
          ? const Value.absent()
          : Value(category),
      priority: Value(priority),
      monthlyContributionTarget:
          monthlyContributionTarget == null && nullToAbsent
              ? const Value.absent()
              : Value(monthlyContributionTarget),
    );
  }

  factory Goal.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Goal(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      purpose: serializer.fromJson<String?>(json['purpose']),
      investmentType: serializer.fromJson<String>(json['investmentType']),
      identificationNumber:
          serializer.fromJson<String?>(json['identificationNumber']),
      currentAmount: serializer.fromJson<double>(json['currentAmount']),
      targetAmount: serializer.fromJson<double>(json['targetAmount']),
      startDate: serializer.fromJson<DateTime>(json['startDate']),
      deadline: serializer.fromJson<DateTime?>(json['deadline']),
      expectedReturn: serializer.fromJson<double?>(json['expectedReturn']),
      color: serializer.fromJson<int>(json['color']),
      icon: serializer.fromJson<String?>(json['icon']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      category: serializer.fromJson<String?>(json['category']),
      priority: serializer.fromJson<String>(json['priority']),
      monthlyContributionTarget:
          serializer.fromJson<double?>(json['monthlyContributionTarget']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'purpose': serializer.toJson<String?>(purpose),
      'investmentType': serializer.toJson<String>(investmentType),
      'identificationNumber': serializer.toJson<String?>(identificationNumber),
      'currentAmount': serializer.toJson<double>(currentAmount),
      'targetAmount': serializer.toJson<double>(targetAmount),
      'startDate': serializer.toJson<DateTime>(startDate),
      'deadline': serializer.toJson<DateTime?>(deadline),
      'expectedReturn': serializer.toJson<double?>(expectedReturn),
      'color': serializer.toJson<int>(color),
      'icon': serializer.toJson<String?>(icon),
      'isCompleted': serializer.toJson<bool>(isCompleted),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'category': serializer.toJson<String?>(category),
      'priority': serializer.toJson<String>(priority),
      'monthlyContributionTarget':
          serializer.toJson<double?>(monthlyContributionTarget),
    };
  }

  Goal copyWith(
          {String? id,
          String? name,
          Value<String?> purpose = const Value.absent(),
          String? investmentType,
          Value<String?> identificationNumber = const Value.absent(),
          double? currentAmount,
          double? targetAmount,
          DateTime? startDate,
          Value<DateTime?> deadline = const Value.absent(),
          Value<double?> expectedReturn = const Value.absent(),
          int? color,
          Value<String?> icon = const Value.absent(),
          bool? isCompleted,
          DateTime? createdAt,
          Value<String?> category = const Value.absent(),
          String? priority,
          Value<double?> monthlyContributionTarget = const Value.absent()}) =>
      Goal(
        id: id ?? this.id,
        name: name ?? this.name,
        purpose: purpose.present ? purpose.value : this.purpose,
        investmentType: investmentType ?? this.investmentType,
        identificationNumber: identificationNumber.present
            ? identificationNumber.value
            : this.identificationNumber,
        currentAmount: currentAmount ?? this.currentAmount,
        targetAmount: targetAmount ?? this.targetAmount,
        startDate: startDate ?? this.startDate,
        deadline: deadline.present ? deadline.value : this.deadline,
        expectedReturn:
            expectedReturn.present ? expectedReturn.value : this.expectedReturn,
        color: color ?? this.color,
        icon: icon.present ? icon.value : this.icon,
        isCompleted: isCompleted ?? this.isCompleted,
        createdAt: createdAt ?? this.createdAt,
        category: category.present ? category.value : this.category,
        priority: priority ?? this.priority,
        monthlyContributionTarget: monthlyContributionTarget.present
            ? monthlyContributionTarget.value
            : this.monthlyContributionTarget,
      );
  Goal copyWithCompanion(GoalsCompanion data) {
    return Goal(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      purpose: data.purpose.present ? data.purpose.value : this.purpose,
      investmentType: data.investmentType.present
          ? data.investmentType.value
          : this.investmentType,
      identificationNumber: data.identificationNumber.present
          ? data.identificationNumber.value
          : this.identificationNumber,
      currentAmount: data.currentAmount.present
          ? data.currentAmount.value
          : this.currentAmount,
      targetAmount: data.targetAmount.present
          ? data.targetAmount.value
          : this.targetAmount,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      deadline: data.deadline.present ? data.deadline.value : this.deadline,
      expectedReturn: data.expectedReturn.present
          ? data.expectedReturn.value
          : this.expectedReturn,
      color: data.color.present ? data.color.value : this.color,
      icon: data.icon.present ? data.icon.value : this.icon,
      isCompleted:
          data.isCompleted.present ? data.isCompleted.value : this.isCompleted,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      category: data.category.present ? data.category.value : this.category,
      priority: data.priority.present ? data.priority.value : this.priority,
      monthlyContributionTarget: data.monthlyContributionTarget.present
          ? data.monthlyContributionTarget.value
          : this.monthlyContributionTarget,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Goal(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('purpose: $purpose, ')
          ..write('investmentType: $investmentType, ')
          ..write('identificationNumber: $identificationNumber, ')
          ..write('currentAmount: $currentAmount, ')
          ..write('targetAmount: $targetAmount, ')
          ..write('startDate: $startDate, ')
          ..write('deadline: $deadline, ')
          ..write('expectedReturn: $expectedReturn, ')
          ..write('color: $color, ')
          ..write('icon: $icon, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('category: $category, ')
          ..write('priority: $priority, ')
          ..write('monthlyContributionTarget: $monthlyContributionTarget')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      name,
      purpose,
      investmentType,
      identificationNumber,
      currentAmount,
      targetAmount,
      startDate,
      deadline,
      expectedReturn,
      color,
      icon,
      isCompleted,
      createdAt,
      category,
      priority,
      monthlyContributionTarget);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Goal &&
          other.id == this.id &&
          other.name == this.name &&
          other.purpose == this.purpose &&
          other.investmentType == this.investmentType &&
          other.identificationNumber == this.identificationNumber &&
          other.currentAmount == this.currentAmount &&
          other.targetAmount == this.targetAmount &&
          other.startDate == this.startDate &&
          other.deadline == this.deadline &&
          other.expectedReturn == this.expectedReturn &&
          other.color == this.color &&
          other.icon == this.icon &&
          other.isCompleted == this.isCompleted &&
          other.createdAt == this.createdAt &&
          other.category == this.category &&
          other.priority == this.priority &&
          other.monthlyContributionTarget == this.monthlyContributionTarget);
}

class GoalsCompanion extends UpdateCompanion<Goal> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> purpose;
  final Value<String> investmentType;
  final Value<String?> identificationNumber;
  final Value<double> currentAmount;
  final Value<double> targetAmount;
  final Value<DateTime> startDate;
  final Value<DateTime?> deadline;
  final Value<double?> expectedReturn;
  final Value<int> color;
  final Value<String?> icon;
  final Value<bool> isCompleted;
  final Value<DateTime> createdAt;
  final Value<String?> category;
  final Value<String> priority;
  final Value<double?> monthlyContributionTarget;
  final Value<int> rowid;
  const GoalsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.purpose = const Value.absent(),
    this.investmentType = const Value.absent(),
    this.identificationNumber = const Value.absent(),
    this.currentAmount = const Value.absent(),
    this.targetAmount = const Value.absent(),
    this.startDate = const Value.absent(),
    this.deadline = const Value.absent(),
    this.expectedReturn = const Value.absent(),
    this.color = const Value.absent(),
    this.icon = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.category = const Value.absent(),
    this.priority = const Value.absent(),
    this.monthlyContributionTarget = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GoalsCompanion.insert({
    required String id,
    required String name,
    this.purpose = const Value.absent(),
    this.investmentType = const Value.absent(),
    this.identificationNumber = const Value.absent(),
    this.currentAmount = const Value.absent(),
    required double targetAmount,
    this.startDate = const Value.absent(),
    this.deadline = const Value.absent(),
    this.expectedReturn = const Value.absent(),
    required int color,
    this.icon = const Value.absent(),
    this.isCompleted = const Value.absent(),
    required DateTime createdAt,
    this.category = const Value.absent(),
    this.priority = const Value.absent(),
    this.monthlyContributionTarget = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        targetAmount = Value(targetAmount),
        color = Value(color),
        createdAt = Value(createdAt);
  static Insertable<Goal> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? purpose,
    Expression<String>? investmentType,
    Expression<String>? identificationNumber,
    Expression<double>? currentAmount,
    Expression<double>? targetAmount,
    Expression<DateTime>? startDate,
    Expression<DateTime>? deadline,
    Expression<double>? expectedReturn,
    Expression<int>? color,
    Expression<String>? icon,
    Expression<bool>? isCompleted,
    Expression<DateTime>? createdAt,
    Expression<String>? category,
    Expression<String>? priority,
    Expression<double>? monthlyContributionTarget,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (purpose != null) 'purpose': purpose,
      if (investmentType != null) 'investment_type': investmentType,
      if (identificationNumber != null)
        'identification_number': identificationNumber,
      if (currentAmount != null) 'current_amount': currentAmount,
      if (targetAmount != null) 'target_amount': targetAmount,
      if (startDate != null) 'start_date': startDate,
      if (deadline != null) 'deadline': deadline,
      if (expectedReturn != null) 'expected_return': expectedReturn,
      if (color != null) 'color': color,
      if (icon != null) 'icon': icon,
      if (isCompleted != null) 'is_completed': isCompleted,
      if (createdAt != null) 'created_at': createdAt,
      if (category != null) 'category': category,
      if (priority != null) 'priority': priority,
      if (monthlyContributionTarget != null)
        'monthly_contribution_target': monthlyContributionTarget,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GoalsCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String?>? purpose,
      Value<String>? investmentType,
      Value<String?>? identificationNumber,
      Value<double>? currentAmount,
      Value<double>? targetAmount,
      Value<DateTime>? startDate,
      Value<DateTime?>? deadline,
      Value<double?>? expectedReturn,
      Value<int>? color,
      Value<String?>? icon,
      Value<bool>? isCompleted,
      Value<DateTime>? createdAt,
      Value<String?>? category,
      Value<String>? priority,
      Value<double?>? monthlyContributionTarget,
      Value<int>? rowid}) {
    return GoalsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      purpose: purpose ?? this.purpose,
      investmentType: investmentType ?? this.investmentType,
      identificationNumber: identificationNumber ?? this.identificationNumber,
      currentAmount: currentAmount ?? this.currentAmount,
      targetAmount: targetAmount ?? this.targetAmount,
      startDate: startDate ?? this.startDate,
      deadline: deadline ?? this.deadline,
      expectedReturn: expectedReturn ?? this.expectedReturn,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      monthlyContributionTarget:
          monthlyContributionTarget ?? this.monthlyContributionTarget,
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
    if (purpose.present) {
      map['purpose'] = Variable<String>(purpose.value);
    }
    if (investmentType.present) {
      map['investment_type'] = Variable<String>(investmentType.value);
    }
    if (identificationNumber.present) {
      map['identification_number'] =
          Variable<String>(identificationNumber.value);
    }
    if (currentAmount.present) {
      map['current_amount'] = Variable<double>(currentAmount.value);
    }
    if (targetAmount.present) {
      map['target_amount'] = Variable<double>(targetAmount.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (deadline.present) {
      map['deadline'] = Variable<DateTime>(deadline.value);
    }
    if (expectedReturn.present) {
      map['expected_return'] = Variable<double>(expectedReturn.value);
    }
    if (color.present) {
      map['color'] = Variable<int>(color.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (priority.present) {
      map['priority'] = Variable<String>(priority.value);
    }
    if (monthlyContributionTarget.present) {
      map['monthly_contribution_target'] =
          Variable<double>(monthlyContributionTarget.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GoalsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('purpose: $purpose, ')
          ..write('investmentType: $investmentType, ')
          ..write('identificationNumber: $identificationNumber, ')
          ..write('currentAmount: $currentAmount, ')
          ..write('targetAmount: $targetAmount, ')
          ..write('startDate: $startDate, ')
          ..write('deadline: $deadline, ')
          ..write('expectedReturn: $expectedReturn, ')
          ..write('color: $color, ')
          ..write('icon: $icon, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('category: $category, ')
          ..write('priority: $priority, ')
          ..write('monthlyContributionTarget: $monthlyContributionTarget, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $HeatmapLimitsTable extends HeatmapLimits
    with TableInfo<$HeatmapLimitsTable, HeatmapLimit> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HeatmapLimitsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _safeLimitMeta =
      const VerificationMeta('safeLimit');
  @override
  late final GeneratedColumn<double> safeLimit = GeneratedColumn<double>(
      'safe_limit', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(500.0));
  static const VerificationMeta _cautionLimitMeta =
      const VerificationMeta('cautionLimit');
  @override
  late final GeneratedColumn<double> cautionLimit = GeneratedColumn<double>(
      'caution_limit', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(2000.0));
  static const VerificationMeta _severeLimitMeta =
      const VerificationMeta('severeLimit');
  @override
  late final GeneratedColumn<double> severeLimit = GeneratedColumn<double>(
      'severe_limit', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(5000.0));
  @override
  List<GeneratedColumn> get $columns =>
      [id, safeLimit, cautionLimit, severeLimit];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'heatmap_limits';
  @override
  VerificationContext validateIntegrity(Insertable<HeatmapLimit> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('safe_limit')) {
      context.handle(_safeLimitMeta,
          safeLimit.isAcceptableOrUnknown(data['safe_limit']!, _safeLimitMeta));
    }
    if (data.containsKey('caution_limit')) {
      context.handle(
          _cautionLimitMeta,
          cautionLimit.isAcceptableOrUnknown(
              data['caution_limit']!, _cautionLimitMeta));
    }
    if (data.containsKey('severe_limit')) {
      context.handle(
          _severeLimitMeta,
          severeLimit.isAcceptableOrUnknown(
              data['severe_limit']!, _severeLimitMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HeatmapLimit map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HeatmapLimit(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      safeLimit: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}safe_limit'])!,
      cautionLimit: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}caution_limit'])!,
      severeLimit: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}severe_limit'])!,
    );
  }

  @override
  $HeatmapLimitsTable createAlias(String alias) {
    return $HeatmapLimitsTable(attachedDatabase, alias);
  }
}

class HeatmapLimit extends DataClass implements Insertable<HeatmapLimit> {
  final String id;
  final double safeLimit;
  final double cautionLimit;
  final double severeLimit;
  const HeatmapLimit(
      {required this.id,
      required this.safeLimit,
      required this.cautionLimit,
      required this.severeLimit});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['safe_limit'] = Variable<double>(safeLimit);
    map['caution_limit'] = Variable<double>(cautionLimit);
    map['severe_limit'] = Variable<double>(severeLimit);
    return map;
  }

  HeatmapLimitsCompanion toCompanion(bool nullToAbsent) {
    return HeatmapLimitsCompanion(
      id: Value(id),
      safeLimit: Value(safeLimit),
      cautionLimit: Value(cautionLimit),
      severeLimit: Value(severeLimit),
    );
  }

  factory HeatmapLimit.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HeatmapLimit(
      id: serializer.fromJson<String>(json['id']),
      safeLimit: serializer.fromJson<double>(json['safeLimit']),
      cautionLimit: serializer.fromJson<double>(json['cautionLimit']),
      severeLimit: serializer.fromJson<double>(json['severeLimit']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'safeLimit': serializer.toJson<double>(safeLimit),
      'cautionLimit': serializer.toJson<double>(cautionLimit),
      'severeLimit': serializer.toJson<double>(severeLimit),
    };
  }

  HeatmapLimit copyWith(
          {String? id,
          double? safeLimit,
          double? cautionLimit,
          double? severeLimit}) =>
      HeatmapLimit(
        id: id ?? this.id,
        safeLimit: safeLimit ?? this.safeLimit,
        cautionLimit: cautionLimit ?? this.cautionLimit,
        severeLimit: severeLimit ?? this.severeLimit,
      );
  HeatmapLimit copyWithCompanion(HeatmapLimitsCompanion data) {
    return HeatmapLimit(
      id: data.id.present ? data.id.value : this.id,
      safeLimit: data.safeLimit.present ? data.safeLimit.value : this.safeLimit,
      cautionLimit: data.cautionLimit.present
          ? data.cautionLimit.value
          : this.cautionLimit,
      severeLimit:
          data.severeLimit.present ? data.severeLimit.value : this.severeLimit,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HeatmapLimit(')
          ..write('id: $id, ')
          ..write('safeLimit: $safeLimit, ')
          ..write('cautionLimit: $cautionLimit, ')
          ..write('severeLimit: $severeLimit')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, safeLimit, cautionLimit, severeLimit);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HeatmapLimit &&
          other.id == this.id &&
          other.safeLimit == this.safeLimit &&
          other.cautionLimit == this.cautionLimit &&
          other.severeLimit == this.severeLimit);
}

class HeatmapLimitsCompanion extends UpdateCompanion<HeatmapLimit> {
  final Value<String> id;
  final Value<double> safeLimit;
  final Value<double> cautionLimit;
  final Value<double> severeLimit;
  final Value<int> rowid;
  const HeatmapLimitsCompanion({
    this.id = const Value.absent(),
    this.safeLimit = const Value.absent(),
    this.cautionLimit = const Value.absent(),
    this.severeLimit = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  HeatmapLimitsCompanion.insert({
    required String id,
    this.safeLimit = const Value.absent(),
    this.cautionLimit = const Value.absent(),
    this.severeLimit = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id);
  static Insertable<HeatmapLimit> custom({
    Expression<String>? id,
    Expression<double>? safeLimit,
    Expression<double>? cautionLimit,
    Expression<double>? severeLimit,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (safeLimit != null) 'safe_limit': safeLimit,
      if (cautionLimit != null) 'caution_limit': cautionLimit,
      if (severeLimit != null) 'severe_limit': severeLimit,
      if (rowid != null) 'rowid': rowid,
    });
  }

  HeatmapLimitsCompanion copyWith(
      {Value<String>? id,
      Value<double>? safeLimit,
      Value<double>? cautionLimit,
      Value<double>? severeLimit,
      Value<int>? rowid}) {
    return HeatmapLimitsCompanion(
      id: id ?? this.id,
      safeLimit: safeLimit ?? this.safeLimit,
      cautionLimit: cautionLimit ?? this.cautionLimit,
      severeLimit: severeLimit ?? this.severeLimit,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (safeLimit.present) {
      map['safe_limit'] = Variable<double>(safeLimit.value);
    }
    if (cautionLimit.present) {
      map['caution_limit'] = Variable<double>(cautionLimit.value);
    }
    if (severeLimit.present) {
      map['severe_limit'] = Variable<double>(severeLimit.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HeatmapLimitsCompanion(')
          ..write('id: $id, ')
          ..write('safeLimit: $safeLimit, ')
          ..write('cautionLimit: $cautionLimit, ')
          ..write('severeLimit: $severeLimit, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppNotificationsTable extends AppNotifications
    with TableInfo<$AppNotificationsTable, AppNotification> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppNotificationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _messageMeta =
      const VerificationMeta('message');
  @override
  late final GeneratedColumn<String> message = GeneratedColumn<String>(
      'message', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _payloadMeta =
      const VerificationMeta('payload');
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
      'payload', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isReadMeta = const VerificationMeta('isRead');
  @override
  late final GeneratedColumn<bool> isRead = GeneratedColumn<bool>(
      'is_read', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_read" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, type, title, message, payload, isRead, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_notifications';
  @override
  VerificationContext validateIntegrity(Insertable<AppNotification> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('message')) {
      context.handle(_messageMeta,
          message.isAcceptableOrUnknown(data['message']!, _messageMeta));
    } else if (isInserting) {
      context.missing(_messageMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(_payloadMeta,
          payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta));
    }
    if (data.containsKey('is_read')) {
      context.handle(_isReadMeta,
          isRead.isAcceptableOrUnknown(data['is_read']!, _isReadMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AppNotification map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppNotification(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      message: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}message'])!,
      payload: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload']),
      isRead: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_read'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $AppNotificationsTable createAlias(String alias) {
    return $AppNotificationsTable(attachedDatabase, alias);
  }
}

class AppNotification extends DataClass implements Insertable<AppNotification> {
  final String id;
  final String type;
  final String title;
  final String message;
  final String? payload;
  final bool isRead;
  final DateTime createdAt;
  const AppNotification(
      {required this.id,
      required this.type,
      required this.title,
      required this.message,
      this.payload,
      required this.isRead,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['type'] = Variable<String>(type);
    map['title'] = Variable<String>(title);
    map['message'] = Variable<String>(message);
    if (!nullToAbsent || payload != null) {
      map['payload'] = Variable<String>(payload);
    }
    map['is_read'] = Variable<bool>(isRead);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  AppNotificationsCompanion toCompanion(bool nullToAbsent) {
    return AppNotificationsCompanion(
      id: Value(id),
      type: Value(type),
      title: Value(title),
      message: Value(message),
      payload: payload == null && nullToAbsent
          ? const Value.absent()
          : Value(payload),
      isRead: Value(isRead),
      createdAt: Value(createdAt),
    );
  }

  factory AppNotification.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppNotification(
      id: serializer.fromJson<String>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      title: serializer.fromJson<String>(json['title']),
      message: serializer.fromJson<String>(json['message']),
      payload: serializer.fromJson<String?>(json['payload']),
      isRead: serializer.fromJson<bool>(json['isRead']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'type': serializer.toJson<String>(type),
      'title': serializer.toJson<String>(title),
      'message': serializer.toJson<String>(message),
      'payload': serializer.toJson<String?>(payload),
      'isRead': serializer.toJson<bool>(isRead),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  AppNotification copyWith(
          {String? id,
          String? type,
          String? title,
          String? message,
          Value<String?> payload = const Value.absent(),
          bool? isRead,
          DateTime? createdAt}) =>
      AppNotification(
        id: id ?? this.id,
        type: type ?? this.type,
        title: title ?? this.title,
        message: message ?? this.message,
        payload: payload.present ? payload.value : this.payload,
        isRead: isRead ?? this.isRead,
        createdAt: createdAt ?? this.createdAt,
      );
  AppNotification copyWithCompanion(AppNotificationsCompanion data) {
    return AppNotification(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      title: data.title.present ? data.title.value : this.title,
      message: data.message.present ? data.message.value : this.message,
      payload: data.payload.present ? data.payload.value : this.payload,
      isRead: data.isRead.present ? data.isRead.value : this.isRead,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppNotification(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('title: $title, ')
          ..write('message: $message, ')
          ..write('payload: $payload, ')
          ..write('isRead: $isRead, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, type, title, message, payload, isRead, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppNotification &&
          other.id == this.id &&
          other.type == this.type &&
          other.title == this.title &&
          other.message == this.message &&
          other.payload == this.payload &&
          other.isRead == this.isRead &&
          other.createdAt == this.createdAt);
}

class AppNotificationsCompanion extends UpdateCompanion<AppNotification> {
  final Value<String> id;
  final Value<String> type;
  final Value<String> title;
  final Value<String> message;
  final Value<String?> payload;
  final Value<bool> isRead;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const AppNotificationsCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.title = const Value.absent(),
    this.message = const Value.absent(),
    this.payload = const Value.absent(),
    this.isRead = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppNotificationsCompanion.insert({
    required String id,
    required String type,
    required String title,
    required String message,
    this.payload = const Value.absent(),
    this.isRead = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        type = Value(type),
        title = Value(title),
        message = Value(message),
        createdAt = Value(createdAt);
  static Insertable<AppNotification> custom({
    Expression<String>? id,
    Expression<String>? type,
    Expression<String>? title,
    Expression<String>? message,
    Expression<String>? payload,
    Expression<bool>? isRead,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (title != null) 'title': title,
      if (message != null) 'message': message,
      if (payload != null) 'payload': payload,
      if (isRead != null) 'is_read': isRead,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppNotificationsCompanion copyWith(
      {Value<String>? id,
      Value<String>? type,
      Value<String>? title,
      Value<String>? message,
      Value<String?>? payload,
      Value<bool>? isRead,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return AppNotificationsCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      payload: payload ?? this.payload,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (message.present) {
      map['message'] = Variable<String>(message.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (isRead.present) {
      map['is_read'] = Variable<bool>(isRead.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppNotificationsCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('title: $title, ')
          ..write('message: $message, ')
          ..write('payload: $payload, ')
          ..write('isRead: $isRead, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RecurringPatternsTable extends RecurringPatterns
    with TableInfo<$RecurringPatternsTable, RecurringPattern> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecurringPatternsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
      'amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
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
  static const VerificationMeta _bucketMeta = const VerificationMeta('bucket');
  @override
  late final GeneratedColumn<String> bucket = GeneratedColumn<String>(
      'bucket', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('Unallocated'));
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _sourceAccountIdMeta =
      const VerificationMeta('sourceAccountId');
  @override
  late final GeneratedColumn<String> sourceAccountId = GeneratedColumn<String>(
      'source_account_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _sourceCardIdMeta =
      const VerificationMeta('sourceCardId');
  @override
  late final GeneratedColumn<String> sourceCardId = GeneratedColumn<String>(
      'source_card_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _destinationAccountIdMeta =
      const VerificationMeta('destinationAccountId');
  @override
  late final GeneratedColumn<String> destinationAccountId =
      GeneratedColumn<String>('destination_account_id', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _frequencyMeta =
      const VerificationMeta('frequency');
  @override
  late final GeneratedColumn<String> frequency = GeneratedColumn<String>(
      'frequency', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _intervalMeta =
      const VerificationMeta('interval');
  @override
  late final GeneratedColumn<int> interval = GeneratedColumn<int>(
      'interval', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _startDateMeta =
      const VerificationMeta('startDate');
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
      'start_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _executionTimeMeta =
      const VerificationMeta('executionTime');
  @override
  late final GeneratedColumn<String> executionTime = GeneratedColumn<String>(
      'execution_time', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _scheduleTypeMeta =
      const VerificationMeta('scheduleType');
  @override
  late final GeneratedColumn<String> scheduleType = GeneratedColumn<String>(
      'schedule_type', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('Fixed'));
  static const VerificationMeta _weekParamMeta =
      const VerificationMeta('weekParam');
  @override
  late final GeneratedColumn<int> weekParam = GeneratedColumn<int>(
      'week_param', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _dayParamMeta =
      const VerificationMeta('dayParam');
  @override
  late final GeneratedColumn<int> dayParam = GeneratedColumn<int>(
      'day_param', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _isVariableMeta =
      const VerificationMeta('isVariable');
  @override
  late final GeneratedColumn<bool> isVariable = GeneratedColumn<bool>(
      'is_variable', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_variable" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _endDateMeta =
      const VerificationMeta('endDate');
  @override
  late final GeneratedColumn<DateTime> endDate = GeneratedColumn<DateTime>(
      'end_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _maxOccurrencesMeta =
      const VerificationMeta('maxOccurrences');
  @override
  late final GeneratedColumn<int> maxOccurrences = GeneratedColumn<int>(
      'max_occurrences', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _occurrencesProcessedMeta =
      const VerificationMeta('occurrencesProcessed');
  @override
  late final GeneratedColumn<int> occurrencesProcessed = GeneratedColumn<int>(
      'occurrences_processed', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _websiteMeta =
      const VerificationMeta('website');
  @override
  late final GeneratedColumn<String> website = GeneratedColumn<String>(
      'website', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _notifyBeforeMeta =
      const VerificationMeta('notifyBefore');
  @override
  late final GeneratedColumn<bool> notifyBefore = GeneratedColumn<bool>(
      'notify_before', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("notify_before" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _nextRunAtMeta =
      const VerificationMeta('nextRunAt');
  @override
  late final GeneratedColumn<DateTime> nextRunAt = GeneratedColumn<DateTime>(
      'next_run_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _autoExecuteMeta =
      const VerificationMeta('autoExecute');
  @override
  late final GeneratedColumn<bool> autoExecute = GeneratedColumn<bool>(
      'auto_execute', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("auto_execute" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        amount,
        type,
        category,
        subCategory,
        bucket,
        notes,
        sourceAccountId,
        sourceCardId,
        destinationAccountId,
        frequency,
        interval,
        startDate,
        executionTime,
        scheduleType,
        weekParam,
        dayParam,
        isVariable,
        endDate,
        maxOccurrences,
        occurrencesProcessed,
        website,
        notifyBefore,
        nextRunAt,
        isActive,
        autoExecute,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recurring_patterns';
  @override
  VerificationContext validateIntegrity(Insertable<RecurringPattern> instance,
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
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
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
    if (data.containsKey('bucket')) {
      context.handle(_bucketMeta,
          bucket.isAcceptableOrUnknown(data['bucket']!, _bucketMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('source_account_id')) {
      context.handle(
          _sourceAccountIdMeta,
          sourceAccountId.isAcceptableOrUnknown(
              data['source_account_id']!, _sourceAccountIdMeta));
    }
    if (data.containsKey('source_card_id')) {
      context.handle(
          _sourceCardIdMeta,
          sourceCardId.isAcceptableOrUnknown(
              data['source_card_id']!, _sourceCardIdMeta));
    }
    if (data.containsKey('destination_account_id')) {
      context.handle(
          _destinationAccountIdMeta,
          destinationAccountId.isAcceptableOrUnknown(
              data['destination_account_id']!, _destinationAccountIdMeta));
    }
    if (data.containsKey('frequency')) {
      context.handle(_frequencyMeta,
          frequency.isAcceptableOrUnknown(data['frequency']!, _frequencyMeta));
    } else if (isInserting) {
      context.missing(_frequencyMeta);
    }
    if (data.containsKey('interval')) {
      context.handle(_intervalMeta,
          interval.isAcceptableOrUnknown(data['interval']!, _intervalMeta));
    }
    if (data.containsKey('start_date')) {
      context.handle(_startDateMeta,
          startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta));
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('execution_time')) {
      context.handle(
          _executionTimeMeta,
          executionTime.isAcceptableOrUnknown(
              data['execution_time']!, _executionTimeMeta));
    } else if (isInserting) {
      context.missing(_executionTimeMeta);
    }
    if (data.containsKey('schedule_type')) {
      context.handle(
          _scheduleTypeMeta,
          scheduleType.isAcceptableOrUnknown(
              data['schedule_type']!, _scheduleTypeMeta));
    }
    if (data.containsKey('week_param')) {
      context.handle(_weekParamMeta,
          weekParam.isAcceptableOrUnknown(data['week_param']!, _weekParamMeta));
    }
    if (data.containsKey('day_param')) {
      context.handle(_dayParamMeta,
          dayParam.isAcceptableOrUnknown(data['day_param']!, _dayParamMeta));
    }
    if (data.containsKey('is_variable')) {
      context.handle(
          _isVariableMeta,
          isVariable.isAcceptableOrUnknown(
              data['is_variable']!, _isVariableMeta));
    }
    if (data.containsKey('end_date')) {
      context.handle(_endDateMeta,
          endDate.isAcceptableOrUnknown(data['end_date']!, _endDateMeta));
    }
    if (data.containsKey('max_occurrences')) {
      context.handle(
          _maxOccurrencesMeta,
          maxOccurrences.isAcceptableOrUnknown(
              data['max_occurrences']!, _maxOccurrencesMeta));
    }
    if (data.containsKey('occurrences_processed')) {
      context.handle(
          _occurrencesProcessedMeta,
          occurrencesProcessed.isAcceptableOrUnknown(
              data['occurrences_processed']!, _occurrencesProcessedMeta));
    }
    if (data.containsKey('website')) {
      context.handle(_websiteMeta,
          website.isAcceptableOrUnknown(data['website']!, _websiteMeta));
    }
    if (data.containsKey('notify_before')) {
      context.handle(
          _notifyBeforeMeta,
          notifyBefore.isAcceptableOrUnknown(
              data['notify_before']!, _notifyBeforeMeta));
    }
    if (data.containsKey('next_run_at')) {
      context.handle(
          _nextRunAtMeta,
          nextRunAt.isAcceptableOrUnknown(
              data['next_run_at']!, _nextRunAtMeta));
    } else if (isInserting) {
      context.missing(_nextRunAtMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('auto_execute')) {
      context.handle(
          _autoExecuteMeta,
          autoExecute.isAcceptableOrUnknown(
              data['auto_execute']!, _autoExecuteMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RecurringPattern map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecurringPattern(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}amount'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      subCategory: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sub_category'])!,
      bucket: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}bucket'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes'])!,
      sourceAccountId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}source_account_id']),
      sourceCardId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source_card_id']),
      destinationAccountId: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}destination_account_id']),
      frequency: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}frequency'])!,
      interval: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}interval'])!,
      startDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}start_date'])!,
      executionTime: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}execution_time'])!,
      scheduleType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}schedule_type'])!,
      weekParam: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}week_param']),
      dayParam: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}day_param']),
      isVariable: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_variable'])!,
      endDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}end_date']),
      maxOccurrences: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}max_occurrences']),
      occurrencesProcessed: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}occurrences_processed'])!,
      website: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}website']),
      notifyBefore: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}notify_before'])!,
      nextRunAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}next_run_at'])!,
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      autoExecute: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}auto_execute'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $RecurringPatternsTable createAlias(String alias) {
    return $RecurringPatternsTable(attachedDatabase, alias);
  }
}

class RecurringPattern extends DataClass
    implements Insertable<RecurringPattern> {
  final String id;
  final String name;
  final double amount;
  final String type;
  final String category;
  final String subCategory;
  final String bucket;
  final String notes;
  final String? sourceAccountId;
  final String? sourceCardId;
  final String? destinationAccountId;
  final String frequency;
  final int interval;
  final DateTime startDate;
  final String executionTime;
  final String scheduleType;
  final int? weekParam;
  final int? dayParam;
  final bool isVariable;
  final DateTime? endDate;
  final int? maxOccurrences;
  final int occurrencesProcessed;
  final String? website;
  final bool notifyBefore;
  final DateTime nextRunAt;
  final bool isActive;
  final bool autoExecute;
  final DateTime createdAt;
  const RecurringPattern(
      {required this.id,
      required this.name,
      required this.amount,
      required this.type,
      required this.category,
      required this.subCategory,
      required this.bucket,
      required this.notes,
      this.sourceAccountId,
      this.sourceCardId,
      this.destinationAccountId,
      required this.frequency,
      required this.interval,
      required this.startDate,
      required this.executionTime,
      required this.scheduleType,
      this.weekParam,
      this.dayParam,
      required this.isVariable,
      this.endDate,
      this.maxOccurrences,
      required this.occurrencesProcessed,
      this.website,
      required this.notifyBefore,
      required this.nextRunAt,
      required this.isActive,
      required this.autoExecute,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['amount'] = Variable<double>(amount);
    map['type'] = Variable<String>(type);
    map['category'] = Variable<String>(category);
    map['sub_category'] = Variable<String>(subCategory);
    map['bucket'] = Variable<String>(bucket);
    map['notes'] = Variable<String>(notes);
    if (!nullToAbsent || sourceAccountId != null) {
      map['source_account_id'] = Variable<String>(sourceAccountId);
    }
    if (!nullToAbsent || sourceCardId != null) {
      map['source_card_id'] = Variable<String>(sourceCardId);
    }
    if (!nullToAbsent || destinationAccountId != null) {
      map['destination_account_id'] = Variable<String>(destinationAccountId);
    }
    map['frequency'] = Variable<String>(frequency);
    map['interval'] = Variable<int>(interval);
    map['start_date'] = Variable<DateTime>(startDate);
    map['execution_time'] = Variable<String>(executionTime);
    map['schedule_type'] = Variable<String>(scheduleType);
    if (!nullToAbsent || weekParam != null) {
      map['week_param'] = Variable<int>(weekParam);
    }
    if (!nullToAbsent || dayParam != null) {
      map['day_param'] = Variable<int>(dayParam);
    }
    map['is_variable'] = Variable<bool>(isVariable);
    if (!nullToAbsent || endDate != null) {
      map['end_date'] = Variable<DateTime>(endDate);
    }
    if (!nullToAbsent || maxOccurrences != null) {
      map['max_occurrences'] = Variable<int>(maxOccurrences);
    }
    map['occurrences_processed'] = Variable<int>(occurrencesProcessed);
    if (!nullToAbsent || website != null) {
      map['website'] = Variable<String>(website);
    }
    map['notify_before'] = Variable<bool>(notifyBefore);
    map['next_run_at'] = Variable<DateTime>(nextRunAt);
    map['is_active'] = Variable<bool>(isActive);
    map['auto_execute'] = Variable<bool>(autoExecute);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  RecurringPatternsCompanion toCompanion(bool nullToAbsent) {
    return RecurringPatternsCompanion(
      id: Value(id),
      name: Value(name),
      amount: Value(amount),
      type: Value(type),
      category: Value(category),
      subCategory: Value(subCategory),
      bucket: Value(bucket),
      notes: Value(notes),
      sourceAccountId: sourceAccountId == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceAccountId),
      sourceCardId: sourceCardId == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceCardId),
      destinationAccountId: destinationAccountId == null && nullToAbsent
          ? const Value.absent()
          : Value(destinationAccountId),
      frequency: Value(frequency),
      interval: Value(interval),
      startDate: Value(startDate),
      executionTime: Value(executionTime),
      scheduleType: Value(scheduleType),
      weekParam: weekParam == null && nullToAbsent
          ? const Value.absent()
          : Value(weekParam),
      dayParam: dayParam == null && nullToAbsent
          ? const Value.absent()
          : Value(dayParam),
      isVariable: Value(isVariable),
      endDate: endDate == null && nullToAbsent
          ? const Value.absent()
          : Value(endDate),
      maxOccurrences: maxOccurrences == null && nullToAbsent
          ? const Value.absent()
          : Value(maxOccurrences),
      occurrencesProcessed: Value(occurrencesProcessed),
      website: website == null && nullToAbsent
          ? const Value.absent()
          : Value(website),
      notifyBefore: Value(notifyBefore),
      nextRunAt: Value(nextRunAt),
      isActive: Value(isActive),
      autoExecute: Value(autoExecute),
      createdAt: Value(createdAt),
    );
  }

  factory RecurringPattern.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecurringPattern(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      amount: serializer.fromJson<double>(json['amount']),
      type: serializer.fromJson<String>(json['type']),
      category: serializer.fromJson<String>(json['category']),
      subCategory: serializer.fromJson<String>(json['subCategory']),
      bucket: serializer.fromJson<String>(json['bucket']),
      notes: serializer.fromJson<String>(json['notes']),
      sourceAccountId: serializer.fromJson<String?>(json['sourceAccountId']),
      sourceCardId: serializer.fromJson<String?>(json['sourceCardId']),
      destinationAccountId:
          serializer.fromJson<String?>(json['destinationAccountId']),
      frequency: serializer.fromJson<String>(json['frequency']),
      interval: serializer.fromJson<int>(json['interval']),
      startDate: serializer.fromJson<DateTime>(json['startDate']),
      executionTime: serializer.fromJson<String>(json['executionTime']),
      scheduleType: serializer.fromJson<String>(json['scheduleType']),
      weekParam: serializer.fromJson<int?>(json['weekParam']),
      dayParam: serializer.fromJson<int?>(json['dayParam']),
      isVariable: serializer.fromJson<bool>(json['isVariable']),
      endDate: serializer.fromJson<DateTime?>(json['endDate']),
      maxOccurrences: serializer.fromJson<int?>(json['maxOccurrences']),
      occurrencesProcessed:
          serializer.fromJson<int>(json['occurrencesProcessed']),
      website: serializer.fromJson<String?>(json['website']),
      notifyBefore: serializer.fromJson<bool>(json['notifyBefore']),
      nextRunAt: serializer.fromJson<DateTime>(json['nextRunAt']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      autoExecute: serializer.fromJson<bool>(json['autoExecute']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'amount': serializer.toJson<double>(amount),
      'type': serializer.toJson<String>(type),
      'category': serializer.toJson<String>(category),
      'subCategory': serializer.toJson<String>(subCategory),
      'bucket': serializer.toJson<String>(bucket),
      'notes': serializer.toJson<String>(notes),
      'sourceAccountId': serializer.toJson<String?>(sourceAccountId),
      'sourceCardId': serializer.toJson<String?>(sourceCardId),
      'destinationAccountId': serializer.toJson<String?>(destinationAccountId),
      'frequency': serializer.toJson<String>(frequency),
      'interval': serializer.toJson<int>(interval),
      'startDate': serializer.toJson<DateTime>(startDate),
      'executionTime': serializer.toJson<String>(executionTime),
      'scheduleType': serializer.toJson<String>(scheduleType),
      'weekParam': serializer.toJson<int?>(weekParam),
      'dayParam': serializer.toJson<int?>(dayParam),
      'isVariable': serializer.toJson<bool>(isVariable),
      'endDate': serializer.toJson<DateTime?>(endDate),
      'maxOccurrences': serializer.toJson<int?>(maxOccurrences),
      'occurrencesProcessed': serializer.toJson<int>(occurrencesProcessed),
      'website': serializer.toJson<String?>(website),
      'notifyBefore': serializer.toJson<bool>(notifyBefore),
      'nextRunAt': serializer.toJson<DateTime>(nextRunAt),
      'isActive': serializer.toJson<bool>(isActive),
      'autoExecute': serializer.toJson<bool>(autoExecute),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  RecurringPattern copyWith(
          {String? id,
          String? name,
          double? amount,
          String? type,
          String? category,
          String? subCategory,
          String? bucket,
          String? notes,
          Value<String?> sourceAccountId = const Value.absent(),
          Value<String?> sourceCardId = const Value.absent(),
          Value<String?> destinationAccountId = const Value.absent(),
          String? frequency,
          int? interval,
          DateTime? startDate,
          String? executionTime,
          String? scheduleType,
          Value<int?> weekParam = const Value.absent(),
          Value<int?> dayParam = const Value.absent(),
          bool? isVariable,
          Value<DateTime?> endDate = const Value.absent(),
          Value<int?> maxOccurrences = const Value.absent(),
          int? occurrencesProcessed,
          Value<String?> website = const Value.absent(),
          bool? notifyBefore,
          DateTime? nextRunAt,
          bool? isActive,
          bool? autoExecute,
          DateTime? createdAt}) =>
      RecurringPattern(
        id: id ?? this.id,
        name: name ?? this.name,
        amount: amount ?? this.amount,
        type: type ?? this.type,
        category: category ?? this.category,
        subCategory: subCategory ?? this.subCategory,
        bucket: bucket ?? this.bucket,
        notes: notes ?? this.notes,
        sourceAccountId: sourceAccountId.present
            ? sourceAccountId.value
            : this.sourceAccountId,
        sourceCardId:
            sourceCardId.present ? sourceCardId.value : this.sourceCardId,
        destinationAccountId: destinationAccountId.present
            ? destinationAccountId.value
            : this.destinationAccountId,
        frequency: frequency ?? this.frequency,
        interval: interval ?? this.interval,
        startDate: startDate ?? this.startDate,
        executionTime: executionTime ?? this.executionTime,
        scheduleType: scheduleType ?? this.scheduleType,
        weekParam: weekParam.present ? weekParam.value : this.weekParam,
        dayParam: dayParam.present ? dayParam.value : this.dayParam,
        isVariable: isVariable ?? this.isVariable,
        endDate: endDate.present ? endDate.value : this.endDate,
        maxOccurrences:
            maxOccurrences.present ? maxOccurrences.value : this.maxOccurrences,
        occurrencesProcessed: occurrencesProcessed ?? this.occurrencesProcessed,
        website: website.present ? website.value : this.website,
        notifyBefore: notifyBefore ?? this.notifyBefore,
        nextRunAt: nextRunAt ?? this.nextRunAt,
        isActive: isActive ?? this.isActive,
        autoExecute: autoExecute ?? this.autoExecute,
        createdAt: createdAt ?? this.createdAt,
      );
  RecurringPattern copyWithCompanion(RecurringPatternsCompanion data) {
    return RecurringPattern(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      amount: data.amount.present ? data.amount.value : this.amount,
      type: data.type.present ? data.type.value : this.type,
      category: data.category.present ? data.category.value : this.category,
      subCategory:
          data.subCategory.present ? data.subCategory.value : this.subCategory,
      bucket: data.bucket.present ? data.bucket.value : this.bucket,
      notes: data.notes.present ? data.notes.value : this.notes,
      sourceAccountId: data.sourceAccountId.present
          ? data.sourceAccountId.value
          : this.sourceAccountId,
      sourceCardId: data.sourceCardId.present
          ? data.sourceCardId.value
          : this.sourceCardId,
      destinationAccountId: data.destinationAccountId.present
          ? data.destinationAccountId.value
          : this.destinationAccountId,
      frequency: data.frequency.present ? data.frequency.value : this.frequency,
      interval: data.interval.present ? data.interval.value : this.interval,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      executionTime: data.executionTime.present
          ? data.executionTime.value
          : this.executionTime,
      scheduleType: data.scheduleType.present
          ? data.scheduleType.value
          : this.scheduleType,
      weekParam: data.weekParam.present ? data.weekParam.value : this.weekParam,
      dayParam: data.dayParam.present ? data.dayParam.value : this.dayParam,
      isVariable:
          data.isVariable.present ? data.isVariable.value : this.isVariable,
      endDate: data.endDate.present ? data.endDate.value : this.endDate,
      maxOccurrences: data.maxOccurrences.present
          ? data.maxOccurrences.value
          : this.maxOccurrences,
      occurrencesProcessed: data.occurrencesProcessed.present
          ? data.occurrencesProcessed.value
          : this.occurrencesProcessed,
      website: data.website.present ? data.website.value : this.website,
      notifyBefore: data.notifyBefore.present
          ? data.notifyBefore.value
          : this.notifyBefore,
      nextRunAt: data.nextRunAt.present ? data.nextRunAt.value : this.nextRunAt,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      autoExecute:
          data.autoExecute.present ? data.autoExecute.value : this.autoExecute,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecurringPattern(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('amount: $amount, ')
          ..write('type: $type, ')
          ..write('category: $category, ')
          ..write('subCategory: $subCategory, ')
          ..write('bucket: $bucket, ')
          ..write('notes: $notes, ')
          ..write('sourceAccountId: $sourceAccountId, ')
          ..write('sourceCardId: $sourceCardId, ')
          ..write('destinationAccountId: $destinationAccountId, ')
          ..write('frequency: $frequency, ')
          ..write('interval: $interval, ')
          ..write('startDate: $startDate, ')
          ..write('executionTime: $executionTime, ')
          ..write('scheduleType: $scheduleType, ')
          ..write('weekParam: $weekParam, ')
          ..write('dayParam: $dayParam, ')
          ..write('isVariable: $isVariable, ')
          ..write('endDate: $endDate, ')
          ..write('maxOccurrences: $maxOccurrences, ')
          ..write('occurrencesProcessed: $occurrencesProcessed, ')
          ..write('website: $website, ')
          ..write('notifyBefore: $notifyBefore, ')
          ..write('nextRunAt: $nextRunAt, ')
          ..write('isActive: $isActive, ')
          ..write('autoExecute: $autoExecute, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        name,
        amount,
        type,
        category,
        subCategory,
        bucket,
        notes,
        sourceAccountId,
        sourceCardId,
        destinationAccountId,
        frequency,
        interval,
        startDate,
        executionTime,
        scheduleType,
        weekParam,
        dayParam,
        isVariable,
        endDate,
        maxOccurrences,
        occurrencesProcessed,
        website,
        notifyBefore,
        nextRunAt,
        isActive,
        autoExecute,
        createdAt
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecurringPattern &&
          other.id == this.id &&
          other.name == this.name &&
          other.amount == this.amount &&
          other.type == this.type &&
          other.category == this.category &&
          other.subCategory == this.subCategory &&
          other.bucket == this.bucket &&
          other.notes == this.notes &&
          other.sourceAccountId == this.sourceAccountId &&
          other.sourceCardId == this.sourceCardId &&
          other.destinationAccountId == this.destinationAccountId &&
          other.frequency == this.frequency &&
          other.interval == this.interval &&
          other.startDate == this.startDate &&
          other.executionTime == this.executionTime &&
          other.scheduleType == this.scheduleType &&
          other.weekParam == this.weekParam &&
          other.dayParam == this.dayParam &&
          other.isVariable == this.isVariable &&
          other.endDate == this.endDate &&
          other.maxOccurrences == this.maxOccurrences &&
          other.occurrencesProcessed == this.occurrencesProcessed &&
          other.website == this.website &&
          other.notifyBefore == this.notifyBefore &&
          other.nextRunAt == this.nextRunAt &&
          other.isActive == this.isActive &&
          other.autoExecute == this.autoExecute &&
          other.createdAt == this.createdAt);
}

class RecurringPatternsCompanion extends UpdateCompanion<RecurringPattern> {
  final Value<String> id;
  final Value<String> name;
  final Value<double> amount;
  final Value<String> type;
  final Value<String> category;
  final Value<String> subCategory;
  final Value<String> bucket;
  final Value<String> notes;
  final Value<String?> sourceAccountId;
  final Value<String?> sourceCardId;
  final Value<String?> destinationAccountId;
  final Value<String> frequency;
  final Value<int> interval;
  final Value<DateTime> startDate;
  final Value<String> executionTime;
  final Value<String> scheduleType;
  final Value<int?> weekParam;
  final Value<int?> dayParam;
  final Value<bool> isVariable;
  final Value<DateTime?> endDate;
  final Value<int?> maxOccurrences;
  final Value<int> occurrencesProcessed;
  final Value<String?> website;
  final Value<bool> notifyBefore;
  final Value<DateTime> nextRunAt;
  final Value<bool> isActive;
  final Value<bool> autoExecute;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const RecurringPatternsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.amount = const Value.absent(),
    this.type = const Value.absent(),
    this.category = const Value.absent(),
    this.subCategory = const Value.absent(),
    this.bucket = const Value.absent(),
    this.notes = const Value.absent(),
    this.sourceAccountId = const Value.absent(),
    this.sourceCardId = const Value.absent(),
    this.destinationAccountId = const Value.absent(),
    this.frequency = const Value.absent(),
    this.interval = const Value.absent(),
    this.startDate = const Value.absent(),
    this.executionTime = const Value.absent(),
    this.scheduleType = const Value.absent(),
    this.weekParam = const Value.absent(),
    this.dayParam = const Value.absent(),
    this.isVariable = const Value.absent(),
    this.endDate = const Value.absent(),
    this.maxOccurrences = const Value.absent(),
    this.occurrencesProcessed = const Value.absent(),
    this.website = const Value.absent(),
    this.notifyBefore = const Value.absent(),
    this.nextRunAt = const Value.absent(),
    this.isActive = const Value.absent(),
    this.autoExecute = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RecurringPatternsCompanion.insert({
    required String id,
    required String name,
    required double amount,
    required String type,
    required String category,
    required String subCategory,
    this.bucket = const Value.absent(),
    this.notes = const Value.absent(),
    this.sourceAccountId = const Value.absent(),
    this.sourceCardId = const Value.absent(),
    this.destinationAccountId = const Value.absent(),
    required String frequency,
    this.interval = const Value.absent(),
    required DateTime startDate,
    required String executionTime,
    this.scheduleType = const Value.absent(),
    this.weekParam = const Value.absent(),
    this.dayParam = const Value.absent(),
    this.isVariable = const Value.absent(),
    this.endDate = const Value.absent(),
    this.maxOccurrences = const Value.absent(),
    this.occurrencesProcessed = const Value.absent(),
    this.website = const Value.absent(),
    this.notifyBefore = const Value.absent(),
    required DateTime nextRunAt,
    this.isActive = const Value.absent(),
    this.autoExecute = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        amount = Value(amount),
        type = Value(type),
        category = Value(category),
        subCategory = Value(subCategory),
        frequency = Value(frequency),
        startDate = Value(startDate),
        executionTime = Value(executionTime),
        nextRunAt = Value(nextRunAt);
  static Insertable<RecurringPattern> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<double>? amount,
    Expression<String>? type,
    Expression<String>? category,
    Expression<String>? subCategory,
    Expression<String>? bucket,
    Expression<String>? notes,
    Expression<String>? sourceAccountId,
    Expression<String>? sourceCardId,
    Expression<String>? destinationAccountId,
    Expression<String>? frequency,
    Expression<int>? interval,
    Expression<DateTime>? startDate,
    Expression<String>? executionTime,
    Expression<String>? scheduleType,
    Expression<int>? weekParam,
    Expression<int>? dayParam,
    Expression<bool>? isVariable,
    Expression<DateTime>? endDate,
    Expression<int>? maxOccurrences,
    Expression<int>? occurrencesProcessed,
    Expression<String>? website,
    Expression<bool>? notifyBefore,
    Expression<DateTime>? nextRunAt,
    Expression<bool>? isActive,
    Expression<bool>? autoExecute,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (amount != null) 'amount': amount,
      if (type != null) 'type': type,
      if (category != null) 'category': category,
      if (subCategory != null) 'sub_category': subCategory,
      if (bucket != null) 'bucket': bucket,
      if (notes != null) 'notes': notes,
      if (sourceAccountId != null) 'source_account_id': sourceAccountId,
      if (sourceCardId != null) 'source_card_id': sourceCardId,
      if (destinationAccountId != null)
        'destination_account_id': destinationAccountId,
      if (frequency != null) 'frequency': frequency,
      if (interval != null) 'interval': interval,
      if (startDate != null) 'start_date': startDate,
      if (executionTime != null) 'execution_time': executionTime,
      if (scheduleType != null) 'schedule_type': scheduleType,
      if (weekParam != null) 'week_param': weekParam,
      if (dayParam != null) 'day_param': dayParam,
      if (isVariable != null) 'is_variable': isVariable,
      if (endDate != null) 'end_date': endDate,
      if (maxOccurrences != null) 'max_occurrences': maxOccurrences,
      if (occurrencesProcessed != null)
        'occurrences_processed': occurrencesProcessed,
      if (website != null) 'website': website,
      if (notifyBefore != null) 'notify_before': notifyBefore,
      if (nextRunAt != null) 'next_run_at': nextRunAt,
      if (isActive != null) 'is_active': isActive,
      if (autoExecute != null) 'auto_execute': autoExecute,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RecurringPatternsCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<double>? amount,
      Value<String>? type,
      Value<String>? category,
      Value<String>? subCategory,
      Value<String>? bucket,
      Value<String>? notes,
      Value<String?>? sourceAccountId,
      Value<String?>? sourceCardId,
      Value<String?>? destinationAccountId,
      Value<String>? frequency,
      Value<int>? interval,
      Value<DateTime>? startDate,
      Value<String>? executionTime,
      Value<String>? scheduleType,
      Value<int?>? weekParam,
      Value<int?>? dayParam,
      Value<bool>? isVariable,
      Value<DateTime?>? endDate,
      Value<int?>? maxOccurrences,
      Value<int>? occurrencesProcessed,
      Value<String?>? website,
      Value<bool>? notifyBefore,
      Value<DateTime>? nextRunAt,
      Value<bool>? isActive,
      Value<bool>? autoExecute,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return RecurringPatternsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      category: category ?? this.category,
      subCategory: subCategory ?? this.subCategory,
      bucket: bucket ?? this.bucket,
      notes: notes ?? this.notes,
      sourceAccountId: sourceAccountId ?? this.sourceAccountId,
      sourceCardId: sourceCardId ?? this.sourceCardId,
      destinationAccountId: destinationAccountId ?? this.destinationAccountId,
      frequency: frequency ?? this.frequency,
      interval: interval ?? this.interval,
      startDate: startDate ?? this.startDate,
      executionTime: executionTime ?? this.executionTime,
      scheduleType: scheduleType ?? this.scheduleType,
      weekParam: weekParam ?? this.weekParam,
      dayParam: dayParam ?? this.dayParam,
      isVariable: isVariable ?? this.isVariable,
      endDate: endDate ?? this.endDate,
      maxOccurrences: maxOccurrences ?? this.maxOccurrences,
      occurrencesProcessed: occurrencesProcessed ?? this.occurrencesProcessed,
      website: website ?? this.website,
      notifyBefore: notifyBefore ?? this.notifyBefore,
      nextRunAt: nextRunAt ?? this.nextRunAt,
      isActive: isActive ?? this.isActive,
      autoExecute: autoExecute ?? this.autoExecute,
      createdAt: createdAt ?? this.createdAt,
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
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
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
    if (bucket.present) {
      map['bucket'] = Variable<String>(bucket.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (sourceAccountId.present) {
      map['source_account_id'] = Variable<String>(sourceAccountId.value);
    }
    if (sourceCardId.present) {
      map['source_card_id'] = Variable<String>(sourceCardId.value);
    }
    if (destinationAccountId.present) {
      map['destination_account_id'] =
          Variable<String>(destinationAccountId.value);
    }
    if (frequency.present) {
      map['frequency'] = Variable<String>(frequency.value);
    }
    if (interval.present) {
      map['interval'] = Variable<int>(interval.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (executionTime.present) {
      map['execution_time'] = Variable<String>(executionTime.value);
    }
    if (scheduleType.present) {
      map['schedule_type'] = Variable<String>(scheduleType.value);
    }
    if (weekParam.present) {
      map['week_param'] = Variable<int>(weekParam.value);
    }
    if (dayParam.present) {
      map['day_param'] = Variable<int>(dayParam.value);
    }
    if (isVariable.present) {
      map['is_variable'] = Variable<bool>(isVariable.value);
    }
    if (endDate.present) {
      map['end_date'] = Variable<DateTime>(endDate.value);
    }
    if (maxOccurrences.present) {
      map['max_occurrences'] = Variable<int>(maxOccurrences.value);
    }
    if (occurrencesProcessed.present) {
      map['occurrences_processed'] = Variable<int>(occurrencesProcessed.value);
    }
    if (website.present) {
      map['website'] = Variable<String>(website.value);
    }
    if (notifyBefore.present) {
      map['notify_before'] = Variable<bool>(notifyBefore.value);
    }
    if (nextRunAt.present) {
      map['next_run_at'] = Variable<DateTime>(nextRunAt.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (autoExecute.present) {
      map['auto_execute'] = Variable<bool>(autoExecute.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecurringPatternsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('amount: $amount, ')
          ..write('type: $type, ')
          ..write('category: $category, ')
          ..write('subCategory: $subCategory, ')
          ..write('bucket: $bucket, ')
          ..write('notes: $notes, ')
          ..write('sourceAccountId: $sourceAccountId, ')
          ..write('sourceCardId: $sourceCardId, ')
          ..write('destinationAccountId: $destinationAccountId, ')
          ..write('frequency: $frequency, ')
          ..write('interval: $interval, ')
          ..write('startDate: $startDate, ')
          ..write('executionTime: $executionTime, ')
          ..write('scheduleType: $scheduleType, ')
          ..write('weekParam: $weekParam, ')
          ..write('dayParam: $dayParam, ')
          ..write('isVariable: $isVariable, ')
          ..write('endDate: $endDate, ')
          ..write('maxOccurrences: $maxOccurrences, ')
          ..write('occurrencesProcessed: $occurrencesProcessed, ')
          ..write('website: $website, ')
          ..write('notifyBefore: $notifyBefore, ')
          ..write('nextRunAt: $nextRunAt, ')
          ..write('isActive: $isActive, ')
          ..write('autoExecute: $autoExecute, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RecurringLogsTable extends RecurringLogs
    with TableInfo<$RecurringLogsTable, RecurringLog> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecurringLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _patternIdMeta =
      const VerificationMeta('patternId');
  @override
  late final GeneratedColumn<String> patternId = GeneratedColumn<String>(
      'pattern_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES recurring_patterns (id)'));
  static const VerificationMeta _executedAtMeta =
      const VerificationMeta('executedAt');
  @override
  late final GeneratedColumn<DateTime> executedAt = GeneratedColumn<DateTime>(
      'executed_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _isSuccessMeta =
      const VerificationMeta('isSuccess');
  @override
  late final GeneratedColumn<bool> isSuccess = GeneratedColumn<bool>(
      'is_success', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_success" IN (0, 1))'));
  static const VerificationMeta _errorMeta = const VerificationMeta('error');
  @override
  late final GeneratedColumn<String> error = GeneratedColumn<String>(
      'error', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _generatedTxnIdMeta =
      const VerificationMeta('generatedTxnId');
  @override
  late final GeneratedColumn<String> generatedTxnId = GeneratedColumn<String>(
      'generated_txn_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, patternId, executedAt, isSuccess, error, generatedTxnId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recurring_logs';
  @override
  VerificationContext validateIntegrity(Insertable<RecurringLog> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('pattern_id')) {
      context.handle(_patternIdMeta,
          patternId.isAcceptableOrUnknown(data['pattern_id']!, _patternIdMeta));
    } else if (isInserting) {
      context.missing(_patternIdMeta);
    }
    if (data.containsKey('executed_at')) {
      context.handle(
          _executedAtMeta,
          executedAt.isAcceptableOrUnknown(
              data['executed_at']!, _executedAtMeta));
    } else if (isInserting) {
      context.missing(_executedAtMeta);
    }
    if (data.containsKey('is_success')) {
      context.handle(_isSuccessMeta,
          isSuccess.isAcceptableOrUnknown(data['is_success']!, _isSuccessMeta));
    } else if (isInserting) {
      context.missing(_isSuccessMeta);
    }
    if (data.containsKey('error')) {
      context.handle(
          _errorMeta, error.isAcceptableOrUnknown(data['error']!, _errorMeta));
    }
    if (data.containsKey('generated_txn_id')) {
      context.handle(
          _generatedTxnIdMeta,
          generatedTxnId.isAcceptableOrUnknown(
              data['generated_txn_id']!, _generatedTxnIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RecurringLog map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecurringLog(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      patternId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}pattern_id'])!,
      executedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}executed_at'])!,
      isSuccess: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_success'])!,
      error: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}error']),
      generatedTxnId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}generated_txn_id']),
    );
  }

  @override
  $RecurringLogsTable createAlias(String alias) {
    return $RecurringLogsTable(attachedDatabase, alias);
  }
}

class RecurringLog extends DataClass implements Insertable<RecurringLog> {
  final String id;
  final String patternId;
  final DateTime executedAt;
  final bool isSuccess;
  final String? error;
  final String? generatedTxnId;
  const RecurringLog(
      {required this.id,
      required this.patternId,
      required this.executedAt,
      required this.isSuccess,
      this.error,
      this.generatedTxnId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['pattern_id'] = Variable<String>(patternId);
    map['executed_at'] = Variable<DateTime>(executedAt);
    map['is_success'] = Variable<bool>(isSuccess);
    if (!nullToAbsent || error != null) {
      map['error'] = Variable<String>(error);
    }
    if (!nullToAbsent || generatedTxnId != null) {
      map['generated_txn_id'] = Variable<String>(generatedTxnId);
    }
    return map;
  }

  RecurringLogsCompanion toCompanion(bool nullToAbsent) {
    return RecurringLogsCompanion(
      id: Value(id),
      patternId: Value(patternId),
      executedAt: Value(executedAt),
      isSuccess: Value(isSuccess),
      error:
          error == null && nullToAbsent ? const Value.absent() : Value(error),
      generatedTxnId: generatedTxnId == null && nullToAbsent
          ? const Value.absent()
          : Value(generatedTxnId),
    );
  }

  factory RecurringLog.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecurringLog(
      id: serializer.fromJson<String>(json['id']),
      patternId: serializer.fromJson<String>(json['patternId']),
      executedAt: serializer.fromJson<DateTime>(json['executedAt']),
      isSuccess: serializer.fromJson<bool>(json['isSuccess']),
      error: serializer.fromJson<String?>(json['error']),
      generatedTxnId: serializer.fromJson<String?>(json['generatedTxnId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'patternId': serializer.toJson<String>(patternId),
      'executedAt': serializer.toJson<DateTime>(executedAt),
      'isSuccess': serializer.toJson<bool>(isSuccess),
      'error': serializer.toJson<String?>(error),
      'generatedTxnId': serializer.toJson<String?>(generatedTxnId),
    };
  }

  RecurringLog copyWith(
          {String? id,
          String? patternId,
          DateTime? executedAt,
          bool? isSuccess,
          Value<String?> error = const Value.absent(),
          Value<String?> generatedTxnId = const Value.absent()}) =>
      RecurringLog(
        id: id ?? this.id,
        patternId: patternId ?? this.patternId,
        executedAt: executedAt ?? this.executedAt,
        isSuccess: isSuccess ?? this.isSuccess,
        error: error.present ? error.value : this.error,
        generatedTxnId:
            generatedTxnId.present ? generatedTxnId.value : this.generatedTxnId,
      );
  RecurringLog copyWithCompanion(RecurringLogsCompanion data) {
    return RecurringLog(
      id: data.id.present ? data.id.value : this.id,
      patternId: data.patternId.present ? data.patternId.value : this.patternId,
      executedAt:
          data.executedAt.present ? data.executedAt.value : this.executedAt,
      isSuccess: data.isSuccess.present ? data.isSuccess.value : this.isSuccess,
      error: data.error.present ? data.error.value : this.error,
      generatedTxnId: data.generatedTxnId.present
          ? data.generatedTxnId.value
          : this.generatedTxnId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecurringLog(')
          ..write('id: $id, ')
          ..write('patternId: $patternId, ')
          ..write('executedAt: $executedAt, ')
          ..write('isSuccess: $isSuccess, ')
          ..write('error: $error, ')
          ..write('generatedTxnId: $generatedTxnId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, patternId, executedAt, isSuccess, error, generatedTxnId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecurringLog &&
          other.id == this.id &&
          other.patternId == this.patternId &&
          other.executedAt == this.executedAt &&
          other.isSuccess == this.isSuccess &&
          other.error == this.error &&
          other.generatedTxnId == this.generatedTxnId);
}

class RecurringLogsCompanion extends UpdateCompanion<RecurringLog> {
  final Value<String> id;
  final Value<String> patternId;
  final Value<DateTime> executedAt;
  final Value<bool> isSuccess;
  final Value<String?> error;
  final Value<String?> generatedTxnId;
  final Value<int> rowid;
  const RecurringLogsCompanion({
    this.id = const Value.absent(),
    this.patternId = const Value.absent(),
    this.executedAt = const Value.absent(),
    this.isSuccess = const Value.absent(),
    this.error = const Value.absent(),
    this.generatedTxnId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RecurringLogsCompanion.insert({
    required String id,
    required String patternId,
    required DateTime executedAt,
    required bool isSuccess,
    this.error = const Value.absent(),
    this.generatedTxnId = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        patternId = Value(patternId),
        executedAt = Value(executedAt),
        isSuccess = Value(isSuccess);
  static Insertable<RecurringLog> custom({
    Expression<String>? id,
    Expression<String>? patternId,
    Expression<DateTime>? executedAt,
    Expression<bool>? isSuccess,
    Expression<String>? error,
    Expression<String>? generatedTxnId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (patternId != null) 'pattern_id': patternId,
      if (executedAt != null) 'executed_at': executedAt,
      if (isSuccess != null) 'is_success': isSuccess,
      if (error != null) 'error': error,
      if (generatedTxnId != null) 'generated_txn_id': generatedTxnId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RecurringLogsCompanion copyWith(
      {Value<String>? id,
      Value<String>? patternId,
      Value<DateTime>? executedAt,
      Value<bool>? isSuccess,
      Value<String?>? error,
      Value<String?>? generatedTxnId,
      Value<int>? rowid}) {
    return RecurringLogsCompanion(
      id: id ?? this.id,
      patternId: patternId ?? this.patternId,
      executedAt: executedAt ?? this.executedAt,
      isSuccess: isSuccess ?? this.isSuccess,
      error: error ?? this.error,
      generatedTxnId: generatedTxnId ?? this.generatedTxnId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (patternId.present) {
      map['pattern_id'] = Variable<String>(patternId.value);
    }
    if (executedAt.present) {
      map['executed_at'] = Variable<DateTime>(executedAt.value);
    }
    if (isSuccess.present) {
      map['is_success'] = Variable<bool>(isSuccess.value);
    }
    if (error.present) {
      map['error'] = Variable<String>(error.value);
    }
    if (generatedTxnId.present) {
      map['generated_txn_id'] = Variable<String>(generatedTxnId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecurringLogsCompanion(')
          ..write('id: $id, ')
          ..write('patternId: $patternId, ')
          ..write('executedAt: $executedAt, ')
          ..write('isSuccess: $isSuccess, ')
          ..write('error: $error, ')
          ..write('generatedTxnId: $generatedTxnId, ')
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
  late final $AssetLogsTable assetLogs = $AssetLogsTable(this);
  late final $LoansTable loans = $LoansTable(this);
  late final $GoalsTable goals = $GoalsTable(this);
  late final $HeatmapLimitsTable heatmapLimits = $HeatmapLimitsTable(this);
  late final $AppNotificationsTable appNotifications =
      $AppNotificationsTable(this);
  late final $RecurringPatternsTable recurringPatterns =
      $RecurringPatternsTable(this);
  late final $RecurringLogsTable recurringLogs = $RecurringLogsTable(this);
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
        settings,
        assetLogs,
        loans,
        goals,
        heatmapLimits,
        appNotifications,
        recurringPatterns,
        recurringLogs
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

  ColumnWithTypeConverterFilters<double, double, double> get currentBalance =>
      $composableBuilder(
          column: $table.currentBalance,
          builder: (column) => ColumnWithTypeConverterFilters(column));

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

  GeneratedColumnWithTypeConverter<double, double> get currentBalance =>
      $composableBuilder(
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

  ColumnWithTypeConverterFilters<double, double, double> get currentBalance =>
      $composableBuilder(
          column: $table.currentBalance,
          builder: (column) => ColumnWithTypeConverterFilters(column));

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

  GeneratedColumnWithTypeConverter<double, double> get currentBalance =>
      $composableBuilder(
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
  Value<double> bankAccounts,
  Value<double> cashInHand,
  Value<double> mutualFunds,
  Value<double> equity,
  Value<double> bonds,
  Value<double> deposits,
  Value<double> realEstate,
  Value<double> otherAssets,
  Value<String?> assetNotes,
  Value<double> loans,
  Value<double> creditCardOutstanding,
  Value<double> creditLineOutstanding,
  Value<double> otherDebts,
  Value<String?> liabilityNotes,
  Value<double> totalIncome,
  Value<double> totalExpense,
  Value<double> budgetedIncome,
  Value<double> budgetedExpense,
  Value<double> nonCalcIncome,
  Value<double> nonCalcExpense,
  Value<double> outOfBucketExpense,
  Value<int> rowid,
});
typedef $$NetWorthSplitsTableUpdateCompanionBuilder = NetWorthSplitsCompanion
    Function({
  Value<String> id,
  Value<DateTime> date,
  Value<double> bankAccounts,
  Value<double> cashInHand,
  Value<double> mutualFunds,
  Value<double> equity,
  Value<double> bonds,
  Value<double> deposits,
  Value<double> realEstate,
  Value<double> otherAssets,
  Value<String?> assetNotes,
  Value<double> loans,
  Value<double> creditCardOutstanding,
  Value<double> creditLineOutstanding,
  Value<double> otherDebts,
  Value<String?> liabilityNotes,
  Value<double> totalIncome,
  Value<double> totalExpense,
  Value<double> budgetedIncome,
  Value<double> budgetedExpense,
  Value<double> nonCalcIncome,
  Value<double> nonCalcExpense,
  Value<double> outOfBucketExpense,
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

  ColumnFilters<double> get bankAccounts => $composableBuilder(
      column: $table.bankAccounts, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get cashInHand => $composableBuilder(
      column: $table.cashInHand, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get mutualFunds => $composableBuilder(
      column: $table.mutualFunds, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get equity => $composableBuilder(
      column: $table.equity, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get bonds => $composableBuilder(
      column: $table.bonds, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get deposits => $composableBuilder(
      column: $table.deposits, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get realEstate => $composableBuilder(
      column: $table.realEstate, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get otherAssets => $composableBuilder(
      column: $table.otherAssets, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get assetNotes => $composableBuilder(
      column: $table.assetNotes, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get loans => $composableBuilder(
      column: $table.loans, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get creditCardOutstanding => $composableBuilder(
      column: $table.creditCardOutstanding,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get creditLineOutstanding => $composableBuilder(
      column: $table.creditLineOutstanding,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get otherDebts => $composableBuilder(
      column: $table.otherDebts, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get liabilityNotes => $composableBuilder(
      column: $table.liabilityNotes,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get totalIncome => $composableBuilder(
      column: $table.totalIncome, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get totalExpense => $composableBuilder(
      column: $table.totalExpense, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get budgetedIncome => $composableBuilder(
      column: $table.budgetedIncome,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get budgetedExpense => $composableBuilder(
      column: $table.budgetedExpense,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get nonCalcIncome => $composableBuilder(
      column: $table.nonCalcIncome, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get nonCalcExpense => $composableBuilder(
      column: $table.nonCalcExpense,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get outOfBucketExpense => $composableBuilder(
      column: $table.outOfBucketExpense,
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

  ColumnOrderings<double> get bankAccounts => $composableBuilder(
      column: $table.bankAccounts,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get cashInHand => $composableBuilder(
      column: $table.cashInHand, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get mutualFunds => $composableBuilder(
      column: $table.mutualFunds, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get equity => $composableBuilder(
      column: $table.equity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get bonds => $composableBuilder(
      column: $table.bonds, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get deposits => $composableBuilder(
      column: $table.deposits, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get realEstate => $composableBuilder(
      column: $table.realEstate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get otherAssets => $composableBuilder(
      column: $table.otherAssets, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get assetNotes => $composableBuilder(
      column: $table.assetNotes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get loans => $composableBuilder(
      column: $table.loans, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get creditCardOutstanding => $composableBuilder(
      column: $table.creditCardOutstanding,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get creditLineOutstanding => $composableBuilder(
      column: $table.creditLineOutstanding,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get otherDebts => $composableBuilder(
      column: $table.otherDebts, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get liabilityNotes => $composableBuilder(
      column: $table.liabilityNotes,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get totalIncome => $composableBuilder(
      column: $table.totalIncome, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get totalExpense => $composableBuilder(
      column: $table.totalExpense,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get budgetedIncome => $composableBuilder(
      column: $table.budgetedIncome,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get budgetedExpense => $composableBuilder(
      column: $table.budgetedExpense,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get nonCalcIncome => $composableBuilder(
      column: $table.nonCalcIncome,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get nonCalcExpense => $composableBuilder(
      column: $table.nonCalcExpense,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get outOfBucketExpense => $composableBuilder(
      column: $table.outOfBucketExpense,
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

  GeneratedColumn<double> get bankAccounts => $composableBuilder(
      column: $table.bankAccounts, builder: (column) => column);

  GeneratedColumn<double> get cashInHand => $composableBuilder(
      column: $table.cashInHand, builder: (column) => column);

  GeneratedColumn<double> get mutualFunds => $composableBuilder(
      column: $table.mutualFunds, builder: (column) => column);

  GeneratedColumn<double> get equity =>
      $composableBuilder(column: $table.equity, builder: (column) => column);

  GeneratedColumn<double> get bonds =>
      $composableBuilder(column: $table.bonds, builder: (column) => column);

  GeneratedColumn<double> get deposits =>
      $composableBuilder(column: $table.deposits, builder: (column) => column);

  GeneratedColumn<double> get realEstate => $composableBuilder(
      column: $table.realEstate, builder: (column) => column);

  GeneratedColumn<double> get otherAssets => $composableBuilder(
      column: $table.otherAssets, builder: (column) => column);

  GeneratedColumn<String> get assetNotes => $composableBuilder(
      column: $table.assetNotes, builder: (column) => column);

  GeneratedColumn<double> get loans =>
      $composableBuilder(column: $table.loans, builder: (column) => column);

  GeneratedColumn<double> get creditCardOutstanding => $composableBuilder(
      column: $table.creditCardOutstanding, builder: (column) => column);

  GeneratedColumn<double> get creditLineOutstanding => $composableBuilder(
      column: $table.creditLineOutstanding, builder: (column) => column);

  GeneratedColumn<double> get otherDebts => $composableBuilder(
      column: $table.otherDebts, builder: (column) => column);

  GeneratedColumn<String> get liabilityNotes => $composableBuilder(
      column: $table.liabilityNotes, builder: (column) => column);

  GeneratedColumn<double> get totalIncome => $composableBuilder(
      column: $table.totalIncome, builder: (column) => column);

  GeneratedColumn<double> get totalExpense => $composableBuilder(
      column: $table.totalExpense, builder: (column) => column);

  GeneratedColumn<double> get budgetedIncome => $composableBuilder(
      column: $table.budgetedIncome, builder: (column) => column);

  GeneratedColumn<double> get budgetedExpense => $composableBuilder(
      column: $table.budgetedExpense, builder: (column) => column);

  GeneratedColumn<double> get nonCalcIncome => $composableBuilder(
      column: $table.nonCalcIncome, builder: (column) => column);

  GeneratedColumn<double> get nonCalcExpense => $composableBuilder(
      column: $table.nonCalcExpense, builder: (column) => column);

  GeneratedColumn<double> get outOfBucketExpense => $composableBuilder(
      column: $table.outOfBucketExpense, builder: (column) => column);
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
            Value<double> bankAccounts = const Value.absent(),
            Value<double> cashInHand = const Value.absent(),
            Value<double> mutualFunds = const Value.absent(),
            Value<double> equity = const Value.absent(),
            Value<double> bonds = const Value.absent(),
            Value<double> deposits = const Value.absent(),
            Value<double> realEstate = const Value.absent(),
            Value<double> otherAssets = const Value.absent(),
            Value<String?> assetNotes = const Value.absent(),
            Value<double> loans = const Value.absent(),
            Value<double> creditCardOutstanding = const Value.absent(),
            Value<double> creditLineOutstanding = const Value.absent(),
            Value<double> otherDebts = const Value.absent(),
            Value<String?> liabilityNotes = const Value.absent(),
            Value<double> totalIncome = const Value.absent(),
            Value<double> totalExpense = const Value.absent(),
            Value<double> budgetedIncome = const Value.absent(),
            Value<double> budgetedExpense = const Value.absent(),
            Value<double> nonCalcIncome = const Value.absent(),
            Value<double> nonCalcExpense = const Value.absent(),
            Value<double> outOfBucketExpense = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              NetWorthSplitsCompanion(
            id: id,
            date: date,
            bankAccounts: bankAccounts,
            cashInHand: cashInHand,
            mutualFunds: mutualFunds,
            equity: equity,
            bonds: bonds,
            deposits: deposits,
            realEstate: realEstate,
            otherAssets: otherAssets,
            assetNotes: assetNotes,
            loans: loans,
            creditCardOutstanding: creditCardOutstanding,
            creditLineOutstanding: creditLineOutstanding,
            otherDebts: otherDebts,
            liabilityNotes: liabilityNotes,
            totalIncome: totalIncome,
            totalExpense: totalExpense,
            budgetedIncome: budgetedIncome,
            budgetedExpense: budgetedExpense,
            nonCalcIncome: nonCalcIncome,
            nonCalcExpense: nonCalcExpense,
            outOfBucketExpense: outOfBucketExpense,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required DateTime date,
            Value<double> bankAccounts = const Value.absent(),
            Value<double> cashInHand = const Value.absent(),
            Value<double> mutualFunds = const Value.absent(),
            Value<double> equity = const Value.absent(),
            Value<double> bonds = const Value.absent(),
            Value<double> deposits = const Value.absent(),
            Value<double> realEstate = const Value.absent(),
            Value<double> otherAssets = const Value.absent(),
            Value<String?> assetNotes = const Value.absent(),
            Value<double> loans = const Value.absent(),
            Value<double> creditCardOutstanding = const Value.absent(),
            Value<double> creditLineOutstanding = const Value.absent(),
            Value<double> otherDebts = const Value.absent(),
            Value<String?> liabilityNotes = const Value.absent(),
            Value<double> totalIncome = const Value.absent(),
            Value<double> totalExpense = const Value.absent(),
            Value<double> budgetedIncome = const Value.absent(),
            Value<double> budgetedExpense = const Value.absent(),
            Value<double> nonCalcIncome = const Value.absent(),
            Value<double> nonCalcExpense = const Value.absent(),
            Value<double> outOfBucketExpense = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              NetWorthSplitsCompanion.insert(
            id: id,
            date: date,
            bankAccounts: bankAccounts,
            cashInHand: cashInHand,
            mutualFunds: mutualFunds,
            equity: equity,
            bonds: bonds,
            deposits: deposits,
            realEstate: realEstate,
            otherAssets: otherAssets,
            assetNotes: assetNotes,
            loans: loans,
            creditCardOutstanding: creditCardOutstanding,
            creditLineOutstanding: creditLineOutstanding,
            otherDebts: otherDebts,
            liabilityNotes: liabilityNotes,
            totalIncome: totalIncome,
            totalExpense: totalExpense,
            budgetedIncome: budgetedIncome,
            budgetedExpense: budgetedExpense,
            nonCalcIncome: nonCalcIncome,
            nonCalcExpense: nonCalcExpense,
            outOfBucketExpense: outOfBucketExpense,
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
typedef $$AssetLogsTableCreateCompanionBuilder = AssetLogsCompanion Function({
  required String id,
  required String parentId,
  required String type,
  required double amount,
  Value<double> interestComponent,
  required DateTime date,
  Value<String?> notes,
  Value<int> rowid,
});
typedef $$AssetLogsTableUpdateCompanionBuilder = AssetLogsCompanion Function({
  Value<String> id,
  Value<String> parentId,
  Value<String> type,
  Value<double> amount,
  Value<double> interestComponent,
  Value<DateTime> date,
  Value<String?> notes,
  Value<int> rowid,
});

class $$AssetLogsTableFilterComposer
    extends Composer<_$AppDatabase, $AssetLogsTable> {
  $$AssetLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get parentId => $composableBuilder(
      column: $table.parentId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get interestComponent => $composableBuilder(
      column: $table.interestComponent,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));
}

class $$AssetLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $AssetLogsTable> {
  $$AssetLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get parentId => $composableBuilder(
      column: $table.parentId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get interestComponent => $composableBuilder(
      column: $table.interestComponent,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));
}

class $$AssetLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AssetLogsTable> {
  $$AssetLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get parentId =>
      $composableBuilder(column: $table.parentId, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<double> get interestComponent => $composableBuilder(
      column: $table.interestComponent, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);
}

class $$AssetLogsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AssetLogsTable,
    AssetLog,
    $$AssetLogsTableFilterComposer,
    $$AssetLogsTableOrderingComposer,
    $$AssetLogsTableAnnotationComposer,
    $$AssetLogsTableCreateCompanionBuilder,
    $$AssetLogsTableUpdateCompanionBuilder,
    (AssetLog, BaseReferences<_$AppDatabase, $AssetLogsTable, AssetLog>),
    AssetLog,
    PrefetchHooks Function()> {
  $$AssetLogsTableTableManager(_$AppDatabase db, $AssetLogsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AssetLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AssetLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AssetLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> parentId = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<double> amount = const Value.absent(),
            Value<double> interestComponent = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AssetLogsCompanion(
            id: id,
            parentId: parentId,
            type: type,
            amount: amount,
            interestComponent: interestComponent,
            date: date,
            notes: notes,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String parentId,
            required String type,
            required double amount,
            Value<double> interestComponent = const Value.absent(),
            required DateTime date,
            Value<String?> notes = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AssetLogsCompanion.insert(
            id: id,
            parentId: parentId,
            type: type,
            amount: amount,
            interestComponent: interestComponent,
            date: date,
            notes: notes,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AssetLogsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AssetLogsTable,
    AssetLog,
    $$AssetLogsTableFilterComposer,
    $$AssetLogsTableOrderingComposer,
    $$AssetLogsTableAnnotationComposer,
    $$AssetLogsTableCreateCompanionBuilder,
    $$AssetLogsTableUpdateCompanionBuilder,
    (AssetLog, BaseReferences<_$AppDatabase, $AssetLogsTable, AssetLog>),
    AssetLog,
    PrefetchHooks Function()>;
typedef $$LoansTableCreateCompanionBuilder = LoansCompanion Function({
  required String id,
  required String title,
  required String provider,
  required String type,
  Value<double> principalAmount,
  required double totalAmount,
  Value<double> paidAmount,
  Value<double> interestRate,
  Value<double?> emiAmount,
  required DateTime startDate,
  Value<DateTime?> dueDate,
  Value<DateTime?> nextPaymentDate,
  Value<String?> notes,
  Value<bool> isClosed,
  Value<int> rowid,
});
typedef $$LoansTableUpdateCompanionBuilder = LoansCompanion Function({
  Value<String> id,
  Value<String> title,
  Value<String> provider,
  Value<String> type,
  Value<double> principalAmount,
  Value<double> totalAmount,
  Value<double> paidAmount,
  Value<double> interestRate,
  Value<double?> emiAmount,
  Value<DateTime> startDate,
  Value<DateTime?> dueDate,
  Value<DateTime?> nextPaymentDate,
  Value<String?> notes,
  Value<bool> isClosed,
  Value<int> rowid,
});

class $$LoansTableFilterComposer extends Composer<_$AppDatabase, $LoansTable> {
  $$LoansTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get provider => $composableBuilder(
      column: $table.provider, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get principalAmount => $composableBuilder(
      column: $table.principalAmount,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get totalAmount => $composableBuilder(
      column: $table.totalAmount, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get paidAmount => $composableBuilder(
      column: $table.paidAmount, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get interestRate => $composableBuilder(
      column: $table.interestRate, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get emiAmount => $composableBuilder(
      column: $table.emiAmount, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startDate => $composableBuilder(
      column: $table.startDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get dueDate => $composableBuilder(
      column: $table.dueDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get nextPaymentDate => $composableBuilder(
      column: $table.nextPaymentDate,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isClosed => $composableBuilder(
      column: $table.isClosed, builder: (column) => ColumnFilters(column));
}

class $$LoansTableOrderingComposer
    extends Composer<_$AppDatabase, $LoansTable> {
  $$LoansTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get provider => $composableBuilder(
      column: $table.provider, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get principalAmount => $composableBuilder(
      column: $table.principalAmount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get totalAmount => $composableBuilder(
      column: $table.totalAmount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get paidAmount => $composableBuilder(
      column: $table.paidAmount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get interestRate => $composableBuilder(
      column: $table.interestRate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get emiAmount => $composableBuilder(
      column: $table.emiAmount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
      column: $table.startDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get dueDate => $composableBuilder(
      column: $table.dueDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get nextPaymentDate => $composableBuilder(
      column: $table.nextPaymentDate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isClosed => $composableBuilder(
      column: $table.isClosed, builder: (column) => ColumnOrderings(column));
}

class $$LoansTableAnnotationComposer
    extends Composer<_$AppDatabase, $LoansTable> {
  $$LoansTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get provider =>
      $composableBuilder(column: $table.provider, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<double> get principalAmount => $composableBuilder(
      column: $table.principalAmount, builder: (column) => column);

  GeneratedColumn<double> get totalAmount => $composableBuilder(
      column: $table.totalAmount, builder: (column) => column);

  GeneratedColumn<double> get paidAmount => $composableBuilder(
      column: $table.paidAmount, builder: (column) => column);

  GeneratedColumn<double> get interestRate => $composableBuilder(
      column: $table.interestRate, builder: (column) => column);

  GeneratedColumn<double> get emiAmount =>
      $composableBuilder(column: $table.emiAmount, builder: (column) => column);

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<DateTime> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<DateTime> get nextPaymentDate => $composableBuilder(
      column: $table.nextPaymentDate, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<bool> get isClosed =>
      $composableBuilder(column: $table.isClosed, builder: (column) => column);
}

class $$LoansTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LoansTable,
    Loan,
    $$LoansTableFilterComposer,
    $$LoansTableOrderingComposer,
    $$LoansTableAnnotationComposer,
    $$LoansTableCreateCompanionBuilder,
    $$LoansTableUpdateCompanionBuilder,
    (Loan, BaseReferences<_$AppDatabase, $LoansTable, Loan>),
    Loan,
    PrefetchHooks Function()> {
  $$LoansTableTableManager(_$AppDatabase db, $LoansTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LoansTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LoansTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LoansTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> provider = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<double> principalAmount = const Value.absent(),
            Value<double> totalAmount = const Value.absent(),
            Value<double> paidAmount = const Value.absent(),
            Value<double> interestRate = const Value.absent(),
            Value<double?> emiAmount = const Value.absent(),
            Value<DateTime> startDate = const Value.absent(),
            Value<DateTime?> dueDate = const Value.absent(),
            Value<DateTime?> nextPaymentDate = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<bool> isClosed = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LoansCompanion(
            id: id,
            title: title,
            provider: provider,
            type: type,
            principalAmount: principalAmount,
            totalAmount: totalAmount,
            paidAmount: paidAmount,
            interestRate: interestRate,
            emiAmount: emiAmount,
            startDate: startDate,
            dueDate: dueDate,
            nextPaymentDate: nextPaymentDate,
            notes: notes,
            isClosed: isClosed,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String title,
            required String provider,
            required String type,
            Value<double> principalAmount = const Value.absent(),
            required double totalAmount,
            Value<double> paidAmount = const Value.absent(),
            Value<double> interestRate = const Value.absent(),
            Value<double?> emiAmount = const Value.absent(),
            required DateTime startDate,
            Value<DateTime?> dueDate = const Value.absent(),
            Value<DateTime?> nextPaymentDate = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<bool> isClosed = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LoansCompanion.insert(
            id: id,
            title: title,
            provider: provider,
            type: type,
            principalAmount: principalAmount,
            totalAmount: totalAmount,
            paidAmount: paidAmount,
            interestRate: interestRate,
            emiAmount: emiAmount,
            startDate: startDate,
            dueDate: dueDate,
            nextPaymentDate: nextPaymentDate,
            notes: notes,
            isClosed: isClosed,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LoansTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LoansTable,
    Loan,
    $$LoansTableFilterComposer,
    $$LoansTableOrderingComposer,
    $$LoansTableAnnotationComposer,
    $$LoansTableCreateCompanionBuilder,
    $$LoansTableUpdateCompanionBuilder,
    (Loan, BaseReferences<_$AppDatabase, $LoansTable, Loan>),
    Loan,
    PrefetchHooks Function()>;
typedef $$GoalsTableCreateCompanionBuilder = GoalsCompanion Function({
  required String id,
  required String name,
  Value<String?> purpose,
  Value<String> investmentType,
  Value<String?> identificationNumber,
  Value<double> currentAmount,
  required double targetAmount,
  Value<DateTime> startDate,
  Value<DateTime?> deadline,
  Value<double?> expectedReturn,
  required int color,
  Value<String?> icon,
  Value<bool> isCompleted,
  required DateTime createdAt,
  Value<String?> category,
  Value<String> priority,
  Value<double?> monthlyContributionTarget,
  Value<int> rowid,
});
typedef $$GoalsTableUpdateCompanionBuilder = GoalsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String?> purpose,
  Value<String> investmentType,
  Value<String?> identificationNumber,
  Value<double> currentAmount,
  Value<double> targetAmount,
  Value<DateTime> startDate,
  Value<DateTime?> deadline,
  Value<double?> expectedReturn,
  Value<int> color,
  Value<String?> icon,
  Value<bool> isCompleted,
  Value<DateTime> createdAt,
  Value<String?> category,
  Value<String> priority,
  Value<double?> monthlyContributionTarget,
  Value<int> rowid,
});

class $$GoalsTableFilterComposer extends Composer<_$AppDatabase, $GoalsTable> {
  $$GoalsTableFilterComposer({
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

  ColumnFilters<String> get purpose => $composableBuilder(
      column: $table.purpose, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get investmentType => $composableBuilder(
      column: $table.investmentType,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get identificationNumber => $composableBuilder(
      column: $table.identificationNumber,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get currentAmount => $composableBuilder(
      column: $table.currentAmount, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get targetAmount => $composableBuilder(
      column: $table.targetAmount, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startDate => $composableBuilder(
      column: $table.startDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deadline => $composableBuilder(
      column: $table.deadline, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get expectedReturn => $composableBuilder(
      column: $table.expectedReturn,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get color => $composableBuilder(
      column: $table.color, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get icon => $composableBuilder(
      column: $table.icon, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get priority => $composableBuilder(
      column: $table.priority, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get monthlyContributionTarget => $composableBuilder(
      column: $table.monthlyContributionTarget,
      builder: (column) => ColumnFilters(column));
}

class $$GoalsTableOrderingComposer
    extends Composer<_$AppDatabase, $GoalsTable> {
  $$GoalsTableOrderingComposer({
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

  ColumnOrderings<String> get purpose => $composableBuilder(
      column: $table.purpose, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get investmentType => $composableBuilder(
      column: $table.investmentType,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get identificationNumber => $composableBuilder(
      column: $table.identificationNumber,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get currentAmount => $composableBuilder(
      column: $table.currentAmount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get targetAmount => $composableBuilder(
      column: $table.targetAmount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
      column: $table.startDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deadline => $composableBuilder(
      column: $table.deadline, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get expectedReturn => $composableBuilder(
      column: $table.expectedReturn,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get color => $composableBuilder(
      column: $table.color, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get icon => $composableBuilder(
      column: $table.icon, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get priority => $composableBuilder(
      column: $table.priority, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get monthlyContributionTarget => $composableBuilder(
      column: $table.monthlyContributionTarget,
      builder: (column) => ColumnOrderings(column));
}

class $$GoalsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GoalsTable> {
  $$GoalsTableAnnotationComposer({
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

  GeneratedColumn<String> get purpose =>
      $composableBuilder(column: $table.purpose, builder: (column) => column);

  GeneratedColumn<String> get investmentType => $composableBuilder(
      column: $table.investmentType, builder: (column) => column);

  GeneratedColumn<String> get identificationNumber => $composableBuilder(
      column: $table.identificationNumber, builder: (column) => column);

  GeneratedColumn<double> get currentAmount => $composableBuilder(
      column: $table.currentAmount, builder: (column) => column);

  GeneratedColumn<double> get targetAmount => $composableBuilder(
      column: $table.targetAmount, builder: (column) => column);

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<DateTime> get deadline =>
      $composableBuilder(column: $table.deadline, builder: (column) => column);

  GeneratedColumn<double> get expectedReturn => $composableBuilder(
      column: $table.expectedReturn, builder: (column) => column);

  GeneratedColumn<int> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<double> get monthlyContributionTarget => $composableBuilder(
      column: $table.monthlyContributionTarget, builder: (column) => column);
}

class $$GoalsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $GoalsTable,
    Goal,
    $$GoalsTableFilterComposer,
    $$GoalsTableOrderingComposer,
    $$GoalsTableAnnotationComposer,
    $$GoalsTableCreateCompanionBuilder,
    $$GoalsTableUpdateCompanionBuilder,
    (Goal, BaseReferences<_$AppDatabase, $GoalsTable, Goal>),
    Goal,
    PrefetchHooks Function()> {
  $$GoalsTableTableManager(_$AppDatabase db, $GoalsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GoalsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GoalsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GoalsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> purpose = const Value.absent(),
            Value<String> investmentType = const Value.absent(),
            Value<String?> identificationNumber = const Value.absent(),
            Value<double> currentAmount = const Value.absent(),
            Value<double> targetAmount = const Value.absent(),
            Value<DateTime> startDate = const Value.absent(),
            Value<DateTime?> deadline = const Value.absent(),
            Value<double?> expectedReturn = const Value.absent(),
            Value<int> color = const Value.absent(),
            Value<String?> icon = const Value.absent(),
            Value<bool> isCompleted = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<String?> category = const Value.absent(),
            Value<String> priority = const Value.absent(),
            Value<double?> monthlyContributionTarget = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              GoalsCompanion(
            id: id,
            name: name,
            purpose: purpose,
            investmentType: investmentType,
            identificationNumber: identificationNumber,
            currentAmount: currentAmount,
            targetAmount: targetAmount,
            startDate: startDate,
            deadline: deadline,
            expectedReturn: expectedReturn,
            color: color,
            icon: icon,
            isCompleted: isCompleted,
            createdAt: createdAt,
            category: category,
            priority: priority,
            monthlyContributionTarget: monthlyContributionTarget,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            Value<String?> purpose = const Value.absent(),
            Value<String> investmentType = const Value.absent(),
            Value<String?> identificationNumber = const Value.absent(),
            Value<double> currentAmount = const Value.absent(),
            required double targetAmount,
            Value<DateTime> startDate = const Value.absent(),
            Value<DateTime?> deadline = const Value.absent(),
            Value<double?> expectedReturn = const Value.absent(),
            required int color,
            Value<String?> icon = const Value.absent(),
            Value<bool> isCompleted = const Value.absent(),
            required DateTime createdAt,
            Value<String?> category = const Value.absent(),
            Value<String> priority = const Value.absent(),
            Value<double?> monthlyContributionTarget = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              GoalsCompanion.insert(
            id: id,
            name: name,
            purpose: purpose,
            investmentType: investmentType,
            identificationNumber: identificationNumber,
            currentAmount: currentAmount,
            targetAmount: targetAmount,
            startDate: startDate,
            deadline: deadline,
            expectedReturn: expectedReturn,
            color: color,
            icon: icon,
            isCompleted: isCompleted,
            createdAt: createdAt,
            category: category,
            priority: priority,
            monthlyContributionTarget: monthlyContributionTarget,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$GoalsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $GoalsTable,
    Goal,
    $$GoalsTableFilterComposer,
    $$GoalsTableOrderingComposer,
    $$GoalsTableAnnotationComposer,
    $$GoalsTableCreateCompanionBuilder,
    $$GoalsTableUpdateCompanionBuilder,
    (Goal, BaseReferences<_$AppDatabase, $GoalsTable, Goal>),
    Goal,
    PrefetchHooks Function()>;
typedef $$HeatmapLimitsTableCreateCompanionBuilder = HeatmapLimitsCompanion
    Function({
  required String id,
  Value<double> safeLimit,
  Value<double> cautionLimit,
  Value<double> severeLimit,
  Value<int> rowid,
});
typedef $$HeatmapLimitsTableUpdateCompanionBuilder = HeatmapLimitsCompanion
    Function({
  Value<String> id,
  Value<double> safeLimit,
  Value<double> cautionLimit,
  Value<double> severeLimit,
  Value<int> rowid,
});

class $$HeatmapLimitsTableFilterComposer
    extends Composer<_$AppDatabase, $HeatmapLimitsTable> {
  $$HeatmapLimitsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get safeLimit => $composableBuilder(
      column: $table.safeLimit, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get cautionLimit => $composableBuilder(
      column: $table.cautionLimit, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get severeLimit => $composableBuilder(
      column: $table.severeLimit, builder: (column) => ColumnFilters(column));
}

class $$HeatmapLimitsTableOrderingComposer
    extends Composer<_$AppDatabase, $HeatmapLimitsTable> {
  $$HeatmapLimitsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get safeLimit => $composableBuilder(
      column: $table.safeLimit, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get cautionLimit => $composableBuilder(
      column: $table.cautionLimit,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get severeLimit => $composableBuilder(
      column: $table.severeLimit, builder: (column) => ColumnOrderings(column));
}

class $$HeatmapLimitsTableAnnotationComposer
    extends Composer<_$AppDatabase, $HeatmapLimitsTable> {
  $$HeatmapLimitsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get safeLimit =>
      $composableBuilder(column: $table.safeLimit, builder: (column) => column);

  GeneratedColumn<double> get cautionLimit => $composableBuilder(
      column: $table.cautionLimit, builder: (column) => column);

  GeneratedColumn<double> get severeLimit => $composableBuilder(
      column: $table.severeLimit, builder: (column) => column);
}

class $$HeatmapLimitsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $HeatmapLimitsTable,
    HeatmapLimit,
    $$HeatmapLimitsTableFilterComposer,
    $$HeatmapLimitsTableOrderingComposer,
    $$HeatmapLimitsTableAnnotationComposer,
    $$HeatmapLimitsTableCreateCompanionBuilder,
    $$HeatmapLimitsTableUpdateCompanionBuilder,
    (
      HeatmapLimit,
      BaseReferences<_$AppDatabase, $HeatmapLimitsTable, HeatmapLimit>
    ),
    HeatmapLimit,
    PrefetchHooks Function()> {
  $$HeatmapLimitsTableTableManager(_$AppDatabase db, $HeatmapLimitsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HeatmapLimitsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HeatmapLimitsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HeatmapLimitsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<double> safeLimit = const Value.absent(),
            Value<double> cautionLimit = const Value.absent(),
            Value<double> severeLimit = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              HeatmapLimitsCompanion(
            id: id,
            safeLimit: safeLimit,
            cautionLimit: cautionLimit,
            severeLimit: severeLimit,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<double> safeLimit = const Value.absent(),
            Value<double> cautionLimit = const Value.absent(),
            Value<double> severeLimit = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              HeatmapLimitsCompanion.insert(
            id: id,
            safeLimit: safeLimit,
            cautionLimit: cautionLimit,
            severeLimit: severeLimit,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$HeatmapLimitsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $HeatmapLimitsTable,
    HeatmapLimit,
    $$HeatmapLimitsTableFilterComposer,
    $$HeatmapLimitsTableOrderingComposer,
    $$HeatmapLimitsTableAnnotationComposer,
    $$HeatmapLimitsTableCreateCompanionBuilder,
    $$HeatmapLimitsTableUpdateCompanionBuilder,
    (
      HeatmapLimit,
      BaseReferences<_$AppDatabase, $HeatmapLimitsTable, HeatmapLimit>
    ),
    HeatmapLimit,
    PrefetchHooks Function()>;
typedef $$AppNotificationsTableCreateCompanionBuilder
    = AppNotificationsCompanion Function({
  required String id,
  required String type,
  required String title,
  required String message,
  Value<String?> payload,
  Value<bool> isRead,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$AppNotificationsTableUpdateCompanionBuilder
    = AppNotificationsCompanion Function({
  Value<String> id,
  Value<String> type,
  Value<String> title,
  Value<String> message,
  Value<String?> payload,
  Value<bool> isRead,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$AppNotificationsTableFilterComposer
    extends Composer<_$AppDatabase, $AppNotificationsTable> {
  $$AppNotificationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get message => $composableBuilder(
      column: $table.message, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payload => $composableBuilder(
      column: $table.payload, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isRead => $composableBuilder(
      column: $table.isRead, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$AppNotificationsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppNotificationsTable> {
  $$AppNotificationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get message => $composableBuilder(
      column: $table.message, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payload => $composableBuilder(
      column: $table.payload, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isRead => $composableBuilder(
      column: $table.isRead, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$AppNotificationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppNotificationsTable> {
  $$AppNotificationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get message =>
      $composableBuilder(column: $table.message, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<bool> get isRead =>
      $composableBuilder(column: $table.isRead, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$AppNotificationsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AppNotificationsTable,
    AppNotification,
    $$AppNotificationsTableFilterComposer,
    $$AppNotificationsTableOrderingComposer,
    $$AppNotificationsTableAnnotationComposer,
    $$AppNotificationsTableCreateCompanionBuilder,
    $$AppNotificationsTableUpdateCompanionBuilder,
    (
      AppNotification,
      BaseReferences<_$AppDatabase, $AppNotificationsTable, AppNotification>
    ),
    AppNotification,
    PrefetchHooks Function()> {
  $$AppNotificationsTableTableManager(
      _$AppDatabase db, $AppNotificationsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppNotificationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppNotificationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppNotificationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String> message = const Value.absent(),
            Value<String?> payload = const Value.absent(),
            Value<bool> isRead = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AppNotificationsCompanion(
            id: id,
            type: type,
            title: title,
            message: message,
            payload: payload,
            isRead: isRead,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String type,
            required String title,
            required String message,
            Value<String?> payload = const Value.absent(),
            Value<bool> isRead = const Value.absent(),
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              AppNotificationsCompanion.insert(
            id: id,
            type: type,
            title: title,
            message: message,
            payload: payload,
            isRead: isRead,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AppNotificationsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AppNotificationsTable,
    AppNotification,
    $$AppNotificationsTableFilterComposer,
    $$AppNotificationsTableOrderingComposer,
    $$AppNotificationsTableAnnotationComposer,
    $$AppNotificationsTableCreateCompanionBuilder,
    $$AppNotificationsTableUpdateCompanionBuilder,
    (
      AppNotification,
      BaseReferences<_$AppDatabase, $AppNotificationsTable, AppNotification>
    ),
    AppNotification,
    PrefetchHooks Function()>;
typedef $$RecurringPatternsTableCreateCompanionBuilder
    = RecurringPatternsCompanion Function({
  required String id,
  required String name,
  required double amount,
  required String type,
  required String category,
  required String subCategory,
  Value<String> bucket,
  Value<String> notes,
  Value<String?> sourceAccountId,
  Value<String?> sourceCardId,
  Value<String?> destinationAccountId,
  required String frequency,
  Value<int> interval,
  required DateTime startDate,
  required String executionTime,
  Value<String> scheduleType,
  Value<int?> weekParam,
  Value<int?> dayParam,
  Value<bool> isVariable,
  Value<DateTime?> endDate,
  Value<int?> maxOccurrences,
  Value<int> occurrencesProcessed,
  Value<String?> website,
  Value<bool> notifyBefore,
  required DateTime nextRunAt,
  Value<bool> isActive,
  Value<bool> autoExecute,
  Value<DateTime> createdAt,
  Value<int> rowid,
});
typedef $$RecurringPatternsTableUpdateCompanionBuilder
    = RecurringPatternsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<double> amount,
  Value<String> type,
  Value<String> category,
  Value<String> subCategory,
  Value<String> bucket,
  Value<String> notes,
  Value<String?> sourceAccountId,
  Value<String?> sourceCardId,
  Value<String?> destinationAccountId,
  Value<String> frequency,
  Value<int> interval,
  Value<DateTime> startDate,
  Value<String> executionTime,
  Value<String> scheduleType,
  Value<int?> weekParam,
  Value<int?> dayParam,
  Value<bool> isVariable,
  Value<DateTime?> endDate,
  Value<int?> maxOccurrences,
  Value<int> occurrencesProcessed,
  Value<String?> website,
  Value<bool> notifyBefore,
  Value<DateTime> nextRunAt,
  Value<bool> isActive,
  Value<bool> autoExecute,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

final class $$RecurringPatternsTableReferences extends BaseReferences<
    _$AppDatabase, $RecurringPatternsTable, RecurringPattern> {
  $$RecurringPatternsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$RecurringLogsTable, List<RecurringLog>>
      _recurringLogsRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.recurringLogs,
              aliasName: $_aliasNameGenerator(
                  db.recurringPatterns.id, db.recurringLogs.patternId));

  $$RecurringLogsTableProcessedTableManager get recurringLogsRefs {
    final manager = $$RecurringLogsTableTableManager($_db, $_db.recurringLogs)
        .filter((f) => f.patternId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_recurringLogsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$RecurringPatternsTableFilterComposer
    extends Composer<_$AppDatabase, $RecurringPatternsTable> {
  $$RecurringPatternsTableFilterComposer({
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

  ColumnFilters<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get subCategory => $composableBuilder(
      column: $table.subCategory, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get bucket => $composableBuilder(
      column: $table.bucket, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sourceAccountId => $composableBuilder(
      column: $table.sourceAccountId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sourceCardId => $composableBuilder(
      column: $table.sourceCardId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get destinationAccountId => $composableBuilder(
      column: $table.destinationAccountId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get frequency => $composableBuilder(
      column: $table.frequency, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get interval => $composableBuilder(
      column: $table.interval, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startDate => $composableBuilder(
      column: $table.startDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get executionTime => $composableBuilder(
      column: $table.executionTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get scheduleType => $composableBuilder(
      column: $table.scheduleType, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get weekParam => $composableBuilder(
      column: $table.weekParam, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get dayParam => $composableBuilder(
      column: $table.dayParam, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isVariable => $composableBuilder(
      column: $table.isVariable, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get endDate => $composableBuilder(
      column: $table.endDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get maxOccurrences => $composableBuilder(
      column: $table.maxOccurrences,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get occurrencesProcessed => $composableBuilder(
      column: $table.occurrencesProcessed,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get website => $composableBuilder(
      column: $table.website, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get notifyBefore => $composableBuilder(
      column: $table.notifyBefore, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get nextRunAt => $composableBuilder(
      column: $table.nextRunAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get autoExecute => $composableBuilder(
      column: $table.autoExecute, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  Expression<bool> recurringLogsRefs(
      Expression<bool> Function($$RecurringLogsTableFilterComposer f) f) {
    final $$RecurringLogsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.recurringLogs,
        getReferencedColumn: (t) => t.patternId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RecurringLogsTableFilterComposer(
              $db: $db,
              $table: $db.recurringLogs,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$RecurringPatternsTableOrderingComposer
    extends Composer<_$AppDatabase, $RecurringPatternsTable> {
  $$RecurringPatternsTableOrderingComposer({
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

  ColumnOrderings<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get subCategory => $composableBuilder(
      column: $table.subCategory, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get bucket => $composableBuilder(
      column: $table.bucket, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sourceAccountId => $composableBuilder(
      column: $table.sourceAccountId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sourceCardId => $composableBuilder(
      column: $table.sourceCardId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get destinationAccountId => $composableBuilder(
      column: $table.destinationAccountId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get frequency => $composableBuilder(
      column: $table.frequency, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get interval => $composableBuilder(
      column: $table.interval, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
      column: $table.startDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get executionTime => $composableBuilder(
      column: $table.executionTime,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get scheduleType => $composableBuilder(
      column: $table.scheduleType,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get weekParam => $composableBuilder(
      column: $table.weekParam, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get dayParam => $composableBuilder(
      column: $table.dayParam, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isVariable => $composableBuilder(
      column: $table.isVariable, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get endDate => $composableBuilder(
      column: $table.endDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get maxOccurrences => $composableBuilder(
      column: $table.maxOccurrences,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get occurrencesProcessed => $composableBuilder(
      column: $table.occurrencesProcessed,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get website => $composableBuilder(
      column: $table.website, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get notifyBefore => $composableBuilder(
      column: $table.notifyBefore,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get nextRunAt => $composableBuilder(
      column: $table.nextRunAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get autoExecute => $composableBuilder(
      column: $table.autoExecute, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$RecurringPatternsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecurringPatternsTable> {
  $$RecurringPatternsTableAnnotationComposer({
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

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get subCategory => $composableBuilder(
      column: $table.subCategory, builder: (column) => column);

  GeneratedColumn<String> get bucket =>
      $composableBuilder(column: $table.bucket, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get sourceAccountId => $composableBuilder(
      column: $table.sourceAccountId, builder: (column) => column);

  GeneratedColumn<String> get sourceCardId => $composableBuilder(
      column: $table.sourceCardId, builder: (column) => column);

  GeneratedColumn<String> get destinationAccountId => $composableBuilder(
      column: $table.destinationAccountId, builder: (column) => column);

  GeneratedColumn<String> get frequency =>
      $composableBuilder(column: $table.frequency, builder: (column) => column);

  GeneratedColumn<int> get interval =>
      $composableBuilder(column: $table.interval, builder: (column) => column);

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<String> get executionTime => $composableBuilder(
      column: $table.executionTime, builder: (column) => column);

  GeneratedColumn<String> get scheduleType => $composableBuilder(
      column: $table.scheduleType, builder: (column) => column);

  GeneratedColumn<int> get weekParam =>
      $composableBuilder(column: $table.weekParam, builder: (column) => column);

  GeneratedColumn<int> get dayParam =>
      $composableBuilder(column: $table.dayParam, builder: (column) => column);

  GeneratedColumn<bool> get isVariable => $composableBuilder(
      column: $table.isVariable, builder: (column) => column);

  GeneratedColumn<DateTime> get endDate =>
      $composableBuilder(column: $table.endDate, builder: (column) => column);

  GeneratedColumn<int> get maxOccurrences => $composableBuilder(
      column: $table.maxOccurrences, builder: (column) => column);

  GeneratedColumn<int> get occurrencesProcessed => $composableBuilder(
      column: $table.occurrencesProcessed, builder: (column) => column);

  GeneratedColumn<String> get website =>
      $composableBuilder(column: $table.website, builder: (column) => column);

  GeneratedColumn<bool> get notifyBefore => $composableBuilder(
      column: $table.notifyBefore, builder: (column) => column);

  GeneratedColumn<DateTime> get nextRunAt =>
      $composableBuilder(column: $table.nextRunAt, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<bool> get autoExecute => $composableBuilder(
      column: $table.autoExecute, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> recurringLogsRefs<T extends Object>(
      Expression<T> Function($$RecurringLogsTableAnnotationComposer a) f) {
    final $$RecurringLogsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.recurringLogs,
        getReferencedColumn: (t) => t.patternId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RecurringLogsTableAnnotationComposer(
              $db: $db,
              $table: $db.recurringLogs,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$RecurringPatternsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RecurringPatternsTable,
    RecurringPattern,
    $$RecurringPatternsTableFilterComposer,
    $$RecurringPatternsTableOrderingComposer,
    $$RecurringPatternsTableAnnotationComposer,
    $$RecurringPatternsTableCreateCompanionBuilder,
    $$RecurringPatternsTableUpdateCompanionBuilder,
    (RecurringPattern, $$RecurringPatternsTableReferences),
    RecurringPattern,
    PrefetchHooks Function({bool recurringLogsRefs})> {
  $$RecurringPatternsTableTableManager(
      _$AppDatabase db, $RecurringPatternsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecurringPatternsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecurringPatternsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecurringPatternsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<double> amount = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<String> subCategory = const Value.absent(),
            Value<String> bucket = const Value.absent(),
            Value<String> notes = const Value.absent(),
            Value<String?> sourceAccountId = const Value.absent(),
            Value<String?> sourceCardId = const Value.absent(),
            Value<String?> destinationAccountId = const Value.absent(),
            Value<String> frequency = const Value.absent(),
            Value<int> interval = const Value.absent(),
            Value<DateTime> startDate = const Value.absent(),
            Value<String> executionTime = const Value.absent(),
            Value<String> scheduleType = const Value.absent(),
            Value<int?> weekParam = const Value.absent(),
            Value<int?> dayParam = const Value.absent(),
            Value<bool> isVariable = const Value.absent(),
            Value<DateTime?> endDate = const Value.absent(),
            Value<int?> maxOccurrences = const Value.absent(),
            Value<int> occurrencesProcessed = const Value.absent(),
            Value<String?> website = const Value.absent(),
            Value<bool> notifyBefore = const Value.absent(),
            Value<DateTime> nextRunAt = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<bool> autoExecute = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RecurringPatternsCompanion(
            id: id,
            name: name,
            amount: amount,
            type: type,
            category: category,
            subCategory: subCategory,
            bucket: bucket,
            notes: notes,
            sourceAccountId: sourceAccountId,
            sourceCardId: sourceCardId,
            destinationAccountId: destinationAccountId,
            frequency: frequency,
            interval: interval,
            startDate: startDate,
            executionTime: executionTime,
            scheduleType: scheduleType,
            weekParam: weekParam,
            dayParam: dayParam,
            isVariable: isVariable,
            endDate: endDate,
            maxOccurrences: maxOccurrences,
            occurrencesProcessed: occurrencesProcessed,
            website: website,
            notifyBefore: notifyBefore,
            nextRunAt: nextRunAt,
            isActive: isActive,
            autoExecute: autoExecute,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            required double amount,
            required String type,
            required String category,
            required String subCategory,
            Value<String> bucket = const Value.absent(),
            Value<String> notes = const Value.absent(),
            Value<String?> sourceAccountId = const Value.absent(),
            Value<String?> sourceCardId = const Value.absent(),
            Value<String?> destinationAccountId = const Value.absent(),
            required String frequency,
            Value<int> interval = const Value.absent(),
            required DateTime startDate,
            required String executionTime,
            Value<String> scheduleType = const Value.absent(),
            Value<int?> weekParam = const Value.absent(),
            Value<int?> dayParam = const Value.absent(),
            Value<bool> isVariable = const Value.absent(),
            Value<DateTime?> endDate = const Value.absent(),
            Value<int?> maxOccurrences = const Value.absent(),
            Value<int> occurrencesProcessed = const Value.absent(),
            Value<String?> website = const Value.absent(),
            Value<bool> notifyBefore = const Value.absent(),
            required DateTime nextRunAt,
            Value<bool> isActive = const Value.absent(),
            Value<bool> autoExecute = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RecurringPatternsCompanion.insert(
            id: id,
            name: name,
            amount: amount,
            type: type,
            category: category,
            subCategory: subCategory,
            bucket: bucket,
            notes: notes,
            sourceAccountId: sourceAccountId,
            sourceCardId: sourceCardId,
            destinationAccountId: destinationAccountId,
            frequency: frequency,
            interval: interval,
            startDate: startDate,
            executionTime: executionTime,
            scheduleType: scheduleType,
            weekParam: weekParam,
            dayParam: dayParam,
            isVariable: isVariable,
            endDate: endDate,
            maxOccurrences: maxOccurrences,
            occurrencesProcessed: occurrencesProcessed,
            website: website,
            notifyBefore: notifyBefore,
            nextRunAt: nextRunAt,
            isActive: isActive,
            autoExecute: autoExecute,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$RecurringPatternsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({recurringLogsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (recurringLogsRefs) db.recurringLogs
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (recurringLogsRefs)
                    await $_getPrefetchedData<RecurringPattern,
                            $RecurringPatternsTable, RecurringLog>(
                        currentTable: table,
                        referencedTable: $$RecurringPatternsTableReferences
                            ._recurringLogsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$RecurringPatternsTableReferences(db, table, p0)
                                .recurringLogsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.patternId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$RecurringPatternsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $RecurringPatternsTable,
    RecurringPattern,
    $$RecurringPatternsTableFilterComposer,
    $$RecurringPatternsTableOrderingComposer,
    $$RecurringPatternsTableAnnotationComposer,
    $$RecurringPatternsTableCreateCompanionBuilder,
    $$RecurringPatternsTableUpdateCompanionBuilder,
    (RecurringPattern, $$RecurringPatternsTableReferences),
    RecurringPattern,
    PrefetchHooks Function({bool recurringLogsRefs})>;
typedef $$RecurringLogsTableCreateCompanionBuilder = RecurringLogsCompanion
    Function({
  required String id,
  required String patternId,
  required DateTime executedAt,
  required bool isSuccess,
  Value<String?> error,
  Value<String?> generatedTxnId,
  Value<int> rowid,
});
typedef $$RecurringLogsTableUpdateCompanionBuilder = RecurringLogsCompanion
    Function({
  Value<String> id,
  Value<String> patternId,
  Value<DateTime> executedAt,
  Value<bool> isSuccess,
  Value<String?> error,
  Value<String?> generatedTxnId,
  Value<int> rowid,
});

final class $$RecurringLogsTableReferences
    extends BaseReferences<_$AppDatabase, $RecurringLogsTable, RecurringLog> {
  $$RecurringLogsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $RecurringPatternsTable _patternIdTable(_$AppDatabase db) =>
      db.recurringPatterns.createAlias($_aliasNameGenerator(
          db.recurringLogs.patternId, db.recurringPatterns.id));

  $$RecurringPatternsTableProcessedTableManager get patternId {
    final $_column = $_itemColumn<String>('pattern_id')!;

    final manager =
        $$RecurringPatternsTableTableManager($_db, $_db.recurringPatterns)
            .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_patternIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$RecurringLogsTableFilterComposer
    extends Composer<_$AppDatabase, $RecurringLogsTable> {
  $$RecurringLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get executedAt => $composableBuilder(
      column: $table.executedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isSuccess => $composableBuilder(
      column: $table.isSuccess, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get error => $composableBuilder(
      column: $table.error, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get generatedTxnId => $composableBuilder(
      column: $table.generatedTxnId,
      builder: (column) => ColumnFilters(column));

  $$RecurringPatternsTableFilterComposer get patternId {
    final $$RecurringPatternsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.patternId,
        referencedTable: $db.recurringPatterns,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RecurringPatternsTableFilterComposer(
              $db: $db,
              $table: $db.recurringPatterns,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$RecurringLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $RecurringLogsTable> {
  $$RecurringLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get executedAt => $composableBuilder(
      column: $table.executedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isSuccess => $composableBuilder(
      column: $table.isSuccess, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get error => $composableBuilder(
      column: $table.error, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get generatedTxnId => $composableBuilder(
      column: $table.generatedTxnId,
      builder: (column) => ColumnOrderings(column));

  $$RecurringPatternsTableOrderingComposer get patternId {
    final $$RecurringPatternsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.patternId,
        referencedTable: $db.recurringPatterns,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RecurringPatternsTableOrderingComposer(
              $db: $db,
              $table: $db.recurringPatterns,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$RecurringLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecurringLogsTable> {
  $$RecurringLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get executedAt => $composableBuilder(
      column: $table.executedAt, builder: (column) => column);

  GeneratedColumn<bool> get isSuccess =>
      $composableBuilder(column: $table.isSuccess, builder: (column) => column);

  GeneratedColumn<String> get error =>
      $composableBuilder(column: $table.error, builder: (column) => column);

  GeneratedColumn<String> get generatedTxnId => $composableBuilder(
      column: $table.generatedTxnId, builder: (column) => column);

  $$RecurringPatternsTableAnnotationComposer get patternId {
    final $$RecurringPatternsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.patternId,
            referencedTable: $db.recurringPatterns,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$RecurringPatternsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.recurringPatterns,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return composer;
  }
}

class $$RecurringLogsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RecurringLogsTable,
    RecurringLog,
    $$RecurringLogsTableFilterComposer,
    $$RecurringLogsTableOrderingComposer,
    $$RecurringLogsTableAnnotationComposer,
    $$RecurringLogsTableCreateCompanionBuilder,
    $$RecurringLogsTableUpdateCompanionBuilder,
    (RecurringLog, $$RecurringLogsTableReferences),
    RecurringLog,
    PrefetchHooks Function({bool patternId})> {
  $$RecurringLogsTableTableManager(_$AppDatabase db, $RecurringLogsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecurringLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecurringLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecurringLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> patternId = const Value.absent(),
            Value<DateTime> executedAt = const Value.absent(),
            Value<bool> isSuccess = const Value.absent(),
            Value<String?> error = const Value.absent(),
            Value<String?> generatedTxnId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RecurringLogsCompanion(
            id: id,
            patternId: patternId,
            executedAt: executedAt,
            isSuccess: isSuccess,
            error: error,
            generatedTxnId: generatedTxnId,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String patternId,
            required DateTime executedAt,
            required bool isSuccess,
            Value<String?> error = const Value.absent(),
            Value<String?> generatedTxnId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RecurringLogsCompanion.insert(
            id: id,
            patternId: patternId,
            executedAt: executedAt,
            isSuccess: isSuccess,
            error: error,
            generatedTxnId: generatedTxnId,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$RecurringLogsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({patternId = false}) {
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
                if (patternId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.patternId,
                    referencedTable:
                        $$RecurringLogsTableReferences._patternIdTable(db),
                    referencedColumn:
                        $$RecurringLogsTableReferences._patternIdTable(db).id,
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

typedef $$RecurringLogsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $RecurringLogsTable,
    RecurringLog,
    $$RecurringLogsTableFilterComposer,
    $$RecurringLogsTableOrderingComposer,
    $$RecurringLogsTableAnnotationComposer,
    $$RecurringLogsTableCreateCompanionBuilder,
    $$RecurringLogsTableUpdateCompanionBuilder,
    (RecurringLog, $$RecurringLogsTableReferences),
    RecurringLog,
    PrefetchHooks Function({bool patternId})>;

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
  $$AssetLogsTableTableManager get assetLogs =>
      $$AssetLogsTableTableManager(_db, _db.assetLogs);
  $$LoansTableTableManager get loans =>
      $$LoansTableTableManager(_db, _db.loans);
  $$GoalsTableTableManager get goals =>
      $$GoalsTableTableManager(_db, _db.goals);
  $$HeatmapLimitsTableTableManager get heatmapLimits =>
      $$HeatmapLimitsTableTableManager(_db, _db.heatmapLimits);
  $$AppNotificationsTableTableManager get appNotifications =>
      $$AppNotificationsTableTableManager(_db, _db.appNotifications);
  $$RecurringPatternsTableTableManager get recurringPatterns =>
      $$RecurringPatternsTableTableManager(_db, _db.recurringPatterns);
  $$RecurringLogsTableTableManager get recurringLogs =>
      $$RecurringLogsTableTableManager(_db, _db.recurringLogs);
}
