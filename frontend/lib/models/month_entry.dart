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
    this.notes,
    this.warningFlags = const [],
    this.syncStatus = SyncStatus.pendingSync,
    required this.createdAt,
    required this.updatedAt,
  });

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
        'sofa_loan_disbursed': sofaLoanDisbursed,
        'sofa_loan_repayment': sofaLoanRepayment,
        'sofa_loan_interest_collected': sofaLoanInterestCollected,
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
