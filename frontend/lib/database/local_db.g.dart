// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_db.dart';

// ignore_for_file: type=lint
class $GroupsTableTable extends GroupsTable
    with TableInfo<$GroupsTableTable, GroupsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GroupsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _villageNameMeta =
      const VerificationMeta('villageName');
  @override
  late final GeneratedColumn<String> villageName = GeneratedColumn<String>(
      'village_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _codeMeta = const VerificationMeta('code');
  @override
  late final GeneratedColumn<String> code = GeneratedColumn<String>(
      'code', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
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
  @override
  List<GeneratedColumn> get $columns => [id, name, villageName, code, isActive];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'groups';
  @override
  VerificationContext validateIntegrity(Insertable<GroupsTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('village_name')) {
      context.handle(
          _villageNameMeta,
          villageName.isAcceptableOrUnknown(
              data['village_name']!, _villageNameMeta));
    } else if (isInserting) {
      context.missing(_villageNameMeta);
    }
    if (data.containsKey('code')) {
      context.handle(
          _codeMeta, code.isAcceptableOrUnknown(data['code']!, _codeMeta));
    } else if (isInserting) {
      context.missing(_codeMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GroupsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GroupsTableData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      villageName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}village_name'])!,
      code: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}code'])!,
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
    );
  }

  @override
  $GroupsTableTable createAlias(String alias) {
    return $GroupsTableTable(attachedDatabase, alias);
  }
}

class GroupsTableData extends DataClass implements Insertable<GroupsTableData> {
  final int id;
  final String name;
  final String villageName;
  final String code;
  final bool isActive;
  const GroupsTableData(
      {required this.id,
      required this.name,
      required this.villageName,
      required this.code,
      required this.isActive});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['village_name'] = Variable<String>(villageName);
    map['code'] = Variable<String>(code);
    map['is_active'] = Variable<bool>(isActive);
    return map;
  }

  GroupsTableCompanion toCompanion(bool nullToAbsent) {
    return GroupsTableCompanion(
      id: Value(id),
      name: Value(name),
      villageName: Value(villageName),
      code: Value(code),
      isActive: Value(isActive),
    );
  }

  factory GroupsTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GroupsTableData(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      villageName: serializer.fromJson<String>(json['villageName']),
      code: serializer.fromJson<String>(json['code']),
      isActive: serializer.fromJson<bool>(json['isActive']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'villageName': serializer.toJson<String>(villageName),
      'code': serializer.toJson<String>(code),
      'isActive': serializer.toJson<bool>(isActive),
    };
  }

  GroupsTableData copyWith(
          {int? id,
          String? name,
          String? villageName,
          String? code,
          bool? isActive}) =>
      GroupsTableData(
        id: id ?? this.id,
        name: name ?? this.name,
        villageName: villageName ?? this.villageName,
        code: code ?? this.code,
        isActive: isActive ?? this.isActive,
      );
  GroupsTableData copyWithCompanion(GroupsTableCompanion data) {
    return GroupsTableData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      villageName:
          data.villageName.present ? data.villageName.value : this.villageName,
      code: data.code.present ? data.code.value : this.code,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GroupsTableData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('villageName: $villageName, ')
          ..write('code: $code, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, villageName, code, isActive);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GroupsTableData &&
          other.id == this.id &&
          other.name == this.name &&
          other.villageName == this.villageName &&
          other.code == this.code &&
          other.isActive == this.isActive);
}

