class Group {
  final int id;
  final String name;
  final String villageName;
  final String code;
  final bool isActive;

  const Group({
    required this.id,
    required this.name,
    required this.villageName,
    required this.code,
    required this.isActive,
  });

  factory Group.fromJson(Map<String, dynamic> json) => Group(
        id: json['id'] as int,
        name: json['name'] as String,
        villageName: json['village_name'] as String,
        code: json['code'] as String,
        isActive: json['is_active'] as bool,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'village_name': villageName,
        'code': code,
        'is_active': isActive,
      };
}
