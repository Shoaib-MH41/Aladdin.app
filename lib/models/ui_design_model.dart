// lib/models/ui_design_model.dart

import 'dart:convert';

class UIDesignModel {
  final String componentType; // button, card, textfield, container, appbar, navbar
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

  // Modern design preset generator
  static UIDesignModel createModernButton({
    String label = 'Click Me',
    String? customPrompt,
  }) {
    return UIDesignModel(
      componentType: 'button',
      label: label,
      properties: {
        'width': 120.0,
        'height': 50.0,
        'padding': {'top': 12.0, 'right': 24.0, 'bottom': 12.0, 'left': 24.0},
        'margin': {'top': 0.0, 'right': 0.0, 'bottom': 0.0, 'left': 0.0},
        'alignment': 'center',
        'constraints': {'minWidth': 80.0, 'maxWidth': 200.0},
      },
      style: {
        'backgroundColor': '#6366F1',
        'borderRadius': 12.0,
        'border': {'color': '#8B5CF6', 'width': 2.0},
        'shadow': {
          'type': 'medium',
          'color': '#000000',
          'blurRadius': 10.0,
          'offsetX': 0.0,
          'offsetY': 4.0,
          'spreadRadius': 0.0,
        },
        'gradient': {
          'type': 'linear',
          'colors': ['#6366F1', '#8B5CF6'],
          'stops': [0.0, 1.0],
          'angle': 135.0,
          'center': {'x': 0.5, 'y': 0.5},
        },
        'textStyle': {
          'color': '#FFFFFF',
          'fontSize': 14.0,
          'fontWeight': 'w600',
          'fontFamily': 'Poppins',
          'letterSpacing': 0.5,
          'height': 1.2,
        },
        'icon': {
          'name': IconsConstants.arrowForward,
          'color': '#FFFFFF',
          'size': 16.0,
          'position': 'end',
        },
      },
      animation: {
        'type': 'scale',
        'duration': 200,
        'curve': 'easeOutBack',
        'delay': 0,
        'repeat': false,
      },
      interaction: {
        'hoverEffect': 'scale',
        'hoverScale': 1.05,
        'onTap': 'onPressed',
        'feedback': 'vibrate',
        'rippleColor': '#FFFFFF',
        'rippleOpacity': 0.2,
      },
      metadata: {
        'version': '1.0',
        'theme': 'modern',
        'createdBy': 'AI Designer',
        'tags': ['button', 'modern', 'gradient'],
      },
      promptUsed: customPrompt,
    );
  }

  static UIDesignModel createModernCard({
    String label = 'Card Title',
    String? customPrompt,
  }) {
    return UIDesignModel(
      componentType: 'card',
      label: label,
      properties: {
        'width': 300.0,
        'height': 200.0,
        'padding': {'top': 16.0, 'right': 16.0, 'bottom': 16.0, 'left': 16.0},
        'margin': {'top': 8.0, 'right': 8.0, 'bottom': 8.0, 'left': 8.0},
        'elevation': 4.0,
        'constraints': {'minWidth': 200.0, 'maxWidth': 400.0},
      },
      style: {
        'backgroundColor': '#FFFFFF',
        'borderRadius': 20.0,
        'border': {'color': '#E2E8F0', 'width': 1.0},
        'shadow': {
          'type': 'large',
          'color': '#000000',
          'blurRadius': 25.0,
          'offsetX': 0.0,
          'offsetY': 10.0,
          'spreadRadius': 0.0,
        },
        'gradient': null,
        'textStyle': {
          'title': {
            'color': '#1E293B',
            'fontSize': 18.0,
            'fontWeight': 'w700',
            'fontFamily': 'Poppins',
          },
          'subtitle': {
            'color': '#64748B',
            'fontSize': 14.0,
            'fontWeight': 'w400',
            'fontFamily': 'Poppins',
          },
          'body': {
            'color': '#475569',
            'fontSize': 12.0,
            'fontWeight': 'w300',
            'fontFamily': 'Poppins',
          },
        },
      },
      animation: {
        'type': 'fade',
        'duration': 300,
        'curve': 'easeOut',
        'delay': 100,
      },
      children: [
        UIDesignModel(
          componentType: 'text',
          label: 'Card Content',
          properties: {
            'margin': {'top': 8.0, 'right': 0.0, 'bottom': 8.0, 'left': 0.0},
          },
          style: {
            'textStyle': {
              'color': '#475569',
              'fontSize': 14.0,
              'fontWeight': 'w400',
            },
          },
          metadata: {},
        ),
        UIDesignModel.createModernButton(label: 'Action'),
      ],
      metadata: {
        'version': '1.0',
        'theme': 'modern',
        'createdBy': 'AI Designer',
        'tags': ['card', 'modern', 'elevated'],
      },
      promptUsed: customPrompt,
    );
  }

