class SofaLoanEntry {
  final int id;
  final int sofaLoanId;
  final String entryMonth;
  final double disbursed;
  final double repayment;
  final double interestCollected;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SofaLoanEntry({
    required this.id,
    required this.sofaLoanId,
    required this.entryMonth,
    required this.disbursed,
    required this.repayment,
    required this.interestCollected,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SofaLoanEntry.fromJson(Map<String, dynamic> json) {
    final now = DateTime.now();
    return SofaLoanEntry(
      id: json['id'] as int,
      sofaLoanId: json['sofa_loan_id'] as int,
      entryMonth: json['entry_month'] as String,
      disbursed: (json['disbursed'] as num).toDouble(),
      repayment: (json['repayment'] as num).toDouble(),
      interestCollected: (json['interest_collected'] as num).toDouble(),
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? now,
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? '') ?? now,
    );
  }
}
