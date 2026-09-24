import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState extends ChangeNotifier {
  AuthState(this._authService);

  final AuthService _authService;

  AuthStatus status = AuthStatus.unknown;
  AppUser? user;
  String? errorMessage;
  bool isBusy = false;

  Future<void> restoreSession() async {
    user = await _authService.tryRestoreSession();
    status = user != null ? AuthStatus.authenticated : AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<bool> login(String email, String password) => _run(() async {
        user = await _authService.login(email: email, password: password);
        status = AuthStatus.authenticated;
      });

  Future<bool> register(String email, String password, String fullName) => _run(() async {
        user = await _authService.register(email: email, password: password, fullName: fullName);
        status = AuthStatus.authenticated;
      });

  Future<bool> loginWithGoogle() => _run(() async {
        user = await _authService.loginWithGoogle();
        status = AuthStatus.authenticated;
      });

  Future<void> logout() async {
    await _authService.logout();
    user = null;
    status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<bool> _run(Future<void> Function() action) async {
    isBusy = true;
    errorMessage = null;
    notifyListeners();
    try {
      await action();
      return true;
    } on AuthException catch (e) {
      errorMessage = e.message;
      return false;
    } finally {
      isBusy = false;
      notifyListeners();
    }
  }
}