  static UIDesignModel createTextField({
    String label = 'Enter text',
    String hintText = 'Type here...',
    String? customPrompt,
  }) {
    return UIDesignModel(
      componentType: 'textfield',
      label: label,
      properties: {
        'width': 280.0,
        'height': 56.0,
        'padding': {'top': 0.0, 'right': 16.0, 'bottom': 0.0, 'left': 16.0},
        'margin': {'top': 8.0, 'right': 0.0, 'bottom': 8.0, 'left': 0.0},
        'hintText': hintText,
        'maxLines': 1,
        'obscureText': false,
        'keyboardType': 'text',
      },
      style: {
        'backgroundColor': '#FFFFFF',
        'borderRadius': 12.0,
        'border': {
          'enabled': {'color': '#E2E8F0', 'width': 1.0},
          'focused': {'color': '#6366F1', 'width': 2.0},
          'error': {'color': '#EF4444', 'width': 2.0},
        },
        'shadow': {
          'type': 'small',
          'color': '#000000',
          'blurRadius': 4.0,
          'offsetX': 0.0,
          'offsetY': 2.0,
        },
        'textStyle': {
          'color': '#1E293B',
          'fontSize': 14.0,
          'fontWeight': 'w400',
          'fontFamily': 'Poppins',
        },
        'hintStyle': {
          'color': '#94A3B8',
          'fontSize': 14.0,
          'fontWeight': 'w300',
        },
        'prefixIcon': {
          'name': IconsConstants.search,
          'color': '#94A3B8',
          'size': 20.0,
        },
        'suffixIcon': {
          'name': IconsConstants.clear,
          'color': '#94A3B8',
          'size': 20.0,
        },
      },
      animation: {
        'type': 'slide',
        'duration': 200,
        'curve': 'easeOut',
        'direction': 'up',
      },
      interaction: {
        'onChanged': 'onTextChanged',
        'onSubmitted': 'onSubmitted',
        'onTap': 'onTap',
        'autofocus': false,
        'enableSuggestions': true,
      },
      metadata: {
        'version': '1.0',
        'theme': 'modern',
        'createdBy': 'AI Designer',
        'tags': ['textfield', 'input', 'modern'],
      },
      promptUsed: customPrompt,
    );
  }

