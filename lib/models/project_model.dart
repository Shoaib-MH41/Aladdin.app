
class Project {
  final String id;
  String name;
  String framework;
  List<String> platforms;
  Map<String, String> assets;
  Map<String, String> features;
  String? generatedCode;
  String? apkLink;
  String? githubRepoUrl;
  String? geminiPrompt;
  String? status;
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
    this.githubRepoUrl,
    this.geminiPrompt,
    this.status = 'draft',
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
      'githubRepoUrl': githubRepoUrl,
      'geminiPrompt': geminiPrompt,
      'status': status,
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
      githubRepoUrl: map['githubRepoUrl'],
      geminiPrompt: map['geminiPrompt'],
      status: map['status'] ?? 'draft',
      createdAt: DateTime.parse(map['createdAt']),
      lastUpdated: map['lastUpdated'] != null ? DateTime.parse(map['lastUpdated']) : null,
    );
  }

  bool get isGenerated => generatedCode != null && generatedCode!.isNotEmpty;
  bool get hasError => status == 'error';
  bool get isOnGitHub => githubRepoUrl != null && githubRepoUrl!.isNotEmpty;
}
