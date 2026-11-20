class AppUser {
  const AppUser({required this.id, this.email, required this.emailVerified});

  final String id;
  final String? email;
  final bool emailVerified;
}
