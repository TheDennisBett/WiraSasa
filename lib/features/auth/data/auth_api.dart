import 'package:wirasasa/core/network/api_client.dart';
import 'package:wirasasa/core/network/api_models.dart';

class AuthApi {
  AuthApi(this._client);

  final ApiClient _client;

  Future<UserLookup> checkUser({
    required String phoneNumber,
    required String requestedRole,
  }) async {
    final response = await _client.postJson(
      '/api/auth/check-user',
      body: {
        'phoneNumber': phoneNumber,
        'requestedRole': requestedRole,
      },
    );
    return UserLookup.fromJson(response as Map<String, dynamic>);
  }

  Future<AuthUser> register({
    required String phoneNumber,
    required String displayName,
    required String requestedRole,
  }) async {
    final response = await _client.postJson(
      '/api/auth/register',
      body: {
        'phoneNumber': phoneNumber,
        'displayName': displayName,
        'requestedRole': requestedRole,
      },
    );
    return AuthUser.fromJson(response as Map<String, dynamic>);
  }

  Future<AuthUser> registerAccount({
    required String phoneNumber,
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String requestedRole,
  }) async {
    final response = await _client.postJson(
      '/api/auth/register-account',
      body: {
        'phoneNumber': phoneNumber,
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'password': password,
        'requestedRole': requestedRole,
      },
    );
    return AuthUser.fromJson(response as Map<String, dynamic>);
  }

  Future<OtpChallenge> sendOtp({
    required String phoneNumber,
    required String requestedRole,
  }) async {
    final response = await _client.postJson(
      '/api/auth/send-otp',
      body: {
        'phoneNumber': phoneNumber,
        'requestedRole': requestedRole,
      },
    );
    return OtpChallenge.fromJson(response as Map<String, dynamic>);
  }

  Future<AuthSession> verifyOtp({
    required String challengeId,
    required String code,
    required String requestedRole,
    String? displayName,
  }) async {
    final response = await _client.postJson(
      '/api/auth/verify-otp',
      body: {
        'challengeId': challengeId,
        'code': code,
        'requestedRole': requestedRole,
        'displayName': displayName,
      },
    );
    return AuthSession.fromJson(response as Map<String, dynamic>);
  }

  Future<AuthSession> refresh(String refreshToken) async {
    final response = await _client.postJson(
      '/api/auth/refresh',
      body: {'refreshToken': refreshToken},
    );
    return AuthSession.fromJson(response as Map<String, dynamic>);
  }
}
