import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

class PasswordHasher {
  PasswordHasher._();

  /// Generates a random alphanumeric salt string
  static String generateSalt([int length = 16]) {
    final rand = Random.secure();
    final bytes = List<int>.generate(length, (_) => rand.nextInt(256));
    return base64Url.encode(bytes);
  }

  /// Hashes a password with SHA-256 and a per-user salt
  static String hashPassword(String password, String salt) {
    final bytes = utf8.encode('$salt$password');
    return sha256.convert(bytes).toString();
  }

  /// Verifies a plain password against a stored hash and salt
  static bool verifyPassword({
    required String password,
    required String salt,
    required String storedHash,
  }) {
    final computed = hashPassword(password, salt);
    return computed == storedHash;
  }
}
