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

  factory AccessCheckResult.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> nested = const {};
    for (final key in ['user', 'userInfo', 'users', 'profile']) {
      final v = json[key];
      if (v is Map) {
        nested = Map<String, dynamic>.from(v);
        break;
      }
    }

    String pick(List<String> keys) {
      for (final k in keys) {
        final v = json[k] ?? nested[k];
        if (v == null || v is Map || v is List) continue;
        final s = v.toString().trim();
        if (s.isNotEmpty && s != 'null') return s;
      }
      return '';
    }

    return AccessCheckResult(
      canAccess: json['canAccess'] == true || nested['canAccess'] == true,
      role: pick(['role', 'roleName']),
      userId: pick(['userId', 'id', 'landlordId', 'tenantId']),
      fullName: pick(['fullName', 'name']),
      phoneNumber: pick(['phoneNumber', 'phone', 'mobile']),
      email: pick(['email']),
    );
  }
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
    id: (json['id'] ??
            json['userId'] ??
            json['sub'] ??
            json['username'] ??
            '')
        .toString(),
    userName: (json['userName'] ?? json['username'] ?? '').toString(),
    fullName: (json['fullName'] ?? json['name'] ?? '').toString(),
    email: (json['email'] ?? '').toString(),
    phoneNumber:
        (json['phoneNumber'] ?? json['phone'] ?? json['mobile'] ?? '')
            .toString(),
    role: (json['role'] ?? '').toString(),
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

