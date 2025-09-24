import 'dart:io';

class TermuxService {
  static Future<String> runCommand(String command) async {
    try {
      final ProcessResult result = await Process.run('sh', ['-c', command]);
      
      if (result.exitCode == 0) {
        return result.stdout.toString();
      } else {
        throw Exception("Command failed: ${result.stderr}");
      }
    } catch (e) {
      throw Exception("Termux command error: $e");
    }
  }
  
  static Future<String> buildAPK(String projectName, String code) async {
    try {
      // پہلے کوڈ کو فائل میں سیو کریں
      await runCommand('''
      cd /data/data/com.termux/files/home &&
      mkdir -p projects/$projectName &&
      cat > projects/$projectName/lib/main.dart << 'EOF'
      $code
      EOF
      ''');
      
      // پھر APK بنائیں
      final String result = await runCommand('''
      cd /data/data/com.termux/files/home/projects/$projectName &&
      flutter build apk --release
      ''');
      
      return "APK built successfully! Path: /home/projects/$projectName/build/app/outputs/flutter-apk/app-release.apk";
    } catch (e) {
      throw Exception("APK build failed: $e");
    }
  }
}
