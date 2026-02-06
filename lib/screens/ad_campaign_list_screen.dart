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
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              // نیا اشتہار مہم اسکرین پر جائیں
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _campaigns.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.campaign, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('کوئی اشتہار مہم نہیں ہے'),
                      SizedBox(height: 8),
                      Text(
                        'پہلی اشتہار مہم بنائیں',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _campaigns.length,
                  itemBuilder: (context, index) {
                    final campaign = _campaigns[index];
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: campaign.statusColor,
                          child: Icon(Icons.campaign, color: Colors.white),
                        ),
                        title: Text(campaign.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('بجٹ: \$${campaign.dailyBudget}/روز'),
                            Text('حیثیت: ${campaign.statusText}'),
                          ],
                        ),
                        trailing: Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          // اشتہار مہم کی تفصیل دیکھیں
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
