import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:archive/archive_io.dart';

class AppPublisher {
  Future<Map<String, dynamic>> prepareForPlayStore({
    required String appName,
    required String generatedCode,
    required String framework,
  }) async {
    return {
      "package_name": "com.${appName.toLowerCase().replaceAll(' ', '_')}.app",
      "permissions": ["INTERNET", "READ_EXTERNAL_STORAGE"],
      "privacy_policy":
          "https://yourdomain.com/${appName.toLowerCase()}_privacy_policy.html",
      "app_icon": ["512x512 PNG", "1024x1024 Icon"],
      "generated_code": generatedCode,
    };
  }

  String getBuildCommands(String appName, {required String framework}) {
    if (framework.toLowerCase() == "flutter") {
      return '''
# Build APK for Release
flutter build apk --release

# Output Path
build/app/outputs/flutter-apk/app-release.apk
''';
    } else {
      return '# Add your $framework build command here';
    }
  }

  Future<String> exportToZip(Map<String, dynamic> publishData, String appName) async {
    final dir = await getApplicationDocumentsDirectory();
    final exportDir = Directory(p.join(dir.path, appName));
    if (!exportDir.existsSync()) exportDir.createSync(recursive: true);

    File(p.join(exportDir.path, "publish_info.json"))
        .writeAsStringSync(jsonEncode(publishData));

    final zipPath = p.join(dir.path, "$appName-Package.zip");
    final encoder = ZipFileEncoder();
    encoder.create(zipPath);
    encoder.addDirectory(exportDir);
    encoder.close();
    return zipPath;
  }

  Future<String> uploadToPlayStore({
    required String serviceAccountPath,
    required String packageName,
  }) async {
    try {
      final credentials = jsonDecode(File(serviceAccountPath).readAsStringSync());
      final clientEmail = credentials['client_email'];
      final privateKey = credentials['private_key'];

      final jwtHeader = base64UrlEncode(utf8.encode(jsonEncode({
        "alg": "RS256",
        "typ": "JWT",
      })));

      final iat = (DateTime.now().millisecondsSinceEpoch / 1000).floor();
      final exp = iat + 3600;

      final jwtClaim = base64UrlEncode(utf8.encode(jsonEncode({
        "iss": clientEmail,
        "scope": "https://www.googleapis.com/auth/androidpublisher",
        "aud": "https://oauth2.googleapis.com/token",
        "exp": exp,
        "iat": iat,
      })));

      final jwtSignature = _fakeSignJwt("$jwtHeader.$jwtClaim", privateKey);
      final jwt = "$jwtHeader.$jwtClaim.$jwtSignature";

      final tokenResponse = await http.post(
        Uri.parse("https://oauth2.googleapis.com/token"),
        headers: {"Content-Type": "application/x-www-form-urlencoded"},
        body: {
          "grant_type": "urn:ietf:params:oauth:grant-type:jwt-bearer",
          "assertion": jwt,
        },
      );

      if (tokenResponse.statusCode != 200) {
        throw Exception("Failed to get access token: ${tokenResponse.body}");
      }

      return "✅ Token generated successfully! Ready for upload of $packageName";
    } catch (e) {
      throw Exception("Upload failed: $e");
    }
  }

  String _fakeSignJwt(String input, String privateKey) {
    // Placeholder signature – real signing requires RSA implementation
    return base64UrlEncode(utf8.encode("fake_signature"));
  }
}

