// models/ad_model.dart

import 'package:flutter/foundation.dart';

// اشتہار مہم کی قسمیں
enum AdCampaignType {
  socialMedia,
  searchEngine,
  mobileAds,
  videoAds,
  displayAds,
}

// اشتہار مہم کی حیثیت
enum AdCampaignStatus {
  draft,
  active,
  paused,
  completed,
  cancelled,
}

// ادائیگی کا طریقہ
enum PaymentMethod {
  creditCard,
  paypal,
  googlePay,
  applePay,
  bankTransfer,
}

// اشتہار مہم کا ماڈل
class AdCampaign {
  final String id;
  final String projectId;
  final String projectName;
  String name;
  String description;
  AdCampaignType type;
  double dailyBudget;
  double totalBudget;
  String adText;
  String targetAudience;
  List<String> keywords;
  List<String> platforms;
  DateTime startDate;
  DateTime? endDate;
  AdCampaignStatus status;
  PaymentMethod paymentMethod;
  String paymentId;
  DateTime createdAt;
  DateTime updatedAt;
  Map<String, dynamic> metrics;
  Map<String, dynamic> settings;

  AdCampaign({
    required this.id,
    required this.projectId,
    required this.projectName,
    required this.name,
    this.description = '',
    this.type = AdCampaignType.socialMedia,
    required this.dailyBudget,
    required this.totalBudget,
    required this.adText,
    this.targetAudience = 'عام صارفین',
    this.keywords = const [],
    this.platforms = const ['Facebook', 'Google'],
    required this.startDate,
    this.endDate,
    this.status = AdCampaignStatus.draft,
    this.paymentMethod = PaymentMethod.creditCard,
    required this.paymentId,
    required this.createdAt,
    required this.updatedAt,
    this.metrics = const {},
    this.settings = const {},
  });

  // JSON سے AdCampaign بنانے کے لیے
  factory AdCampaign.fromJson(Map<String, dynamic> json) {
    return AdCampaign(
      id: json['id'] ?? '',
      projectId: json['projectId'] ?? '',
      projectName: json['projectName'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      type: _parseAdType(json['type']),
      dailyBudget: (json['dailyBudget'] ?? 0.0).toDouble(),
      totalBudget: (json['totalBudget'] ?? 0.0).toDouble(),
      adText: json['adText'] ?? '',
      targetAudience: json['targetAudience'] ?? 'عام صارفین',
      keywords: List<String>.from(json['keywords'] ?? []),
      platforms: List<String>.from(json['platforms'] ?? ['Facebook', 'Google']),
      startDate: DateTime.parse(json['startDate']),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      status: _parseAdStatus(json['status']),
      paymentMethod: _parsePaymentMethod(json['paymentMethod']),
      paymentId: json['paymentId'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      metrics: Map<String, dynamic>.from(json['metrics'] ?? {}),
      settings: Map<String, dynamic>.from(json['settings'] ?? {}),
    );
  }

  // AdCampaign کو JSON میں تبدیل کرنے کے لیے
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectId': projectId,
      'projectName': projectName,
      'name': name,
      'description': description,
      'type': describeEnum(type),
      'dailyBudget': dailyBudget,
      'totalBudget': totalBudget,
      'adText': adText,
      'targetAudience': targetAudience,
      'keywords': keywords,
      'platforms': platforms,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'status': describeEnum(status),
      'paymentMethod': describeEnum(paymentMethod),
      'paymentId': paymentId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'metrics': metrics,
      'settings': settings,
    };
  }

