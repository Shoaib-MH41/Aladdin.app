// lib/screens/chat/chat_ad_manager.dart
import 'package:flutter/material.dart';
import '../../models/ad_model.dart';          // ✅ ریلٹیو پیٹھ
import '../../models/project_model.dart';     // ✅ ریلٹیو پیٹھ
import '../../services/gemini_service.dart';  // ✅ ریلٹیو پیٹھ
import '../../screens/ads_screen.dart';       // ✅ ریلٹیو پیٹھ

class ChatAdManager {
  final GeminiService geminiService;
  final Project project;
  final Function(AdCampaign) onCampaignCreated;
  
  double _adBudget = 100.0;
  String _adText = "میرے ایپ کو آزمائیں!";
  bool _showAdsPanel = false;

  ChatAdManager({
    required this.geminiService,
    required this.project,
    required this.onCampaignCreated,
  });

  void startAdCampaign(BuildContext context) async {
    final newCampaign = AdCampaign(
      id: 'campaign_${DateTime.now().millisecondsSinceEpoch}',
      projectId: project.id,
      projectName: project.name,
      name: '${project.name} لانچ مہم',
      description: '${project.name} ایپ کی مارکیٹنگ مہم',
      type: AdCampaignType.socialMedia,
      dailyBudget: _adBudget,
      totalBudget: _adBudget * 10,
      adText: _adText,
      targetAudience: '18-45 سال کے صارفین',
      keywords: [project.name, 'ایپ', 'مفت', 'لانچ'],
      platforms: ['Facebook', 'Instagram', 'Google'],
      startDate: DateTime.now(),
      endDate: DateTime.now().add(Duration(days: 30)),
      status: AdCampaignStatus.draft,
      paymentMethod: PaymentMethod.creditCard,
      paymentId: 'pay_${DateTime.now().millisecondsSinceEpoch}',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      metrics: {
        'impressions': 0,
        'clicks': 0,
        'totalSpent': 0.0,
        'conversions': 0,
      },
      settings: {
        'autoOptimize': true,
        'dailyLimit': _adBudget,
        'targeting': {
          'age': '18-45',
          'gender': 'all',
          'interests': ['technology', 'mobile apps'],
        },
      },
    );

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdsScreen(
          projectName: project.name,
          initialBudget: _adBudget,
          initialAdText: _adText,
        ),
      ),
    );

    if (result != null && result is Map) {
      _adBudget = result['budget'] ?? _adBudget;
      _adText = result['adText'] ?? _adText;
      
      newCampaign.updateStatus(AdCampaignStatus.active);
      newCampaign.updateBudget(_adBudget);
      
      onCampaignCreated(newCampaign);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('✅ اشتہار مہم کامیابی سے شروع ہو گئی!'),
              SizedBox(height: 4),
              Text(
                'روزانہ بجٹ: \$$_adBudget',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  void suggestAdOptimization(BuildContext context, AdCampaign campaign) async {
    try {
      String optimizationPrompt = """
میں نے ایک اشتہار مہم بنائی ہے۔ براہ کرم اسے بہتر بنانے کی تجاویز دیں۔

اشتہار مہم کی تفصیل:
- نام: ${campaign.name}
- ایپ: ${campaign.projectName}
- اشتہاری متن: ${campaign.adText}
- بجٹ: \$${campaign.dailyBudget} روزانہ
- ہدف سامعین: ${campaign.targetAudience}

براہ کرم مجھے 3 تجاویز دیں:
1. اشتہاری متن کو بہتر بنانے کے لیے
2. بجٹ کو بہترین طریقے سے استعمال کرنے کے لیے
3. ہدف سامعین تک بہتر پہنچنے کے لیے

مختصر اور عملی تجاویز دیں۔
""";

      final String aiSuggestions = await geminiService.generateCode(
        prompt: optimizationPrompt,
        framework: 'marketing',
        platforms: ['all'],
      );

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('🤖 AI کی تجاویز'),
            content: SingleChildScrollView(
              child: Text(aiSuggestions),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('ٹھیک ہے'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      print('AI suggestions failed: $e');
    }
  }

  Widget buildAdsPanel(BuildContext context, VoidCallback toggleCallback) {
    return Container(
      padding: EdgeInsets.all(12),
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '📢 اشتہار مہم',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade800,
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, size: 18),
                onPressed: toggleCallback,
                padding: EdgeInsets.zero,
              ),
            ],
          ),
          SizedBox(height: 8),
          Text('بجٹ: \$$_adBudget'),
          SizedBox(height: 4),
          Text('اشتہاری متن: "$_adText"'),
          SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => startAdCampaign(context),
            child: Text('اشتہار مہم شروع کریں'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  IconButton buildAdsToggleButton(VoidCallback toggleCallback) {
    return IconButton(
      icon: Icon(_showAdsPanel ? Icons.close : Icons.ads_click),
      tooltip: _showAdsPanel ? 'اشتہار پینل چھپائیں' : 'اشتہار پینل دکھائیں',
      onPressed: toggleCallback,
    );
  }
}
