// lib/screens/chat/ui_design_preview.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/ui_design_model.dart';

class UIDesignPreview extends StatelessWidget {
  final Map<String, dynamic> designData;

  const UIDesignPreview({super.key, required this.designData});

  @override
  Widget build(BuildContext context) {
    final componentType = designData['componentType'] ?? 'container';
    final style = designData['style'] ?? {};
    final properties = designData['properties'] ?? {};

    final bgColor = _parseColor(style['backgroundColor'] ?? '#6366F1');
    final borderRadius = (style['borderRadius'] ?? 16.0).toDouble();
    final hasGradient = style['gradient'] != null;

    List<Color> gradientColors = [bgColor, bgColor];
    if (hasGradient) {
      final gradient = style['gradient'];
      final colors = gradient['colors'] ?? ['#6366F1', '#8B5CF6'];
      gradientColors = colors.map((c) => _parseColor(c.toString())).toList();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: hasGradient
            ? LinearGradient(
                colors: gradientColors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: hasGradient ? null : bgColor,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                componentType.toString().toUpperCase(),
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'AI Generated',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // ڈیزائن کی visual نمائش
          Container(
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(borderRadius / 2),
            ),
            child: Center(
              child: Icon(
                _getIconForComponent(componentType.toString()),
                color: Colors.white,
                size: 32,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildDesignFeature('Border Radius', '$borderRadius'),
              const SizedBox(width: 12),
              _buildDesignFeature('Gradient', hasGradient ? 'Yes' : 'No'),
              const SizedBox(width: 12),
              _buildDesignFeature('Shadow', 'Medium'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDesignFeature(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              color: Colors.white.withOpacity(0.7),
              fontSize: 9,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color _parseColor(String colorString) {
    try {
      String hex = colorString.replaceAll('#', '');
      if (hex.length == 6) hex = 'FF$hex';
      return Color(int.parse(hex, radix: 16));
    } catch (e) {
      return const Color(0xFF6366F1);
    }
  }

  IconData _getIconForComponent(String type) {
    switch (type.toLowerCase()) {
      case 'button':
        return Icons.touch_app;
      case 'card':
        return Icons.dashboard;
      case 'textfield':
        return Icons.text_fields;
      case 'appbar':
        return Icons.web_asset;
      case 'navbar':
        return Icons.navigation;
      default:
        return Icons.widgets;
    }
  }
}
