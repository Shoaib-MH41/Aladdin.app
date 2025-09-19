import 'package:flutter/material.dart';

class AppTypeModel {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;

  const AppTypeModel({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
  });

  /// JSON سے Object بنانے کے لیے
  factory AppTypeModel.fromJson(Map<String, dynamic> json) {
    return AppTypeModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      icon: _getIconFromString(json['icon'] as String),
      color: _getColorFromString(json['color'] as String),
    );
  }

  /// Object کو JSON میں تبدیل کرنے کے لیے
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': _getIconName(icon),
      'color': _getColorName(color),
    };
  }

  /// Helper methods - String → IconData
  static IconData _getIconFromString(String iconName) {
    switch (iconName) {
      case 'person':
        return Icons.person;
      case 'admin':
        return Icons.admin_panel_settings;
      case 'delivery':
        return Icons.delivery_dining;
      default:
        return Icons.help;
    }
  }

  /// Helper methods - IconData → String
  static String _getIconName(IconData icon) {
    if (icon == Icons.person) return 'person';
    if (icon == Icons.admin_panel_settings) return 'admin';
    if (icon == Icons.delivery_dining) return 'delivery';
    return 'help';
  }

  /// Helper methods - String → Color
  static Color _getColorFromString(String colorName) {
    switch (colorName) {
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'orange':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  /// Helper methods - Color → String
  static String _getColorName(Color color) {
    if (color == Colors.blue) return 'blue';
    if (color == Colors.green) return 'green';
    if (color == Colors.orange) return 'orange';
    return 'grey';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppTypeModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'AppTypeModel(id: $id, name: $name, description: $description)';
  }
}
