enum UserRole {
  admin,
  staff,
  client,
}

class UserProfile {
  final String id;
  final String name;
  final String email;
  final UserRole role;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  factory UserProfile.fromMap(Map<String, dynamic> map, String documentId) {
    UserRole parsedRole;
    switch (map['role']) {
      case 'admin':
        parsedRole = UserRole.admin;
        break;
      case 'staff':
        parsedRole = UserRole.staff;
        break;
      case 'client':
      default:
        parsedRole = UserRole.client;
        break;
    }

    return UserProfile(
      id: documentId,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: parsedRole,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'role': role.name,
    };
  }
}