class GroupsTableCompanion extends UpdateCompanion<GroupsTableData> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> villageName;
  final Value<String> code;
  final Value<bool> isActive;
  const GroupsTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.villageName = const Value.absent(),
    this.code = const Value.absent(),
    this.isActive = const Value.absent(),
  });
  GroupsTableCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String villageName,
    required String code,
    this.isActive = const Value.absent(),
  })  : name = Value(name),
        villageName = Value(villageName),
        code = Value(code);
  static Insertable<GroupsTableData> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? villageName,
    Expression<String>? code,
    Expression<bool>? isActive,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (villageName != null) 'village_name': villageName,
      if (code != null) 'code': code,
      if (isActive != null) 'is_active': isActive,
    });
  }

  GroupsTableCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<String>? villageName,
      Value<String>? code,
      Value<bool>? isActive}) {
    return GroupsTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      villageName: villageName ?? this.villageName,
      code: code ?? this.code,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (villageName.present) {
      map['village_name'] = Variable<String>(villageName.value);
    }
    if (code.present) {
      map['code'] = Variable<String>(code.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GroupsTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('villageName: $villageName, ')
          ..write('code: $code, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }
}

class $MonthEntriesTableTable extends MonthEntriesTable
    with TableInfo<$MonthEntriesTableTable, MonthEntriesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MonthEntriesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _localIdMeta =
      const VerificationMeta('localId');
  @override
  late final GeneratedColumn<String> localId = GeneratedColumn<String>(
      'local_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _serverIdMeta =
      const VerificationMeta('serverId');
  @override
  late final GeneratedColumn<int> serverId = GeneratedColumn<int>(
      'server_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _groupIdMeta =
      const VerificationMeta('groupId');
  @override
  late final GeneratedColumn<int> groupId = GeneratedColumn<int>(
      'group_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _entryMonthMeta =
      const VerificationMeta('entryMonth');
  @override
  late final GeneratedColumn<String> entryMonth = GeneratedColumn<String>(
      'entry_month', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _entryModeMeta =
      const VerificationMeta('entryMode');
  @override
  late final GeneratedColumn<String> entryMode = GeneratedColumn<String>(
      'entry_mode', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('manual'));
  static const VerificationMeta _savingsCollectedMeta =
      const VerificationMeta('savingsCollected');
  @override
  late final GeneratedColumn<double> savingsCollected = GeneratedColumn<double>(
      'savings_collected', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _internalLoanPrincipalDisbursedMeta =
      const VerificationMeta('internalLoanPrincipalDisbursed');
  @override
  late final GeneratedColumn<double> internalLoanPrincipalDisbursed =
      GeneratedColumn<double>(
          'internal_loan_principal_disbursed', aliasedName, false,
          type: DriftSqlType.double,
          requiredDuringInsert: false,
          defaultValue: const Constant(0));
  static const VerificationMeta _internalLoanInterestCollectedMeta =
      const VerificationMeta('internalLoanInterestCollected');
  @override
  late final GeneratedColumn<double> internalLoanInterestCollected =
      GeneratedColumn<double>(
          'internal_loan_interest_collected', aliasedName, false,
          type: DriftSqlType.double,
          requiredDuringInsert: false,
          defaultValue: const Constant(0));
  static const VerificationMeta _toBankMeta = const VerificationMeta('toBank');
  @override
  late final GeneratedColumn<double> toBank = GeneratedColumn<double>(
      'to_bank', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _fromBankMeta =
      const VerificationMeta('fromBank');
  @override
  late final GeneratedColumn<double> fromBank = GeneratedColumn<double>(
      'from_bank', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _sofaLoanDisbursedMeta =
      const VerificationMeta('sofaLoanDisbursed');
  @override
  late final GeneratedColumn<double> sofaLoanDisbursed =
      GeneratedColumn<double>('sofa_loan_disbursed', aliasedName, false,
          type: DriftSqlType.double,
          requiredDuringInsert: false,
          defaultValue: const Constant(0));
  static const VerificationMeta _sofaLoanRepaymentMeta =
      const VerificationMeta('sofaLoanRepayment');
  @override
  late final GeneratedColumn<double> sofaLoanRepayment =
      GeneratedColumn<double>('sofa_loan_repayment', aliasedName, false,
          type: DriftSqlType.double,
          requiredDuringInsert: false,
          defaultValue: const Constant(0));
  static const VerificationMeta _sofaLoanInterestCollectedMeta =
      const VerificationMeta('sofaLoanInterestCollected');
  @override
  late final GeneratedColumn<double> sofaLoanInterestCollected =
      GeneratedColumn<double>(
          'sofa_loan_interest_collected', aliasedName, false,
          type: DriftSqlType.double,
          requiredDuringInsert: false,
          defaultValue: const Constant(0));
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
      'notes', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _warningFlagsMeta =
      const VerificationMeta('warningFlags');
  @override
  late final GeneratedColumn<String> warningFlags = GeneratedColumn<String>(
      'warning_flags', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('[]'));
  static const VerificationMeta _syncStatusMeta =
      const VerificationMeta('syncStatus');
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
      'sync_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pending_sync'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<String> createdAt = GeneratedColumn<String>(
      'created_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<String> updatedAt = GeneratedColumn<String>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        localId,
        serverId,
        groupId,
        entryMonth,
        entryMode,
        savingsCollected,
        internalLoanPrincipalDisbursed,
        internalLoanInterestCollected,
        toBank,
        fromBank,
        sofaLoanDisbursed,
        sofaLoanRepayment,
        sofaLoanInterestCollected,
        notes,
        warningFlags,
        syncStatus,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'month_entries';
  @override
  VerificationContext validateIntegrity(
      Insertable<MonthEntriesTableData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('local_id')) {
      context.handle(_localIdMeta,
          localId.isAcceptableOrUnknown(data['local_id']!, _localIdMeta));
    } else if (isInserting) {
      context.missing(_localIdMeta);
    }
    if (data.containsKey('server_id')) {
      context.handle(_serverIdMeta,
          serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta));
    }
    if (data.containsKey('group_id')) {
      context.handle(_groupIdMeta,
          groupId.isAcceptableOrUnknown(data['group_id']!, _groupIdMeta));
    } else if (isInserting) {
      context.missing(_groupIdMeta);
    }
    if (data.containsKey('entry_month')) {
      context.handle(
          _entryMonthMeta,
          entryMonth.isAcceptableOrUnknown(
              data['entry_month']!, _entryMonthMeta));
    } else if (isInserting) {
      context.missing(_entryMonthMeta);
    }
    if (data.containsKey('entry_mode')) {
      context.handle(_entryModeMeta,
          entryMode.isAcceptableOrUnknown(data['entry_mode']!, _entryModeMeta));
    }
    if (data.containsKey('savings_collected')) {
      context.handle(
          _savingsCollectedMeta,
          savingsCollected.isAcceptableOrUnknown(
              data['savings_collected']!, _savingsCollectedMeta));
    }
    if (data.containsKey('internal_loan_principal_disbursed')) {
      context.handle(
          _internalLoanPrincipalDisbursedMeta,
          internalLoanPrincipalDisbursed.isAcceptableOrUnknown(
              data['internal_loan_principal_disbursed']!,
              _internalLoanPrincipalDisbursedMeta));
    }
    if (data.containsKey('internal_loan_interest_collected')) {
      context.handle(
          _internalLoanInterestCollectedMeta,
          internalLoanInterestCollected.isAcceptableOrUnknown(
              data['internal_loan_interest_collected']!,
              _internalLoanInterestCollectedMeta));
    }
    if (data.containsKey('to_bank')) {
      context.handle(_toBankMeta,
          toBank.isAcceptableOrUnknown(data['to_bank']!, _toBankMeta));
    }
    if (data.containsKey('from_bank')) {
      context.handle(_fromBankMeta,
          fromBank.isAcceptableOrUnknown(data['from_bank']!, _fromBankMeta));
    }
    if (data.containsKey('sofa_loan_disbursed')) {
      context.handle(
          _sofaLoanDisbursedMeta,
          sofaLoanDisbursed.isAcceptableOrUnknown(
              data['sofa_loan_disbursed']!, _sofaLoanDisbursedMeta));
    }
    if (data.containsKey('sofa_loan_repayment')) {
      context.handle(
          _sofaLoanRepaymentMeta,
          sofaLoanRepayment.isAcceptableOrUnknown(
              data['sofa_loan_repayment']!, _sofaLoanRepaymentMeta));
    }
    if (data.containsKey('sofa_loan_interest_collected')) {
      context.handle(
          _sofaLoanInterestCollectedMeta,
          sofaLoanInterestCollected.isAcceptableOrUnknown(
              data['sofa_loan_interest_collected']!,
              _sofaLoanInterestCollectedMeta));
    }
    if (data.containsKey('notes')) {
      context.handle(
          _notesMeta, notes.isAcceptableOrUnknown(data['notes']!, _notesMeta));
    }
    if (data.containsKey('warning_flags')) {
      context.handle(
          _warningFlagsMeta,
          warningFlags.isAcceptableOrUnknown(
              data['warning_flags']!, _warningFlagsMeta));
    }
    if (data.containsKey('sync_status')) {
      context.handle(
          _syncStatusMeta,
          syncStatus.isAcceptableOrUnknown(
              data['sync_status']!, _syncStatusMeta));
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
  Set<GeneratedColumn> get $primaryKey => {localId};
  @override
  MonthEntriesTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MonthEntriesTableData(
      localId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}local_id'])!,
      serverId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}server_id']),
      groupId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}group_id'])!,
      entryMonth: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entry_month'])!,
      entryMode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entry_mode'])!,
      savingsCollected: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}savings_collected'])!,
      internalLoanPrincipalDisbursed: attachedDatabase.typeMapping.read(
          DriftSqlType.double,
          data['${effectivePrefix}internal_loan_principal_disbursed'])!,
      internalLoanInterestCollected: attachedDatabase.typeMapping.read(
          DriftSqlType.double,
          data['${effectivePrefix}internal_loan_interest_collected'])!,
      toBank: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}to_bank'])!,
      fromBank: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}from_bank'])!,
      sofaLoanDisbursed: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}sofa_loan_disbursed'])!,
      sofaLoanRepayment: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}sofa_loan_repayment'])!,
      sofaLoanInterestCollected: attachedDatabase.typeMapping.read(
          DriftSqlType.double,
          data['${effectivePrefix}sofa_loan_interest_collected'])!,
      notes: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}notes']),
      warningFlags: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}warning_flags'])!,
      syncStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sync_status'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $MonthEntriesTableTable createAlias(String alias) {
    return $MonthEntriesTableTable(attachedDatabase, alias);
  }
}

