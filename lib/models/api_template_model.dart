class ApiTemplate {
  final String id;
  final String name;
  final String provider;
  final String url;
  final String description;
  final bool keyRequired;
  final String freeTierInfo;
  final String category;

  ApiTemplate({
    required this.id,
    required this.name,
    required this.provider,
    required this.url,
    required this.description,
    required this.keyRequired,
    required this.freeTierInfo,
    required this.category,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'provider': provider,
      'url': url,
      'description': description,
      'keyRequired': keyRequired,
      'freeTierInfo': freeTierInfo,
      'category': category,
    };
  }
}