  // اشتہار مہم کی حیثیت کا رنگ
  Color get statusColor {
    switch (status) {
      case AdCampaignStatus.active:
        return Colors.green;
      case AdCampaignStatus.paused:
        return Colors.orange;
      case AdCampaignStatus.completed:
        return Colors.blue;
      case AdCampaignStatus.cancelled:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // اشتہار مہم کی حیثیت کا متن
  String get statusText {
    switch (status) {
      case AdCampaignStatus.draft:
        return 'ڈرافٹ';
      case AdCampaignStatus.active:
        return 'فعال';
      case AdCampaignStatus.paused:
        return 'روکا ہوا';
      case AdCampaignStatus.completed:
        return 'مکمل';
      case AdCampaignStatus.cancelled:
        return 'منسوخ';
    }
  }

  // اشتہار مہم کی قسم کا متن
  String get typeText {
    switch (type) {
      case AdCampaignType.socialMedia:
        return 'سوشل میڈیا';
      case AdCampaignType.searchEngine:
        return 'سرچ انجن';
      case AdCampaignType.mobileAds:
        return 'موبائل اشتہارات';
      case AdCampaignType.videoAds:
        return 'ویڈیو اشتہارات';
      case AdCampaignType.displayAds:
        return 'ڈسپلے اشتہارات';
    }
  }

  // ادائیگی کا طریقہ متن
  String get paymentMethodText {
    switch (paymentMethod) {
      case PaymentMethod.creditCard:
        return 'کریڈٹ کارڈ';
      case PaymentMethod.paypal:
        return 'پے پال';
      case PaymentMethod.googlePay:
        return 'گوگل پے';
      case PaymentMethod.applePay:
        return 'ایپل پے';
      case PaymentMethod.bankTransfer:
        return 'بینک ٹرانسفر';
    }
  }

  // باقی دن
  int get remainingDays {
    if (endDate == null) return 0;
    final now = DateTime.now();
    final difference = endDate!.difference(now);
    return difference.inDays;
  }

  // کل اخراجات
  double get totalSpent {
    return metrics['totalSpent'] ?? 0.0;
  }

  // روزانہ اوسط اخراجات
  double get averageDailySpend {
    final daysRunning = DateTime.now().difference(startDate).inDays;
    if (daysRunning == 0) return 0.0;
    return totalSpent / daysRunning;
  }

  // کارکردگی میٹرک
  double get clickThroughRate {
    final impressions = metrics['impressions'] ?? 0;
    final clicks = metrics['clicks'] ?? 0;
    if (impressions == 0) return 0.0;
    return (clicks / impressions) * 100;
  }

  // میٹرک اپ ڈیٹ کرنے کا طریقہ
  void updateMetrics(Map<String, dynamic> newMetrics) {
    metrics.addAll(newMetrics);
    updatedAt = DateTime.now();
  }

  // حیثیت تبدیل کرنے کا طریقہ
  void updateStatus(AdCampaignStatus newStatus) {
    status = newStatus;
    updatedAt = DateTime.now();
  }

  // بجٹ اپ ڈیٹ کرنے کا طریقہ
  void updateBudget(double newDailyBudget) {
    dailyBudget = newDailyBudget;
    updatedAt = DateTime.now();
  }

  // Helper functions for parsing enums
  static AdCampaignType _parseAdType(String type) {
    switch (type) {
      case 'socialMedia': return AdCampaignType.socialMedia;
      case 'searchEngine': return AdCampaignType.searchEngine;
      case 'mobileAds': return AdCampaignType.mobileAds;
      case 'videoAds': return AdCampaignType.videoAds;
      case 'displayAds': return AdCampaignType.displayAds;
      default: return AdCampaignType.socialMedia;
    }
  }

  static AdCampaignStatus _parseAdStatus(String status) {
    switch (status) {
      case 'draft': return AdCampaignStatus.draft;
      case 'active': return AdCampaignStatus.active;
      case 'paused': return AdCampaignStatus.paused;
      case 'completed': return AdCampaignStatus.completed;
      case 'cancelled': return AdCampaignStatus.cancelled;
      default: return AdCampaignStatus.draft;
    }
  }

  static PaymentMethod _parsePaymentMethod(String method) {
    switch (method) {
      case 'creditCard': return PaymentMethod.creditCard;
      case 'paypal': return PaymentMethod.paypal;
      case 'googlePay': return PaymentMethod.googlePay;
      case 'applePay': return PaymentMethod.applePay;
      case 'bankTransfer': return PaymentMethod.bankTransfer;
      default: return PaymentMethod.creditCard;
    }
  }
}

// ادائیگی کی معلومات کا ماڈل
class PaymentInfo {
  final String id;
  final String campaignId;
  final PaymentMethod method;
  final double amount;
  final String transactionId;
  final DateTime paymentDate;
  final String status; // pending, completed, failed
  final Map<String, dynamic> details;

  PaymentInfo({
    required this.id,
    required this.campaignId,
    required this.method,
    required this.amount,
    required this.transactionId,
    required this.paymentDate,
    required this.status,
    this.details = const {},
  });

  factory PaymentInfo.fromJson(Map<String, dynamic> json) {
    return PaymentInfo(
      id: json['id'] ?? '',
      campaignId: json['campaignId'] ?? '',
      method: AdCampaign._parsePaymentMethod(json['method']),
      amount: (json['amount'] ?? 0.0).toDouble(),
      transactionId: json['transactionId'] ?? '',
      paymentDate: DateTime.parse(json['paymentDate']),
      status: json['status'] ?? 'pending',
      details: Map<String, dynamic>.from(json['details'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'campaignId': campaignId,
      'method': describeEnum(method),
      'amount': amount,
      'transactionId': transactionId,
      'paymentDate': paymentDate.toIso8601String(),
      'status': status,
      'details': details,
    };
  }
}

// اشتہار کارکردگی رپورٹ
class AdPerformanceReport {
  final String campaignId;
  final DateTime periodStart;
  final DateTime periodEnd;
  final Map<String, dynamic> metrics;
  final List<Map<String, dynamic>> dailyData;

  AdPerformanceReport({
    required this.campaignId,
    required this.periodStart,
    required this.periodEnd,
    required this.metrics,
    required this.dailyData,
  });

  double get totalImpressions => metrics['impressions'] ?? 0;
  double get totalClicks => metrics['clicks'] ?? 0;
  double get totalSpent => metrics['spent'] ?? 0;
  double get averageCtr => metrics['ctr'] ?? 0;
  double get averageCpc => metrics['cpc'] ?? 0;

  factory AdPerformanceReport.fromJson(Map<String, dynamic> json) {
    return AdPerformanceReport(
      campaignId: json['campaignId'] ?? '',
      periodStart: DateTime.parse(json['periodStart']),
      periodEnd: DateTime.parse(json['periodEnd']),
      metrics: Map<String, dynamic>.from(json['metrics'] ?? {}),
      dailyData: List<Map<String, dynamic>>.from(json['dailyData'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'campaignId': campaignId,
      'periodStart': periodStart.toIso8601String(),
      'periodEnd': periodEnd.toIso8601String(),
      'metrics': metrics,
      'dailyData': dailyData,
    };
  }
}

// اشتہار کے لیے پبلشر معلومات
class AdPublisher {
  final String id;
  final String name;
  final String platform; // Google, Facebook, Instagram, etc.
  final double commissionRate;
  final List<String> supportedCountries;
  final Map<String, dynamic> requirements;

  AdPublisher({
    required this.id,
    required this.name,
    required this.platform,
    this.commissionRate = 0.3, // 30% default
    this.supportedCountries = const ['US', 'UK', 'PK'],
    this.requirements = const {},
  });

  factory AdPublisher.fromJson(Map<String, dynamic> json) {
    return AdPublisher(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      platform: json['platform'] ?? '',
      commissionRate: (json['commissionRate'] ?? 0.3).toDouble(),
      supportedCountries: List<String>.from(json['supportedCountries'] ?? []),
      requirements: Map<String, dynamic>.from(json['requirements'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'platform': platform,
      'commissionRate': commissionRate,
      'supportedCountries': supportedCountries,
      'requirements': requirements,
    };
  }
}
