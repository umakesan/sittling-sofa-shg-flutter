class Group {
  final int id;
  final String name;
  final String villageName;
  final String code;
  final bool isActive;
  final double openingBankBalance;

  const Group({
    required this.id,
    required this.name,
    required this.villageName,
    required this.code,
    required this.isActive,
    this.openingBankBalance = 0,
  });

  factory Group.fromJson(Map<String, dynamic> json) => Group(
        id: json['id'] as int,
        name: json['name'] as String,
        villageName: json['village_name'] as String,
        code: json['code'] as String,
        isActive: json['is_active'] as bool,
        openingBankBalance:
            (json['opening_bank_balance'] as num? ?? 0).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'village_name': villageName,
        'code': code,
        'is_active': isActive,
        'opening_bank_balance': openingBankBalance,
      };
}
