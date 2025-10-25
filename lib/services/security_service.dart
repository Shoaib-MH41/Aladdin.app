import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecurityService {
  static const _storage = FlutterSecureStorage();
  static const _pinKey = 'user_pin';

  /// ✅ PIN محفوظ کریں
  Future<void> savePin(String pin) async {
    await _storage.write(key: _pinKey, value: pin);
  }

  /// ✅ PIN تصدیق کریں
  Future<bool> verifyPin(String pin) async {
    final savedPin = await _storage.read(key: _pinKey);
    return savedPin == pin;
  }

  /// ✅ چیک کریں کہ PIN پہلے سے محفوظ ہے یا نہیں
  Future<bool> hasPin() async {
    final savedPin = await _storage.read(key: _pinKey);
    return savedPin != null;
  }

  /// ✅ PIN ہٹا دیں
  Future<void> clearPin() async {
    await _storage.delete(key: _pinKey);
  }
}
