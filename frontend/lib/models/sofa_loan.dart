class SofaLoan {
  final int id;
  final int groupId;
  final String name;
  final double principalAmount;
  final String disbursedDate;
  final String status; // 'active' | 'closed'
  final String? closedDate;
  final double outstanding;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SofaLoan({
    required this.id,
    required this.groupId,
    required this.name,
    required this.principalAmount,
    required this.disbursedDate,
    required this.status,
    this.closedDate,
    required this.outstanding,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isActive => status == 'active';

  factory SofaLoan.fromJson(Map<String, dynamic> json) {
    final now = DateTime.now();
    return SofaLoan(
      id: json['id'] as int,
      groupId: json['group_id'] as int,
      name: json['name'] as String,
      principalAmount: (json['principal_amount'] as num).toDouble(),
      disbursedDate: json['disbursed_date'] as String,
      status: json['status'] as String,
      closedDate: json['closed_date'] as String?,
      outstanding: (json['outstanding'] as num).toDouble(),
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? now,
      updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? '') ?? now,
    );
  }
}
