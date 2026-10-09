class AccountModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final DateTime? createdAt;
  const AccountModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.createdAt,
  });

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    String pick(List<String> keys) {
      for (final k in keys) {
        final v = json[k];
        if (v != null && v.toString().trim().isNotEmpty) return v.toString().trim();
      }
      return '';
    }

    final created = pick(['createdAt', 'createdDate', 'joinedAt']);
    return AccountModel(
      id: pick(['id', 'userId']),
      name: pick(['name', 'fullName']),
      email: pick(['email']),
      phone: pick(['phone', 'phoneNumber']),
      role: pick(['role']),
      createdAt: created.isEmpty ? null : DateTime.tryParse(created),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'phone': phone,
    'role': role,
    'createdAt': createdAt?.toIso8601String(),
  };

  AccountModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? role,
    DateTime? createdAt,
  }) {
    return AccountModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}