class MonthEntriesTableData extends DataClass
    implements Insertable<MonthEntriesTableData> {
  final String localId;
  final int? serverId;
  final int groupId;
  final String entryMonth;
  final String entryMode;
  final double savingsCollected;
  final double internalLoanPrincipalDisbursed;
  final double internalLoanInterestCollected;
  final double toBank;
  final double fromBank;
  final double sofaLoanDisbursed;
  final double sofaLoanRepayment;
  final double sofaLoanInterestCollected;
  final String? notes;
  final String warningFlags;
  final String syncStatus;
  final String createdAt;
  final String updatedAt;
  const MonthEntriesTableData(
      {required this.localId,
      this.serverId,
      required this.groupId,
      required this.entryMonth,
      required this.entryMode,
      required this.savingsCollected,
      required this.internalLoanPrincipalDisbursed,
      required this.internalLoanInterestCollected,
      required this.toBank,
      required this.fromBank,
      required this.sofaLoanDisbursed,
      required this.sofaLoanRepayment,
      required this.sofaLoanInterestCollected,
      this.notes,
      required this.warningFlags,
      required this.syncStatus,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['local_id'] = Variable<String>(localId);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<int>(serverId);
    }
    map['group_id'] = Variable<int>(groupId);
    map['entry_month'] = Variable<String>(entryMonth);
    map['entry_mode'] = Variable<String>(entryMode);
    map['savings_collected'] = Variable<double>(savingsCollected);
    map['internal_loan_principal_disbursed'] =
        Variable<double>(internalLoanPrincipalDisbursed);
    map['internal_loan_interest_collected'] =
        Variable<double>(internalLoanInterestCollected);
    map['to_bank'] = Variable<double>(toBank);
    map['from_bank'] = Variable<double>(fromBank);
    map['sofa_loan_disbursed'] = Variable<double>(sofaLoanDisbursed);
    map['sofa_loan_repayment'] = Variable<double>(sofaLoanRepayment);
    map['sofa_loan_interest_collected'] =
        Variable<double>(sofaLoanInterestCollected);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['warning_flags'] = Variable<String>(warningFlags);
    map['sync_status'] = Variable<String>(syncStatus);
    map['created_at'] = Variable<String>(createdAt);
    map['updated_at'] = Variable<String>(updatedAt);
    return map;
  }

  MonthEntriesTableCompanion toCompanion(bool nullToAbsent) {
    return MonthEntriesTableCompanion(
      localId: Value(localId),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      groupId: Value(groupId),
      entryMonth: Value(entryMonth),
      entryMode: Value(entryMode),
      savingsCollected: Value(savingsCollected),
      internalLoanPrincipalDisbursed: Value(internalLoanPrincipalDisbursed),
      internalLoanInterestCollected: Value(internalLoanInterestCollected),
      toBank: Value(toBank),
      fromBank: Value(fromBank),
      sofaLoanDisbursed: Value(sofaLoanDisbursed),
      sofaLoanRepayment: Value(sofaLoanRepayment),
      sofaLoanInterestCollected: Value(sofaLoanInterestCollected),
      notes:
          notes == null && nullToAbsent ? const Value.absent() : Value(notes),
      warningFlags: Value(warningFlags),
      syncStatus: Value(syncStatus),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory MonthEntriesTableData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MonthEntriesTableData(
      localId: serializer.fromJson<String>(json['localId']),
      serverId: serializer.fromJson<int?>(json['serverId']),
      groupId: serializer.fromJson<int>(json['groupId']),
      entryMonth: serializer.fromJson<String>(json['entryMonth']),
      entryMode: serializer.fromJson<String>(json['entryMode']),
      savingsCollected: serializer.fromJson<double>(json['savingsCollected']),
      internalLoanPrincipalDisbursed:
          serializer.fromJson<double>(json['internalLoanPrincipalDisbursed']),
      internalLoanInterestCollected:
          serializer.fromJson<double>(json['internalLoanInterestCollected']),
      toBank: serializer.fromJson<double>(json['toBank']),
      fromBank: serializer.fromJson<double>(json['fromBank']),
      sofaLoanDisbursed: serializer.fromJson<double>(json['sofaLoanDisbursed']),
      sofaLoanRepayment: serializer.fromJson<double>(json['sofaLoanRepayment']),
      sofaLoanInterestCollected:
          serializer.fromJson<double>(json['sofaLoanInterestCollected']),
      notes: serializer.fromJson<String?>(json['notes']),
      warningFlags: serializer.fromJson<String>(json['warningFlags']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      createdAt: serializer.fromJson<String>(json['createdAt']),
      updatedAt: serializer.fromJson<String>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'localId': serializer.toJson<String>(localId),
      'serverId': serializer.toJson<int?>(serverId),
      'groupId': serializer.toJson<int>(groupId),
      'entryMonth': serializer.toJson<String>(entryMonth),
      'entryMode': serializer.toJson<String>(entryMode),
      'savingsCollected': serializer.toJson<double>(savingsCollected),
      'internalLoanPrincipalDisbursed':
          serializer.toJson<double>(internalLoanPrincipalDisbursed),
      'internalLoanInterestCollected':
          serializer.toJson<double>(internalLoanInterestCollected),
      'toBank': serializer.toJson<double>(toBank),
      'fromBank': serializer.toJson<double>(fromBank),
      'sofaLoanDisbursed': serializer.toJson<double>(sofaLoanDisbursed),
      'sofaLoanRepayment': serializer.toJson<double>(sofaLoanRepayment),
      'sofaLoanInterestCollected':
          serializer.toJson<double>(sofaLoanInterestCollected),
      'notes': serializer.toJson<String?>(notes),
      'warningFlags': serializer.toJson<String>(warningFlags),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'createdAt': serializer.toJson<String>(createdAt),
      'updatedAt': serializer.toJson<String>(updatedAt),
    };
  }

  MonthEntriesTableData copyWith(
          {String? localId,
          Value<int?> serverId = const Value.absent(),
          int? groupId,
          String? entryMonth,
          String? entryMode,
          double? savingsCollected,
          double? internalLoanPrincipalDisbursed,
          double? internalLoanInterestCollected,
          double? toBank,
          double? fromBank,
          double? sofaLoanDisbursed,
          double? sofaLoanRepayment,
          double? sofaLoanInterestCollected,
          Value<String?> notes = const Value.absent(),
          String? warningFlags,
          String? syncStatus,
          String? createdAt,
          String? updatedAt}) =>
      MonthEntriesTableData(
        localId: localId ?? this.localId,
        serverId: serverId.present ? serverId.value : this.serverId,
        groupId: groupId ?? this.groupId,
        entryMonth: entryMonth ?? this.entryMonth,
        entryMode: entryMode ?? this.entryMode,
        savingsCollected: savingsCollected ?? this.savingsCollected,
        internalLoanPrincipalDisbursed: internalLoanPrincipalDisbursed ??
            this.internalLoanPrincipalDisbursed,
        internalLoanInterestCollected:
            internalLoanInterestCollected ?? this.internalLoanInterestCollected,
        toBank: toBank ?? this.toBank,
        fromBank: fromBank ?? this.fromBank,
        sofaLoanDisbursed: sofaLoanDisbursed ?? this.sofaLoanDisbursed,
        sofaLoanRepayment: sofaLoanRepayment ?? this.sofaLoanRepayment,
        sofaLoanInterestCollected:
            sofaLoanInterestCollected ?? this.sofaLoanInterestCollected,
        notes: notes.present ? notes.value : this.notes,
        warningFlags: warningFlags ?? this.warningFlags,
        syncStatus: syncStatus ?? this.syncStatus,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  MonthEntriesTableData copyWithCompanion(MonthEntriesTableCompanion data) {
    return MonthEntriesTableData(
      localId: data.localId.present ? data.localId.value : this.localId,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      groupId: data.groupId.present ? data.groupId.value : this.groupId,
      entryMonth:
          data.entryMonth.present ? data.entryMonth.value : this.entryMonth,
      entryMode: data.entryMode.present ? data.entryMode.value : this.entryMode,
      savingsCollected: data.savingsCollected.present
          ? data.savingsCollected.value
          : this.savingsCollected,
      internalLoanPrincipalDisbursed:
          data.internalLoanPrincipalDisbursed.present
              ? data.internalLoanPrincipalDisbursed.value
              : this.internalLoanPrincipalDisbursed,
      internalLoanInterestCollected: data.internalLoanInterestCollected.present
          ? data.internalLoanInterestCollected.value
          : this.internalLoanInterestCollected,
      toBank: data.toBank.present ? data.toBank.value : this.toBank,
      fromBank: data.fromBank.present ? data.fromBank.value : this.fromBank,
      sofaLoanDisbursed: data.sofaLoanDisbursed.present
          ? data.sofaLoanDisbursed.value
          : this.sofaLoanDisbursed,
      sofaLoanRepayment: data.sofaLoanRepayment.present
          ? data.sofaLoanRepayment.value
          : this.sofaLoanRepayment,
      sofaLoanInterestCollected: data.sofaLoanInterestCollected.present
          ? data.sofaLoanInterestCollected.value
          : this.sofaLoanInterestCollected,
      notes: data.notes.present ? data.notes.value : this.notes,
      warningFlags: data.warningFlags.present
          ? data.warningFlags.value
          : this.warningFlags,
      syncStatus:
          data.syncStatus.present ? data.syncStatus.value : this.syncStatus,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MonthEntriesTableData(')
          ..write('localId: $localId, ')
          ..write('serverId: $serverId, ')
          ..write('groupId: $groupId, ')
          ..write('entryMonth: $entryMonth, ')
          ..write('entryMode: $entryMode, ')
          ..write('savingsCollected: $savingsCollected, ')
          ..write(
              'internalLoanPrincipalDisbursed: $internalLoanPrincipalDisbursed, ')
          ..write(
              'internalLoanInterestCollected: $internalLoanInterestCollected, ')
          ..write('toBank: $toBank, ')
          ..write('fromBank: $fromBank, ')
          ..write('sofaLoanDisbursed: $sofaLoanDisbursed, ')
          ..write('sofaLoanRepayment: $sofaLoanRepayment, ')
          ..write('sofaLoanInterestCollected: $sofaLoanInterestCollected, ')
          ..write('notes: $notes, ')
          ..write('warningFlags: $warningFlags, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      localId,
      serverId,
      groupId,
      entryMonth,
      entryMode,
      savingsCollected,
      internalLoanPrincipalDisbursed,
      internalLoanInterestCollected,
      toBank,
      fromBank,
      sofaLoanDisbursed,
      sofaLoanRepayment,
      sofaLoanInterestCollected,
      notes,
      warningFlags,
      syncStatus,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MonthEntriesTableData &&
          other.localId == this.localId &&
          other.serverId == this.serverId &&
          other.groupId == this.groupId &&
          other.entryMonth == this.entryMonth &&
          other.entryMode == this.entryMode &&
          other.savingsCollected == this.savingsCollected &&
          other.internalLoanPrincipalDisbursed ==
              this.internalLoanPrincipalDisbursed &&
          other.internalLoanInterestCollected ==
              this.internalLoanInterestCollected &&
          other.toBank == this.toBank &&
          other.fromBank == this.fromBank &&
          other.sofaLoanDisbursed == this.sofaLoanDisbursed &&
          other.sofaLoanRepayment == this.sofaLoanRepayment &&
          other.sofaLoanInterestCollected == this.sofaLoanInterestCollected &&
          other.notes == this.notes &&
          other.warningFlags == this.warningFlags &&
          other.syncStatus == this.syncStatus &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class MonthEntriesTableCompanion
    extends UpdateCompanion<MonthEntriesTableData> {
  final Value<String> localId;
  final Value<int?> serverId;
  final Value<int> groupId;
  final Value<String> entryMonth;
  final Value<String> entryMode;
  final Value<double> savingsCollected;
  final Value<double> internalLoanPrincipalDisbursed;
  final Value<double> internalLoanInterestCollected;
  final Value<double> toBank;
  final Value<double> fromBank;
  final Value<double> sofaLoanDisbursed;
  final Value<double> sofaLoanRepayment;
  final Value<double> sofaLoanInterestCollected;
  final Value<String?> notes;
  final Value<String> warningFlags;
  final Value<String> syncStatus;
  final Value<String> createdAt;
  final Value<String> updatedAt;
  final Value<int> rowid;
  const MonthEntriesTableCompanion({
    this.localId = const Value.absent(),
    this.serverId = const Value.absent(),
    this.groupId = const Value.absent(),
    this.entryMonth = const Value.absent(),
    this.entryMode = const Value.absent(),
    this.savingsCollected = const Value.absent(),
    this.internalLoanPrincipalDisbursed = const Value.absent(),
    this.internalLoanInterestCollected = const Value.absent(),
    this.toBank = const Value.absent(),
    this.fromBank = const Value.absent(),
    this.sofaLoanDisbursed = const Value.absent(),
    this.sofaLoanRepayment = const Value.absent(),
    this.sofaLoanInterestCollected = const Value.absent(),
    this.notes = const Value.absent(),
    this.warningFlags = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MonthEntriesTableCompanion.insert({
    required String localId,
    this.serverId = const Value.absent(),
    required int groupId,
    required String entryMonth,
    this.entryMode = const Value.absent(),
    this.savingsCollected = const Value.absent(),
    this.internalLoanPrincipalDisbursed = const Value.absent(),
    this.internalLoanInterestCollected = const Value.absent(),
    this.toBank = const Value.absent(),
    this.fromBank = const Value.absent(),
    this.sofaLoanDisbursed = const Value.absent(),
    this.sofaLoanRepayment = const Value.absent(),
    this.sofaLoanInterestCollected = const Value.absent(),
    this.notes = const Value.absent(),
    this.warningFlags = const Value.absent(),
    this.syncStatus = const Value.absent(),
    required String createdAt,
    required String updatedAt,
    this.rowid = const Value.absent(),
  })  : localId = Value(localId),
        groupId = Value(groupId),
        entryMonth = Value(entryMonth),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<MonthEntriesTableData> custom({
    Expression<String>? localId,
    Expression<int>? serverId,
    Expression<int>? groupId,
    Expression<String>? entryMonth,
    Expression<String>? entryMode,
    Expression<double>? savingsCollected,
    Expression<double>? internalLoanPrincipalDisbursed,
    Expression<double>? internalLoanInterestCollected,
    Expression<double>? toBank,
    Expression<double>? fromBank,
    Expression<double>? sofaLoanDisbursed,
    Expression<double>? sofaLoanRepayment,
    Expression<double>? sofaLoanInterestCollected,
    Expression<String>? notes,
    Expression<String>? warningFlags,
    Expression<String>? syncStatus,
    Expression<String>? createdAt,
    Expression<String>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (localId != null) 'local_id': localId,
      if (serverId != null) 'server_id': serverId,
      if (groupId != null) 'group_id': groupId,
      if (entryMonth != null) 'entry_month': entryMonth,
      if (entryMode != null) 'entry_mode': entryMode,
      if (savingsCollected != null) 'savings_collected': savingsCollected,
      if (internalLoanPrincipalDisbursed != null)
        'internal_loan_principal_disbursed': internalLoanPrincipalDisbursed,
      if (internalLoanInterestCollected != null)
        'internal_loan_interest_collected': internalLoanInterestCollected,
      if (toBank != null) 'to_bank': toBank,
      if (fromBank != null) 'from_bank': fromBank,
      if (sofaLoanDisbursed != null) 'sofa_loan_disbursed': sofaLoanDisbursed,
      if (sofaLoanRepayment != null) 'sofa_loan_repayment': sofaLoanRepayment,
      if (sofaLoanInterestCollected != null)
        'sofa_loan_interest_collected': sofaLoanInterestCollected,
      if (notes != null) 'notes': notes,
      if (warningFlags != null) 'warning_flags': warningFlags,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MonthEntriesTableCompanion copyWith(
      {Value<String>? localId,
      Value<int?>? serverId,
      Value<int>? groupId,
      Value<String>? entryMonth,
      Value<String>? entryMode,
      Value<double>? savingsCollected,
      Value<double>? internalLoanPrincipalDisbursed,
      Value<double>? internalLoanInterestCollected,
      Value<double>? toBank,
      Value<double>? fromBank,
      Value<double>? sofaLoanDisbursed,
      Value<double>? sofaLoanRepayment,
      Value<double>? sofaLoanInterestCollected,
      Value<String?>? notes,
      Value<String>? warningFlags,
      Value<String>? syncStatus,
      Value<String>? createdAt,
      Value<String>? updatedAt,
      Value<int>? rowid}) {
    return MonthEntriesTableCompanion(
      localId: localId ?? this.localId,
      serverId: serverId ?? this.serverId,
      groupId: groupId ?? this.groupId,
      entryMonth: entryMonth ?? this.entryMonth,
      entryMode: entryMode ?? this.entryMode,
      savingsCollected: savingsCollected ?? this.savingsCollected,
      internalLoanPrincipalDisbursed:
          internalLoanPrincipalDisbursed ?? this.internalLoanPrincipalDisbursed,
      internalLoanInterestCollected:
          internalLoanInterestCollected ?? this.internalLoanInterestCollected,
      toBank: toBank ?? this.toBank,
      fromBank: fromBank ?? this.fromBank,
      sofaLoanDisbursed: sofaLoanDisbursed ?? this.sofaLoanDisbursed,
      sofaLoanRepayment: sofaLoanRepayment ?? this.sofaLoanRepayment,
      sofaLoanInterestCollected:
          sofaLoanInterestCollected ?? this.sofaLoanInterestCollected,
      notes: notes ?? this.notes,
      warningFlags: warningFlags ?? this.warningFlags,
      syncStatus: syncStatus ?? this.syncStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (localId.present) {
      map['local_id'] = Variable<String>(localId.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<int>(serverId.value);
    }
    if (groupId.present) {
      map['group_id'] = Variable<int>(groupId.value);
    }
    if (entryMonth.present) {
      map['entry_month'] = Variable<String>(entryMonth.value);
    }
    if (entryMode.present) {
      map['entry_mode'] = Variable<String>(entryMode.value);
    }
    if (savingsCollected.present) {
      map['savings_collected'] = Variable<double>(savingsCollected.value);
    }
    if (internalLoanPrincipalDisbursed.present) {
      map['internal_loan_principal_disbursed'] =
          Variable<double>(internalLoanPrincipalDisbursed.value);
    }
    if (internalLoanInterestCollected.present) {
      map['internal_loan_interest_collected'] =
          Variable<double>(internalLoanInterestCollected.value);
    }
    if (toBank.present) {
      map['to_bank'] = Variable<double>(toBank.value);
    }
    if (fromBank.present) {
      map['from_bank'] = Variable<double>(fromBank.value);
    }
    if (sofaLoanDisbursed.present) {
      map['sofa_loan_disbursed'] = Variable<double>(sofaLoanDisbursed.value);
    }
    if (sofaLoanRepayment.present) {
      map['sofa_loan_repayment'] = Variable<double>(sofaLoanRepayment.value);
    }
    if (sofaLoanInterestCollected.present) {
      map['sofa_loan_interest_collected'] =
          Variable<double>(sofaLoanInterestCollected.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (warningFlags.present) {
      map['warning_flags'] = Variable<String>(warningFlags.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<String>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<String>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MonthEntriesTableCompanion(')
          ..write('localId: $localId, ')
          ..write('serverId: $serverId, ')
          ..write('groupId: $groupId, ')
          ..write('entryMonth: $entryMonth, ')
          ..write('entryMode: $entryMode, ')
          ..write('savingsCollected: $savingsCollected, ')
          ..write(
              'internalLoanPrincipalDisbursed: $internalLoanPrincipalDisbursed, ')
          ..write(
              'internalLoanInterestCollected: $internalLoanInterestCollected, ')
          ..write('toBank: $toBank, ')
          ..write('fromBank: $fromBank, ')
          ..write('sofaLoanDisbursed: $sofaLoanDisbursed, ')
          ..write('sofaLoanRepayment: $sofaLoanRepayment, ')
          ..write('sofaLoanInterestCollected: $sofaLoanInterestCollected, ')
          ..write('notes: $notes, ')
          ..write('warningFlags: $warningFlags, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$LocalDb extends GeneratedDatabase {
  _$LocalDb(QueryExecutor e) : super(e);
  $LocalDbManager get managers => $LocalDbManager(this);
  late final $GroupsTableTable groupsTable = $GroupsTableTable(this);
  late final $MonthEntriesTableTable monthEntriesTable =
      $MonthEntriesTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [groupsTable, monthEntriesTable];
}

typedef $$GroupsTableTableCreateCompanionBuilder = GroupsTableCompanion
    Function({
  Value<int> id,
  required String name,
  required String villageName,
  required String code,
  Value<bool> isActive,
});
typedef $$GroupsTableTableUpdateCompanionBuilder = GroupsTableCompanion
    Function({
  Value<int> id,
  Value<String> name,
  Value<String> villageName,
  Value<String> code,
  Value<bool> isActive,
});

class $$GroupsTableTableFilterComposer
    extends Composer<_$LocalDb, $GroupsTableTable> {
  $$GroupsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get villageName => $composableBuilder(
      column: $table.villageName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get code => $composableBuilder(
      column: $table.code, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));
}

class $$GroupsTableTableOrderingComposer
    extends Composer<_$LocalDb, $GroupsTableTable> {
  $$GroupsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get villageName => $composableBuilder(
      column: $table.villageName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get code => $composableBuilder(
      column: $table.code, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));
}

class $$GroupsTableTableAnnotationComposer
    extends Composer<_$LocalDb, $GroupsTableTable> {
  $$GroupsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get villageName => $composableBuilder(
      column: $table.villageName, builder: (column) => column);

  GeneratedColumn<String> get code =>
      $composableBuilder(column: $table.code, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);
}

class $$GroupsTableTableTableManager extends RootTableManager<
    _$LocalDb,
    $GroupsTableTable,
    GroupsTableData,
    $$GroupsTableTableFilterComposer,
    $$GroupsTableTableOrderingComposer,
    $$GroupsTableTableAnnotationComposer,
    $$GroupsTableTableCreateCompanionBuilder,
    $$GroupsTableTableUpdateCompanionBuilder,
    (
      GroupsTableData,
      BaseReferences<_$LocalDb, $GroupsTableTable, GroupsTableData>
    ),
    GroupsTableData,
    PrefetchHooks Function()> {
  $$GroupsTableTableTableManager(_$LocalDb db, $GroupsTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GroupsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GroupsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GroupsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> villageName = const Value.absent(),
            Value<String> code = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
          }) =>
              GroupsTableCompanion(
            id: id,
            name: name,
            villageName: villageName,
            code: code,
            isActive: isActive,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            required String villageName,
            required String code,
            Value<bool> isActive = const Value.absent(),
          }) =>
              GroupsTableCompanion.insert(
            id: id,
            name: name,
            villageName: villageName,
            code: code,
            isActive: isActive,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$GroupsTableTableProcessedTableManager = ProcessedTableManager<
    _$LocalDb,
    $GroupsTableTable,
    GroupsTableData,
    $$GroupsTableTableFilterComposer,
    $$GroupsTableTableOrderingComposer,
    $$GroupsTableTableAnnotationComposer,
    $$GroupsTableTableCreateCompanionBuilder,
    $$GroupsTableTableUpdateCompanionBuilder,
    (
      GroupsTableData,
      BaseReferences<_$LocalDb, $GroupsTableTable, GroupsTableData>
    ),
    GroupsTableData,
    PrefetchHooks Function()>;
typedef $$MonthEntriesTableTableCreateCompanionBuilder
    = MonthEntriesTableCompanion Function({
  required String localId,
  Value<int?> serverId,
  required int groupId,
  required String entryMonth,
  Value<String> entryMode,
  Value<double> savingsCollected,
  Value<double> internalLoanPrincipalDisbursed,
  Value<double> internalLoanInterestCollected,
  Value<double> toBank,
  Value<double> fromBank,
  Value<double> sofaLoanDisbursed,
  Value<double> sofaLoanRepayment,
  Value<double> sofaLoanInterestCollected,
  Value<String?> notes,
  Value<String> warningFlags,
  Value<String> syncStatus,
  required String createdAt,
  required String updatedAt,
  Value<int> rowid,
});
typedef $$MonthEntriesTableTableUpdateCompanionBuilder
    = MonthEntriesTableCompanion Function({
  Value<String> localId,
  Value<int?> serverId,
  Value<int> groupId,
  Value<String> entryMonth,
  Value<String> entryMode,
  Value<double> savingsCollected,
  Value<double> internalLoanPrincipalDisbursed,
  Value<double> internalLoanInterestCollected,
  Value<double> toBank,
  Value<double> fromBank,
  Value<double> sofaLoanDisbursed,
  Value<double> sofaLoanRepayment,
  Value<double> sofaLoanInterestCollected,
  Value<String?> notes,
  Value<String> warningFlags,
  Value<String> syncStatus,
  Value<String> createdAt,
  Value<String> updatedAt,
  Value<int> rowid,
});

class $$MonthEntriesTableTableFilterComposer
    extends Composer<_$LocalDb, $MonthEntriesTableTable> {
  $$MonthEntriesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get localId => $composableBuilder(
      column: $table.localId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get serverId => $composableBuilder(
      column: $table.serverId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get groupId => $composableBuilder(
      column: $table.groupId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entryMonth => $composableBuilder(
      column: $table.entryMonth, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entryMode => $composableBuilder(
      column: $table.entryMode, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get savingsCollected => $composableBuilder(
      column: $table.savingsCollected,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get internalLoanPrincipalDisbursed =>
      $composableBuilder(
          column: $table.internalLoanPrincipalDisbursed,
          builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get internalLoanInterestCollected => $composableBuilder(
      column: $table.internalLoanInterestCollected,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get toBank => $composableBuilder(
      column: $table.toBank, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get fromBank => $composableBuilder(
      column: $table.fromBank, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get sofaLoanDisbursed => $composableBuilder(
      column: $table.sofaLoanDisbursed,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get sofaLoanRepayment => $composableBuilder(
      column: $table.sofaLoanRepayment,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get sofaLoanInterestCollected => $composableBuilder(
      column: $table.sofaLoanInterestCollected,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get warningFlags => $composableBuilder(
      column: $table.warningFlags, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$MonthEntriesTableTableOrderingComposer
    extends Composer<_$LocalDb, $MonthEntriesTableTable> {
  $$MonthEntriesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get localId => $composableBuilder(
      column: $table.localId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get serverId => $composableBuilder(
      column: $table.serverId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get groupId => $composableBuilder(
      column: $table.groupId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entryMonth => $composableBuilder(
      column: $table.entryMonth, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entryMode => $composableBuilder(
      column: $table.entryMode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get savingsCollected => $composableBuilder(
      column: $table.savingsCollected,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get internalLoanPrincipalDisbursed =>
      $composableBuilder(
          column: $table.internalLoanPrincipalDisbursed,
          builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get internalLoanInterestCollected =>
      $composableBuilder(
          column: $table.internalLoanInterestCollected,
          builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get toBank => $composableBuilder(
      column: $table.toBank, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get fromBank => $composableBuilder(
      column: $table.fromBank, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get sofaLoanDisbursed => $composableBuilder(
      column: $table.sofaLoanDisbursed,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get sofaLoanRepayment => $composableBuilder(
      column: $table.sofaLoanRepayment,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get sofaLoanInterestCollected => $composableBuilder(
      column: $table.sofaLoanInterestCollected,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notes => $composableBuilder(
      column: $table.notes, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get warningFlags => $composableBuilder(
      column: $table.warningFlags,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$MonthEntriesTableTableAnnotationComposer
    extends Composer<_$LocalDb, $MonthEntriesTableTable> {
  $$MonthEntriesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get localId =>
      $composableBuilder(column: $table.localId, builder: (column) => column);

  GeneratedColumn<int> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<int> get groupId =>
      $composableBuilder(column: $table.groupId, builder: (column) => column);

  GeneratedColumn<String> get entryMonth => $composableBuilder(
      column: $table.entryMonth, builder: (column) => column);

  GeneratedColumn<String> get entryMode =>
      $composableBuilder(column: $table.entryMode, builder: (column) => column);

  GeneratedColumn<double> get savingsCollected => $composableBuilder(
      column: $table.savingsCollected, builder: (column) => column);

  GeneratedColumn<double> get internalLoanPrincipalDisbursed =>
      $composableBuilder(
          column: $table.internalLoanPrincipalDisbursed,
          builder: (column) => column);

  GeneratedColumn<double> get internalLoanInterestCollected =>
      $composableBuilder(
          column: $table.internalLoanInterestCollected,
          builder: (column) => column);

  GeneratedColumn<double> get toBank =>
      $composableBuilder(column: $table.toBank, builder: (column) => column);

  GeneratedColumn<double> get fromBank =>
      $composableBuilder(column: $table.fromBank, builder: (column) => column);

  GeneratedColumn<double> get sofaLoanDisbursed => $composableBuilder(
      column: $table.sofaLoanDisbursed, builder: (column) => column);

  GeneratedColumn<double> get sofaLoanRepayment => $composableBuilder(
      column: $table.sofaLoanRepayment, builder: (column) => column);

  GeneratedColumn<double> get sofaLoanInterestCollected => $composableBuilder(
      column: $table.sofaLoanInterestCollected, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get warningFlags => $composableBuilder(
      column: $table.warningFlags, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
      column: $table.syncStatus, builder: (column) => column);

  GeneratedColumn<String> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$MonthEntriesTableTableTableManager extends RootTableManager<
    _$LocalDb,
    $MonthEntriesTableTable,
    MonthEntriesTableData,
    $$MonthEntriesTableTableFilterComposer,
    $$MonthEntriesTableTableOrderingComposer,
    $$MonthEntriesTableTableAnnotationComposer,
    $$MonthEntriesTableTableCreateCompanionBuilder,
    $$MonthEntriesTableTableUpdateCompanionBuilder,
    (
      MonthEntriesTableData,
      BaseReferences<_$LocalDb, $MonthEntriesTableTable, MonthEntriesTableData>
    ),
    MonthEntriesTableData,
    PrefetchHooks Function()> {
  $$MonthEntriesTableTableTableManager(
      _$LocalDb db, $MonthEntriesTableTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MonthEntriesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MonthEntriesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MonthEntriesTableTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> localId = const Value.absent(),
            Value<int?> serverId = const Value.absent(),
            Value<int> groupId = const Value.absent(),
            Value<String> entryMonth = const Value.absent(),
            Value<String> entryMode = const Value.absent(),
            Value<double> savingsCollected = const Value.absent(),
            Value<double> internalLoanPrincipalDisbursed = const Value.absent(),
            Value<double> internalLoanInterestCollected = const Value.absent(),
            Value<double> toBank = const Value.absent(),
            Value<double> fromBank = const Value.absent(),
            Value<double> sofaLoanDisbursed = const Value.absent(),
            Value<double> sofaLoanRepayment = const Value.absent(),
            Value<double> sofaLoanInterestCollected = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<String> warningFlags = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            Value<String> createdAt = const Value.absent(),
            Value<String> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MonthEntriesTableCompanion(
            localId: localId,
            serverId: serverId,
            groupId: groupId,
            entryMonth: entryMonth,
            entryMode: entryMode,
            savingsCollected: savingsCollected,
            internalLoanPrincipalDisbursed: internalLoanPrincipalDisbursed,
            internalLoanInterestCollected: internalLoanInterestCollected,
            toBank: toBank,
            fromBank: fromBank,
            sofaLoanDisbursed: sofaLoanDisbursed,
            sofaLoanRepayment: sofaLoanRepayment,
            sofaLoanInterestCollected: sofaLoanInterestCollected,
            notes: notes,
            warningFlags: warningFlags,
            syncStatus: syncStatus,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String localId,
            Value<int?> serverId = const Value.absent(),
            required int groupId,
            required String entryMonth,
            Value<String> entryMode = const Value.absent(),
            Value<double> savingsCollected = const Value.absent(),
            Value<double> internalLoanPrincipalDisbursed = const Value.absent(),
            Value<double> internalLoanInterestCollected = const Value.absent(),
            Value<double> toBank = const Value.absent(),
            Value<double> fromBank = const Value.absent(),
            Value<double> sofaLoanDisbursed = const Value.absent(),
            Value<double> sofaLoanRepayment = const Value.absent(),
            Value<double> sofaLoanInterestCollected = const Value.absent(),
            Value<String?> notes = const Value.absent(),
            Value<String> warningFlags = const Value.absent(),
            Value<String> syncStatus = const Value.absent(),
            required String createdAt,
            required String updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              MonthEntriesTableCompanion.insert(
            localId: localId,
            serverId: serverId,
            groupId: groupId,
            entryMonth: entryMonth,
            entryMode: entryMode,
            savingsCollected: savingsCollected,
            internalLoanPrincipalDisbursed: internalLoanPrincipalDisbursed,
            internalLoanInterestCollected: internalLoanInterestCollected,
            toBank: toBank,
            fromBank: fromBank,
            sofaLoanDisbursed: sofaLoanDisbursed,
            sofaLoanRepayment: sofaLoanRepayment,
            sofaLoanInterestCollected: sofaLoanInterestCollected,
            notes: notes,
            warningFlags: warningFlags,
            syncStatus: syncStatus,
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

typedef $$MonthEntriesTableTableProcessedTableManager = ProcessedTableManager<
    _$LocalDb,
    $MonthEntriesTableTable,
    MonthEntriesTableData,
    $$MonthEntriesTableTableFilterComposer,
    $$MonthEntriesTableTableOrderingComposer,
    $$MonthEntriesTableTableAnnotationComposer,
    $$MonthEntriesTableTableCreateCompanionBuilder,
    $$MonthEntriesTableTableUpdateCompanionBuilder,
    (
      MonthEntriesTableData,
      BaseReferences<_$LocalDb, $MonthEntriesTableTable, MonthEntriesTableData>
    ),
    MonthEntriesTableData,
    PrefetchHooks Function()>;

class $LocalDbManager {
  final _$LocalDb _db;
  $LocalDbManager(this._db);
  $$GroupsTableTableTableManager get groupsTable =>
      $$GroupsTableTableTableManager(_db, _db.groupsTable);
  $$MonthEntriesTableTableTableManager get monthEntriesTable =>
      $$MonthEntriesTableTableTableManager(_db, _db.monthEntriesTable);
}
