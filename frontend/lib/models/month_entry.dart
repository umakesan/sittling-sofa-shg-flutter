enum SyncStatus { pendingSync, synced }

enum EntryMode { manual, prefill }

class MonthEntry {
  final String localId; // UUID generated on device
  final int? serverId; // null until synced to backend
  final int groupId;
  final String entryMonth; // "YYYY-MM-DD" (always 1st of month)
  final EntryMode entryMode;
  final double savingsCollected;
  final double internalLoanPrincipalDisbursed;
  final double internalLoanInterestCollected;
  final double toBank;
  final double fromBank;
  final double sofaLoanDisbursed;
  final double sofaLoanRepayment;
  final double sofaLoanInterestCollected;
  final int? sofaLoanEntryId; // server-assigned after sync
  final String? notes;
  final List<String> warningFlags;
  final SyncStatus syncStatus;
  final DateTime createdAt;
  final DateTime updatedAt;

  const MonthEntry({
    required this.localId,
    this.serverId,
    required this.groupId,
    required this.entryMonth,
    required this.entryMode,
    this.savingsCollected = 0,
    this.internalLoanPrincipalDisbursed = 0,
    this.internalLoanInterestCollected = 0,
    this.toBank = 0,
    this.fromBank = 0,
    this.sofaLoanDisbursed = 0,
    this.sofaLoanRepayment = 0,
    this.sofaLoanInterestCollected = 0,
    this.sofaLoanEntryId,
    this.notes,
    this.warningFlags = const [],
    this.syncStatus = SyncStatus.pendingSync,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MonthEntry.fromServerJson(Map<String, dynamic> json) {
    final now = DateTime.now();
    return MonthEntry(
      localId: 'srv_${json['id']}',
      serverId: json['id'] as int,
      groupId: json['group_id'] as int,
      entryMonth: json['entry_month'] as String,
      entryMode: json['entry_mode'] == 'prefill' ? EntryMode.prefill : EntryMode.manual,
      savingsCollected: (json['savings_collected'] as num).toDouble(),
      internalLoanPrincipalDisbursed:
          (json['internal_loan_principal_disbursed'] as num).toDouble(),
      internalLoanInterestCollected:
          (json['internal_loan_interest_collected'] as num).toDouble(),
      toBank: (json['to_bank'] as num).toDouble(),
      fromBank: (json['from_bank'] as num).toDouble(),
      sofaLoanDisbursed: (json['sofa_disbursed'] as num? ?? 0).toDouble(),
      sofaLoanRepayment: (json['sofa_repayment'] as num? ?? 0).toDouble(),
      sofaLoanInterestCollected: (json['sofa_interest'] as num? ?? 0).toDouble(),
      sofaLoanEntryId: json['sofa_loan_entry_id'] as int?,
      notes: json['notes'] as String?,
      warningFlags: List<String>.from((json['warning_flags'] as List?) ?? []),
      syncStatus: SyncStatus.synced,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? now,
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? '') ?? now,
    );
  }

  // Build the JSON body to POST to FastAPI
  Map<String, dynamic> toApiPayload() => {
        'group_id': groupId,
        'entry_month': entryMonth,
        'entry_mode': entryMode.name,
        'savings_collected': savingsCollected,
        'internal_loan_principal_disbursed': internalLoanPrincipalDisbursed,
        'internal_loan_interest_collected': internalLoanInterestCollected,
        'to_bank': toBank,
        'from_bank': fromBank,
        'sofa_disbursed': sofaLoanDisbursed,
        'sofa_repayment': sofaLoanRepayment,
        'sofa_interest': sofaLoanInterestCollected,
        if (notes != null) 'notes': notes,
      };

  MonthEntry copyWith({
    int? serverId,
    SyncStatus? syncStatus,
    List<String>? warningFlags,
    DateTime? updatedAt,
    double? savingsCollected,
    double? internalLoanPrincipalDisbursed,
    double? internalLoanInterestCollected,
    double? toBank,
    double? fromBank,
    double? sofaLoanDisbursed,
    double? sofaLoanRepayment,
    double? sofaLoanInterestCollected,
    int? sofaLoanEntryId,
    String? notes,
  }) =>
      MonthEntry(
        localId: localId,
        serverId: serverId ?? this.serverId,
        groupId: groupId,
        entryMonth: entryMonth,
        entryMode: entryMode,
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
        sofaLoanEntryId: sofaLoanEntryId ?? this.sofaLoanEntryId,
        notes: notes ?? this.notes,
        warningFlags: warningFlags ?? this.warningFlags,
        syncStatus: syncStatus ?? this.syncStatus,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}

class DashboardSummary {
  final double totalSavingsCollected;
  final double totalInternalLoanPrincipal;
  final double totalInternalLoanInterest;
  final double totalSofaDisbursed;
  final double totalSofaRepaid;
  final int warningEntryCount;

  const DashboardSummary({
    required this.totalSavingsCollected,
    required this.totalInternalLoanPrincipal,
    required this.totalInternalLoanInterest,
    required this.totalSofaDisbursed,
    required this.totalSofaRepaid,
    required this.warningEntryCount,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) => DashboardSummary(
        totalSavingsCollected: (json['total_savings_collected'] as num).toDouble(),
        totalInternalLoanPrincipal: (json['total_internal_loan_principal'] as num).toDouble(),
        totalInternalLoanInterest: (json['total_internal_loan_interest'] as num).toDouble(),
        totalSofaDisbursed: (json['total_sofa_disbursed'] as num).toDouble(),
        totalSofaRepaid: (json['total_sofa_repaid'] as num).toDouble(),
        warningEntryCount: json['warning_entry_count'] as int,
      );
}
