class UserModel {
  final String token;
  final int role;
  final String name;
  final String email;
  final String nik;
  final String tokenExpiresAt;

  UserModel({
    required this.token,
    required this.role,
    required this.name,
    required this.email,
    required this.nik,
    required this.tokenExpiresAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      token: json['access_token'],
      role: json['role'] is int
          ? json['role']
          : int.tryParse(json['role'].toString()) ?? 0,
      name: json['name'],
      email: json['email'],
      nik: json['nik'],
      tokenExpiresAt: json['expires_at'],
    );
  }
}
