class Project {
  final String id;
  String name;
  String framework;
  List<String> platforms;
  Map<String, String> assets;

  Project({
    required this.id,
    required this.name,
    required this.framework,
    required this.platforms,
    required this.assets,
  });

  // Convert to Map (for Firebase/GitHub/API use later)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'framework': framework,
      'platforms': platforms,
      'assets': assets,
    };
  }

  // Convert back from Map
  factory Project.fromMap(Map<String, dynamic> map) {
    return Project(
      id: map['id'],
      name: map['name'],
      framework: map['framework'],
      platforms: List<String>.from(map['platforms']),
      assets: Map<String, String>.from(map['assets']),
    );
  }
}
