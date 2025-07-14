class Profile {
  final String id;
  final String fullName;
  final String role;
  final String avatarUrl;

  Profile({
    required this.id,
    required this.fullName,
    required this.role,
    required this.avatarUrl,
  });

  factory Profile.fromMap(Map<String, dynamic> map) {
    return Profile(
      id: map['id'] as String,
      fullName: map['full_name'] as String? ?? '',
      role: map['role'] as String? ?? 'customer',
      avatarUrl: map['avatar_url'] as String? ?? '',
    );
  }
} 