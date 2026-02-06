// services/ad_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/ad_model.dart';

class AdService {
  static const String _baseUrl = 'https://your-ad-api.com'; // اپنا API URL استعمال کریں

  // نئی اشتہار مہم بنائیں
  Future<AdCampaign> createCampaign(AdCampaign campaign) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/campaigns'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(campaign.toJson()),
    );

    if (response.statusCode == 201) {
      return AdCampaign.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create campaign');
    }
  }

  // اشتہار مہم اپ ڈیٹ کریں
  Future<AdCampaign> updateCampaign(String id, AdCampaign campaign) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/campaigns/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(campaign.toJson()),
    );

    if (response.statusCode == 200) {
      return AdCampaign.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update campaign');
    }
  }

  // تمام اشتہار مہمیں حاصل کریں
  Future<List<AdCampaign>> getCampaigns(String projectId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/projects/$projectId/campaigns'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => AdCampaign.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load campaigns');
    }
  }

  // کارکردگی رپورٹ حاصل کریں
  Future<AdPerformanceReport> getPerformanceReport(String campaignId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/campaigns/$campaignId/report'),
    );

    if (response.statusCode == 200) {
      return AdPerformanceReport.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load report');
    }
  }

  // ادائیگی کا طریقہ شامل کریں
  Future<PaymentInfo> processPayment(PaymentInfo payment) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/payments'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(payment.toJson()),
    );

    if (response.statusCode == 201) {
      return PaymentInfo.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to process payment');
    }
  }

  // مصنوعی ڈیٹا (مثلاً کے لیے)
  static AdCampaign createMockCampaign(String projectId, String projectName) {
    return AdCampaign(
      id: 'campaign_${DateTime.now().millisecondsSinceEpoch}',
      projectId: projectId,
      projectName: projectName,
      name: '$projectName لانچ مہم',
      dailyBudget: 100.0,
      totalBudget: 1000.0,
      adText: 'میرے نئے ایپ کو آزمائیں! مکمل مفت۔',
      startDate: DateTime.now(),
      paymentId: 'pay_${DateTime.now().millisecondsSinceEpoch}',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      metrics: {
        'impressions': 1500,
        'clicks': 45,
        'totalSpent': 75.50,
        'conversions': 8,
      },
      settings: {
        'autoOptimize': true,
        'dailyLimit': 100.0,
        'targeting': {'age': '18-45', 'gender': 'all'},
      },
    );
  }
}