  static UIDesignModel createAppBar({
    String title = 'App Title',
    String? customPrompt,
  }) {
    return UIDesignModel(
      componentType: 'appbar',
      label: title,
      properties: {
        'height': 56.0,
        'elevation': 4.0,
        'centerTitle': true,
        'automaticallyImplyLeading': true,
      },
      style: {
        'backgroundColor': '#1E293B',
        'foregroundColor': '#FFFFFF',
        'gradient': {
          'type': 'linear',
          'colors': ['#1E293B', '#334155'],
          'stops': [0.0, 1.0],
          'angle': 180.0,
        },
        'titleTextStyle': {
          'color': '#FFFFFF',
          'fontSize': 20.0,
          'fontWeight': 'w600',
          'fontFamily': 'Poppins',
        },
        'toolbarHeight': 56.0,
        'shape': {
          'type': 'rounded',
          'borderRadius': {'bottomLeft': 20.0, 'bottomRight': 20.0},
        },
      },
      children: [
        UIDesignModel(
          componentType: 'icon_button',
          label: 'Menu',
          properties: {
            'icon': IconsConstants.menu,
            'size': 24.0,
          },
          style: {
            'color': '#FFFFFF',
          },
          metadata: {},
        ),
        UIDesignModel(
          componentType: 'icon_button',
          label: 'Search',
          properties: {
            'icon': IconsConstants.search,
            'size': 24.0,
          },
          style: {
            'color': '#FFFFFF',
          },
          metadata: {},
        ),
      ],
      metadata: {
        'version': '1.0',
        'theme': 'dark',
        'createdBy': 'AI Designer',
        'tags': ['appbar', 'navigation', 'modern'],
      },
      promptUsed: customPrompt,
    );
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

  Color get backgroundColor {
    final color = style['backgroundColor'];
    if (color is String) {
      return _parseColor(color);
    }
    return const Color(0xFF6366F1);
  }

  List<Color> get gradientColors {
    if (!hasGradient) return [backgroundColor];
    final gradient = style['gradient'];
    final colors = gradient['colors'] as List?;
    if (colors == null || colors.isEmpty) return [backgroundColor];
    
    return colors.map((c) {
      if (c is String) return _parseColor(c);
      return const Color(0xFF6366F1);
    }).toList();
  }

  static Color _parseColor(String colorString) {
    try {
      String hex = colorString.replaceAll('#', '');
      if (hex.length == 6) hex = 'FF$hex';
      return Color(int.parse(hex, radix: 16));
    } catch (e) {
      return const Color(0xFF6366F1);
    }
  }

  // Validation methods
  bool validate() {
    if (componentType.isEmpty) return false;
    if (label.isEmpty) return false;
    
    // Validate style
    if (style.isEmpty) return false;
    
    return true;
  }

  List<String> get validationErrors {
    final errors = <String>[];
    
    if (componentType.isEmpty) errors.add('Component type is required');
    if (label.isEmpty) errors.add('Label is required');
    if (style.isEmpty) errors.add('Style configuration is required');
    
    return errors;
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

  // Animation Presets
  static const Map<String, Map<String, dynamic>> animationPresets = {
    'fade': {
      'type': 'fade',
      'duration': 300,
      'curve': 'easeOut',
      'delay': 0,
    },
    'slideUp': {
      'type': 'slide',
      'duration': 400,
      'curve': 'easeOutBack',
      'direction': 'up',
      'delay': 100,
    },
    'slideDown': {
      'type': 'slide',
      'duration': 400,
      'curve': 'easeOutBack',
      'direction': 'down',
      'delay': 100,
    },
    'scale': {
      'type': 'scale',
      'duration': 300,
      'curve': 'easeOutQuad',
      'delay': 0,
    },
    'bounce': {
      'type': 'bounce',
      'duration': 500,
      'curve': 'bounceOut',
      'delay': 0,
    },
  };

  // Curve Types
  static const List<String> curveTypes = [
    'linear',
    'ease',
    'easeIn',
    'easeOut',
    'easeInOut',
    'fastOutSlowIn',
    'slowMiddle',
    'bounceIn',
    'bounceOut',
    'elasticOut',
  ];

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
  
  // Font Awesome Icons (optional)
  static const String faHome = 'fa_home';
  static const String faUser = 'fa_user';
  static const String faCog = 'fa_cog';
  static const String faBell = 'fa_bell';
  static const String faHeart = 'fa_heart';
  static const String faStar = 'fa_star';
}

// Modern Theme Presets
class ThemePresets {
  static Map<String, dynamic> modernDarkTheme() {
    return {
      'name': 'Modern Dark',
      'colors': {
        'primary': '#6366F1',
        'secondary': '#8B5CF6',
        'accent': '#10B981',
        'background': '#0F172A',
        'surface': '#1E293B',
        'text': '#F1F5F9',
        'textSecondary': '#94A3B8',
        'error': '#EF4444',
        'success': '#10B981',
        'warning': '#F59E0B',
        'info': '#3B82F6',
      },
      'typography': {
        'fontFamily': 'Poppins',
        'fontSizes': {
          'xs': 12.0,
          'sm': 14.0,
          'md': 16.0,
          'lg': 18.0,
          'xl': 20.0,
          '2xl': 24.0,
          '3xl': 30.0,
        },
        'fontWeights': {
          'light': 'w300',
          'regular': 'w400',
          'medium': 'w500',
          'semibold': 'w600',
          'bold': 'w700',
        },
      },
      'shapes': {
        'borderRadius': {
          'none': 0.0,
          'sm': 4.0,
          'md': 8.0,
          'lg': 12.0,
          'xl': 16.0,
          'full': 999.0,
        },
      },
      'shadows': DesignConstants.shadowPresets,
      'animations': DesignConstants.animationPresets,
    };
  }

  static Map<String, dynamic> modernLightTheme() {
    return {
      'name': 'Modern Light',
      'colors': {
        'primary': '#6366F1',
        'secondary': '#8B5CF6',
        'accent': '#10B981',
        'background': '#FFFFFF',
        'surface': '#F8FAFC',
        'text': '#1E293B',
        'textSecondary': '#64748B',
        'error': '#EF4444',
        'success': '#10B981',
        'warning': '#F59E0B',
        'info': '#3B82F6',
      },
      'typography': {
        'fontFamily': 'Inter',
        'fontSizes': {
          'xs': 12.0,
          'sm': 14.0,
          'md': 16.0,
          'lg': 18.0,
          'xl': 20.0,
          '2xl': 24.0,
          '3xl': 30.0,
        },
      },
      'shapes': {
        'borderRadius': {
          'none': 0.0,
          'sm': 4.0,
          'md': 8.0,
          'lg': 12.0,
          'xl': 16.0,
          'full': 999.0,
        },
      },
      'shadows': DesignConstants.shadowPresets,
      'animations': DesignConstants.animationPresets,
    };
  }
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

  static List<UIDesignModel> generateUIKitFromTheme(Map<String, dynamic> theme) {
    return [
      UIDesignModel.createModernButton(
        label: 'Primary Button',
        customPrompt: 'Primary button for ${theme['name']} theme',
      ),
      UIDesignModel.createModernCard(
        label: 'Info Card',
        customPrompt: 'Card component for ${theme['name']} theme',
      ),
      UIDesignModel.createTextField(
        label: 'Search Input',
        hintText: 'Search...',
        customPrompt: 'Search field for ${theme['name']} theme',
      ),
      UIDesignModel.createAppBar(
        title: 'App Bar',
        customPrompt: 'App bar for ${theme['name']} theme',
      ),
    ];
  }

  static bool validateDesignJson(Map<String, dynamic> json) {
    try {
      final design = UIDesignModel.fromJson(json);
      return design.validate();
    } catch (e) {
      return false;
    }
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

// Extension methods for Flutter integration
extension UIDesignModelExtensions on UIDesignModel {
  Map<String, dynamic> toFlutterWidgetJson() {
    return {
      'widgetType': _getFlutterWidgetType(componentType),
      'parameters': _extractFlutterParameters(),
      'style': _convertToFlutterStyle(),
      'children': children?.map((child) => child.toFlutterWidgetJson()).toList(),
    };
  }

  String _getFlutterWidgetType(String componentType) {
    switch (componentType) {
      case 'button':
        return 'ElevatedButton';
      case 'card':
        return 'Card';
      case 'textfield':
        return 'TextField';
      case 'container':
        return 'Container';
      case 'appbar':
        return 'AppBar';
      case 'text':
        return 'Text';
      default:
        return 'Container';
    }
  }

  Map<String, dynamic> _extractFlutterParameters() {
    final params = <String, dynamic>{};
    
    // Add properties
    params.addAll(properties);
    
    // Add label/text
    params['child'] = label;
    
    return params;
  }

  Map<String, dynamic> _convertToFlutterStyle() {
    final flutterStyle = <String, dynamic>{};
    
    // Convert colors
    if (style['backgroundColor'] != null) {
      flutterStyle['color'] = _parseFlutterColor(style['backgroundColor'].toString());
    }
    
    // Convert border radius
    if (style['borderRadius'] != null) {
      flutterStyle['borderRadius'] = BorderRadius.circular(borderRadius);
    }
    
    // Convert gradient
    if (hasGradient) {
      final gradient = style['gradient'];
      final colors = gradientColors;
      final stops = (gradient['stops'] as List?)?.cast<double>() ?? [0.0, 1.0];
      
      if (gradient['type'] == 'linear') {
        final angle = gradient['angle'] ?? 0.0;
        flutterStyle['gradient'] = {
          'type': 'LinearGradient',
          'colors': colors.map((c) => c.value).toList(),
          'stops': stops,
          'begin': _getAlignmentFromAngle(angle, true),
          'end': _getAlignmentFromAngle(angle, false),
        };
      } else {
        flutterStyle['gradient'] = {
          'type': 'RadialGradient',
          'colors': colors.map((c) => c.value).toList(),
          'stops': stops,
        };
      }
    }
    
    return flutterStyle;
  }

  int _parseFlutterColor(String colorString) {
    try {
      String hex = colorString.replaceAll('#', '');
      if (hex.length == 6) hex = 'FF$hex';
      return int.parse(hex, radix: 16);
    } catch (e) {
      return 0xFF6366F1;
    }
  }

  Map<String, double> _getAlignmentFromAngle(double angle, bool isBegin) {
    final rad = angle * (3.14159 / 180.0);
    final x = 0.5 + 0.5 * cos(rad);
    final y = 0.5 + 0.5 * sin(rad);
    
    if (isBegin) {
      return {'x': 1 - x, 'y': 1 - y};
    } else {
      return {'x': x, 'y': y};
    }
  }
}
