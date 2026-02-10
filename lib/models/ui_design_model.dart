// lib/models/ui_design_model.dart

import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';

class UIDesignModel {
  final String componentType;
  final String label;
  final Map<String, dynamic> properties;
  final Map<String, dynamic> style;
  final Map<String, dynamic>? animation;
  final Map<String, dynamic>? interaction;
  final List<UIDesignModel>? children;
  final Map<String, dynamic> metadata;
  final String? promptUsed;

  UIDesignModel({
    required this.componentType,
    required this.label,
    required this.properties,
    required this.style,
    this.animation,
    this.interaction,
    this.children,
    this.metadata = const {},
    this.promptUsed,
  });

  factory UIDesignModel.fromJson(Map<String, dynamic> json) {
    return UIDesignModel(
      componentType: json['componentType']?.toString().toLowerCase() ?? 'container',
      label: json['label']?.toString() ?? 'Untitled Component',
      properties: Map<String, dynamic>.from(json['properties'] ?? {}),
      style: Map<String, dynamic>.from(json['style'] ?? {}),
      animation: json['animation'] != null 
          ? Map<String, dynamic>.from(json['animation']) 
          : null,
      interaction: json['interaction'] != null
          ? Map<String, dynamic>.from(json['interaction'])
          : null,
      children: json['children'] != null
          ? (json['children'] as List)
              .map((child) => UIDesignModel.fromJson(child))
              .toList()
          : null,
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
      promptUsed: json['promptUsed']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'componentType': componentType,
      'label': label,
      'properties': properties,
      'style': style,
      'animation': animation,
      'interaction': interaction,
      'children': children?.map((child) => child.toJson()).toList(),
      'metadata': metadata,
      'promptUsed': promptUsed,
      'generatedAt': DateTime.now().toIso8601String(),
    };
  }

  String toPrettyJson() {
    final encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(toJson());
  }

  // Helper methods
  bool get hasGradient => style['gradient'] != null;
  bool get hasShadow => style['shadow'] != null;
  bool get hasAnimation => animation != null;
  bool get hasChildren => children != null && children!.isNotEmpty;

  double get borderRadius {
    final br = style['borderRadius'];
    if (br is double) return br;
    if (br is int) return br.toDouble();
    return 0.0;
  }

  @override
  String toString() {
    return 'UIDesignModel(type: $componentType, label: $label)';
  }
}

// Modern Design Constants
class DesignConstants {
  // Modern Color Palette
  static const Map<String, String> modernColors = {
    'indigo': '#6366F1',
    'violet': '#8B5CF6',
    'pink': '#EC4899',
    'emerald': '#10B981',
    'blue': '#3B82F6',
    'amber': '#F59E0B',
    'rose': '#F43F5E',
    'cyan': '#06B6D4',
    'slate': '#64748B',
    'gray': '#6B7280',
  };

  // Border Radius Presets
  static const Map<String, double> borderRadiusPresets = {
    'none': 0.0,
    'sm': 4.0,
    'md': 8.0,
    'lg': 12.0,
    'xl': 16.0,
    '2xl': 20.0,
    '3xl': 24.0,
    'full': 999.0,
  };

  // Shadow Presets
  static const Map<String, Map<String, dynamic>> shadowPresets = {
    'none': {
      'color': '#00000000',
      'blurRadius': 0.0,
      'offsetX': 0.0,
      'offsetY': 0.0,
    },
    'sm': {
      'color': '#000000',
      'blurRadius': 4.0,
      'offsetX': 0.0,
      'offsetY': 2.0,
      'opacity': 0.1,
    },
    'md': {
      'color': '#000000',
      'blurRadius': 10.0,
      'offsetX': 0.0,
      'offsetY': 4.0,
      'opacity': 0.15,
    },
    'lg': {
      'color': '#000000',
      'blurRadius': 25.0,
      'offsetX': 0.0,
      'offsetY': 10.0,
      'opacity': 0.2,
    },
    'xl': {
      'color': '#000000',
      'blurRadius': 40.0,
      'offsetX': 0.0,
      'offsetY': 20.0,
      'opacity': 0.25,
    },
  };

  // Component Types
  static const List<String> componentTypes = [
    'button',
    'card',
    'container',
    'textfield',
    'appbar',
    'navbar',
    'list',
    'grid',
    'image',
    'icon',
    'text',
    'switch',
    'checkbox',
    'radio',
    'slider',
    'progress',
    'chip',
    'badge',
    'avatar',
  ];
}

// Icons Constants
class IconsConstants {
  // Material Icons names (as strings for AI generation)
  static const String arrowForward = 'arrow_forward';
  static const String search = 'search';
  static const String menu = 'menu';
  static const String clear = 'clear';
  static const String close = 'close';
  static const String check = 'check';
  static const String add = 'add';
  static const String remove = 'remove';
  static const String home = 'home';
  static const String person = 'person';
  static const String settings = 'settings';
  static const String notifications = 'notifications';
  static const String favorite = 'favorite';
  static const String share = 'share';
  static const String download = 'download';
  static const String upload = 'upload';
  static const String edit = 'edit';
  static const String delete = 'delete';
  static const String refresh = 'refresh';
  static const String help = 'help';
  static const String info = 'info';
  static const String warning = 'warning';
  static const String error = 'error';
  static const String success = 'check_circle';
}

// Utility functions for design operations
class DesignUtils {
  static Map<String, dynamic> mergeDesigns(
    Map<String, dynamic> baseDesign,
    Map<String, dynamic> overlayDesign,
  ) {
    final merged = Map<String, dynamic>.from(baseDesign);
    
    overlayDesign.forEach((key, value) {
      if (value is Map && merged[key] is Map) {
        merged[key] = mergeDesigns(merged[key] as Map<String, dynamic>, value as Map<String, dynamic>);
      } else {
        merged[key] = value;
      }
    });
    
    return merged;
  }

  static String extractDesignSummary(Map<String, dynamic> design) {
    final type = design['componentType'] ?? 'unknown';
    final label = design['label'] ?? 'Unnamed';
    final style = design['style'] ?? {};
    final hasGradient = style['gradient'] != null;
    final borderRadius = style['borderRadius'] ?? 0;
    
    return '''
Type: $type
Label: $label
Features: ${hasGradient ? 'Gradient, ' : ''}Border Radius: $borderRadius
''';
  }
}
