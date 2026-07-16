import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'dart:math';

class HashUtil {
  /// Generates a secure, random 4-digit numeric verification code
  static String generatePlaintextCode() {
    final Random random = Random.secure();
    int code = 1000 + random.nextInt(9000); // Guarantees a 4-digit code
    return code.toString();
  }

  /// Hashes a plaintext code using SHA-256 for secure Firestore comparisons
  static String hashStringToSha256(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Verifies a plaintext input matches a stored SHA-256 hash
  static bool verifyMatch(String plaincodeInput, String storedHash) {
    final hashedInput = hashStringToSha256(plaincodeInput);
    return hashedInput == storedHash;
  }
}
