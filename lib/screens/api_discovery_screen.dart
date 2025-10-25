import 'package:flutter/material.dart';
import '../models/api_template_model.dart';
import 'api_integration_screen.dart';

class ApiDiscoveryScreen extends StatefulWidget {
  final List<ApiTemplate> discoveredApis;
  final String projectName;

  const ApiDiscoveryScreen({
    super.key,
    required this.discoveredApis,
    required this.projectName,
  });

  @override
  State<ApiDiscoveryScreen> createState() => _ApiDiscoveryScreenState();
}

class _ApiDiscoveryScreenState extends State<ApiDiscoveryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("AI کی دریافت کردہ APIs - ${widget.projectName}"),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: widget.discoveredApis.isEmpty
          ? _buildEmptyState()
          : _buildApiList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'کوئی APIs نہیں ملیں',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'AI آپ کی ایپ کے لیے متعلقہ APIs نہیں ڈھونڈ سکا',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text('واپس جائیں'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApiList() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Card(
            color: Colors.purple[50],
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.auto_awesome, color: Colors.purple),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI کی تجاویز',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.purple[800],
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'آپ کی ایپ کے لیے متعلقہ APIs',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                  Chip(
                    label: Text('${widget.discoveredApis.length} APIs'),
                    backgroundColor: Colors.purple[100],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),

          // APIs List
          Expanded(
            child: ListView.builder(
              itemCount: widget.discoveredApis.length,
              itemBuilder: (context, index) {
                final api = widget.discoveredApis[index];
                return _buildApiCard(api);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApiCard(ApiTemplate api) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // API Header
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(api.category),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.api, size: 20, color: Colors.white),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        api.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        api.provider,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                if (api.keyRequired)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'KEY درکار',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.orange[800],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),

            SizedBox(height: 12),

            // API Description
            Text(
              api.description,
              style: TextStyle(fontSize: 14),
            ),

            SizedBox(height: 8),

            // API Details
            Row(
              children: [
                Icon(Icons.category, size: 14, color: Colors.grey),
                SizedBox(width: 4),
                Text(
                  api.category,
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                SizedBox(width: 16),
                Icon(Icons.star, size: 14, color: Colors.grey),
                SizedBox(width: 4),
                Text(
                  api.freeTierInfo,
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),

            SizedBox(height: 12),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: Icon(Icons.open_in_new, size: 16),
                    label: Text('ویب سائٹ کھولیں'),
                    onPressed: () => _openWebsite(api.url),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.integration_instructions, size: 16),
                    label: Text('ایپ میں شامل کریں'),
                    onPressed: () => _integrateApi(api),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'ai':
        return Colors.purple;
      case 'weather':
        return Colors.blue;
      case 'productivity':
        return Colors.green;
      case 'authentication':
        return Colors.orange;
      case 'development':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }

  void _openWebsite(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ویب سائٹ نہیں کھل سکی')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خرابی: $e')),
      );
    }
  }

  void _integrateApi(ApiTemplate api) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ApiIntegrationScreen(
          apiTemplate: api,
          onApiKeySubmitted: (apiKey) {
            // یہاں آپ API key process کر سکتے ہیں
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('✅ ${api.name} کی API key جمع ہو گئی')),
            );
            Navigator.popUntil(context, (route) => route.isFirst);
          },
        ),
      ),
    );
  }
}
