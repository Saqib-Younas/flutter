enum UserRole { user, admin }

extension UserRoleX on UserRole {
  String get wire => name;

  static UserRole fromWire(String? value) =>
      value == 'admin' ? UserRole.admin : UserRole.user;
}

class UserModel {
  UserModel({
    required this.id,
    required this.email,
    this.name = '',
    this.role = UserRole.user,
    this.phone,
    this.createdAt,
  });

  final String id;
  final String email;
  final String name;
  final UserRole role;
  final String? phone;
  final DateTime? createdAt;

  bool get isAdmin => role == UserRole.admin;

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: (json['id'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      role: UserRoleX.fromWire(json['role']?.toString()),
      phone: json['phone']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }
}
