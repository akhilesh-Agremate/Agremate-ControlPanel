class ApiResult<T> {
  final bool status;
  final String message;
  final T? data;

  const ApiResult({required this.status, required this.message, this.data});

  factory ApiResult.failure(String message) =>
      ApiResult(status: false, message: message);
}

class AccessCheckResult {
  final bool canAccess;
  final String role;
  final String userId;
  final String fullName;
  final String phoneNumber;
  final String email;

  const AccessCheckResult({
    required this.canAccess,
    required this.role,
    required this.userId,
    required this.fullName,
    required this.phoneNumber,
    required this.email,
  });

  factory AccessCheckResult.fromJson(Map<String, dynamic> json) =>
      AccessCheckResult(
        canAccess: json['canAccess'] == true,
        role: json['role'] ?? '',
        userId: json['userId'] ?? '',
        fullName: json['fullName'] ?? json['name'] ?? '',
        phoneNumber: json['phoneNumber'] ?? '',
        email: json['email'] ?? '',
      );
}

class UserInfo {
  final String id;
  final String userName;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String role;

  const UserInfo({
    required this.id,
    required this.userName,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.role,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) => UserInfo(
    id: json['id'] ?? '',
    userName: json['userName'] ?? '',
    fullName: json['fullName'] ?? '',
    email: json['email'] ?? '',
    phoneNumber: json['phoneNumber'] ?? '',
    role: json['role'] ?? '',
  );
}

class AuthSession {
  final bool isSuccess;
  final String accessToken;
  final String idToken;
  final String refreshToken; 
  final String tokenType;
  final int expiration;
  final UserInfo? userInfo; 

  const AuthSession({
    required this.isSuccess,
    required this.accessToken,
    required this.idToken,
    required this.refreshToken,
    required this.tokenType,
    required this.expiration,
    this.userInfo,
  });

  factory AuthSession.fromJson(Map<String, dynamic> json) => AuthSession(
    isSuccess: json['isSuccess'] ?? (json['accessToken'] != null),
    accessToken: json['accessToken'] ?? '',
    idToken: json['idToken'] ?? '',
    refreshToken: json['refreshToken'] ?? '',
    tokenType: json['tokenType'] ?? 'Bearer',
    expiration: (json['expiration'] ?? 0) as int,
    userInfo: json['userInfo'] != null
        ? UserInfo.fromJson(Map<String, dynamic>.from(json['userInfo']))
        : null,
  );
}

