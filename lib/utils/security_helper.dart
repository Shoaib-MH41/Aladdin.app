import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

class SecurityHelper {
  static final _storage = FlutterSecureStorage();
  static final _auth = LocalAuthentication();

  // ✅ PIN محفوظ کرنا
  static Future<void> savePin(String pin) async {
    await _storage.write(key: 'app_pin', value: pin);
  }

  // ✅ PIN حاصل کرنا
  static Future<String?> getPin() async {
    return await _storage.read(key: 'app_pin');
  }

  // ✅ PIN تصدیق
  static Future<bool> verifyPin(BuildContext context) async {
    String? savedPin = await getPin();

    if (savedPin == null) {
      // نیا PIN سیٹ کرو
      TextEditingController pinController = TextEditingController();
      bool confirmed = false;

      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text("نیا PIN سیٹ کریں"),
          content: TextField(
            controller: pinController,
            obscureText: true,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(hintText: "4 ہندسوں والا PIN درج کریں"),
          ),
          actions: [
            TextButton(
              child: Text("محفوظ کریں"),
              onPressed: () async {
                await savePin(pinController.text.trim());
                confirmed = true;
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      );

      return confirmed;
    } else {
      // تصدیق کے لیے PIN مانگو
      TextEditingController pinController = TextEditingController();
      bool verified = false;

      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text("PIN درج کریں"),
          content: TextField(
            controller: pinController,
            obscureText: true,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(hintText: "اپنا PIN درج کریں"),
          ),
          actions: [
            TextButton(
              child: Text("تصدیق کریں"),
              onPressed: () {
                if (pinController.text.trim() == savedPin) verified = true;
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      );

      return verified;
    }
  }

  // ✅ بائیومیٹرک لاک (اختیاری)
  static Future<bool> tryBiometric() async {
    bool canCheck = await _auth.canCheckBiometrics;
    if (!canCheck) return false;

    try {
      return await _auth.authenticate(
        localizedReason: 'اپنی شناخت کی تصدیق کریں',
        options: AuthenticationOptions(biometricOnly: true),
      );
    } catch (e) {
      return false;
    }
  }

  // ✅ API Key محفوظ کرنا
  static Future<void> saveApiKey(String key) async {
    await _storage.write(key: 'gemini_api', value: key);
  }

  static Future<String?> getApiKey() async {
    return await _storage.read(key: 'gemini_api');
  }

  // ✅ GitHub Token محفوظ کرنا
  static Future<void> saveGitToken(String token) async {
    await _storage.write(key: 'github_token', value: token);
  }

  static Future<String?> getGitToken() async {
    return await _storage.read(key: 'github_token');
  }

  // ✅ تمام ڈیٹا صاف کرنا
  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
