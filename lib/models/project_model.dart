class Project {
  final String id;
  String name;
  String framework;
  List<String> platforms;
  Map<String, String> assets;
  Map<String, String> features;
  String? generatedCode;
  String? apkLink;

  Project({
    required this.id,
    required this.name,
    required this.framework,
    required this.platforms,
    required this.assets,
    this.features = const {},
    this.generatedCode,
    this.apkLink,
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
    );
  }
}
