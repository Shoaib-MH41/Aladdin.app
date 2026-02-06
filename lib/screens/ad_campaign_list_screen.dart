// screens/ad_campaign_list_screen.dart

import 'package:flutter/material.dart';
import '../models/ad_model.dart';
import '../services/ad_service.dart';

class AdCampaignListScreen extends StatefulWidget {
  final String projectId;
  final String projectName;

  const AdCampaignListScreen({
    super.key,
    required this.projectId,
    required this.projectName,
  });

  @override
  State<AdCampaignListScreen> createState() => _AdCampaignListScreenState();
}

class _AdCampaignListScreenState extends State<AdCampaignListScreen> {
  final AdService _adService = AdService();
  List<AdCampaign> _campaigns = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCampaigns();
  }

  // مہمات لوڈ کرنے کا فنکشن
  Future<void> _loadCampaigns() async {
    try {
      final campaigns = await _adService.getCampaigns(widget.projectId);
      setState(() {
        _campaigns = campaigns;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('مہمیں لوڈ کرنے میں ناکامی: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('اشتہار مہمیں - ${widget.projectName}'),
        backgroundColor: Colors.deepPurple, // ڈیزائن کے لیے رنگ شامل کیا
        actions: [
          // ✅ نیا اشتہار مہم بنانے والا بٹن
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'نئی مہم بنائیں',
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/ads',
                arguments: {
                  'projectName': widget.projectName, // ✅ خودکار نام
                  'initialBudget': 100.0,
                  'initialAdText': 'میرے ایپ ${widget.projectName} کو آزمائیں!',
                },
              ).then((result) {
                // ✅ واپسی پر لسٹ کو ریفریش کریں
                if (result != null) {
                  _loadCampaigns();
                }
              });
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _campaigns.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.campaign, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text('اس پروجیکٹ کی کوئی اشتہار مہم نہیں ہے'),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () {
                          // خالی اسکرین پر بھی بٹن کام کرے
                          Navigator.pushNamed(
                            context,
                            '/ads',
                            arguments: {
                              'projectName': widget.projectName,
                              'initialBudget': 100.0,
                              'initialAdText': 'میرے ایپ کو آزمائیں!',
                            },
                          ).then((_) => _loadCampaigns());
                        },
                        child: const Text('پہلی اشتہار مہم بنائیں'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _campaigns.length,
                  itemBuilder: (context, index) {
                    final campaign = _campaigns[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      elevation: 4,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: campaign.statusColor,
                          child: const Icon(Icons.campaign, color: Colors.white),
                        ),
                        title: Text(campaign.name, style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text('💰 بجٹ: \$${campaign.dailyBudget}/روز'),
                            Text(
                              '📊 حیثیت: ${campaign.statusText}',
                              style: TextStyle(color: campaign.statusColor),
                            ),
                          ],
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          // اگر آپ مہم کی تفصیل دیکھنا چاہیں تو یہاں کوڈ آئے گا
                          // فی الحال ہم صرف سنیپ بار دکھا رہے ہیں
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('منتخب مہم: ${campaign.name}')),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
