import 'dart:io';

class TermuxService {
  static Future<String> buildAPK(String projectName, String flutterCode) async {
    try {
      print("🚀 APK بنانے کا پروسیس شروع...");

      // ✅ پہلے Download folder میں ڈائریکٹری بنائیں
      final downloadDir = Directory('/storage/emulated/0/Download/aladdin_projects');
      if (!await downloadDir.exists()) {
        await downloadDir.create(recursive: true);
      }

      final projectDir = Directory('${downloadDir.path}/$projectName');
      if (await projectDir.exists()) {
        await projectDir.delete(recursive: true);
      }
      await projectDir.create(recursive: true);

      // ✅ lib ڈائریکٹری بنائیں
      final libDir = Directory('${projectDir.path}/lib');
      await libDir.create(recursive: true);

      // ✅ main.dart فائل بنائیں
      final mainFile = File('${libDir.path}/main.dart');
      await mainFile.writeAsString(flutterCode);

      // ✅ pubspec.yaml بنائیں
      final pubspecFile = File('${projectDir.path}/pubspec.yaml');
      await pubspecFile.writeAsString('''
