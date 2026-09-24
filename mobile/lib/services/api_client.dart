import 'dart:io' show Platform;
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path_provider/path_provider.dart';

/// Central Dio instance the whole app shares. Handles attaching the access
/// token to every request and persists the backend's httpOnly refresh-token
/// cookie across app launches via a disk-backed cookie jar (Dio, unlike a
/// browser, does not do this automatically).
class ApiClient {
  ApiClient._internal();

  static final ApiClient instance = ApiClient._internal();

  /// The Android emulator can't reach the host machine via `localhost` — it
  /// needs the special alias `10.0.2.2`. iOS simulators and desktop targets
  /// use `localhost` directly. A physical device needs your Mac's LAN IP
  /// instead (e.g. http://192.168.1.23:4000/api) — override manually below
  /// if you're testing on real hardware.
  static String get baseUrl {
    if (!kIsWeb && Platform.isAndroid) return 'http://10.0.2.2:4000/api';
    return 'http://localhost:4000/api';
  }

  late final Dio _dio;
  String? _accessToken;
  final _storage = const FlutterSecureStorage();
  bool _initialized = false;

  Dio get dio => _dio;

  /// Must be awaited once before the app makes any requests (see main.dart).
  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
      ),
    );

    final appDocDir = await getApplicationDocumentsDirectory();
    final cookieJar = PersistCookieJar(storage: FileStorage('${appDocDir.path}/.cookies/'));
    _dio.interceptors.add(CookieManager(cookieJar));

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (_accessToken != null) {
            options.headers['Authorization'] = 'Bearer $_accessToken';
          }
          handler.next(options);
        },
      ),
    );

    _accessToken = await _storage.read(key: 'accessToken');
  }

  Future<void> setAccessToken(String? token) async {
    _accessToken = token;
    if (token == null) {
      await _storage.delete(key: 'accessToken');
    } else {
      await _storage.write(key: 'accessToken', value: token);
    }
  }

  String? get accessToken => _accessToken;
}
