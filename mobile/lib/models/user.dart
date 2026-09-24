class AppUser {
  const AppUser({
    required this.id,
    required this.email,
    required this.fullName,
    this.authProvider = 'password',
  });

  final String id;
  final String email;
  final String fullName;
  final String authProvider; // 'password' | 'google'

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        id: json['id'] as String,
        email: json['email'] as String,
        fullName: json['full_name'] as String,
        authProvider: json['auth_provider'] as String? ?? 'password',
      );
}
