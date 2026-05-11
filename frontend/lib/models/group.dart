class Group {
  final int id;
  final String name;
  final String villageName;
  final int? villageId;
  final String code;
  final bool isActive;
  final double openingBankBalance;
  final String? meetingDay;

  const Group({
    required this.id,
    required this.name,
    required this.villageName,
    this.villageId,
    required this.code,
    required this.isActive,
    this.openingBankBalance = 0,
    this.meetingDay,
  });

  factory Group.fromJson(Map<String, dynamic> json) => Group(
        id: json['id'] as int,
        name: json['name'] as String,
        villageName: json['village_name'] as String,
        villageId: json['village_id'] as int?,
        code: json['code'] as String,
        isActive: json['is_active'] as bool,
        openingBankBalance:
            (json['opening_bank_balance'] as num? ?? 0).toDouble(),
        meetingDay: json['meeting_day'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'village_name': villageName,
        if (villageId != null) 'village_id': villageId,
        'code': code,
        'is_active': isActive,
        'opening_bank_balance': openingBankBalance,
        if (meetingDay != null) 'meeting_day': meetingDay,
      };
}
