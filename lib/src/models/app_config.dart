
class AppConfig {
  // 🔹 Basic App Info
  String? appName;       
  String? appType;       
  String? language;      

  // 🔹 Theme Settings
  String? theme;         
  String? primaryColor;  

  // 🔹 API Config
  String? apiInput;                 
  Map<String, dynamic>? apiConfig;  

  AppConfig({
    this.appName,
    this.appType,
    this.language,
    this.theme,
    this.primaryColor,
    this.apiInput,
    this.apiConfig,
  });

  // JSON میں تبدیل کرنے کا فنکشن
  Map<String, dynamic> toJson() {
    return {
      'appName': appName,
      'appType': appType,
      'language': language,
      'theme': theme,
      'primaryColor': primaryColor,
      'apiInput': apiInput,
      'apiConfig': apiConfig,
    };
  }

  // JSON سے واپس AppConfig بنانے کا فنکشن
  factory AppConfig.fromJson(Map<String, dynamic> json) {
    return AppConfig(
      appName: json['appName'],
      appType: json['appType'],
      language: json['language'],
      theme: json['theme'],
      primaryColor: json['primaryColor'],
      apiInput: json['apiInput'],
      apiConfig: json['apiConfig'],
    );
  }
}
