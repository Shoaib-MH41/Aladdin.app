class AppConfig {
  final String? appName;
  final String? appVersion;
  final String? baseUrl;
  final String? apiKey;
  final String? environment;
  final String? logLevel;
  final Map<String, dynamic>? features;
  final String? appType;      // نیا
  final String? language;     // نیا
  final String? theme;        // نیا
  final String? primaryColor; // نیا
  final String? apiInput;     // نیا

  AppConfig({
    this.appName,
    this.appVersion,
    this.baseUrl,
    this.apiKey,
    this.environment,
    this.logLevel,
    this.features,
    this.appType,
    this.language,
    this.theme,
    this.primaryColor,
    this.apiInput,
  });

  factory AppConfig.fromJson(Map<String, dynamic> json) {
    return AppConfig(
      appName: json['appName'] as String?,
      appVersion: json['appVersion'] as String?,
      baseUrl: json['baseUrl'] as String?,
      apiKey: json['apiKey'] as String?,
      environment: json['environment'] as String?,
      logLevel: json['logLevel'] as String?,
      features: json['features'] as Map<String, dynamic>?,
      appType: json['appType'] as String?,      // نیا
      language: json['language'] as String?,    // نیا
      theme: json['theme'] as String?,          // نیا
      primaryColor: json['primaryColor'] as String?, // نیا
      apiInput: json['apiInput'] as String?,    // نیا
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'appName': appName,
      'appVersion': appVersion,
      'baseUrl': baseUrl,
      'apiKey': apiKey,
      'environment': environment,
      'logLevel': logLevel,
      'features': features,
      'appType': appType,      // نیا
      'language': language,    // نیا
      'theme': theme,          // نیا
      'primaryColor': primaryColor, // نیا
      'apiInput': apiInput,    // نیا
    };
  }
}
