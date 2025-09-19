
import 'package:flutter/material.dart';

// درست: اس لائن کو ڈیلیٹ کریں
class LanguageModel {
  final String code;
  final String name;
  final String nativeName;
  final String flagEmoji;

  const LanguageModel({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.flagEmoji,
  });

  // JSON سے Object بنانے کے لیے
  factory LanguageModel.fromJson(Map<String, dynamic> json) {
    return LanguageModel(
      code: json['code'] as String, // ✅ Type casting
      name: json['name'] as String, // ✅ Type casting
      nativeName: json['nativeName'] as String, // ✅ Type casting
      flagEmoji: json['flagEmoji'] as String, // ✅ Type casting
    );
  }

  // Object کو JSON میں تبدیل کرنے کے لیے
  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'nativeName': nativeName,
      'flagEmoji': flagEmoji,
    };
  }

  // دو زبانوں کا موازنہ کرنے کے لیے
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is LanguageModel && other.code == code;
  }

  @override
  int get hashCode => code.hashCode;

  // toString method - print کرنے کے لیے
  @override
  String toString() {
    return 'LanguageModel(code: $code, name: $name, nativeName: $nativeName)';
  }

  // کاپی کرنے کے لیے method
  LanguageModel copyWith({
    String? code,
    String? name,
    String? nativeName,
    String? flagEmoji,
  }) {
    return LanguageModel(
      code: code ?? this.code,
      name: name ?? this.name,
      nativeName: nativeName ?? this.nativeName,
      flagEmoji: flagEmoji ?? this.flagEmoji,
    );
  }
}

// زبانوں کی مستقل فہرست
class AppLanguages {
  static const List<LanguageModel> supportedLanguages = [
    LanguageModel(
      code: 'en',
      name: 'English',
      nativeName: 'English',
      flagEmoji: '🇺🇸',
    ),
    LanguageModel(
      code: 'ur',
      name: 'Urdu',
      nativeName: 'اردو',
      flagEmoji: '🇵🇰',
    ),
    LanguageModel(
      code: 'ar',
      name: 'Arabic',
      nativeName: 'العربية',
      flagEmoji: '🇸🇦',
    ),
    LanguageModel(
      code: 'hi',
      name: 'Hindi',
      nativeName: 'हिन्दी',
      flagEmoji: '🇮🇳',
    ),
  ];

  // زبان کوڈ سے زبان ڈھونڈنے کے لیے
  static LanguageModel? getLanguageByCode(String code) {
    try {
      return supportedLanguages.firstWhere(
        (language) => language.code == code,
      );
    } catch (e) {
      return null;
    }
  }

  // ڈیفالٹ زبان
  static const LanguageModel defaultLanguage = LanguageModel(
    code: 'en',
    name: 'English',
    nativeName: 'English',
    flagEmoji: '🇺🇸',
  );
}
