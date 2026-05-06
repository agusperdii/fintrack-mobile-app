class UserProfile {
  final String id;
  final String name;
  final String handle;
  final String username;
  final String email;
  final String avatar;

  UserProfile({
    required this.id,
    required this.name,
    required this.handle,
    required this.username,
    required this.email,
    required this.avatar,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final email = json['email'] as String? ?? '';
    final username = json['username'] as String?;
    final id = json['id']?.toString() ?? '';
    
    return UserProfile(
      id: id,
      name: json['full_name'] ?? email.split('@')[0],
      handle: username != null ? '@$username' : '@${email.split('@')[0]}',
      username: username ?? '',
      email: email,
      avatar: 'https://www.gravatar.com/avatar/$id?d=identicon&s=200',
    );
  }
}
