import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static const _keyAuthToken = 'fv_auth_token';
  static const _keyUserEmail = 'fv_user_email';
  static const _keyUserRole = 'fv_user_role';

  SecureStorageService._();

  static Future<void> saveAuthToken(String token) async {
    await _storage.write(key: _keyAuthToken, value: token);
  }

  static Future<String?> getAuthToken() async {
    return await _storage.read(key: _keyAuthToken);
  }

  static Future<void> saveUserCredentials({required String email, required String role}) async {
    await _storage.write(key: _keyUserEmail, value: email);
    await _storage.write(key: _keyUserRole, value: role);
  }

  static Future<Map<String, String?>> getUserCredentials() async {
    final email = await _storage.read(key: _keyUserEmail);
    final role = await _storage.read(key: _keyUserRole);
    return {'email': email, 'role': role};
  }

  static Future<void> clearAuthData() async {
    await _storage.delete(key: _keyAuthToken);
    await _storage.delete(key: _keyUserEmail);
    await _storage.delete(key: _keyUserRole);
  }
}
