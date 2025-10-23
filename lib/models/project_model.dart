class Project {
  final String id;
  String name;
  String framework;
  List<String> platforms;
  Map<String, String> assets;
  Map<String, String> features;
  String? generatedCode;
  String? apkLink;
  
  // ✅ نئے فیلڈز Gemini + GitHub کے لیے
  String? githubRepoUrl;
  String? geminiPrompt;
  String? status; // 'generating', 'debugging', 'completed', 'error'
  String? lastError;
  DateTime createdAt;
  DateTime? lastUpdated;

  Project({
    required this.id,
    required this.name,
    required this.framework,
    required this.platforms,
    required this.assets,
    this.features = const {},
    this.generatedCode,
    this.apkLink,
    // ✅ نئے parameters
    this.githubRepoUrl,
    this.geminiPrompt,
    this.status = 'draft',
    this.lastError,
    required this.createdAt,
    this.lastUpdated,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'framework': framework,
      'platforms': platforms,
      'assets': assets,
      'features': features,
      'generatedCode': generatedCode,
      'apkLink': apkLink,
      // ✅ نئے فیلڈز
      'githubRepoUrl': githubRepoUrl,
      'geminiPrompt': geminiPrompt,
      'status': status,
      'lastError': lastError,
      'createdAt': createdAt.toIso8601String(),
      'lastUpdated': lastUpdated?.toIso8601String(),
    };
  }

  factory Project.fromMap(Map<String, dynamic> map) {
    return Project(
      id: map['id'],
      name: map['name'],
      framework: map['framework'],
      platforms: List<String>.from(map['platforms']),
      assets: Map<String, String>.from(map['assets']),
      features: Map<String, String>.from(map['features'] ?? {}),
      generatedCode: map['generatedCode'],
      apkLink: map['apkLink'],
      // ✅ نئے فیلڈز
      githubRepoUrl: map['githubRepoUrl'],
      geminiPrompt: map['geminiPrompt'],
      status: map['status'] ?? 'draft',
      lastError: map['lastError'],
      createdAt: DateTime.parse(map['createdAt']),
      lastUpdated: map['lastUpdated'] != null ? DateTime.parse(map['lastUpdated']) : null,
    );
  }

  // ✅ helper methods
  bool get isGenerated => generatedCode != null && generatedCode!.isNotEmpty;
  bool get hasError => lastError != null && lastError!.isNotEmpty;
  bool get isOnGitHub => githubRepoUrl != null && githubRepoUrl!.isNotEmpty;
}
