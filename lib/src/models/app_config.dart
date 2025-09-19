class AppConfig {
  final String? appName;
  final String? appVersion;
  final String? baseUrl;
  final String? apiKey;
  final String? environment;
  final String? logLevel;
  final Map<String, dynamic>? features;

  AppConfig({
    this.appName,
    this.appVersion,
    this.baseUrl,
    this.apiKey,
    this.environment,
    this.logLevel,
    this.features,
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
    };
  }
}
