class VillageOption {
  final int id;
  final String name;
  final String abbreviation;

  const VillageOption({
    required this.id,
    required this.name,
    required this.abbreviation,
  });

  factory VillageOption.fromJson(Map<String, dynamic> json) => VillageOption(
        id: json['id'] as int,
        name: json['name'] as String,
        abbreviation: (json['abbreviation'] as String?) ?? '',
      );
}
