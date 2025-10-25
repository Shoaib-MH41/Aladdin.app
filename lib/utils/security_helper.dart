import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

class SecurityHelper {
  // 🔒 Secure Storage instance
  static const _storage = FlutterSecureStorage();
  static final LocalAuthentication _auth = LocalAuthentication();

  // 🔹 محفوظ کرنا (Encrypted)
  static Future<void> saveSecureData(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } catch (e) {
      throw Exception('ڈیٹا محفوظ نہیں ہو سکا: $e');
    }
  }

  // 🔹 پڑھنا (Decrypted)
  static Future<String?> getSecureData(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (e) {
      throw Exception('ڈیٹا حاصل نہیں ہو سکا: $e');
    }
  }

  // 🔹 حذف کرنا
  static Future<void> deleteSecureData(String key) async {
    try {
      await _storage.delete(key: key);
    } catch (e) {
      throw Exception('ڈیٹا حذف کرنے میں مسئلہ: $e');
    }
  }

  // 🔹 بایومیٹرک تصدیق (Fingerprint / Face ID)
  static Future<bool> authenticateUser() async {
    try {
      final bool canCheck = await _auth.canCheckBiometrics;
      final bool isSupported = await _auth.isDeviceSupported();

      if (!canCheck || !isSupported) {
        return false; // اگر ڈیوائس سپورٹ نہیں کرتی
      }

      final bool didAuthenticate = await _auth.authenticate(
        localizedReason: 'اپنی شناخت کی تصدیق کریں تاکہ API Keys تک رسائی حاصل ہو',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      return didAuthenticate;
    } catch (e) {
      print('Biometric error: $e');
      return false;
    }
  }

  // 🔹 PIN محفوظ کرنا (fallback اگر biometric نہ ہو)
  static Future<void> savePIN(String pin) async {
    await saveSecureData('user_pin', pin);
  }

  static Future<bool> verifyPIN(String inputPIN) async {
    final storedPIN = await getSecureData('user_pin');
    return storedPIN != null && storedPIN == inputPIN;
  }
}

