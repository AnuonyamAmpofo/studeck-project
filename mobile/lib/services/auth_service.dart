import 'package:dio/dio.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user.dart';
import 'api_client.dart';
import 'demo_data_store.dart';
import 'demo_mode.dart';

class AuthException implements Exception {
  AuthException(this.message);
  final String message;
  @override
  String toString() => message;
}

class AuthService {
  AuthService(this._client);

  final ApiClient _client;

  Future<AppUser> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    if (kDemoMode) {
      await Future.delayed(const Duration(milliseconds: 400));
      final user = AppUser(id: 'demo-user', email: email, fullName: fullName);
      DemoDataStore.instance.currentUser = user;
      return user;
    }
    try {
      final res = await _client.dio.post('/auth/register', data: {
        'email': email,
        'password': password,
        'fullName': fullName,
      });
      await _client.setAccessToken(res.data['accessToken'] as String);
      return AppUser.fromJson(res.data['user'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw AuthException(_extractMessage(e));
    }
  }

  Future<AppUser> login({required String email, required String password}) async {
    if (kDemoMode) {
      await Future.delayed(const Duration(milliseconds: 400));
      final user = DemoDataStore.instance.currentUser ??
          AppUser(id: 'demo-user', email: email, fullName: 'John Doe');
      DemoDataStore.instance.currentUser = user;
      return user;
    }
    try {
      final res = await _client.dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      await _client.setAccessToken(res.data['accessToken'] as String);
      return AppUser.fromJson(res.data['user'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw AuthException(_extractMessage(e));
    }
  }

  /// Triggers the native Google sign-in sheet, then exchanges the resulting
  /// ID token for a Studeck session via POST /auth/google. Requires
  /// GoogleSignIn.instance.initialize() to have already been awaited once
  /// at app startup (see main.dart).
  Future<AppUser> loginWithGoogle() async {
    if (kDemoMode) {
      await Future.delayed(const Duration(milliseconds: 400));
      final user = DemoDataStore.instance.currentUser ??
          const AppUser(id: 'demo-user', email: 'demo@studeck.app', fullName: 'John Doe', authProvider: 'google');
      DemoDataStore.instance.currentUser = user;
      return user;
    }

    GoogleSignInAccount account;
    try {
      account = await GoogleSignIn.instance.authenticate();
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        throw AuthException('Sign-in cancelled.');
      }
      throw AuthException('Google sign-in failed. Please try again.');
    }

    final idToken = account.authentication.idToken;
    if (idToken == null) {
      throw AuthException('Google did not return a valid sign-in token. Please try again.');
    }

    try {
      final res = await _client.dio.post('/auth/google', data: {'idToken': idToken});
      await _client.setAccessToken(res.data['accessToken'] as String);
      return AppUser.fromJson(res.data['user'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw AuthException(_extractMessage(e));
    }
  }

  /// Called on app start: uses the persisted refresh cookie to get a fresh
  /// access token without asking the user to log in again.
  Future<AppUser?> tryRestoreSession() async {
    if (kDemoMode) return DemoDataStore.instance.currentUser;
    try {
      final refreshRes = await _client.dio.post('/auth/refresh');
      await _client.setAccessToken(refreshRes.data['accessToken'] as String);
      final meRes = await _client.dio.get('/auth/me');
      return AppUser.fromJson(meRes.data['user'] as Map<String, dynamic>);
    } on DioException {
      await _client.setAccessToken(null);
      return null;
    }
  }

  Future<void> logout() async {
    if (kDemoMode) {
      DemoDataStore.instance.currentUser = null;
      return;
    }
    try {
      await _client.dio.post('/auth/logout');
    } on DioException {
      // Ignore network errors on logout — clearing local state still succeeds.
    }
    await _client.setAccessToken(null);
    try {
      await GoogleSignIn.instance.signOut();
    } catch (_) {
      // No-op if the user never signed in with Google.
    }
  }

  String _extractMessage(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['error'] is Map && data['error']['message'] is String) {
      return data['error']['message'] as String;
    }

    // No response at all means the request never reached the server —
    // almost always a wrong base URL, or the backend isn't running.
    switch (e.type) {
      case DioExceptionType.connectionError:
      case DioExceptionType.connectionTimeout:
        return "Can't reach the server. Is the backend running, and is the "
            'app pointed at the right address for this device/emulator?';
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return 'The server took too long to respond. Try again.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }
}
