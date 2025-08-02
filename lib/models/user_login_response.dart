class UserLoginResponse {
  final int id;
  final String name;
  final String email;
  final String role;
  final bool admin;
  final bool active;
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final int expiresIn;
  final String issuedAt;
  final String expiresAt;

  UserLoginResponse({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.admin,
    required this.active,
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.expiresIn,
    required this.issuedAt,
    required this.expiresAt,
  });

  factory UserLoginResponse.fromJson(Map<String, dynamic> json) {
    return UserLoginResponse(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: json['role'],
      admin: json['admin'],
      active: json['active'],
      accessToken: json['accessToken'] ?? '',
      refreshToken: json['refreshToken'] ?? '',
      tokenType: json['tokenType'],
      expiresIn: json['expiresIn'],
      issuedAt: json['issuedAt'],
      expiresAt: json['expiresAt'],
    );
  }
}
