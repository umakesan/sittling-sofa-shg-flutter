import 'dart:convert';

class AppUser {
  final String userId;
  final String name;
  final String role;

  const AppUser({
    required this.userId,
    required this.name,
    required this.role,
  });

  bool get isAdmin => role == 'admin';

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        userId: json['user_id'] as String,
        name: json['name'] as String,
        role: json['role'] as String,
      );

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'name': name,
        'role': role,
      };

  String toJsonString() => jsonEncode(toJson());

  factory AppUser.fromJsonString(String s) =>
      AppUser.fromJson(jsonDecode(s) as Map<String, dynamic>);
}
