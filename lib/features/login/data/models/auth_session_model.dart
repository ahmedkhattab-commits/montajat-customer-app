class AuthSessionModel {
  const AuthSessionModel({
    required this.accessToken,
    required this.mobile,
    this.refreshToken,
  });

  final String accessToken;
  final String mobile;
  final String? refreshToken;

  factory AuthSessionModel.fromJson(
    Map<String, dynamic> json, {
    required String mobile,
  }) {
    final dataValue = json['data'];
    final data = dataValue is Map<String, dynamic> ? dataValue : json;
    final accessTokenValue = data['access_token'] ?? data['token'];
    if (accessTokenValue is! String || accessTokenValue.trim().isEmpty) {
      throw const FormatException('Missing access token in OTP response.');
    }

    final refreshTokenValue = data['refresh_token'];
    return AuthSessionModel(
      accessToken: accessTokenValue,
      mobile: mobile,
      refreshToken: refreshTokenValue is String && refreshTokenValue.isNotEmpty
          ? refreshTokenValue
          : null,
    );
  }
}
