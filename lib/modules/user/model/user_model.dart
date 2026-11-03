class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String avatar;
  final DateTime createdAt;
  final String? profilePictureUrl;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.profilePictureUrl,
    this.role = 'Super Admin',
    this.avatar = '',
    required this.createdAt,
  });

  UserModel copyWith({
    String? name,
    String? email,
    String? phone,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role,
      avatar: avatar,
      createdAt: createdAt,
      profilePictureUrl: profilePictureUrl,
    );
  }
}
